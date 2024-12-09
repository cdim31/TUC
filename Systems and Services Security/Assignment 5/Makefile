CC = gcc
CFLAGS = -lpcap
TARGET = pcap_ex

all: $(TARGET)

$(TARGET): pcap_ex.c
	$(CC) -o $(TARGET) pcap_ex.c $(CFLAGS)

clean:
	rm -f $(TARGET) *.o
                                                                         
              
