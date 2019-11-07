#ifndef __FOXAIR_SHARED_ARRAY_H__
#define __FOXAIR_SHARED_ARRAY_H__

#include <algorithm>

#include "atomic.h"

namespace Foxair {
template<typename T> void nop(T t) {
}
template<typename T> class SharedArray {
private:
    typedef SharedArray<T> type_this;
    typedef void (*array_deletor)(T*);

public:
    explicit SharedArray(T* p = 0, array_deletor ad = __DELETOR)
        :m_px(p)
        ,m_deletor(ad) {
        m_pn = new int(1);
    }

    SharedArray(const SharedArray &sa)
        :m_deletor(sa.m_deletor)
        ,m_px(sa.m_px)
        ,m_pn(sa.m_pn) {
        atomicIncrement(m_pn);
    }

    SharedArray& operator=(const SharedArray &sa) {
        reset();
        delete m_pn;
        m_deletor = sa.m_deletor;
        m_px = sa.m_px;
        m_pn = sa.m_pn;
        atomicIncrement(m_pn);
        return *this;
    }

    T* get() const {
        return m_px;
    }

    T& operator [](unsigned int t) {
        return m_px[t];
    }

    operator bool() {
        return m_px;
    }

    bool operator !() {
        return m_px;
    }

    void reset(T* p = 0, array_deletor ad = __DELETOR) {
        type_this(p, ad).swap(*this);
    }

    void swap(SharedArray<T> &sa) {
        std::swap(m_deletor, sa.m_deletor);
        std::swap(m_px, sa.m_px);
        std::swap(m_pn, sa.m_pn);
    }

    ~SharedArray() {
        if (atomicDecrement(m_pn) <= 0) {
            if (m_px) {
                m_deletor(m_px);
            }
            delete m_pn;
        }
    }

private:
    static void __DELETOR(T* px) {
        delete[] px;
    }
private:
    T* m_px;
    int *m_pn;
    array_deletor m_deletor;
};
}
#endif
