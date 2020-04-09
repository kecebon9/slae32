; SLAE Exam Assignment #5: Metasploit Shellcode exec 
; msfvenom -p linux/x86/exec CMD=/bin/pwd  | ndisasm -u - | cut -f4- -d" " | column -t

global _start

section .text

_start:
    push   byte  +0xb
    pop    eax
    cdq
    push   edx
    push   word   0x632d
    mov    edi,esp
    push   dword  0x68732f
    push   dword  0x6e69622f
    mov    ebx,esp
    push   edx
    call   0x26
    das
    bound  ebp,[ecx+0x6e]
    das
    jo     0x9b
    add    [fs:edi+0x53],dl
    mov    ecx,esp
    int    0x80