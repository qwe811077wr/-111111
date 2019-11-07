//
//  SdkHelper.h
//  project_swordsman_client
//
//  Created by Lewis.liu on 15/6/3.
//
//

#ifndef __project_wly2_lua_client__SdkHelper__
#define __project_wly2_lua_client__SdkHelper__

#include <stdio.h>

#include "cocos2d.h"
#include "CCLuaEngine.h"

USING_NS_CC;

class SdkHelper: public cocos2d::Ref
{
public:
    enum UFuncType
    {
        kTypeUnknown = 0,
        kTypeUpdateHandler,
        kTypeLoginHandler,
        KTypeLogoutHandler,
        kTypeExitHandler,
        kTypeChargeHandler,
    };

    static SdkHelper* getInstance();

    SdkHelper();
    ~SdkHelper();

    void runSDKCmd(const char *param, LUA_FUNCTION nHandler);

    // 退出
    void exit();

    bool isUserCentre();

    void runAction(const char *param);
    void runJavaCmd(const char* param);

    // 注册Lua回调函数
    void registerScriptHandler(LUA_FUNCTION nHandler,int nScriptEventType);
    // 注销Lua回调函数
    void unregisterScriptHandler(int nScriptEventType);
    // 获取Lua回调函数
    int getScriptHandler(int nScriptEventType);
private:
    bool _bUserCentre;
    std::map<int, int> m_mapScriptHandler;
};



#endif /* defined(__project_swordsman_client__SdkHelper__) */
