#include "socket.h"

#include <vector>
#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32 || CC_TARGET_PLATFORM == CC_PLATFORM_WP8)
#include <winsock2.h>
static const char *
inet_ntop_v4 (const void *src, char *dst, size_t size)
{
	const char digits[] = "0123456789";
	int i;
	struct in_addr *addr = (struct in_addr *)src;
	u_long a = ntohl(addr->s_addr);
	const char *orig_dst = dst;

	for (i = 0; i < 4; ++i) {
		int n = (a >> (24 - i * 8)) & 0xFF;
		int non_zerop = 0;

		if (non_zerop || n / 100 > 0) {
			*dst++ = digits[n / 100];
			n %= 100;
			non_zerop = 1;
		}
		if (non_zerop || n / 10	> 0) {
			*dst++ = digits[n / 10];
			n %= 10;
			non_zerop = 1;
		}
		*dst++ = digits[n];
		if (i != 3)
			*dst++ = '.';
		}
	*dst++ = '\0';
	return orig_dst;
}


#elif (CC_TARGET_PLATFORM == CC_PLATFORM_IOS || CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID || CC_TARGET_PLATFORM == CC_PLATFORM_MAC)
#include <sys/socket.h>
#include <arpa/inet.h>
#include <netdb.h>
#include <unistd.h>
#else
#include <sys/socket.h>
#include <netdb.h>
#include <arpa/inet.h>
#endif
#include <sys/types.h>

#include "buffer.h"
#include <errno.h>
#include <algorithm>

namespace Foxair {
	Socket::Socket(int domain, int type, int protocol) {
#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32 || CC_TARGET_PLATFORM == CC_PLATFORM_WP8)
		WSADATA Ws;
		//Init Windows Socket
		if ( WSAStartup(MAKEWORD(2,2), &Ws) != 0 )
		{
			GAME_LOG("Init Windows Socket Failed::%d", GetLastError());
			return;
		}
		m_fd = socket(domain, type, protocol);
		if(m_fd<0)
		{
			GAME_LOG("Connect Error::%d", GetLastError());
		}
#elif (CC_TARGET_PLATFORM == CC_PLATFORM_IOS || CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
		m_fd = socket(domain, type, protocol);
#else
		m_fd = socket(domain, type, protocol);
#endif
        m_domain = domain;
	}

	int Socket::connect(const std::string &host, unsigned short port) {
        
        
        int connect_ret = 0;
#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32 || CC_TARGET_PLATFORM == CC_PLATFORM_WP8)
		//SOCKET CientSocket;
		struct sockaddr_in ServerAddr;
        
        int AddrLen = 0;
		HANDLE hThread = NULL;

		//windows host.
        ServerAddr.sin_family = AF_INET;

		struct hostent *hent = gethostbyname(host.c_str());
		char ip[16];
		memset(ip, 0, 16);
		inet_ntop_v4(hent->h_addr_list[0], ip, 15);

		ServerAddr.sin_addr.s_addr = inet_addr(ip);
		ServerAddr.sin_port = htons(port);
		memset(ServerAddr.sin_zero, 0x00, 8);

		GAME_LOG("addr:%s\n", ip);
		int err = ::connect(m_fd,(struct sockaddr*)&ServerAddr, sizeof(ServerAddr));
		connect_ret = err;
		if ( err == SOCKET_ERROR )  
		{
			//GAME_LOG("Connect Error::%d",GetLastError());
			return err;
		}
#elif (CC_TARGET_PLATFORM == CC_PLATFORM_IOS || CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID || CC_TARGET_PLATFORM == CC_PLATFORM_MAC)
        if (m_domain == AF_INET6) {
//            struct hostent* he = gethostbyname(host.c_str());
            char ip[128];
            memset(ip, 0, sizeof(ip));
            struct addrinfo *result;
            int error = getaddrinfo(host.c_str(), NULL, NULL, &result);
            if (error != 0 ){
                log("===scoket getaddrinfo error = %d", error);
                return -1;
            }
            const struct sockaddr *sa = result->ai_addr;
            const char	* inet_ntopRet = inet_ntop(AF_INET6, &(((struct sockaddr_in6 *)sa)->sin6_addr),
                      ip, 128);
            if(inet_ntopRet == NULL){
                log("===scoket inet_ntop error");
                return -1;
            }

            struct sockaddr_in6 svraddr_6;
            bzero(&svraddr_6, sizeof(svraddr_6));
            svraddr_6.sin6_family = AF_INET6;
            svraddr_6.sin6_port = htons(port);
            inet_pton(AF_INET6, ip, &svraddr_6.sin6_addr);
           
            connect_ret = ::connect(m_fd, (struct sockaddr*)&svraddr_6, sizeof(svraddr_6));
        } else {
            struct hostent* he = gethostbyname(host.c_str());
            if (he == NULL){
                log("===scoket gethostbyname null");
                return -1;

            }
            char ip[32];
            const char	* inet_ntopRet = inet_ntop(he->h_addrtype, he->h_addr, ip, sizeof(ip));
            if(inet_ntopRet == NULL){
                log("===scoket inet_ntop error");
                return -1;
            }
            
            struct sockaddr_in serv_name;
            memset(&serv_name, 0, sizeof(serv_name));
            serv_name.sin_family = AF_INET;
            inet_aton(ip, &serv_name.sin_addr);
            serv_name.sin_port = htons(port);
            connect_ret = ::connect(m_fd, (struct sockaddr*)&serv_name, sizeof(serv_name));
        }
#else
        if (m_domain == AF_INET6) {
            char ip[128];
            memset(ip, 0, sizeof(ip));
            struct addrinfo *result;
            int error = getaddrinfo(host.c_str(), NULL, NULL, &result);
            if (error != 0 ){
                log("===scoket getaddrinfo error = %d", error);
                return -1;
            }
            const struct sockaddr *sa = result->ai_addr;
            const char * inet_ntopRet = inet_ntop(AF_INET6, &(((struct sockaddr_in6 *)sa)->sin6_addr),
                      ip, 128);
            if(inet_ntopRet == NULL){
                log("===scoket inet_ntop error");
                return -1;
            }

            
            struct sockaddr_in6 svraddr_6;
            bzero(&svraddr_6, sizeof(svraddr_6));
            svraddr_6.sin6_family = AF_INET6;
            svraddr_6.sin6_port = htons(port);
            inet_pton(AF_INET6, ip, &svraddr_6.sin6_addr);
            
            connect_ret = ::connect(m_fd, (struct sockaddr*)&svraddr_6, sizeof(svraddr_6));
        } else {
            struct sockaddr_in serv_name;
            memset(&serv_name, 0, sizeof(serv_name));
            serv_name.sin_family = AF_INET;
            inet_aton(host.c_str(), &serv_name.sin_addr);
            serv_name.sin_port = htons(port);
            connect_ret =::connect(m_fd, (struct sockaddr*)&serv_name, sizeof(serv_name));
        }
#endif
		return connect_ret;
	}

