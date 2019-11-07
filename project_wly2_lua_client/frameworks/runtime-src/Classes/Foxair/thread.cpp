#include "thread.h"

#if (CC_TARGET_PLATFORM == CC_PLATFORM_WP8)
namespace Foxair {
	Thread::Thread() {
	}

	void Thread::start(Function<void ()> dg) {
		std::thread std_thread(Thread::__THREAD_RUNNER, new Function<void()>(dg));
		std_thread.detach();
	}

	void* Thread::__THREAD_RUNNER(void *data) {
		Function<void ()> *pFunc = (Function<void ()> *)data;
		Function<void ()> dg = *pFunc;
		delete pFunc;
		dg();
		return NULL;
	}
}
#else
namespace Foxair {
Thread::Thread() {
    pthread_attr_init(&m_attr);
}

void Thread::start(Function<void ()> dg) {
    pthread_attr_setdetachstate(&m_attr, PTHREAD_CREATE_DETACHED);
    pthread_create(&m_threadId, &m_attr, &__THREAD_RUNNER, new Function<void ()>(dg));
}

void* Thread::__THREAD_RUNNER(void *data) {
    Function<void ()> *pFunc = (Function<void ()> *)data;
    Function<void ()> dg = *pFunc;
    delete pFunc;
    dg();
    return NULL;
}
}
#endif
