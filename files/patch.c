#ifndef _GNU_SOURCE
#define _GNU_SOURCE
#endif

#include <dlfcn.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <arpa/inet.h>

#include <stdio.h>

typedef int (*bind_t)(int sockfd, const struct sockaddr *addr, socklen_t addrlen);
bind_t real_bind;

typedef int (*connect_t)(int sockfd, const struct sockaddr *addr, socklen_t addrlen);
connect_t real_connect;

int bind(int sockfd, const struct sockaddr *addr, socklen_t addrlen)
{
    if (!real_bind)
        real_bind = dlsym(RTLD_NEXT, "bind");

    struct sockaddr_in *addr_in = (struct sockaddr_in*)addr;
    //addr_in->sin_addr.s_addr = INADDR_ANY;

    char* address = inet_ntoa(addr_in->sin_addr);
    uint16_t port = ntohl(addr_in->sin_port);
    printf("DET ER TIRSDAG! - %s:%u\n", address, port);

    return real_bind(sockfd, addr, addrlen);
}

int connect(int sockfd, const struct sockaddr *addr, socklen_t addrlen)
{
    if (!real_connect)
        real_connect = dlsym(RTLD_NEXT, "connect");

    struct sockaddr_in *addr_in = (struct sockaddr_in*)addr;

    char* address = inet_ntoa(addr_in->sin_addr);
    uint16_t port = ntohl(addr_in->sin_port);

    printf("DET ER MANDAG! - %s:%u\n", address, port);

    // If connecting to lobbyserver on port 3100, use default lobby server port instead.
    if (addr_in->sin_addr.s_addr == inet_addr("216.98.48.56") && addr_in->sin_port == htons(3100))
        addr_in->sin_port = htons(3035);

    return real_connect(sockfd, addr, addrlen);
}

// How to build and run:
// Build: gcc patch.c -shared -fPIC -ldl -o patch.so -m32
// Run with: LD_PRELOAD=./patch.so ./FarCry2_server
// Maybe you need "apt-get install gcc libc6-dev-i386"
