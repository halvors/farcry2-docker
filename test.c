#include <sys/socket.h>
#include <netdb.h>
#include <ifaddrs.h>
#include <stdio.h>
#include <stdlib.h>

#include <net/if.h>

int main()
{
	struct ifaddrs *ifaddr_list;

	if (getifaddrs(&ifaddr_list) < 0) {
		return -1;
	}

	struct ifaddrs *ifaddr = ifaddr_list;
        char name[15];

	while (ifaddr) {
		int family = ifaddr->ifa_addr->sa_family;

		if (family == AF_INET && (ifaddr->ifa_flags & IFF_LOOPBACK) == 0) {
			getnameinfo(ifaddr->ifa_addr, sizeof(*ifaddr->ifa_addr), name, sizeof(name), 0, 0, NI_NUMERICHOST);
		}

		ifaddr = ifaddr->ifa_next;
	}

	freeifaddrs(ifaddr_list);

        printf("%s\n", name);

	return 0;
}
