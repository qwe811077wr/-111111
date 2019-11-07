//
//  RemoteNotificationHelp.h
//  project_wly2_lua_client
//
//  Created by liyuan on 15/9/17.
//
//

#ifndef project_wly2_lua_client_RemoteNotificationHelp_h
#define project_wly2_lua_client_RemoteNotificationHelp_h

#include <stdio.h>
#include "cocos2d.h"

USING_NS_CC;

class RemoteNotificationHelp: public cocos2d::Ref
{
public:
    std::string m_deviceToken;

    static RemoteNotificationHelp* getInstance();

    RemoteNotificationHelp();
    ~RemoteNotificationHelp();

    std::string getClientid();
    void setDeviceToken(std::string deviceToken);
    std::string getDeviceToken();
    private:
    std::string _clientid;
};
#endif
