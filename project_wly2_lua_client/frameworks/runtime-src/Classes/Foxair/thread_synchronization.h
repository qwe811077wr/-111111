#ifndef __FOXAIRTHREAD_SYNCHRONIZATION_H__
#define __FOXAIRTHREAD_SYNCHRONIZATION_H__

#include "../platform/CCApplication.h"


#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32 )
#include "pthread.h"
#elif (CC_TARGET_PLATFORM == CC_PLATFORM_IOS || CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
#include <pthread.h>
#elif (CC_TARGET_PLATFORM == CC_PLATFORM_WP8)
#include <mutex>
#else
#include <pthread.h>
#endif

#if (CC_TARGET_PLATFORM == CC_PLATFORM_WP8)
namespace Foxair {
	class Mutex {
	public:
		class ScopedLock {
		public:
			ScopedLock(Mutex &mutex)
				:m_mutex(mutex) {
				m_mutex.lock();
				m_locked = true;
			}
			void lock() {
				if (!m_locked) {
					m_mutex.lock();
					m_locked = true;
				}
			}
			void unlock() {
				if (m_locked) {
					m_mutex.unlock();
					m_locked = false;
				}
			}
			~ScopedLock() {
				unlock();
			}

		private:
			bool m_locked;
			Mutex &m_mutex;
		};
		Mutex();
		void lock();
		void unlock();
		~Mutex();

	private:
		std::mutex m_pmutex;
	};
}
#else
namespace Foxair {
class Mutex {
public:
    class ScopedLock {
    public:
        ScopedLock(Mutex &mutex)
            :m_mutex(mutex) {
            m_mutex.lock();
            m_locked = true;
        }
        void lock() {
            if (!m_locked) {
                m_mutex.lock();
                m_locked = true;
            }
        }
        void unlock() {
            if (m_locked) {
                m_mutex.unlock();
                m_locked = false;
            }
        }
        ~ScopedLock() {
            unlock();
        }

    private:
        bool m_locked;
        Mutex &m_mutex;
    };
    Mutex();
    void lock();
    void unlock();
    ~Mutex();

private:
    pthread_mutex_t m_pmutex;
};
}
#endif
#endif
