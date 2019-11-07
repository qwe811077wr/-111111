#ifndef __FOXAIR_SHARED_PTR_H__
#define __FOXAIR_SHARED_PTR_H__

#include <algorithm>

#include "atomic.h"

namespace Foxair {
template<typename T> class SharedPtr {
private:
    typedef SharedPtr<T> type_this;
    typedef void (*ptr_deletor)(T*);
public:
    explicit SharedPtr(T* p = 0, ptr_deletor pd = __DELETOR)
        :m_px(p)
        ,m_deletor(pd) {
        m_pn = new int(1);
    }

    SharedPtr(const SharedPtr<T> &sp)
        :m_px(sp.m_px)
        ,m_pn(sp.m_pn)
        ,m_deletor(sp.m_deletor) {
        atomicIncrement(m_pn);
    }

    SharedPtr<T>& operator=(const SharedPtr<T> &sp) {
        reset();
        delete m_pn;
        m_px = sp.m_px;
        m_pn = sp.m_pn;
        m_deletor = sp.m_deletor;
        atomicIncrement(m_pn);
        return *this;
    }

    T* get() const {
        return m_px;
    }

    T& operator *() {
        return *m_px;
    }

    T* operator ->() {
        return m_px;
    }

	T* operator ->() const {
		return m_px;
	}

	bool operator !=(const SharedPtr<T> &sp) {
		return m_px != sp.get();
	}

    operator bool() {
        return m_px;
    }

    bool operator !() {
        return !m_px;
    }

    void reset(T* p = 0, ptr_deletor pd = __DELETOR) {
        type_this(p, pd).swap(*this);
    }

    void swap(SharedPtr<T> &sp) {
        std::swap(m_px, sp.m_px);
        std::swap(m_pn, sp.m_pn);
        std::swap(m_deletor, sp.m_deletor);
    }

    ~SharedPtr() {
        if (atomicDecrement(m_pn) <= 0) {
            if (m_px) {
                m_deletor(m_px);
            }
            delete m_pn;
        }
    }

private:
    static void __DELETOR(T* px) {
        delete px;
    }

private:
    T* m_px;
    int *m_pn;
    ptr_deletor m_deletor;
};
}
#endif
