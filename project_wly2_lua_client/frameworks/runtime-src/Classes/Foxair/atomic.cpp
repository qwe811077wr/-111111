#include "atomic.h"

namespace Foxair {
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)

#include <libkern/OSAtomic.h>
int32_t atomicDecrement(volatile int32_t* t) {
    return OSAtomicDecrement32Barrier(t);
}
int32_t atomicIncrement(volatile int32_t* t) {
    return OSAtomicIncrement32Barrier(t);
}
#elif (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)

#include <stdatomic.h>
int atomicDecrement(volatile int* t) {
    __sync_fetch_and_sub(t, 1);
    return *t;
}
int atomicIncrement(volatile int* t) {
    __sync_fetch_and_add(t, 1);
    return *t;
}
#elif (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32 || CC_TARGET_PLATFORM == CC_PLATFORM_WP8)

#include <intrin.h>
LONG atomicDecrement(volatile int* t) {
    return InterlockedDecrement((LONG* )t);
}

LONG atomicIncrement(volatile int* t) {
    return InterlockedIncrement((LONG* )t);
}
#else
int atomicDecrement(volatile int* t) {
    return __sync_sub_and_fetch(t, 1);
}
int atomicIncrement(volatile int* t) {
    return __sync_add_and_fetch(t, 1);
}
#endif
}
