#include "game_connection.h"
#include "../platform/CCApplication.h"
#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32 || CC_TARGET_PLATFORM == CC_PLATFORM_WP8)
#include <winsock2.h>
#include <WS2tcpip.h>
#elif (CC_TARGET_PLATFORM == CC_PLATFORM_IOS || CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
#include <fcntl.h>
#include <sys/socket.h>
#include <arpa/inet.h>
#include <netdb.h>
#else
#include <fcntl.h>
#include <sys/socket.h>
#include <arpa/inet.h>
#include <netdb.h>
#endif
#include <errno.h>

#include "crypto_helper.h"
#include "function.h"
#include "iomanager.h"

#include <assert.h>
#include <time.h>

#if COCOS2D_DEBUG == 1
#include <time.h>
#endif

#include "../manual/CCLuaEngine.h"

namespace Foxair {

    // singleton stuff
    static GameConnection *s_SharedGameConnection = NULL;


    GameConnection* GameConnection::sharedGameConnection(void) {
        if (s_SharedGameConnection == NULL)
            //        assert(s_SharedGameConnection);
            return NULL;

        return s_SharedGameConnection;
    }

    GameConnection* GameConnection::sharedGameConnection(const std::string &host, unsigned short port) {
		if (!s_SharedGameConnection) {
			s_SharedGameConnection = new GameConnection(host, port);
		} else {
			s_SharedGameConnection->reset(host, port);
		}
        return s_SharedGameConnection;
    }

    GameConnection::GameConnection(const std::string &host, unsigned short port)
		:m_writePending(false)
		,m_socket(AF_INET, SOCK_STREAM)
		,m_host(host)
		,m_port(port)
		,m_ErrorHandler(0)
		,m_state(CONNECTION_STATE_INIT)
		,m_lastSendTimestamp(0)
		,m_lastRecvTimestamp(0)
		,m_serverTimestamp(0) {
		IOManager::get();
        struct addrinfo *result;

        int error = getaddrinfo(host.c_str(), NULL, NULL, &result);
        if (error == 0 ){
            const struct sockaddr *sa = result->ai_addr;
            m_socket = Socket(sa->sa_family, SOCK_STREAM);
        }

}

	void GameConnection::reset(const std::string &host, unsigned short port) {
		this->close();
		m_writePending = false;
        struct addrinfo *result;
        int error = getaddrinfo(host.c_str(), NULL, NULL, &result);
        if (error == 0 ){
            const struct sockaddr *sa = result->ai_addr;
            m_socket = Socket(sa->sa_family, SOCK_STREAM);
        }
//        m_socket = Socket(AF_INET, SOCK_STREAM);
		m_host = host;
		m_port = port;
		m_ErrorHandler = 0;
		m_state = CONNECTION_STATE_INIT;
		m_lastSendTimestamp = 0;
		m_lastRecvTimestamp = 0;
		m_serverTimestamp = 0;
	}

    GameConnection::~GameConnection()
    {
    }

    void GameConnection::close(void)
    {
		IOManager::get()->cancelEvent(m_socket.fd(), IOManager::IO_EVENT_READ);
		IOManager::get()->cancelEvent(m_socket.fd(), IOManager::IO_EVENT_WRITE);
		m_socket.close();
    }

    int GameConnection::connect() {
		if (m_state == CONNECTION_STATE_OPEN || m_state == CONNECTION_STATE_OPENING)
		{
			return m_state;
		}
        m_state = CONNECTION_STATE_OPENING;
        int ret = m_socket.connect(m_host, m_port);
		if (ret) {
			m_state = CONNECTION_STATE_ERROR;
		}
		else {
			m_state = CONNECTION_STATE_OPEN;
		}
        return ret;
    }

    int GameConnection::connect(int handle)
    {
        if(m_state == CONNECTION_STATE_OPEN || m_state == CONNECTION_STATE_OPENING)
        {
            return m_state;
        }
        this->m_ErrorHandler = handle;
        m_state = CONNECTION_STATE_OPENING;
        int ret = m_socket.connect(m_host, m_port);
        m_state = CONNECTION_STATE_OPEN;
        return ret;
    }

    void GameConnection::setErrorHandler(int handle)
    {
        this->m_ErrorHandler = handle;
    }

    void GameConnection::start() {
#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32 || CC_TARGET_PLATFORM == CC_PLATFORM_WP8)
        unsigned long mode = 1;
        ioctlsocket(m_socket.fd(), FIONBIO, &mode);
#elif (CC_TARGET_PLATFORM == CC_PLATFORM_IOS || CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
        fcntl(m_socket.fd(), F_SETFL, O_NONBLOCK);
#else
        fcntl(m_socket.fd(), F_SETFL, O_NONBLOCK);
#endif
        IOManager::get()->registerEvent(m_socket.fd(), IOManager::IO_EVENT_READ, Bind(&GameConnection::readCB, this));
    }

