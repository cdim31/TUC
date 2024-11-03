# Compiler and flags
CC = gcc
CFLAGS = -Wall -g
LDFLAG_ECDH = -lsodium
LDFLAG_RSA = -lgmp

# Target executables
TARGETS = ecdh_assign_1 rsa_assign_1

# Source files
SRCS_ECDH = ecdh_assign_1.c
SRCS_RSA = rsa_assign_1.c

# Object files (same names as sources but with .o extension)
OBJS_ECDH = $(SRCS_ECDH:.c=.o)
OBJS_RSA = $(SRCS_RSA:.c=.o)

# Default rule to build both executables
all: $(TARGETS)

# Rule to link the object files and create the ecdh_assign_1 executable
ecdh_assign_1: $(OBJS_ECDH)
	$(CC) $(CFLAGS) -o ecdh_assign_1 $(OBJS_ECDH) $(LDFLAG_ECDH)

# Rule to link the object files and create the rsa executable
rsa_assign_1: $(OBJS_RSA)
	$(CC) $(CFLAGS) -o rsa_assign_1 $(OBJS_RSA) $(LDFLAG_RSA)

# Rule to compile source files into object files
%.o: %.c
	$(CC) $(CFLAGS) -c $<

# Clean rule to remove object files and the executables
clean:
	rm -f $(OBJS_ECDH) $(OBJS_RSA) $(TARGETS)

# Phony targets (so Make doesn't look for files named 'clean' or 'all')
.PHONY: all clean
