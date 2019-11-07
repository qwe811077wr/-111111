//
//  SdkHelper.cpp
//  project_swordsman_client
//
//  Created by Lewis.liu on 15/6/3.
//
//

#include "SdkHelper.h"
#include "../manual/CCLuaEngine.h"
#include "json/document.h"
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
#include <stdio.h>
#include <stdlib.h>
#include <jni.h>
#include <string>
#include "JniHelper.h"

jobject javaObj;
JniMethodInfo method;
#endif

#define CLASS_NAME "org/cocos2dx/lua/AppActivity"

using namespace std;

USING_NS_CC;

static SdkHelper* m_sdkHelper = NULL;
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
extern "C"  {
    void Java_org_cocos2dx_lua_AppActivity_initBridge(JNIEnv *env, jobject thiz)
    {
        printf("sdkInit");
        javaObj = env->NewGlobalRef(thiz);
    }

    void Java_org_cocos2dx_lua_AppActivity_doJavaCmd(JNIEnv *env, jobject thiz, jstring arg0)
    {
        const char *param = env->GetStringUTFChars(arg0, NULL);
        SdkHelper::getInstance()->runJavaCmd(param);
    }
}

void callVoidMethod(const char* param) {
    //log("callVoidMethod");
    jstring stringArg = method.env->NewStringUTF(param);
    method.env->CallVoidMethod(javaObj, method.methodID, stringArg);
    method.env->DeleteLocalRef(stringArg);
    method.env->DeleteLocalRef(method.classID);
}

void callStaticVoidMethod(const char* param) {
    //log("callStaticVoidMethod");
    JniMethodInfo mi;
    if (JniHelper::getStaticMethodInfo(mi, CLASS_NAME, "sdkExecute", "(Ljava/lang/String;)V")){
        jstring stringArg = mi.env->NewStringUTF(param);
        mi.env->CallStaticVoidMethod(mi.classID, mi.methodID, stringArg);
        mi.env->DeleteLocalRef(stringArg);
        mi.env->DeleteLocalRef(mi.classID);
    }
}
#endif

SdkHelper* SdkHelper::getInstance()
{
    if (m_sdkHelper == NULL) {
        m_sdkHelper = new SdkHelper();
    }
    return m_sdkHelper;
}

SdkHelper::SdkHelper()
{
    _bUserCentre = false;
}

SdkHelper::~SdkHelper(){
}

void SdkHelper::runSDKCmd(const char *param, LUA_FUNCTION nHandler)
{
    registerScriptHandler(nHandler, UFuncType::kTypeUnknown);
    runAction(param);
}

void SdkHelper::exit()
{
    ::exit(0);
}

bool SdkHelper::isUserCentre()
{
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
    JniMethodInfo t;
    if (JniHelper::getStaticMethodInfo(t, CLASS_NAME, "hasUserCenter","()Z")) {
        jboolean b = t.env->CallStaticBooleanMethod(t.classID, t.methodID);
        t.env->DeleteLocalRef(t.classID);
        _bUserCentre = false;
        if (b) {
            _bUserCentre = true;
        }
    }
#endif
    return _bUserCentre;
}

void SdkHelper::runAction(const char *param)
{
    log("SdkHelper::runAction(), param : %s", param);
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
    // callVoidMethod(param);
    callStaticVoidMethod(param);
#endif
}

void SdkHelper::runJavaCmd(const char* param)
{
    log("onSDKComplete param is : %s", param);
    rapidjson::Document document;
    document.Parse<0>(param);
    if (!document.HasMember("action")) {
        return;
    }
    char const *action = document["action"].GetString();
    auto luaEngine = LuaEngine::getInstance();
    if(strcmp(action, "GameExit") == 0) {
        exit();
    } else {
        LUA_FUNCTION handler = getScriptHandler(UFuncType::kTypeUnknown);
        luaEngine->getLuaStack()->clean();
        if (handler > 0) {
            luaEngine->getLuaStack()->pushString(param);
            luaEngine->getLuaStack()->executeFunctionByHandler(handler, 1);
            unregisterScriptHandler(UFuncType::kTypeUnknown);
        }
    }
}

/*
 * 获取回调
 */
int SdkHelper::getScriptHandler(int nScriptEventType) {
    std::map<int,int>::iterator iter = m_mapScriptHandler.find(nScriptEventType);
    if (m_mapScriptHandler.end() != iter)
        return iter->second;
    
    return 0;
}

/*
 * 注册回调
 */
void SdkHelper::registerScriptHandler(LUA_FUNCTION nHandler,int nScriptEventType) {
    if (nHandler <= 0) {
        return;
    }
    unregisterScriptHandler(nScriptEventType);
    m_mapScriptHandler[nScriptEventType] = nHandler;
}

/*
 * 注销回调
 */
void SdkHelper::unregisterScriptHandler(int nScriptEventType) {
    std::map<int,int>::iterator iter = m_mapScriptHandler.find(nScriptEventType);
    if (m_mapScriptHandler.end() != iter)
    {
        m_mapScriptHandler.erase(iter);
    }
}
