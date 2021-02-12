#ifndef _GNU_SOURCE
#define _GNU_SOURCE
#endif

#include <dlfcn.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <arpa/inet.h>
#include <netinet/in.h>

#include <stdbool.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#define DEBUG true
#define REDIRECT_ADDRESS "216.98.48.56"
#define REDIRECT_PORT_FROM 3100
#define REDIRECT_PORT_TO 3035

typedef int (*bind_t)(int sockfd, const struct sockaddr *addr, socklen_t addrlen);
bind_t real_bind;

typedef int (*connect_t)(int sockfd, const struct sockaddr *addr, socklen_t addrlen);
connect_t real_connect;

int bind(int sockfd, const struct sockaddr *addr, socklen_t addrlen)
{
    if (!real_bind)
        real_bind = dlsym(RTLD_NEXT, "bind");

    // Parsing valid ports.
    const char *s = getenv("PORT_RANGE_BEGIN");
    printf("PORTS: %s\n", s != NULL ? s : "NULL");

    if (addr->sa_family == AF_INET) {
    	struct sockaddr_in *addr_in = (struct sockaddr_in*)addr;
    	uint16_t port = ntohs(addr_in->sin_port);

        // Parsing valid ports.
        const char *s = getenv("PORTS");
        printf("PORTS: %s\n", s != NULL ? s : "NULL");

	// Only touch known FarCry2 ports.
	switch (port) {
        case 9000:
        case 9001:
        case 9002:
        case 9003:
            {
                if (addr_in->sin_addr.s_addr != htonl(INADDR_ANY)) {
		    if (DEBUG)
                    	printf("bind() %s:%u -> %s:%u\n", inet_ntoa(addr_in->sin_addr), port, "0.0.0.0", port);

		    // Change address to zero, byte order doesn't matter here.
		    addr_in->sin_addr.s_addr = INADDR_ANY;
                }
            }
            break;
	}
    }

    return real_bind(sockfd, addr, addrlen);
}

int connect(int sockfd, const struct sockaddr *addr, socklen_t addrlen)
{
    if (!real_connect)
        real_connect = dlsym(RTLD_NEXT, "connect");

    if (addr->sa_family == AF_INET) {
    	struct sockaddr_in *addr_in = (struct sockaddr_in*)addr;

    	// If connecting to lobbyserver on port 3100, use default lobby server port instead.
    	if (addr_in->sin_addr.s_addr == inet_addr(REDIRECT_ADDRESS) &&
            addr_in->sin_port == htons(REDIRECT_PORT_FROM)) {


            // Redirect port to new one.
	    addr_in->sin_port = htons(REDIRECT_PORT_TO);

            if (DEBUG) {
                char* address = inet_ntoa(addr_in->sin_addr);
                printf("connect() %s:%u -> %s:%u\n", address, REDIRECT_PORT_FROM, address, REDIRECT_PORT_TO);
	    }
        }
    }

    return real_connect(sockfd, addr, addrlen);
}

// How to build and run:
// Build: gcc patch.c -shared -fPIC -ldl -o patch.so -m32
// Run with: LD_PRELOAD=./patch.so [command]
// Maybe you need "apt-get install gcc libc6-dev-i386"
