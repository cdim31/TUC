
all: logger acmonitor test_aclog


logger: logger.c
	gcc -Wall -fPIC -shared -o logger.so logger.c -lcrypto -ldl 


acmonitor: acmonitor.c 
	gcc acmonitor.c -o acmonitor


test_aclog: test_aclog.c 
	gcc test_aclog.c -o test_aclog


run: logger.so test_aclog
	LD_PRELOAD=./logger.so ./test_aclog


clean:
	rm -rf test_aclog
	rm -rf acmonitor
	rm -rf file_*
	rm -rf junk_*
	rm -rf testFile_*
	rm -rf file_logging.log
	rm -rf acmonitor
	rm -rf test_aclog
