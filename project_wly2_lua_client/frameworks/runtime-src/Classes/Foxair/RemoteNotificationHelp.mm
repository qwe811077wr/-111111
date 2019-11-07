//
//  RemoteNotificationHelp.m
//  project_wly2_lua_client
//
//  Created by liyuan on 15/9/17.
//
//

#include "RemoteNotificationHelp.h"

USING_NS_CC;

static RemoteNotificationHelp* m_remoteNotificationHelp = NULL;


RemoteNotificationHelp* RemoteNotificationHelp::getInstance()
{
    if (m_remoteNotificationHelp== NULL) {
        m_remoteNotificationHelp = new RemoteNotificationHelp();
    }
    return m_remoteNotificationHelp;
}

RemoteNotificationHelp::RemoteNotificationHelp(){

}

RemoteNotificationHelp::~RemoteNotificationHelp(){

}


std::string RemoteNotificationHelp::getClientid(){
    return NULL;
}


void RemoteNotificationHelp::setDeviceToken(std::string deviceToken){
    m_deviceToken = deviceToken;
}

std::string RemoteNotificationHelp::getDeviceToken(){
    return m_deviceToken;
}

