#ifndef _GNU_SOURCE
#define _GNU_SOURCE
#endif

#include <dlfcn.h>
#include <arpa/inet.h>

#include <stdlib.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netdb.h>

#include <ifaddrs.h>
#include <net/if.h>

#include <stdio.h>

typedef int (*connect_t)(int sockfd, const struct sockaddr *addr, socklen_t addrlen);
connect_t real_connect;

typedef int (*bind_t)(int sockfd, const struct sockaddr *addr, socklen_t addrlen);
bind_t real_bind;

typedef struct hostent *(*gethostbyname_t)(const char *name);
gethostbyname_t real_gethostbyname;

int bind(int sockfd, const struct sockaddr *addr, socklen_t addrlen)
{
    if (!real_bind)
        real_bind = dlsym(RTLD_NEXT, "bind");

    struct sockaddr_in *addr_in = (struct sockaddr_in*)addr;
    addr_in->sin_addr.s_addr = INADDR_ANY;

    return real_bind(sockfd, addr, addrlen);
}

int connect(int sockfd, const struct sockaddr *addr, socklen_t addrlen)
{
    if (!real_connect)
        real_connect = dlsym(RTLD_NEXT, "connect");

    struct sockaddr_in *addr_in = (struct sockaddr_in*)addr;

    // If connecting to lobbyserver on port 3100, use default lobby server port instead.
    if (addr_in->sin_addr.s_addr == inet_addr("216.98.48.56") && addr_in->sin_port == htons(3100))
        addr_in->sin_port = htons(3035);

    return real_connect(sockfd, addr, addrlen);
}

void getipbyname(char **name)
{
	struct ifaddrs *ifaddr_list;

        if (getifaddrs(&ifaddr_list) < 0) {
                return;
        }

        struct ifaddrs *ifaddr = ifaddr_list;
        //char name[15];

        while (ifaddr) {
                int family = ifaddr->ifa_addr->sa_family;

                if (family == AF_INET && (ifaddr->ifa_flags & IFF_LOOPBACK) == 0) {
                        getnameinfo(ifaddr->ifa_addr, sizeof(*ifaddr->ifa_addr), *name, sizeof(*name), 0, 0, NI_NUMERICHOST);
                }

                ifaddr = ifaddr->ifa_next;
        }

        freeifaddrs(ifaddr_list);
}

struct hostent *gethostbyname(const char *name)
{
    if (!real_gethostbyname)
        real_gethostbyname = dlsym(RTLD_NEXT, "gethostbyname");

    printf("IP address is: %s----------------------------------------------------\n", name);
    getipbyname((char**)&name);

    printf("Changed to: %s--------------------------------------------------------\n", name);

    return real_gethostbyname(name);
}

// How to build and run:
// Build: gcc patch.c -shared -fPIC -ldl -o patch.so -m32
// Run with: LD_PRELOAD=./patch.so ./FarCry2_server
// Maybe you need "apt-get install gcc libc6-dev-i386"
