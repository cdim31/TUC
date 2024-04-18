#include "tinyos.h"
#include "kernel_dev.h"
#include "kernel_socket.h"
#include "kernel_cc.h"


int socket_read(void* socket_cb_t, char *buf, unsigned int n) {
	socket_cb* peer_read = (socket_cb*) socket_cb_t;
	if(!peer_read) 
		return -1;

	// Check if read end is active and if the socket is peer type
	if(!peer_read->peer_s.read_pipe || peer_read->type != SOCKET_PEER) 
		return -1;
	else{
		int i = pipe_read(peer_read->peer_s.read_pipe,buf,n);
		return i;
	}
}


int socket_write(void* socket_cb_t, const char *buf, unsigned int n){
	socket_cb* peer_write = (socket_cb*) socket_cb_t;
	if(!peer_write) 
		return -1;

	// Check if write end is active and if the socket is peer type
	if(!peer_write->peer_s.write_pipe || peer_write->type != SOCKET_PEER)
		return -1;
	else {
		int j = pipe_write(peer_write->peer_s.write_pipe,buf,n);
		return j;
	}
}


int socket_close(void* socket_cb_t){

	socket_cb* socket = (socket_cb*) socket_cb_t;
	if(!socket) 
		return -1;

	// if socket's type is Listener empty the PORT_MAP and broadcasts the requests available
	if(socket->type==SOCKET_LISTENER){
		PORT_MAP[socket->port] = NULL;
		kernel_broadcast(&socket->listener_s.req_available);
	}
	// else if the socket's type is Peer close the ends needed
	else if(socket->type==SOCKET_PEER){
		if(socket->peer_s.read_pipe!=NULL) { 
			pipe_reader_close(socket->peer_s.read_pipe);
		    socket->peer_s.read_pipe=NULL;
		}		
	    if(socket->peer_s.write_pipe!=NULL) {
		    pipe_writer_close(socket->peer_s.write_pipe);
		    socket->peer_s.write_pipe=NULL;
		}
	}

	// Decrease refconut
	socket->refcount--;
	// Check if refcount = 0 so we can free the socket
	if(socket->refcount==0) 
		free(socket);

	return 0;
}


file_ops socket_file_ops={
	.Open = NULL,
	.Read = socket_read,
	.Write = socket_write,
	.Close = socket_close
};


Fid_t sys_Socket(port_t port)
{
	// Check if the port we received as input is within the proper ranges
	if(port>MAX_PORT || port<0) 
		return NOFILE;

	FCB* fcb;
	Fid_t fid = 0;

	if(fid==NOFILE) 
		return NOFILE;
	if(FCB_reserve(1,&fid,&fcb)==0) 
		return NOFILE;

	// Initialize socket
	socket_cb* socketcb = (socket_cb*)xmalloc(sizeof(socket_cb));

	socketcb->refcount = 0;
	socketcb->fcb = fcb;
	socketcb->type = SOCKET_UNBOUND;
	socketcb->port = port;

	fcb->streamfunc = &socket_file_ops;
	fcb->streamobj = socketcb;

	return fid;	
}


int sys_Listen(Fid_t sock)
{
	FCB* fcb = get_fcb(sock);
	if(!fcb) 
		return -1;

	// Check for the possible errors
	if(sock==NOFILE) 
		return -1;

	socket_cb* socket = (socket_cb*) fcb->streamobj;

	if(!socket || socket->port<0 || socket->port>MAX_PORT) 
		return -1;

	if(PORT_MAP[socket->port] || socket->port==NOPORT ) 
		return -1;

	if(socket->type!=SOCKET_UNBOUND) 
		return -1;
    
    // Set the PORT_MAP
    PORT_MAP[socket->port] = socket;
    // Mark socket as a listener and initializing the fields of the union
	socket->type = SOCKET_LISTENER;
	rlnode_init(&socket->listener_s.queue,NULL);
	socket->listener_s.req_available = COND_INIT;

	return 0;
}


