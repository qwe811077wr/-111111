//
//  RemoteNotificationHelp.m
//  project_wly2_lua_client
//
//  Created by liyuan on 15/9/17.
//
//

#include "RemoteNotificationHelp.h"
#include "../manual/CCLuaEngine.h"
#include "json/document.h"
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
#include <stdio.h>
#include <stdlib.h>
#include <jni.h>
#include <string>
#include "JniHelper.h"

jobject javaObj2;
JniMethodInfo method2;
#endif


#define CLASS_NAME "org/cocos2dx/lua/AppActivity"
using namespace std;
USING_NS_CC;

static RemoteNotificationHelp* m_remoteNotificationHelp = NULL;


RemoteNotificationHelp* RemoteNotificationHelp::getInstance()
{
    if (m_remoteNotificationHelp == NULL) {
        m_remoteNotificationHelp = new RemoteNotificationHelp();
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
        JniMethodInfo minfo;
        if (JniHelper::getStaticMethodInfo(minfo, CLASS_NAME, "getObj","()Ljava/lang/Object;")) {
            jobject obj = minfo.env->CallStaticObjectMethod(minfo.classID, minfo.methodID);
            //CCLog("RemoteNotificationHelp::getInstance()-- javaObj was setup!");
            javaObj2 = minfo.env->NewGlobalRef(obj);
            minfo.env->DeleteLocalRef(minfo.classID);
        }
#endif
    }
    return m_remoteNotificationHelp;
}

RemoteNotificationHelp::RemoteNotificationHelp(){
}

RemoteNotificationHelp::~RemoteNotificationHelp(){
}


std::string RemoteNotificationHelp::getClientid(){
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
    JniMethodInfo t;
    if (JniHelper::getStaticMethodInfo(t, CLASS_NAME, "getClientid","()Ljava/lang/String;")) {
        jstring ret = (jstring)t.env->CallStaticObjectMethod(t.classID, t.methodID);
        const char *pClientid = t.env->GetStringUTFChars(ret, NULL);
        t.env->DeleteLocalRef(t.classID);
        _clientid = std::string(pClientid);
        return _clientid;
    }
#endif
    return "";
}

void RemoteNotificationHelp::setDeviceToken(std::string deviceToken){

}

std::string RemoteNotificationHelp::getDeviceToken(){
    return "";
}
