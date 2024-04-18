#include "tinyos.h"
#include "kernel_sched.h" 
#include "kernel_cc.h"		
#include "kernel_streams.h" 


int pipe_write(void* pipecb_t, const char *buf, unsigned int n) {
	
	int written_from_buf = 0;
	
	pipe_cb* pipe = (pipe_cb*) pipecb_t;
	// Checking if reader and writer are open or the pipe is null
	if (!pipe->reader || !pipe->writer || !pipe)
		return -1;

	/*  
		Loop while buffer is full and if the reader is open until it isn't full.
		The buffer is full when no position is available. The positions available are given by 
		the equation available = w_position - r_position and because we have a circular buffer
		we need to do the modulo of PIPE_BUFFER_SIZE
	*/
	while ((pipe->w_position+1) % PIPE_BUFFER_SIZE == pipe->r_position && pipe->reader) {
		kernel_wait(&pipe->has_space, SCHED_PIPE);
	}

	// Checking if reader closed
	if (!pipe->reader)
		return -1;
	/* 	
		Loop while buffer isn't full and the characters that are written 
		from the buf are fewer than the size that we need to write.
	*/
	while ((pipe->w_position+1) % PIPE_BUFFER_SIZE != pipe->r_position && written_from_buf < n) {
		// Copy data
		pipe->BUFFER[pipe->w_position] = buf[written_from_buf];
		// Increase indexes
		written_from_buf++;
		pipe->w_position++;  
		
		// Check if the writing reached buffer's end and set it 0 to start again
		if (pipe->w_position >= PIPE_BUFFER_SIZE)
			pipe->w_position = 0;
	}

	kernel_broadcast(&pipe->has_data);

	return written_from_buf;

}


int pipe_read(void* pipecb_t, char *buf, unsigned int n) {

	int read_from_buf = 0;

	pipe_cb* pipe = (pipe_cb*) pipecb_t;
	// Checking if reader has already exited or pipe is null
	if (!pipe->reader || !pipe) 
		return -1;

	// Loop while buffer is empty and the writter open
	while (pipe->w_position == pipe->r_position && pipe->writer) {
		kernel_wait(&pipe->has_data, SCHED_PIPE);
	}
	/*
		Loop while buffer isn't empty and the characters that are read 
		from the buf are fewer than the size that we need to read.
	*/
	while (pipe->w_position != pipe->r_position && read_from_buf < n) {
		// Copy data
		buf[read_from_buf] = pipe->BUFFER[pipe->r_position];
		//Increase indexes
		read_from_buf++;
		pipe->r_position++;
		
		// Check if reading reached buffer's size and set it 0 to start again
		if (pipe->r_position >= PIPE_BUFFER_SIZE)
			pipe->r_position = 0;

	}

	kernel_broadcast(&pipe->has_space);

	return read_from_buf;
}


int pipe_writer_close(void* _pipecb) { 

	pipe_cb* pipe = (pipe_cb*) _pipecb;
	if (pipe == NULL) 
		return -1;

	pipe->writer = NULL;
	kernel_broadcast(&pipe->has_data);
	if (pipe->reader == NULL) {
		free(pipe);
	}
	
	return 0;
}


int pipe_reader_close(void* _pipecb) {

	pipe_cb* pipe = (pipe_cb*) _pipecb;
	if (pipe == NULL)
		return -1;

	pipe->reader = NULL;
	if (pipe->writer == NULL) {
		free(pipe);
	}
	
	return 0;
}


static file_ops reader_file_ops = {
    .Open = NULL,
    .Read = pipe_read,
    .Write = NULL,
    .Close = pipe_reader_close
};

static file_ops writer_file_ops = {
    .Open = NULL,
    .Read = NULL,
    .Write = pipe_write,
    .Close = pipe_writer_close
};


pipe_cb* initialize_Pipe(FCB** fcb) 
{
	pipe_cb* pipecb = (pipe_cb*) xmalloc(sizeof(pipe_cb)); 

	if (pipecb == NULL)
		return NULL;
	
	pipecb->reader = fcb[0];
	pipecb->writer = fcb[1];


	pipecb->w_position = 0;
	pipecb->r_position = 0;

	pipecb->has_space = COND_INIT; 
	pipecb->has_data = COND_INIT;
	
	fcb[0]->streamobj = pipecb;
	fcb[0]->streamfunc = &reader_file_ops;

	fcb[1]->streamobj = pipecb;
	fcb[1]->streamfunc = &writer_file_ops;

	return pipecb;
}

int sys_Pipe(pipe_t* pipe)
{
	if (pipe == NULL)
		return -1;

	FCB* fcb[2];
	Fid_t fid[2];

	// Fails to reserve FCB
	if (!FCB_reserve(2, fid, fcb))
		return -1; 

	// Failed to initialize pipe
	if (!initialize_Pipe(fcb)) 
		return -1;
	
	pipe->read = fid[0];
	pipe->write = fid[1];

	return 0;
}