Fid_t sys_Accept(Fid_t lsock)
{
	FCB* fcb = get_fcb(lsock);
	// Check if fcb is legal
	if(!fcb) 
		return NOFILE;

	socket_cb* socket = (socket_cb*) fcb->streamobj;
	// Checks needed
	if(!socket || socket->port<0 || socket->port>MAX_PORT) 
		return NOFILE;

	if(socket->type!=SOCKET_LISTENER) 
		return NOFILE;

	socket->refcount++;
	// Loop while waiting for a request by checking if it's list is empty and refcount != 0
	while(is_rlist_empty(&socket->listener_s.queue) && socket->refcount!=0) {
		// Checking if the port is valid
		if(!PORT_MAP[socket->port]) 
			return NOFILE;
		kernel_wait(&socket->listener_s.req_available,SCHED_PIPE);
	}
	// Checking if the port is still valid
    if(!PORT_MAP[socket->port]) {
    	return NOFILE;
    }
	// If list isn't empty get the first request 	
	rlnode* node = rlist_pop_front(&socket->listener_s.queue);
	connection_request* req= (connection_request*) node -> connection_request;

	req->admitted =1;
	// Create the socket control block that made the request 
	socket_cb* peer1 = req->peer;
    if(!peer1){
    	return NOFILE;
    }
	if(peer1->type!=SOCKET_UNBOUND) 
		return NOFILE;

	// Initializing peer1 and returning it's fid
	Fid_t peer1_fid = sys_Socket(peer1->port);
	// Getting it's fcb from the fid and check it
	FCB* peer2_fcb = get_fcb(peer1_fid);
	if(peer1_fid==NOFILE) 
		return NOFILE;

	// Create the second socket control block from the fcb and check it
	socket_cb* peer2 = (socket_cb*) peer2_fcb->streamobj;
	if(!peer2) 
		return NOFILE;

	// Set both socket control blocks type as Peer
	peer1->type = SOCKET_PEER;
	peer2->type = SOCKET_PEER;

	// Create the first pipe and initialize it
	pipe_cb* pipe1 = (pipe_cb*)xmalloc(sizeof(pipe_cb));
    
	pipe1->writer = peer2->fcb;
	pipe1->reader = peer1->fcb;
	pipe1->has_space = COND_INIT;
    pipe1->has_data = COND_INIT;
    pipe1->w_position = 0;
    pipe1->r_position = 0;

    
	// Create the second pipe and initialize it
    pipe_cb* pipe2 = (pipe_cb*)xmalloc(sizeof(pipe_cb));

    pipe2->writer = peer1->fcb;
	pipe2->reader = peer2->fcb;
	pipe2->has_space = COND_INIT;
    pipe2->has_data = COND_INIT;
    pipe2->w_position = 0;
    pipe2->r_position = 0;
  
    // Connecting the two peers and initializing the connection
    peer1->peer_s.peer = peer2;
    peer1->peer_s.read_pipe = pipe1;
    peer1->peer_s.write_pipe = pipe2;

    peer2->peer_s.peer = peer1;
    peer2->peer_s.read_pipe = pipe2;
    peer2->peer_s.write_pipe = pipe1;

	// Sends signal to  the side it connects and decreases the refcount
	kernel_signal(&req->connected_cv);
	socket->refcount--;

	return peer1_fid;
}


int sys_Connect(Fid_t sock, port_t port, timeout_t timeout)
{
	FCB *fcb = get_fcb(sock);
	if(!fcb)
		return -1;
	
	socket_cb *socket = fcb->streamobj;
	// Checks needed
	if(!socket || socket->type!=SOCKET_UNBOUND) 
		return -1;
	if(port<0 || port>MAX_PORT)
		return -1;

	socket_cb *listener = PORT_MAP[port];
	// No listener socket bound on given port
	if(!listener) 
		return -1;

	socket->refcount++;
	// Create the request 
	connection_request* connect = (connection_request*)xmalloc(sizeof(connection_request));
	// Initialize the request
	connect->admitted=0;
	connect->peer = socket;
	connect->connected_cv = COND_INIT;
	rlnode_init(&connect->queue_node,connect);

	// Insert request in accept queue and sends signal
	rlist_push_back(&listener->listener_s.queue,&connect->queue_node);
	kernel_signal(&listener->listener_s.req_available);

	// Timeout expire
	if(kernel_timedwait(&connect->connected_cv,SCHED_PIPE,timeout)==0){
		return -1;
	}

	free(connect);
	
	// Checking the refcount so we can free the socket
	if(socket->refcount==0) {
		free(socket);
		return -1;
	}
	else{
		// Decrease refcount 
		socket->refcount--;
		// If request is not admitted return error value else success value
		if(connect->admitted==0) {
			return -1;
		}else {
			return 0;
		}
	}

}


int sys_ShutDown(Fid_t sock, shutdown_mode how)
{
	FCB* fcb = get_fcb(sock);
	if(!fcb) 
		return -1;

	socket_cb* socket = (socket_cb*) fcb->streamobj;
	if(socket->type!=SOCKET_PEER) 
		return -1;

	switch(how) {
		case SHUTDOWN_READ:
		// Check if socket's reader pipe is still open
		if(socket->peer_s.read_pipe) {
			pipe_reader_close(socket->peer_s.read_pipe);
			socket->peer_s.read_pipe=NULL;
			
		}
		break;
		case SHUTDOWN_WRITE:
		// Check if socket's writing pipe is still open
		if(socket->peer_s.write_pipe) {
			pipe_writer_close(socket->peer_s.write_pipe);
			socket->peer_s.write_pipe=NULL;

		}
		break;
		case SHUTDOWN_BOTH:
		// Check if socket's both pipes are still open
		if(socket->peer_s.read_pipe) {
			pipe_reader_close(socket->peer_s.read_pipe);
			socket->peer_s.read_pipe=NULL;
		}			

		if(socket->peer_s.write_pipe) {
			pipe_writer_close(socket->peer_s.write_pipe);
			socket->peer_s.write_pipe=NULL;
		
		}
		break;
		default:
		return -1;
		break;
	}

	return 0;
}