	int Socket::read(Buffer &buffer, unsigned int length) {
		std::vector<iovec> iovs = buffer.writeBuffers(length);
#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32 || CC_TARGET_PLATFORM == CC_PLATFORM_WP8)
		char msgChar[2048]={0};
		int ret=recv(m_fd,msgChar,2048,0);
		int i=0;
		int temp=ret;
		while (temp>0){
			unsigned int toProduce=0;
			if(temp<iovs[i].iov_len){
				toProduce=temp;
			}else{
				toProduce=iovs[i].iov_len;
			}
			memcpy(iovs[i].iov_base,msgChar,toProduce);
			temp=temp-toProduce;
			i++;
		}
#elif (CC_TARGET_PLATFORM == CC_PLATFORM_IOS || CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
		msghdr msg;
		memset(&msg, 0, sizeof(msghdr));
		msg.msg_iov = &iovs[0];
		msg.msg_iovlen = iovs.size();
		int ret = recvmsg(m_fd, &msg, 0);
#else
		msghdr msg;
		memset(&msg, 0, sizeof(msghdr));
		msg.msg_iov = &iovs[0];
		msg.msg_iovlen = iovs.size();
		int ret = recvmsg(m_fd, &msg, 0);
#endif
		if (ret > 0) {
			buffer.produce(ret);
		}
		return ret;
	}

	int Socket::write(Buffer &buffer, unsigned int length) {
//        log("Socket::write");
		std::vector<iovec> iovs = buffer.readBuffers(length);
#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32 || CC_TARGET_PLATFORM == CC_PLATFORM_WP8 )
		int ret = 0;
		int i = 0;
		while(i < iovs.size()){
			ret += send(m_fd, (const char*)iovs[i].iov_base, iovs[i].iov_len,0);
			i++;
		}
#elif (CC_TARGET_PLATFORM == CC_PLATFORM_IOS || CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
		msghdr msg;
		memset(&msg, 0, sizeof(msghdr));
		msg.msg_iov = &iovs[0];
		msg.msg_iovlen = iovs.size();
		int ret = sendmsg(m_fd, &msg, 0);
#else
		msghdr msg;
		memset(&msg, 0, sizeof(msghdr));
		msg.msg_iov = &iovs[0];
		msg.msg_iovlen = iovs.size();
		int ret = sendmsg(m_fd, &msg, 0);
#endif
//		log("sendmsg result: %d \n",errno);
		return ret;
	}
    void Socket::close()
    {
#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32 || CC_TARGET_PLATFORM == CC_PLATFORM_WP8)
		shutdown(m_fd,0);
#elif (CC_TARGET_PLATFORM == CC_PLATFORM_MAC)
        shutdown(m_fd, 0);
#else
        if (-1 != m_fd)//防止闪屏
        {
            ::close(m_fd);
            m_fd = -1;
        }
#endif    
    }
}
