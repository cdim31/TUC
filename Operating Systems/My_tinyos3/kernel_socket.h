#include "tinyos.h"
#include "kernel_dev.h"
#include "kernel_streams.h"


enum socket_type{
	SOCKET_LISTENER,
	SOCKET_UNBOUND,
	SOCKET_PEER
};

typedef struct socket_control_block socket_cb;


typedef struct listener_socket {
	rlnode queue;
	CondVar req_available;
} listener_socket;


typedef struct unbound_socket {
	rlnode unbound_socket;
} unbound_socket;


typedef struct peer_socket {
	socket_cb* peer;
	pipe_cb* write_pipe;
	pipe_cb* read_pipe;

} peer_socket;


typedef struct socket_control_block{
	uint refcount;
	FCB* fcb;
	Fid_t fid;
	enum socket_type type;
	port_t port;

	union {
		listener_socket listener_s;
		unbound_socket unbound_s;
		peer_socket peer_s;
	};
} socket_cb;


typedef struct connection_request {
	int admitted;
	socket_cb* peer;

	CondVar connected_cv;
	rlnode queue_node;

} connection_request;

socket_cb* PORT_MAP[MAX_PORT];

int socket_read(void* socket_cb_t, char *buf, unsigned int n);
int socket_write(void* socket_cb_t, const char *buf, unsigned int n);
int socket_close(void* socket_cb_t);