    ProtocolPacket* GameConnection::getPacket() {
        Mutex::ScopedLock lock(m_packetMutex);
        if (m_packets.empty()) {
            return 0;
        }
        ProtocolPacket *packet = m_packets.front();
        m_packets.pop_front();

        return packet;
    }

    void GameConnection::sendPacket(ProtocolPacket *packet, bool crypto) {
        static int TIME_STAMP = 0;
        Buffer buf1, *buf, out;
        buf = &buf1;
        int type = packet->type();

        struct timeval tp;
        gettimeofday(&tp, NULL);

        // 心跳包
		if ( type==0 )
		{
			Mutex::ScopedLock timestampLock(m_timestampMutex);
			// 最近发包时间戳
			m_lastSendTimestamp = (long long)tp.tv_sec * 1000 + (long long)tp.tv_usec;
		}
        buf1.copyIn(&type, sizeof(type));
        buf1.copyIn(*packet->buffer(), packet->buffer()->readAvailable());
		if (crypto && !m_sendKey.empty()) {
            std::string str;
            str.resize(buf1.readAvailable());
            buf1.copyOut(&str[0], str.size());
            std::string md5Str = Foxair::md5sum(str);
            TIME_STAMP++;
            Buffer in;
            in.copyIn(&TIME_STAMP, sizeof(TIME_STAMP));
            in.copyIn(&md5Str[0], md5Str.size());
            in.copyIn(buf1, buf1.readAvailable());
            Foxair::encryptBuffer(in, out, m_sendKey);
            buf = &out;
        }
        int len = buf->readAvailable() + sizeof(len);
        Mutex::ScopedLock lock(m_writeMutex);
        m_writeBuffer.copyIn(&len, sizeof(len));
        m_writeBuffer.copyIn(*buf, buf->readAvailable());
        if (!m_writePending) {
            m_writePending = true;
            IOManager::get()->registerEvent(m_socket.fd(), IOManager::IO_EVENT_WRITE, Bind(&GameConnection::writeCB, this));
        }
    }

    unsigned int GameConnection::sendRawData(Buffer &buffer) {
        return m_socket.write(buffer, buffer.readAvailable());
    }

    unsigned int GameConnection::readRawData(Buffer &buffer) {
        return m_socket.read(buffer, 2048);
    }
	void GameConnection::sendProxy(ProtocolPacket *packet, std::string proxyKey) {
		Buffer out;
		Foxair::encryptBuffer(*packet->buffer(), out, proxyKey);
		Buffer writeBuffer;
		int len = out.readAvailable() + sizeof(len);
		writeBuffer.copyIn(&len, sizeof(len));
		writeBuffer.copyIn(out, out.readAvailable());
		m_socket.write(writeBuffer, writeBuffer.readAvailable());
	}
	unsigned int GameConnection::sendRawDataLua(ProtocolPacket* packet) {
		Foxair::Buffer* buffer = packet->buffer();
		return sendRawData(*buffer);
	}
    ProtocolPacket* GameConnection::readRawPacket() {
        Buffer buffer;
        while (true) {
            int ret = readRawData(buffer);
            if (ret <= 0) {
                return 0;
            }
            int len;
            if (buffer.readAvailable() < sizeof(len)) {
                continue;
            }
            buffer.copyOut(&len, sizeof(len));
            short realLen = short(len);
            if (buffer.readAvailable() < realLen) {
                continue;
            }
            int type;
            if (realLen < sizeof(len) + sizeof(type)) {
                return 0;
            }
            buffer.consume(sizeof(len));
            buffer.copyOut(&type, sizeof(type));
            buffer.consume(sizeof(type));
            ProtocolPacket *pp = new ProtocolPacket;
            pp->type(type);
            pp->buffer()->copyIn(buffer, buffer.readAvailable());
            return pp;
        }
        return 0;
    }

	ProtocolPacket* GameConnection::readRawDataLua(int len) {
		Buffer buffer;
		int size = len;
		while (true) {
			int ret = m_socket.read(buffer, len);
			if (ret <= 0) {
				CCLOG("ret:%d", ret);
				return 0;
			}
			CCLOG("ret:%d,len:%d", ret, buffer.readAvailable());
			if (buffer.readAvailable() >= size) {
				ProtocolPacket *pp = new ProtocolPacket;
				pp->buffer()->copyIn(buffer, size);
				return pp;
			}
			len -= buffer.readAvailable();
		}
		return 0;
	}

