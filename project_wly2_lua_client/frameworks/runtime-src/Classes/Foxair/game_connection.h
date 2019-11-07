#ifndef __FOXAIR_GAME_CONNECTION_H__
#define __FOXAIR_GAME_CONNECTION_H__

#include <list>
#include <iostream>

#include "buffer.h"
#include "socket.h"
#include "thread_synchronization.h"
#include "cocos2d.h"
#include "iomanager.h"


namespace Foxair {
    class IOManager;
    class ProtocolPacket{
    public:
        int type() const { return m_type; }
        void type(int val) { m_type = val; }

        char readChar() {
            char ret;
            m_buffer.copyOut(&ret, 1);
            m_buffer.consume(sizeof(ret));
            return ret;
        }
        unsigned char readUChar() {
            unsigned char ret;
            m_buffer.copyOut(&ret, 1);
            m_buffer.consume(sizeof(ret));
            return ret;
        }
        char subChar(unsigned int pos){
            char ret;
            m_buffer.copyOut(&ret, pos, 1);
            return ret;
        }
        void writeChar(char ch) {
            m_buffer.copyIn(&ch, 1);
        }
        short readShort() {
            short ret;
            m_buffer.copyOut(&ret, sizeof(ret));
            m_buffer.consume(sizeof(ret));
            return ret;
        }
        unsigned short readUShort() {
            unsigned short ret;
            m_buffer.copyOut(&ret, sizeof(ret));
            m_buffer.consume(sizeof(ret));
            return ret;
        }
        short subShort(unsigned int pos){
            short ret;
            m_buffer.copyOut(&ret, pos, sizeof(ret));
            return ret;
        }
        void writeShort(short val) {
            m_buffer.copyIn(&val, sizeof(val));
        }
        int readInt() {
            int ret;
            m_buffer.copyOut(&ret, sizeof(ret));
            m_buffer.consume(sizeof(ret));
            return ret;
        }
        unsigned int readUInt() {
            unsigned int ret;
            m_buffer.copyOut(&ret, sizeof(ret));
            m_buffer.consume(sizeof(ret));
            return ret;
        }
        void writeInt(int val) {
            m_buffer.copyIn(&val, sizeof(val));
        }
        float readFloat() {
            float ret;
            m_buffer.copyOut(&ret, sizeof(ret));
            m_buffer.consume(sizeof(ret));
            return ret;
        }
        void writeFloat(float val) {
            m_buffer.copyIn(&val, sizeof(val));
        }
        double readDouble() {
            double ret;
            m_buffer.copyOut(&ret, sizeof(ret));
            m_buffer.consume(sizeof(ret));
            return ret;
        }
        void writeDouble(double val) {
            m_buffer.copyIn(&val, sizeof(val));
        }
        long long readLongLong() {
            long long ret;
            m_buffer.copyOut(&ret, sizeof(ret));
            m_buffer.consume(sizeof(ret));
            return ret;
        }
        std::string readLLongString() {
            long long ret = readLongLong();
            char report[30];
            //sprintf(report,"%02d%02d%02d%02d%02d%02d%d"
            sprintf(report, "%lld", ret);
            return std::string(report);
        }
        void writeLongLong(long long val) {
            m_buffer.copyIn(&val, sizeof(val));
        }
        std::string readString(unsigned int size) {
			if(size == 0)
			{
				return "";
			}
            std::string ret;
            ret.resize(size);
            m_buffer.copyOut(&ret[0], ret.size());
            m_buffer.consume(ret.size());
            return ret;
        }

        void writeString(const std::string &str, int len = -1) {
            std::string data = str;
            if (len > 0 && (int)data.size() < len) {
                data.resize(len);
            }
            m_buffer.copyIn(&data[0], data.size());
        }
        unsigned int size() const {
            return m_buffer.readAvailable();
        }
        Buffer* buffer() {
            return &m_buffer;
		}
		/**
		合并中间包，像装备，邮件，待合并的包头应该有2个字节的长度
		*/
		void concat(ProtocolPacket *packet, int size) {
			m_buffer.copyIn(packet->m_buffer, size);
			packet->m_buffer.consume(size);
		}

        ProtocolPacket() {

        }
        //write report data to packet
        /*ProtocolPacket(const char *data, int length) {
			unsigned char *out = nullptr;
			ssize_t size = cocos2d::ZipUtils::inflateMemory((unsigned char *)data, length, &out);
			m_buffer.copyIn(out, size);
        }*/
		bool readReportData(const char *filename, bool is_zip);
		void readBuffer(ProtocolPacket *packet, int size) {
			m_buffer.copyOut(packet->m_buffer, size);
			m_buffer.consume(size);
		}
		void del() {
			delete this;
		}
    private:
        int m_type;
        Buffer m_buffer;
    };
    class InetHelper:public cocos2d::Ref {
    public:
        static void openUrl(const std::string &url){
            Application::getInstance()->openURL(url);
        }
    };
    class GameConnection : public cocos2d::Ref{
    public:
        typedef enum {
            CONNECTION_STATE_INIT = 0,
            CONNECTION_STATE_OPENING,
            CONNECTION_STATE_OPEN,
            CONNECTION_STATE_CLOSED,
            CONNECTION_STATE_ERROR,
            CONNECTION_STATE_RESET
        } ConnectionState;

        static GameConnection* sharedGameConnection(void);
        static GameConnection* sharedGameConnection(const std::string &host, unsigned short port);
        GameConnection(const std::string &host, unsigned short port);
		void reset(const std::string &host, unsigned short port);
        int connect();
        void start();
        ProtocolPacket* getPacket();
        void sendKey(const std::string &key) { m_sendKey = key; }
        void readKey(const std::string &key) { m_readKey = key; }
        void sendPacket(ProtocolPacket *packet, bool crypto=true);
        unsigned int sendRawData(Buffer &buffer);
		unsigned int readRawData(Buffer &buffer);
		unsigned int sendRawDataLua(ProtocolPacket *packet);
		void sendProxy(ProtocolPacket *packet, std::string proxyKey);
		ProtocolPacket* readRawDataLua(int size);
        ProtocolPacket* readRawPacket();
        inline ConnectionState getState() { return m_state; }

		//ext
        int connect(int handle);
        void setErrorHandler(int handle);
        void close(void);
        ~GameConnection();

        // 获取服务器时间(毫秒) added by xiaoj 2014-07-03
        long long getServerTime();
    private:
        void readCB(int fd);
        void writeCB(int fd);

    private:
        std::string m_sendKey;
        std::string m_readKey;
        bool m_writePending;

        Socket m_socket;
        std::string m_host;
        unsigned short m_port;

		Buffer m_readBuffer;

        Mutex m_writeMutex;
        Buffer m_writeBuffer;

        Mutex m_packetMutex;
        std::list<ProtocolPacket*> m_packets;

        ConnectionState m_state;

        int m_ErrorHandler;

        // 最近发心跳包时间戳(毫秒) added by xiaoj 2014-07-03
        long long m_lastSendTimestamp;

        // 最近收心跳包时间戳(毫秒) added by xiaoj 2014-07-03
        long long m_lastRecvTimestamp;

        // 服务器时间(毫秒)
        long long m_serverTimestamp;

        // timestamp mutex
        Mutex m_timestampMutex;
    };
}
#endif
