
#include <assert.h>
#include "kernel_cc.h"
#include "kernel_proc.h"
#include "kernel_streams.h"
#include "kernel_sched.h"


/* 
 The process table and related system calls:
 - Exec
 - Exit
 - WaitPid
 - GetPid
 - GetPPid

 */

/* The process table */
PCB PT[MAX_PROC];
unsigned int process_count;

PCB* get_pcb(Pid_t pid)
{
  return PT[pid].pstate==FREE ? NULL : &PT[pid];
}

Pid_t get_pid(PCB* pcb)
{
  return pcb==NULL ? NOPROC : pcb-PT;
}

/* Initialize a PCB */
static inline void initialize_PCB(PCB* pcb)
{
  pcb->pstate = FREE;
  pcb->argl = 0;
  pcb->args = NULL;
  pcb->thread_count = 0;

  for(int i=0;i<MAX_FILEID;i++)
    pcb->FIDT[i] = NULL;

  rlnode_init(& pcb->children_list, NULL);
  rlnode_init(& pcb->exited_list, NULL);
  rlnode_init(& pcb->children_node, pcb);
  rlnode_init(& pcb->exited_node, pcb);
  rlnode_init(& pcb->ptcb_list, NULL);
  pcb->child_exit = COND_INIT;
}


static PCB* pcb_freelist;

void initialize_processes()
{
  /* initialize the PCBs */
  for(Pid_t p=0; p<MAX_PROC; p++) {
    initialize_PCB(&PT[p]);
  }

  /* use the parent field to build a free list */
  PCB* pcbiter;
  pcb_freelist = NULL;
  for(pcbiter = PT+MAX_PROC; pcbiter!=PT; ) {
    --pcbiter;
    pcbiter->parent = pcb_freelist;
    pcb_freelist = pcbiter;
  }

  process_count = 0;

  /* Execute a null "idle" process */
  if(Exec(NULL,0,NULL)!=0)
    FATAL("The scheduler process does not have pid==0");
}


/*
  Must be called with kernel_mutex held
*/
PCB* acquire_PCB()
{
  PCB* pcb = NULL;

  if(pcb_freelist != NULL) {
    pcb = pcb_freelist;
    pcb->pstate = ALIVE;
    pcb_freelist = pcb_freelist->parent;
    process_count++;
  }

  return pcb;
}

/*
  Must be called with kernel_mutex held
*/
void release_PCB(PCB* pcb)
{
  pcb->pstate = FREE;
  pcb->parent = pcb_freelist;
  pcb_freelist = pcb;
  process_count--;
}


/*
 *
 * Process creation
 *
 */

/*
	This function is provided as an argument to spawn,
	to execute the main thread of a process.
*/
void start_main_thread()
{
  int exitval;

  Task call =  CURPROC->main_task;
  int argl = CURPROC->argl;
  void* args = CURPROC->args;

  exitval = call(argl,args);
  Exit(exitval);
}

void new_start_main_thread()
{
  int exitval;

  PTCB* ptcb = cur_thread()->ptcb;
  Task call = ptcb->task;
  int argl = ptcb->argl;
  void* args = ptcb->args;

  exitval = call(argl,args);
  sys_ThreadExit(exitval);
}
/*
	System call to create a new process.
 */
Pid_t sys_Exec(Task call, int argl, void* args)
{
  PCB *curproc, *newproc;
  
  /* The new process PCB */
  newproc = acquire_PCB();

  if(newproc == NULL) goto finish;  /* We have run out of PIDs! */

  if(get_pid(newproc)<=1) {
    /* Processes with pid<=1 (the scheduler and the init process) 
       are parentless and are treated specially. */
    newproc->parent = NULL;
  }
  else
  {
    /* Inherit parent */
    curproc = CURPROC;

    /* Add new process to the parent's child list */
    newproc->parent = curproc;
    rlist_push_front(& curproc->children_list, & newproc->children_node);

    /* Inherit file streams from parent */
    for(int i=0; i<MAX_FILEID; i++) {
       newproc->FIDT[i] = curproc->FIDT[i];
       if(newproc->FIDT[i])
          FCB_incref(newproc->FIDT[i]);
    }
  }


  /* Set the main thread's function */
  newproc->main_task = call;

  /* Copy the arguments to new storage, owned by the new process */
  newproc->argl = argl;
  if(args!=NULL) {
    newproc->args = malloc(argl);
    memcpy(newproc->args, args, argl);
  }
  else
    newproc->args=NULL;

  /* 
    Create and wake up the thread for the main function. This must be the last thing
    we do, because once we wakeup the new thread it may run! so we need to have finished
    the initialization of the PCB.
   */
  if(call != NULL) {
    TCB* tcb = spawn_thread(newproc, start_main_thread);
    newproc->main_thread = tcb;

    PTCB* ptcb = acquire_PTCB();
    initialize_ptcb(ptcb, call, argl, args);

    ptcb->tcb = newproc->main_thread;
    tcb->ptcb = ptcb;

    rlnode_init(&newproc->ptcb_list, newproc);
    rlist_push_back(&newproc->ptcb_list, &ptcb->ptcb_list_node);

    newproc->thread_count++;

    wakeup(newproc->main_thread);
  }


finish:
  return get_pid(newproc);
}


