#ifndef __FOXAIR_BUFFER_H__
#define __FOXAIR_BUFFER_H__

#include "../platform/CCApplication.h"

#include <list>
#include <string>
#include <vector>
#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32 || CC_TARGET_PLATFORM == CC_PLATFORM_WP8)
#include <winsock2.h>
#ifndef _STRUCT_IOVEC
#define	_STRUCT_IOVEC
struct iovec {
	void *   iov_base;	/* [XSI] Base address of I/O memory region */
	size_t	 iov_len;	/* [XSI] Size of region iov_base points to */
};
#endif
#elif (CC_TARGET_PLATFORM == CC_PLATFORM_IOS || CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
#include <sys/uio.h>
#else
#include <sys/uio.h>
#endif

#include "shared_array.h"

namespace Foxair {
struct Buffer {
//private:
    public:
    struct SegmentData {
        friend struct Buffer;
    public:
        SegmentData();
        SegmentData(unsigned int length);
        SegmentData(void *buffer, unsigned int length);

        SegmentData slice(unsigned int start, unsigned int length = ~0);
        const SegmentData slice(unsigned int start, unsigned int length = ~0) const;

        void extend(unsigned int len);

    public:
        void *start() { return m_start; }
        const void *start() const { return m_start; }
        unsigned int length() const { return m_length; }
    private:
        void start(void *p) { m_start = p; }
        void length(unsigned int l) { m_length = l;}
        void *m_start;
        unsigned int m_length;
    private:
        SharedArray<unsigned char> m_array;
    };

    struct Segment {
        friend struct Buffer;
    public:
        Segment(unsigned int len);
        Segment(SegmentData);
        Segment(void *buffer, unsigned int length);

        unsigned int readAvailable() const;
        unsigned int writeAvailable() const;
        unsigned int length() const;
        void produce(unsigned int length);
        void consume(unsigned int length);
        void truncate(unsigned int length);
        void extend(unsigned int length);
        const SegmentData readBuffer() const;
        const SegmentData writeBuffer() const;
        SegmentData writeBuffer();

    private:
        unsigned int m_writeIndex;
        SegmentData m_data;

        void invariant() const;
    };

public:
    Buffer();
    Buffer(const Buffer &copy);
    Buffer(const char *string);
    Buffer(const std::string &string);
    Buffer(const void *data, unsigned int length);

    Buffer &operator =(const Buffer &copy);

    unsigned int readAvailable() const;
    unsigned int writeAvailable() const;
    unsigned int segments() const;

    void adopt(void *buffer, unsigned int length);
    void reserve(unsigned int length);
    void compact();
    void clear(bool clearWriteAvailableAsWell = true);
    void produce(unsigned int length);
    void consume(unsigned int length);
    void truncate(unsigned int length);

    const std::vector<iovec> readBuffers(unsigned int length = ~0) const;
    const iovec readBuffer(unsigned int length, bool reallocate) const;
    std::vector<iovec> writeBuffers(unsigned int length = ~0);
    iovec writeBuffer(unsigned int length, bool reallocate);

    void copyIn(const Buffer& buf, unsigned int length = ~0);
    void copyIn(const char* string);
    void copyIn(const void* data, unsigned int length);

    void copyOut(Buffer &buffer, unsigned int length) const
    { buffer.copyIn(*this, length); }
    void copyOut(void* buffer, unsigned int length) const;
    
    //extensions
    void copyOut(void* buffer, unsigned int pos, unsigned int length) const;

    bool operator== (const Buffer &rhs) const;
    bool operator!= (const Buffer &rhs) const;
    bool operator== (const std::string &str) const;
    bool operator!= (const std::string &str) const;
    bool operator== (const char *str) const;
    bool operator!= (const char *str) const;

private:
    std::list<Segment> m_segments;
    unsigned int m_readAvailable;
    unsigned int m_writeAvailable;
    std::list<Segment>::iterator m_writeIt;

    int opCmp(const Buffer &rhs) const;
    int opCmp(const char *string, unsigned int length) const;

    void invariant() const;
};
}
#endif
