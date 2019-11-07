//
//  LocalNotificationHelp.m
//  project_wly2_lua_client
//
//  Created by liyuan on 15/9/7.
//
//

#include "LocalNotificationHelp.h"

USING_NS_CC;

static LocalNotificationHelp* m_localNotificationHelp = NULL;


LocalNotificationHelp* LocalNotificationHelp::getInstance()
{
    if (m_localNotificationHelp== NULL) {
        m_localNotificationHelp = new LocalNotificationHelp();
    }
    return m_localNotificationHelp;
}

LocalNotificationHelp::LocalNotificationHelp(){

}

LocalNotificationHelp::~LocalNotificationHelp(){

}

void LocalNotificationHelp::registerUserNotification(){

}

void LocalNotificationHelp::addLocalNotification(){

}

void LocalNotificationHelp::removeNotification(){

}

void LocalNotificationHelp::createLocalNotificationConfig(){
}

int LocalNotificationHelp::getLocalNotificationConfig(){
    int status = 0;
    return status;
}

void LocalNotificationHelp::setLocalNotificationConfig(int status){
}


