#ifndef __FOXAIR_ATOMIC_H__
#define __FOXAIR_ATOMIC_H__

#include "../platform/CCApplication.h"

namespace Foxair {
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
int32_t atomicDecrement(volatile int32_t* t);
int32_t atomicIncrement(volatile int32_t* t);
#elif (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
int atomicDecrement(volatile int* t);
int atomicIncrement(volatile int* t);
#elif (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32 || CC_TARGET_PLATFORM == CC_PLATFORM_WP8 )
LONG atomicDecrement(volatile int* t);
LONG atomicIncrement(volatile int* t);
#else
int atomicDecrement(volatile int* t);
int atomicIncrement(volatile int* t);
#endif
}
#endif
