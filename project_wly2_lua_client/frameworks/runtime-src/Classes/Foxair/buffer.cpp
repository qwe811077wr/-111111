#include "buffer.h"

#include <string.h>
#include <algorithm>

#include <assert.h>

static unsigned int iovLength(unsigned int length) {
    return length;
}

namespace Foxair {
Buffer::SegmentData::SegmentData() {
    start(NULL);
    length(0);
}

Buffer::SegmentData::SegmentData(unsigned int length) {
    m_array.reset(new unsigned char[length]);
    start(m_array.get());
    this->length(length);
}

Buffer::SegmentData::SegmentData(void *buffer, unsigned int length) {
    m_array.reset((unsigned char *)buffer, &nop<unsigned char *>);
    start(m_array.get());
    this->length(length);
}

Buffer::SegmentData
Buffer::SegmentData::slice(unsigned int start, unsigned int length) {
    if (length == (unsigned int)~0)
        length = this->length() - start;
    assert(start <= this->length());
    assert(length + start <= this->length());
    SegmentData result;
    result.m_array = m_array;
    result.start((unsigned char*)this->start() + start);
    result.length(length);
    return result;
}

const Buffer::SegmentData
Buffer::SegmentData::slice(unsigned int start, unsigned int length) const {
    if (length == (unsigned int)~0)
        length = this->length() - start;
    assert(start <= this->length());
    assert(length + start <= this->length());
    SegmentData result;
    result.m_array = m_array;
    result.start((unsigned char*)this->start() + start);
    result.length(length);
    return result;
}

void
Buffer::SegmentData::extend(unsigned int length) {
    m_length += length;
}

Buffer::Segment::Segment(unsigned int length)
    :m_writeIndex(0), m_data(length) {
    invariant();
}

Buffer::Segment::Segment(Buffer::SegmentData data)
  :m_writeIndex(data.length()), m_data(data) {
    invariant();
}

Buffer::Segment::Segment(void *buffer, unsigned int length)
  :m_writeIndex(0), m_data(buffer, length) {
    invariant();
}

unsigned int Buffer::Segment::readAvailable() const {
    invariant();
    return m_writeIndex;
}

unsigned int Buffer::Segment::writeAvailable() const {
    invariant();
    return m_data.length() - m_writeIndex;
}

unsigned int Buffer::Segment::length() const {
    invariant();
    return m_data.length();
}

void Buffer::Segment::produce(unsigned int length) {
    assert(length <= writeAvailable());
    m_writeIndex += length;
    invariant();
}

void Buffer::Segment::consume(unsigned int length) {
    assert(length <= readAvailable());
    m_writeIndex -= length;
    m_data = m_data.slice(length);
    invariant();
}

void Buffer::Segment::truncate(unsigned int length) {
    assert(length <= readAvailable());
    assert(m_writeIndex = readAvailable());
    m_writeIndex = length;
    m_data = m_data.slice(0, length);
    invariant();
}

void Buffer::Segment::extend(unsigned int length) {
    m_data.extend(length);
    m_writeIndex += length;
}

const Buffer::SegmentData Buffer::Segment::readBuffer() const {
    invariant();
    return m_data.slice(0, m_writeIndex);
}

Buffer::SegmentData Buffer::Segment::writeBuffer() {
    invariant();
    return m_data.slice(m_writeIndex);
}

const Buffer::SegmentData Buffer::Segment::writeBuffer() const {
    invariant();
    return m_data.slice(m_writeIndex);
}

void Buffer::Segment::invariant() const {
    assert(m_writeIndex <= m_data.length());
}


Buffer::Buffer() {
    m_readAvailable = m_writeAvailable = 0;
    m_writeIt = m_segments.end();
    invariant();
}

Buffer::Buffer(const Buffer &copy) {
    m_readAvailable = m_writeAvailable = 0;
    m_writeIt = m_segments.end();
    copyIn(copy);
}

Buffer::Buffer(const char *string) {
    m_readAvailable = m_writeAvailable = 0;
    m_writeIt = m_segments.end();
    copyIn(string, strlen(string));
}

Buffer::Buffer(const std::string &string) {
    m_readAvailable = m_writeAvailable = 0;
    m_writeIt = m_segments.end();
    copyIn(string.c_str(), string.size());
}

Buffer::Buffer(const void *data, unsigned int length) {
    m_readAvailable = m_writeAvailable = 0;
    m_writeIt = m_segments.end();
    copyIn(data, length);
}

Buffer &
Buffer::operator =(const Buffer &copy) {
    clear();
    copyIn(copy);
    return *this;
}

unsigned int Buffer::readAvailable() const {
    invariant();
    return m_readAvailable;
}

unsigned int Buffer::writeAvailable() const {
    invariant();
    return m_writeAvailable;
}

unsigned int Buffer::segments() const {
    invariant();
    return m_segments.size();
}

void Buffer::adopt(void *buffer, unsigned int length) {
    invariant();
    Segment newSegment(buffer, length);
    if (readAvailable() == 0) {
        m_segments.push_front(newSegment);
        m_writeIt = m_segments.begin();
    } else {
        m_segments.push_back(newSegment);
        if (m_writeAvailable == 0) {
            m_writeIt = m_segments.end();
            --m_writeIt;
        }
    }
    m_writeAvailable += length;
    invariant();
}

void Buffer::reserve(unsigned int length) {
    if (writeAvailable() < length) {
        Segment newSegment(length * 2 - writeAvailable());
        if (readAvailable() == 0) {
            m_segments.push_front(newSegment);
            m_writeIt = m_segments.begin();
        } else {
            m_segments.push_back(newSegment);
            if (m_writeAvailable == 0) {
                m_writeIt = m_segments.end();
                --m_writeIt;
            }
        }
        m_writeAvailable += newSegment.length();
        invariant();
    }
}

void Buffer::compact() {
    invariant();
    if (m_writeIt != m_segments.end()) {
        if (m_writeIt->readAvailable() > 0) {
            Segment newSegment = Segment(m_writeIt->readBuffer());
            m_segments.insert(m_writeIt, newSegment);
        }
        m_writeIt = m_segments.erase(m_writeIt, m_segments.end());
        m_writeAvailable = 0;
    }
    assert(writeAvailable() == 0);
}

void Buffer::clear(bool clearWriteAvailableAsWell) {
    invariant();
    if (clearWriteAvailableAsWell) {
        m_readAvailable = m_writeAvailable = 0;
        m_segments.clear();
        m_writeIt = m_segments.end();
    } else {
        m_readAvailable = 0;
        if (m_writeIt != m_segments.end() && m_writeIt->readAvailable())
            m_writeIt->consume(m_writeIt->readAvailable());
        m_segments.erase(m_segments.begin(), m_writeIt);
    }
    invariant();
    assert(m_readAvailable == 0);
}

void Buffer::produce(unsigned int length) {
    assert(length <= writeAvailable());
    m_readAvailable += length;
    m_writeAvailable -= length;
    while (length > 0) {
        Segment &segment = *m_writeIt;
        unsigned int toProduce = (std::min)(segment.writeAvailable(), length);
        segment.produce(toProduce);
        length -= toProduce;
        if (segment.writeAvailable() == 0)
            ++m_writeIt;
    }
    assert(length == 0);
    invariant();
}

void Buffer::consume(unsigned int length) {
    assert(length <= readAvailable());
    m_readAvailable -= length;
    while (length > 0) {
        Segment &segment = *m_segments.begin();
        unsigned int toConsume = (std::min)(segment.readAvailable(), length);
        segment.consume(toConsume);
        length -= toConsume;
        if (segment.length() == 0)
            m_segments.pop_front();
    }
    assert(length == 0);
    invariant();
}

void Buffer::truncate(unsigned int length) {
    assert(length <= readAvailable());
    if (length == m_readAvailable)
        return;
    if (m_writeIt != m_segments.end() && m_writeIt->readAvailable() != 0) {
        m_segments.insert(m_writeIt, Segment(m_writeIt->readBuffer()));
        m_writeIt->consume(m_writeIt->readAvailable());
    }
    m_readAvailable = length;
    std::list<Segment>::iterator it;
    for (it = m_segments.begin(); it != m_segments.end() && length > 0; ++it) {
        Segment &segment = *it;
        if (length <= segment.readAvailable()) {
            segment.truncate(length);
            length = 0;
            ++it;
            break;
        } else {
            length -= segment.readAvailable();
        }
    }
    assert(length == 0);
    while (it != m_segments.end() && it->readAvailable() > 0) {
        assert(it->writeAvailable() == 0);
        it = m_segments.erase(it);
    }
    invariant();
}

const std::vector<iovec> Buffer::readBuffers(unsigned int length) const {
    if (length == (unsigned int)~0)
        length = readAvailable();
    assert(length <= readAvailable());
    std::vector<iovec> result;
    result.reserve(m_segments.size());
    unsigned int remaining = length;
    std::list<Segment>::const_iterator it;
    for (it = m_segments.begin(); it != m_segments.end(); ++it) {
        unsigned int toConsume = (std::min)(it->readAvailable(), remaining);
        SegmentData data = it->readBuffer().slice(0, toConsume);
        iovec iov;
        iov.iov_base = (void *)data.start();
        iov.iov_len = data.length();
        result.push_back(iov);
        remaining -= toConsume;
        if (remaining == 0)
            break;
    }
    assert(remaining == 0);
    invariant();
    return result;
}

const iovec
Buffer::readBuffer(unsigned int length, bool coalesce) const {
    iovec result;
    result.iov_base = NULL;
    result.iov_len = 0;
    if (length == (unsigned int)~0)
        length = readAvailable();
    assert(length <= readAvailable());
    if (readAvailable() == 0)
        return result;
    if (m_segments.front().readAvailable() >= length) {
        SegmentData data = m_segments.front().readBuffer().slice(0, length);
        result.iov_base = data.start();
        result.iov_len = iovLength(data.length());
        return result;
    }
    if (!coalesce) {
        SegmentData data = m_segments.front().readBuffer();
        result.iov_base = data.start();
        result.iov_len = iovLength(data.length());
        return result;
    }
    Buffer* _this = const_cast<Buffer*>(this);
    if (m_writeIt != m_segments.end() && m_writeIt->writeAvailable()
        >= readAvailable()) {
        copyOut(m_writeIt->writeBuffer().start(), readAvailable());
        Segment newSegment = Segment(m_writeIt->writeBuffer().slice(0,
            readAvailable()));
        _this->m_segments.clear();
        _this->m_segments.push_back(newSegment);
        _this->m_writeAvailable = 0;
        _this->m_writeIt = _this->m_segments.end();
        invariant();
        SegmentData data = newSegment.readBuffer().slice(0, length);
        result.iov_base = data.start();
        result.iov_len = iovLength(data.length());
        return result;
    }
    Segment newSegment = Segment(readAvailable());
    copyOut(newSegment.writeBuffer().start(), readAvailable());
    newSegment.produce(readAvailable());
    _this->m_segments.clear();
    _this->m_segments.push_back(newSegment);
    _this->m_writeAvailable = 0;
    _this->m_writeIt = _this->m_segments.end();
    invariant();
    SegmentData data = newSegment.readBuffer().slice(0, length);
    result.iov_base = data.start();
    result.iov_len = iovLength(data.length());
    return result;
}

std::vector<iovec>
Buffer::writeBuffers(unsigned int length) {
    if (length == (unsigned int)~0)
        length = writeAvailable();
    reserve(length);
    std::vector<iovec> result;
    result.reserve(m_segments.size());
    unsigned int remaining = length;
    std::list<Segment>::iterator it = m_writeIt;
    while (remaining > 0) {
        Segment& segment = *it;
        unsigned int toProduce = (std::min)(segment.writeAvailable(), remaining);
        SegmentData data = segment.writeBuffer().slice(0, toProduce);
        iovec iov;
        iov.iov_base = (void *)data.start();
        iov.iov_len = data.length();
        result.push_back(iov);
        remaining -= toProduce;
        ++it;
    }
    assert(remaining == 0);
    invariant();
    return result;
}

iovec
Buffer::writeBuffer(unsigned int length, bool coalesce) {
    iovec result;
    result.iov_base = NULL;
    result.iov_len = 0;
    if (length == 0u)
        return result;
    if (writeAvailable() == 0) {
        reserve(length);
        assert(m_writeIt != m_segments.end());
        assert(m_writeIt->writeAvailable() >= length);
        SegmentData data = m_writeIt->writeBuffer().slice(0, length);
        result.iov_base = data.start();
        result.iov_len = iovLength(data.length());
        return result;
    }
    if (writeAvailable() > 0 && m_writeIt->writeAvailable() >= length) {
        SegmentData data = m_writeIt->writeBuffer().slice(0, length);
        result.iov_base = data.start();
        result.iov_len = iovLength(data.length());
        return result;
    }
    if (!coalesce) {
        SegmentData data = m_writeIt->writeBuffer();
        result.iov_base = data.start();
        result.iov_len = iovLength(data.length());
        return result;
    }
    compact();
    reserve(length);
    assert(m_writeIt != m_segments.end());
    assert(m_writeIt->writeAvailable() >= length);
    SegmentData data = m_writeIt->writeBuffer().slice(0, length);
    result.iov_base = data.start();
    result.iov_len = iovLength(data.length());
    return result;
}

void
Buffer::copyIn(const Buffer &buffer, unsigned int length) {
    if (length == (unsigned int)~0)
        length = buffer.readAvailable();
    assert(buffer.readAvailable() >= length);
    invariant();
    if (length == 0)
        return;

    if (m_writeIt != m_segments.end() && m_writeIt->readAvailable() != 0) {
        m_segments.insert(m_writeIt, Segment(m_writeIt->readBuffer()));
        m_writeIt->consume(m_writeIt->readAvailable());
        invariant();
    }

    std::list<Segment>::const_iterator it;
    for (it = buffer.m_segments.begin(); it != buffer.m_segments.end(); ++it) {
        unsigned int toConsume = (std::min)(it->readAvailable(), length);
        if (m_readAvailable != 0 && it == buffer.m_segments.begin()) {
            std::list<Segment>::iterator previousIt = m_writeIt;
            --previousIt;
            if ((unsigned char *)previousIt->readBuffer().start() +
                previousIt->readBuffer().length() == it->readBuffer().start() &&
                previousIt->m_data.m_array.get() == it->m_data.m_array.get()) {
                assert(previousIt->writeAvailable() == 0);
                previousIt->extend(toConsume);
                m_readAvailable += toConsume;
                length -= toConsume;
                if (length == 0)
                    break;
                continue;
            }
        }
        Segment newSegment = Segment(it->readBuffer().slice(0, toConsume));
        m_segments.insert(m_writeIt, newSegment);
        m_readAvailable += toConsume;
        length -= toConsume;
        if (length == 0)
            break;
    }
    assert(length == 0);
    assert(readAvailable() >= length);
}

void
Buffer::copyIn(const void *data, unsigned int length) {
    invariant();

    while (m_writeIt != m_segments.end() && length > 0) {
        unsigned int todo = (std::min)(length, m_writeIt->writeAvailable());
        memcpy(m_writeIt->writeBuffer().start(), data, todo);
        m_writeIt->produce(todo);
        m_writeAvailable -= todo;
        m_readAvailable += todo;
        data = (unsigned char*)data + todo;
        length -= todo;
        if (m_writeIt->writeAvailable() == 0)
            ++m_writeIt;
        invariant();
    }

    if (length > 0) {
        Segment newSegment(length);
        memcpy(newSegment.writeBuffer().start(), data, length);
        newSegment.produce(length);
        m_segments.push_back(newSegment);
        m_readAvailable += length;
    }

    assert(readAvailable() >= length);
}

void
Buffer::copyIn(const char *string) {
    copyIn(string, strlen(string));
}

void
Buffer::copyOut(void *buffer, unsigned int length) const {
    assert(length <= readAvailable());
    unsigned char *next = (unsigned char*)buffer;
    std::list<Segment>::const_iterator it;
    for (it = m_segments.begin(); it != m_segments.end(); ++it) {
        unsigned int todo = (std::min)(length, it->readAvailable());
        memcpy(next, it->readBuffer().start(), todo);
        next += todo;
        length -= todo;
        if (length == 0)
            break;
    }
    assert(length == 0);
}

void
Buffer::copyOut(void *buffer, unsigned int pos, unsigned int length) const {
    assert(length <= readAvailable());
    unsigned char *next = (unsigned char*)buffer;
    std::list<Segment>::const_iterator it;
    for (it = m_segments.begin(); it != m_segments.end(); ++it) {
        unsigned int todo = (std::min)(length, it->readAvailable());
        SegmentData data = it->readBuffer().slice(pos, length);
        memcpy(next, data.start(), todo);
        next += todo;
        length -= todo;
        if (length == 0)
            break;
    }
    assert(length == 0);
}

bool
Buffer::operator == (const Buffer &rhs) const {
    if (rhs.readAvailable() != readAvailable())
        return false;
    return opCmp(rhs) == 0;
}

bool
Buffer::operator != (const Buffer &rhs) const {
    if (rhs.readAvailable() != readAvailable())
        return true;
    return opCmp(rhs) != 0;
}

bool
Buffer::operator== (const std::string &string) const {
    if (string.size() != readAvailable())
        return false;
    return opCmp(string.c_str(), string.size()) == 0;
}

bool
Buffer::operator!= (const std::string &string) const {
    if (string.size() != readAvailable())
        return true;
    return opCmp(string.c_str(), string.size()) != 0;
}

bool
Buffer::operator== (const char *string) const {
    unsigned int length = strlen(string);
    if (length != readAvailable())
        return false;
    return opCmp(string, length) == 0;
}

bool
Buffer::operator!= (const char *string) const {
    unsigned int length = strlen(string);
    if (length != readAvailable())
        return true;
    return opCmp(string, length) != 0;
}

int
Buffer::opCmp(const Buffer &rhs) const {
    std::list<Segment>::const_iterator leftIt, rightIt;
    int lengthResult = (int)((ptrdiff_t)readAvailable() - (ptrdiff_t)rhs.readAvailable());
    leftIt = m_segments.begin(); rightIt = rhs.m_segments.begin();
    unsigned int leftOffset = 0, rightOffset = 0;
    while (leftIt != m_segments.end() && rightIt != rhs.m_segments.end())
    {
        assert(leftOffset <= leftIt->readAvailable());
        assert(rightOffset <= rightIt->readAvailable());
        unsigned int tocompare = (std::min)(leftIt->readAvailable() - leftOffset,
            rightIt->readAvailable() - rightOffset);
        if (tocompare == 0)
            break;
        int result = memcmp(
            (const unsigned char *)leftIt->readBuffer().start() + leftOffset,
            (const unsigned char *)rightIt->readBuffer().start() + rightOffset,
            tocompare);
        if (result != 0)
            return result;
        leftOffset += tocompare;
        rightOffset += tocompare;
        if (leftOffset == leftIt->readAvailable()) {
            leftOffset = 0;
            ++leftIt;
        }
        if (rightOffset == rightIt->readAvailable()) {
            rightOffset = 0;
            ++rightIt;
        }
    }
    return lengthResult;
}

int
Buffer::opCmp(const char *string, unsigned int length) const {
    unsigned int offset = 0;
    std::list<Segment>::const_iterator it;
    int lengthResult = (int)((ptrdiff_t)readAvailable() - (ptrdiff_t)length);
    if (lengthResult > 0)
        length = readAvailable();
    for (it = m_segments.begin(); it != m_segments.end(); ++it) {
        unsigned int tocompare = (std::min)(it->readAvailable(), length);
        int result = memcmp(it->readBuffer().start(), string + offset, tocompare);
        if (result != 0)
            return result;
        length -= tocompare;
        offset += tocompare;
        if (length == 0)
            return lengthResult;
    }
    return lengthResult;
}

void
Buffer::invariant() const {
	/*
#ifndef NDEBUG
    unsigned int read = 0;
    unsigned int write = 0;
    bool seenWrite = false;
    std::list<Segment>::const_iterator it;
    for (it = m_segments.begin(); it != m_segments.end(); ++it) {
        const Segment &segment = *it;
        assert(!seenWrite || (seenWrite && segment.readAvailable() == 0));
        read += segment.readAvailable();
        write += segment.writeAvailable();
        if (!seenWrite && segment.writeAvailable() != 0) {
            seenWrite = true;   
            assert(m_writeIt == it);
        }
        std::list<Segment>::const_iterator nextIt = it;
        ++nextIt;
        if (nextIt != m_segments.end()) {
            const Segment& next = *nextIt;
            if (segment.writeAvailable() == 0 &&
                next.readAvailable() != 0) {
                assert((const unsigned char*)segment.readBuffer().start() +
                    segment.readAvailable() != next.readBuffer().start() ||
                    segment.m_data.m_array.get() != next.m_data.m_array.get());
            } else if (segment.writeAvailable() != 0 &&
                next.readAvailable() == 0) {
                assert((const unsigned char*)segment.writeBuffer().start() +
                    segment.writeAvailable() != next.writeBuffer().start() ||
                    segment.m_data.m_array.get() != next.m_data.m_array.get());
            }
        }
    }
    assert(read == m_readAvailable);
    assert(write == m_writeAvailable);
    assert(write != 0 || (write == 0 && m_writeIt == m_segments.end()));
#endif
	*/
}
}
