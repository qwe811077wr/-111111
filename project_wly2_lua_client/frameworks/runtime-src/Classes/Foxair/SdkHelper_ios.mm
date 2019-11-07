//
//  SdkHelper_ios.c
//  project_swordsman_client
//
//  Created by Lewis.liu on 15/6/3.
//
//

#include <stdio.h>
#include "SdkHelper.h"
#include "../manual/CCLuaEngine.h"
#include "json/document.h"

USING_NS_CC;

static SdkHelper* m_sdkHelper = NULL;


SdkHelper* SdkHelper::getInstance()
{
    if (m_sdkHelper== NULL) {
        m_sdkHelper = new SdkHelper();
    }
    return m_sdkHelper;
}

SdkHelper::SdkHelper()
{
}

SdkHelper::~SdkHelper()
{
}

void SdkHelper::runSDKCmd(const char *param, LUA_FUNCTION nHandler)
{
    registerScriptHandler(nHandler, UFuncType::kTypeUnknown);
    runAction(param);
}

void SdkHelper::runAction(const char *param)
{
    auto luaEngine = LuaEngine::getInstance();
    LUA_FUNCTION handler = getScriptHandler(UFuncType::kTypeUnknown);
    luaEngine->getLuaStack()->clean();
    if (handler > 0) {
        luaEngine->getLuaStack()->pushString(param);
        luaEngine->getLuaStack()->executeFunctionByHandler(handler, 1);
        unregisterScriptHandler(UFuncType::kTypeUnknown);
    }
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


void SdkHelper::exit()
{
    ::exit(0);
}

bool SdkHelper::isUserCentre()
{
    return false;
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
