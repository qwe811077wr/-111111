#ifndef __FOXAIR_THREAD_H__
#define __FOXAIR_THREAD_H__

#include "../platform/CCApplication.h"

#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32 )
#include "pthread.h"
#elif (CC_TARGET_PLATFORM == CC_PLATFORM_WP8)
#include <thread>
#elif (CC_TARGET_PLATFORM == CC_PLATFORM_IOS || CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
#include <pthread.h>
#else
#include <pthread.h>
#endif

#include "function.h"

#if (CC_TARGET_PLATFORM == CC_PLATFORM_WP8)
namespace Foxair {
	class Thread {
	public:
		Thread();
		void start(Function<void ()> dg);

	private:
		static void* __THREAD_RUNNER(void *data);
	};
}
#else
namespace Foxair {
class Thread {
public:
    Thread();
    void start(Function<void ()> dg);

private:
    static void* __THREAD_RUNNER(void *data);

private:
    pthread_attr_t m_attr;
    pthread_t m_threadId;
};
}
#endif
#endif
