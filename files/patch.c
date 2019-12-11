#define _GNU_SOURCE

#include <dlfcn.h>
#include <arpa/inet.h>

typedef int (*connect_t)(int sockfd, const struct sockaddr *addr, socklen_t addrlen);
connect_t real_connect;

int connect(int sockfd, const struct sockaddr *addr, socklen_t addrlen) {
	if (!real_connect) {
		real_connect = dlsym(RTLD_NEXT, "connect");
	}

	struct sockaddr_in* addr_in = (struct sockaddr_in*) addr;

 	// If connecting to lobbyserver on port 3100, use default lobby server port instead.
	if (addr_in->sin_addr.s_addr == inet_addr("216.98.48.56") && addr_in->sin_port == htons(3100)) {
		addr_in->sin_port = htons(3035);
	}

        return real_connect(sockfd, addr, addrlen);
}

// How to build and run:
// Build: gcc patch.c -shared -fPIC -ldl -o patch.so -m32
// Run with: LD_PRELOAD=./patch.so ./FarCry2_server
// Maybe you need sudo apt install libc6-dev-i386
