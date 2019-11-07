#ifndef __FOXAIR_IOMANAGER_H__
#define __FOXAIR_IOMANAGER_H__

#include <vector>

#include "function.h"
#include "thread.h"
#include "thread_synchronization.h"

namespace Foxair {
class IOManager {
public:
    typedef enum {
        IO_EVENT_NONE  = 0x0000,
        IO_EVENT_READ  = 0x0001,
        IO_EVENT_WRITE = 0x0004,
        IO_EVENT_ERROR = 0x2000
    } EventType;
    struct AsyncState {
        AsyncState()
            :m_fd(0)
            ,m_events(IO_EVENT_NONE) {
        }

        bool triggerEvent(EventType event, bool trigger = false);

		void cancelEvent(EventType event);

        int m_fd;
        Function<void (int)> m_in, m_out;
        EventType m_events;
        Mutex m_mutex;
    };
private:
    IOManager(unsigned int threads);

public:
    ~IOManager();
	static IOManager* get(unsigned int th_num = 1);
    void registerEvent(int fd, EventType et, Function<void (int)> dg);
	void cancelEvent(int fd, EventType et);
    void start();
    void idle();
    void stop();
private:
    Mutex m_mutex;
    std::vector<AsyncState*> m_states;
    std::vector<Thread> m_threads;
    bool m_stop;
	static IOManager *S_IOMANAGER;
};
}
#endif
