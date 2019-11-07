#include "LocalNotificationHelp.h"

USING_NS_CC;

LocalNotificationHelp::LocalNotificationHelp() {
}
void LocalNotificationHelp::registerUserNotification(){}
void LocalNotificationHelp::addLocalNotification(){}
void LocalNotificationHelp::removeNotification(){}
void LocalNotificationHelp::createLocalNotificationConfig(){}//创建本地通知本地配置
int LocalNotificationHelp::getLocalNotificationConfig() { return 0; }//获取本地通知状态
void LocalNotificationHelp::setLocalNotificationConfig(int status){}//设置本地通知状态

LocalNotificationHelp::~LocalNotificationHelp() {
}

LocalNotificationHelp* LocalNotificationHelp::getInstance() {
	return nullptr;
}