/* System call */
Pid_t sys_GetPid()
{
  return get_pid(CURPROC);
}


Pid_t sys_GetPPid()
{
  return get_pid(CURPROC->parent);
}


static void cleanup_zombie(PCB* pcb, int* status)
{
  if(status != NULL)
    *status = pcb->exitval;

  rlist_remove(& pcb->children_node);
  rlist_remove(& pcb->exited_node);

  release_PCB(pcb);
}


static Pid_t wait_for_specific_child(Pid_t cpid, int* status)
{

  /* Legality checks */
  if((cpid<0) || (cpid>=MAX_PROC)) {
    cpid = NOPROC;
    goto finish;
  }

  PCB* parent = CURPROC;
  PCB* child = get_pcb(cpid);
  if( child == NULL || child->parent != parent)
  {
    cpid = NOPROC;
    goto finish;
  }

  /* Ok, child is a legal child of mine. Wait for it to exit. */
  while(child->pstate == ALIVE)
    kernel_wait(& parent->child_exit, SCHED_USER);
  
  cleanup_zombie(child, status);
  
finish:
  return cpid;
}


static Pid_t wait_for_any_child(int* status)
{
  Pid_t cpid;

  PCB* parent = CURPROC;

  /* Make sure I have children! */
  int no_children, has_exited;
  while(1) {
    no_children = is_rlist_empty(& parent->children_list);
    if( no_children ) break;

    has_exited = ! is_rlist_empty(& parent->exited_list);
    if( has_exited ) break;

    kernel_wait(& parent->child_exit, SCHED_USER);    
  }

  if(no_children)
    return NOPROC;

  PCB* child = parent->exited_list.next->pcb;
  assert(child->pstate == ZOMBIE);
  cpid = get_pid(child);
  cleanup_zombie(child, status);

  return cpid;
}


Pid_t sys_WaitChild(Pid_t cpid, int* status)
{
  /* Wait for specific child. */
  if(cpid != NOPROC) {
    return wait_for_specific_child(cpid, status);
  }
  /* Wait for any child */
  else {
    return wait_for_any_child(status);
  }

}


void sys_Exit(int exitval)
{

  /* First, store the exit status */
  CURPROC->exitval = exitval;

  /* 
    Here, we must check that we are not the init task. 
    If we are, we must wait until all child processes exit. 
   */
  if(get_pid(CURPROC)==1) {

    while(sys_WaitChild(NOPROC,NULL)!=NOPROC);

  } 

  sys_ThreadExit(exitval);
}


file_ops procinfo_ops = {
  .Open = NULL,
  .Read = procinfo_read,
  .Write = NULL,
  .Close = procinfo_close
};


int procinfo_read(void* process_info_cb, char* buf, unsigned int n) {
  procinfo_cb* procinfocb = (procinfo_cb*) process_info_cb;
  // Check cursor
  if (!procinfocb || procinfocb->cursor == MAX_PROC)
    return -1;

  // Loop while cursor doesn't point at final process
  while (procinfocb->cursor < MAX_PROC) {
    // Check if process is free
    if (PT[procinfocb->cursor].pstate != FREE)
      break;
    // point to the next position on the process table
    procinfocb->cursor++;
  }
  if (procinfocb->cursor >= MAX_PROC)
    return 0;

  // Get system info
  procinfocb->info.pid = (Pid_t) procinfocb->cursor;
  procinfocb->info.ppid = (Pid_t) get_pid(PT[procinfocb->cursor].parent);
  procinfocb->info.argl = PT[procinfocb->cursor].argl;
  procinfocb->info.thread_count = PT[procinfocb->cursor].thread_count;
  procinfocb->info.main_task = PT[procinfocb->cursor].main_task;

  // Check if process is ZOMBIE
  if (PT[procinfocb->cursor].pstate == ZOMBIE)
    procinfocb->info.alive = 0;
  else 
    procinfocb->info.alive = 1;

  // Checks if cursor doesn't point at the first process and transfers the args
  if (procinfocb->cursor != 1)
      memcpy(procinfocb->info.args, PT[procinfocb->cursor].args, PROCINFO_MAX_ARGS_SIZE);
  memcpy(buf, (char*)&procinfocb->info, n);
  // Increase cursor num
  procinfocb->cursor++;

  return sizeof(procinfocb); 
}


int procinfo_close(void* process_info_cb) {
  procinfo_cb* procinfocb = (procinfo_cb*) process_info_cb;

  if (!procinfocb)
    return -1;
  procinfocb = NULL;
  free(procinfocb);
  return 0;
}


Fid_t sys_OpenInfo()
{
  FCB* fcb;
  Fid_t fid;

  if (!FCB_reserve(1, &fid, &fcb))
    return NOFILE;

  // Initialize procinfo
  procinfo_cb* procinfo = (procinfo_cb*) xmalloc(sizeof(procinfo_cb));
  procinfo->cursor = 1;

  fcb->streamobj = procinfo;
  fcb->streamfunc = &procinfo_ops;

	return fid;
}

