//
//  LocalNotificationHelp.h
//  project_wly2_lua_client
//
//  Created by liyuan on 15/9/7.
//
//

#ifndef project_wly2_lua_client_LocalNotificationHelp_h
#define project_wly2_lua_client_LocalNotificationHelp_h

#include <stdio.h>
#include "cocos2d.h"

USING_NS_CC;

class LocalNotificationHelp: public cocos2d::Ref
{
public:
    static LocalNotificationHelp* getInstance();

    LocalNotificationHelp();
    ~LocalNotificationHelp();

    void registerUserNotification();//注册本地推送
    void addLocalNotification();//设置推送内容
    void removeNotification();//清楚本地推送
    void createLocalNotificationConfig();//创建本地通知本地配置
    int getLocalNotificationConfig();//获取本地通知状态
    void setLocalNotificationConfig(int status);//设置本地通知状态
};
#endif
