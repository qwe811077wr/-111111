#include "../platform/CCApplication.h"

#include "iomanager.h"
#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32 || CC_TARGET_PLATFORM == CC_PLATFORM_WP8)
#include <winsock2.h>
#elif (CC_TARGET_PLATFORM == CC_PLATFORM_IOS || CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
#include <sys/select.h>
#else
#include <sys/select.h>
#endif
#include <assert.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>

namespace Foxair {
bool IOManager::AsyncState::triggerEvent(EventType event, bool trigger) {
    Mutex::ScopedLock lock(m_mutex);
    if (!trigger) {
        return (m_events & event);
    }
    if (!(m_events & event)) {
        return true;
    }
    m_events = (EventType)(m_events & ~event);
    lock.unlock();
    switch (event) {
        case IO_EVENT_READ:
            m_in(m_fd);
            break;
        case IO_EVENT_WRITE:
            m_out(m_fd);
            break;
        default:
            break;
    }
    return true;
}

void IOManager::AsyncState::cancelEvent(EventType event) {
	Mutex::ScopedLock lock(m_mutex);
	m_events = (EventType)(m_events & ~event);
}

IOManager *IOManager::S_IOMANAGER = NULL;

IOManager::IOManager(unsigned int threads)
    :m_stop(false) {
    m_threads.resize(threads);
    for (unsigned int i = 0; i < m_threads.size(); ++i) {
        m_threads[i].start(Bind(&IOManager::start, this));
    }
}
    
IOManager::~IOManager()
{
    m_stop = true;
//    m_states.clear();
}

void IOManager::start() {
    idle();
}

IOManager* IOManager::get(unsigned int th_num) {
	if (!S_IOMANAGER) {
		S_IOMANAGER = new IOManager(th_num);
	}
	return S_IOMANAGER;
}
    
void IOManager::stop() {
    m_stop = true;
}    

void IOManager::registerEvent(int fd, EventType et, Function<void (int)> dg) {
    assert(fd > 0);
    Mutex::ScopedLock lock(m_mutex);
    if (m_states.size() <= (unsigned int)fd) {
        m_states.resize(fd * 3 / 2);
    }
    if (!m_states[fd]) {
        m_states[fd] = new AsyncState;
        m_states[fd]->m_fd = fd;
    }
    AsyncState &state = *m_states[fd];
    lock.unlock();
    Mutex::ScopedLock lock2(state.m_mutex);
    assert(!(state.m_events & et));
    switch (et) {
        case IO_EVENT_READ:
            state.m_in = dg;
            break;
        case IO_EVENT_WRITE:
            state.m_out = dg;
            break;
        default:
            assert(false);
    }
    state.m_events = (EventType)(state.m_events | et);
}

void IOManager::cancelEvent(int fd, EventType et) {
	Mutex::ScopedLock lock(m_mutex);
	if (m_states.size() <= (size_t)fd || fd < 0) {
		return;
	}
	if (!m_states[fd]) {
		return;
	}
	AsyncState *state = m_states[fd];
	lock.unlock();
	state->cancelEvent(et);
}

void IOManager::idle() {
    fd_set read_fds, write_fds, error_fds;
    struct timeval timeout;
    while (!m_stop) {
        FD_ZERO(&read_fds);
        FD_ZERO(&write_fds);
        FD_ZERO(&error_fds);
        timeout.tv_sec=0;
        timeout.tv_usec=600;
        Mutex::ScopedLock lock(m_mutex);
        int max_fd = 0;
        for (unsigned int i = 0; i < m_states.size(); ++i) {
            if (!m_states[i]) {
                continue;
            }
            AsyncState &state = *m_states[i];
            int fd = state.m_fd;
            if (state.m_events & IO_EVENT_READ) {
                FD_SET(fd, &read_fds);
                max_fd = fd + 1;
            }
            if (state.m_events & IO_EVENT_WRITE) {
                FD_SET(fd, &write_fds);
                max_fd = fd + 1;
            }
        }
        lock.unlock();
        int nfs;
        if ((nfs = select(max_fd, &read_fds, &write_fds, &error_fds, (::timeval*)(&timeout))) < 0) {
            //error
        }
        if (nfs == 0) {
            continue;
        }
        for (int fd = 0; fd < max_fd; ++fd) {
            AsyncState *state;
            lock.lock();
			if (fd >= m_states.size()) {
				continue;
			}
            state = m_states[fd];
            lock.unlock();
            if (!state) {
                continue;
            }
            bool triggered = false;
            triggered = state->triggerEvent(IO_EVENT_READ);
            triggered = triggered || state->triggerEvent(IO_EVENT_WRITE);
            if (!triggered) {
                continue;
            }
            EventType event = IO_EVENT_NONE;
            if (FD_ISSET(fd, &error_fds)) {
                event = (EventType)(IO_EVENT_READ | IO_EVENT_WRITE);
            } else {
                if (FD_ISSET(fd, &read_fds)) {
                    event = (EventType)(event | IO_EVENT_READ);
                }
                if (FD_ISSET(fd, &write_fds)) {
                    event = (EventType)(event | IO_EVENT_WRITE);
                }
            }
            if (event & IO_EVENT_READ) {
                state->triggerEvent(IO_EVENT_READ, true);
            }
            if (event & IO_EVENT_WRITE) {
                state->triggerEvent(IO_EVENT_WRITE, true);
            }
        }
    }
}
}
