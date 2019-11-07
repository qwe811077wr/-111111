#ifndef __FOXAIR_SOCKET_H__
#define __FOXAIR_SOCKET_H__

#include <string>
#include "cocos2d.h"

USING_NS_CC;

#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
#include <android/log.h>
#endif

#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
#define LOG_TAG "System.out"
#define GAME_LOG(...) __android_log_print(ANDROID_LOG_INFO,LOG_TAG,__VA_ARGS__)
#else
#define GAME_LOG(format,...) cocos2d::log(format, ##__VA_ARGS__)
#endif

namespace Foxair {
class Buffer;

class Socket {
public:
    Socket(int domain, int type, int protocol = 0);
    //void connect(const std::string &host, unsigned short port);
    int connect(const std::string &host, unsigned short port);
    int read(Buffer &buffer, unsigned int length);
    int write(Buffer &buffer, unsigned int length);

    int fd() const { return m_fd; }
    void close();
private:
    int m_fd;
    int m_domain;
};
}
#endif
