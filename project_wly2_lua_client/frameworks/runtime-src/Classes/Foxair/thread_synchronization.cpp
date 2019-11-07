    #include "thread_synchronization.h"

#if (CC_TARGET_PLATFORM == CC_PLATFORM_WP8)
namespace Foxair {
Mutex::Mutex() {
}

void Mutex::lock() {
	m_pmutex.lock();
}

void Mutex::unlock() {
	m_pmutex.unlock();
}

Mutex::~Mutex() {
	m_pmutex.unlock();
}
}
#else
namespace Foxair {
	Mutex::Mutex() {
		pthread_mutex_init(&m_pmutex, 0);
	}

	void Mutex::lock() {
		pthread_mutex_lock(&m_pmutex);
	}

	void Mutex::unlock() {
		pthread_mutex_unlock(&m_pmutex);
	}

	Mutex::~Mutex() {
		pthread_mutex_destroy(&m_pmutex);
	}
}
#endif