    void GameConnection::readCB(int fd) {
        //    ProtocolPacket pp;
        //    pp.type(0);
        //    sendPacket(&pp);
        int ret;
        while (true) {
            Buffer buf;
            ret = m_socket.read(buf, 65535);
            if (ret < 0) {
#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32 || CC_TARGET_PLATFORM == CC_PLATFORM_WP8)
                if (errno != 0) {
#elif (CC_TARGET_PLATFORM == CC_PLATFORM_IOS || CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
                if (errno != EAGAIN) {
#else
                if (errno != EAGAIN) {
#endif
                    m_state = CONNECTION_STATE_ERROR;
#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32 || CC_TARGET_PLATFORM == CC_PLATFORM_WP8)
                    if (errno == 104) {
#elif (CC_TARGET_PLATFORM == CC_PLATFORM_IOS || CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
                    if (errno == ECONNRESET) {
#else
                    if (errno == ECONNRESET) {
#endif
                        m_state = CONNECTION_STATE_RESET;
                    }
                    return;
                }
                break;
            } else if (ret == 0) {
                m_state = CONNECTION_STATE_CLOSED;
                return;
            }
            m_readBuffer.copyIn(buf, buf.readAvailable());
        }
        int len;
        while (m_readBuffer.readAvailable() > sizeof(len)) {
            m_readBuffer.copyOut(&len, sizeof(len));

            char flag = (len>>16)&0xff;
            len &= 0x00ffffff;

            if (m_readBuffer.readAvailable() < len) {
                break;
            }
            m_readBuffer.consume(sizeof(len));

            Buffer dataBuf;
            m_readBuffer.copyOut(dataBuf, len - sizeof(len));
            m_readBuffer.consume(len - sizeof(len));

            ProtocolPacket *packet = new ProtocolPacket;
            if (m_readKey.empty()) {
                packet->buffer()->copyIn(dataBuf, dataBuf.readAvailable());
            }
            else
            {
                Foxair::decryptBuffer(dataBuf, *packet->buffer(), m_readKey);
            }
            //        CCLOG("-----==-- %d    %d     %d", flag, len>>16, len);
            int type;
            packet->buffer()->copyOut(&type, sizeof(type));
            packet->buffer()->consume(sizeof(type));
            packet->type(type);
            Mutex::ScopedLock lock(m_packetMutex);
            m_packets.push_back(packet);
        }
        IOManager::get()->registerEvent(m_socket.fd(), IOManager::IO_EVENT_READ, Bind(&GameConnection::readCB, this));
    }

    void GameConnection::writeCB(int fd) {
        Mutex::ScopedLock lock(m_writeMutex);
        while (m_writeBuffer.readAvailable() > 0) {
            int ret = m_socket.write(m_writeBuffer, m_writeBuffer.readAvailable());
            if (ret < 0 ) {
                std::cout << "write errno:" << errno << std::endl;
                if (errno != EAGAIN) {
                    m_state = CONNECTION_STATE_ERROR;
                    if (errno == ECONNRESET) {
                        m_state = CONNECTION_STATE_RESET;
                    }
                    return;
                }
                break;
            }
            m_writeBuffer.consume(ret);
        }
        if (m_writeBuffer.readAvailable() > 0) {
            IOManager::get()->registerEvent(m_socket.fd(), IOManager::IO_EVENT_WRITE, Bind(&GameConnection::writeCB, this));
        } else {
            m_writePending = false;
        }
    }

    long long GameConnection::getServerTime()
    {
		struct timeval tp;
		gettimeofday(&tp, NULL);
		//当前时间
		long long now = (long long)tp.tv_sec * 1000 + (long long)tp.tv_usec;
		Mutex::ScopedLock timestampLock(m_timestampMutex);

		// 距离上次收到心跳包的时间间隔
		long long dt = now - m_lastRecvTimestamp;

		return m_serverTimestamp + dt;
    }

	bool ProtocolPacket::readReportData(const char *filename, bool is_zip) {
		if (!cocos2d::FileUtils::getInstance()->isFileExist(filename)) {
			return false;
		}
		if (is_zip) {
			unsigned char *out = nullptr;
			int size = cocos2d::ZipUtils::inflateGZipFile(filename, &out);
			cocos2d::FileUtils::getInstance()->removeFile(filename);
			if (size < 0) {
				return false;
			}
			m_buffer.copyIn(out, size);
			delete out;;
		}
		else {
			cocos2d::Data data = cocos2d::FileUtils::getInstance()->getDataFromFile(filename);
			m_buffer.copyIn(data.getBytes(), data.getSize());
		}
		return true;
	}
}
