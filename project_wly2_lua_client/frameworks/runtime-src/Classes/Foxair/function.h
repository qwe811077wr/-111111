#ifndef __FOXAIR_FUNCTION_H__
#define __FOXAIR_FUNCTION_H__

#include "shared_ptr.h"

//namespace {
//    struct PlaceHolder {
//    }__1;
//}

namespace Foxair {
template<typename F_> class Function {
};

template<typename R_> class Function0 {
public:
    virtual R_ operator()() = 0;
    virtual ~Function0() {}
};

template<typename R_, typename T1_> class Function1 {
public:
    virtual R_ operator()(T1_ t) = 0;
    virtual ~Function1() {}
};

template<typename R_> class PtrFunction0 : public Function0<R_> {
public:
    typedef R_ (*FuncType)();

    PtrFunction0(FuncType func)
        :m_func(func) {
    }

    R_ operator()() {
        return static_cast<R_>(m_func());
    }

private:
    FuncType m_func;
};

template<typename R_, typename C_> class MemFunction0 : public Function0<R_> {
public:
    typedef R_ (C_::*FuncType)();

    MemFunction0(FuncType func, C_ *obj)
        :m_func(func)
        ,m_obj(obj) {
    }

    R_ operator()() {
        return static_cast<R_>((m_obj->*m_func)());
    }

private:
    FuncType m_func;
    C_ *m_obj;
};

template<typename R_> class Function<R_ ()> {
public:
    Function() {}

    Function(typename PtrFunction0<R_>::FuncType func) {
        m_functor.reset(new PtrFunction0<R_>(func));
    }

    template<typename C_> Function(typename MemFunction0<R_, C_>::FuncType func, C_ *obj) {
        m_functor.reset(new MemFunction0<R_, C_>(func, obj));
    }

    R_ operator()() {
        return static_cast<R_>((*m_functor)());
    }

    operator bool() {
        return m_functor;
    }

private:
    SharedPtr<Function0<R_> > m_functor;
};

template<typename R_, typename T1_> class PtrFunction1 : public Function1<R_, T1_> {
public:
    typedef R_ (*FuncType)(T1_);
    PtrFunction1(FuncType func)
        :m_func(func) {
    }

    R_ operator()(T1_ t1) {
        return static_cast<R_>(m_func(t1));
    }

private:
    FuncType m_func;
};

template<typename R_, typename C_, typename T1_> class MemFunction1 : public Function1<R_, T1_> {
public:
    typedef R_ (C_::*FuncType)(T1_);

    MemFunction1(FuncType func, C_ *obj)
        :m_func(func)
        ,m_obj(obj) {
    }

    R_ operator()(T1_ t1) {
        return static_cast<R_>((m_obj->*m_func)(t1));
    }

private:
    FuncType m_func;
    C_ *m_obj;
};

template<typename R_, typename T1_> class Function<R_ (T1_)> {
public:
    Function() {}

    Function(typename PtrFunction1<R_, T1_>::FuncType func) {
        m_functor.reset(new PtrFunction1<R_, T1_>(func));
    }

    template<typename C_> Function(typename MemFunction1<R_, C_, T1_>::FuncType func, C_ *obj) {
        m_functor.reset(new MemFunction1<R_, C_, T1_>(func, obj));
    }

    R_ operator()(T1_ t1) {
        return static_cast<R_>((*m_functor)(t1));
    }

    operator bool() {
        return m_functor;
    }

private:
    SharedPtr<Function1<R_, T1_> > m_functor;
};

template<typename R_> Function<R_ ()> Bind(R_ (*func)()) {
    return Function<R_ ()>(func);
}

template<typename R_, typename C_> Function<R_ ()> Bind(R_ (C_::*func)(), C_ *obj) {
    return Function<R_ ()>(func, obj);
}

template<typename R_, typename T1_> Function<R_ (T1_)> Bind(R_ (*func)(T1_)) {
    return Function<R_ (T1_)>(func);
}

template<typename R_, typename C_, typename T1_> Function<R_ (T1_)> Bind(R_ (C_::*func)(T1_), C_ *obj) {
    return Function<R_ (T1_)>(func, obj);
}
}
#endif
