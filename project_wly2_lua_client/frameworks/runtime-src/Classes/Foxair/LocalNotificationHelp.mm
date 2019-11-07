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
    //如果已经获得发送通知的授权则创建本地通知，否则请求授权(注意：如果不请求授权在设置中是没有对应的通知设置项的，也就是说如果从来没有发送过请求，即使通过设置也打不开消息允许设置)
    UIDevice *device = [UIDevice currentDevice];
    float sysVersion = [device.systemVersion floatValue];
    //ios 8以上
    if (sysVersion >= 8.0f) {
        if ([[UIApplication sharedApplication]currentUserNotificationSettings].types!=UIUserNotificationTypeNone) {
            addLocalNotification();

        }else{
            [[UIApplication sharedApplication]registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound  categories:nil]];
        }
    }else{
        UIRemoteNotificationType type = [[UIApplication sharedApplication] enabledRemoteNotificationTypes];
        if(UIRemoteNotificationTypeNone != type){
            addLocalNotification();
        }else{
            [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
             (UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert)];
        }
    };
}

void LocalNotificationHelp::addLocalNotification(){
#pragma mark 斗兽场本地推送
    NSArray *ltArray = [NSArray arrayWithObjects:@"19:55:00",nil];
    for (NSString *timeStr in ltArray) {
        NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
        [formatter setDateFormat:@"HH:mm:ss"];
        NSDate *now = [formatter dateFromString:timeStr];
        //定义本地通知对象
        UILocalNotification *notification = [[[UILocalNotification alloc]init] autorelease];
        //设置时区
        notification.timeZone = [NSTimeZone defaultTimeZone];
        //设置调用时间 通知触发的时间
        notification.fireDate = now;
        NSLog(@"当前时间%@", notification.fireDate);
        //通知重复次数(每天循环)
        notification.repeatInterval = kCFCalendarUnitDay;
        //循环当前日历
        //notification.repeatCalendar = [NSCalendar currentCalendar];
        //设置通知属性
        notification.alertBody=@"斗兽场已经开启，海量奖励等你来战！";
        //应用程序图标右上角显示的消息数
        notification.applicationIconBadgeNumber=1;
        //待机界面的滑动动作提示
        notification.alertAction=@"打开游戏";
        //通过点击通知打开应用时的启动图片,这里使用程序启动图片
        notification.alertLaunchImage=@"Default";
        //通知声音
        notification.soundName=@"msg.caf";

        //调用通知
        [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    }

#pragma mark 精英刷新
    NSArray *jyArray = [NSArray arrayWithObjects:@"12:25:00",nil];
    for (NSString *timeStr in jyArray) {
        NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
        [formatter setDateFormat:@"HH:mm:ss"];
        NSDate *now = [formatter dateFromString:timeStr];
        //定义本地通知对象
        UILocalNotification *notification = [[[UILocalNotification alloc]init] autorelease];
        //设置时区
        notification.timeZone = [NSTimeZone defaultTimeZone];
        //设置调用时间 通知触发的时间
        notification.fireDate = now;
        NSLog(@"当前时间%@", notification.fireDate);
        //通知重复次数(每天循环)
        notification.repeatInterval = kCFCalendarUnitDay;
        //循环当前日历
        //notification.repeatCalendar = [NSCalendar currentCalendar];
        //设置通知属性
        notification.alertBody=@"精英副本刷新完成，极品装备点击就送！";
        //应用程序图标右上角显示的消息数
        notification.applicationIconBadgeNumber=1;
        //待机界面的滑动动作提示
        notification.alertAction=@"打开游戏";
        //通过点击通知打开应用时的启动图片,这里使用程序启动图片
        notification.alertLaunchImage=@"Default";
        //通知声音
        notification.soundName=@"msg.caf";

        //调用通知
        [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    }

#pragma mark 势力之王争夺战
    std::string timeStr = "19:55";
    int weekday = 7;
    NSString *str= [NSString stringWithCString:timeStr.c_str() encoding:[NSString defaultCStringEncoding]];
    NSLog(@"设置每周固定时间");
    NSCalendar *calendar=[NSCalendar currentCalendar];
    [calendar setTimeZone:[NSTimeZone defaultTimeZone]];
    unsigned currentFlag=NSDayCalendarUnit|NSMonthCalendarUnit|NSYearCalendarUnit|NSWeekdayCalendarUnit;
    NSDateComponents *comp=[calendar components:currentFlag fromDate:[NSDate date]];
    NSInteger hour=[[[str componentsSeparatedByString:@":"] objectAtIndex:0] intValue];
    NSInteger min=[[[str componentsSeparatedByString:@":"] objectAtIndex:1] intValue];
    comp.hour=hour;
    comp.minute=min;
    comp.second=0;

    NSLog(@"设置当前时 分 秒 (%li:%li:%li)",(long)comp.hour,(long)comp.minute,(long)comp.second);
    NSLog(@"设置星期 :%i ",weekday);
    NSLog(@"当前星期 %li",(long)comp.weekday);
    NSInteger diff=(weekday-comp.weekday);
    NSLog(@"difference :%li",(long)diff);

    NSInteger multiplier;
    if (weekday==0) {
        multiplier=0;
    }else
    {
        multiplier=diff>0?diff:(diff==0?diff:diff+7);
    }

    NSLog(@"multiplier :%li",(long)multiplier);

    NSDate *now = [[calendar dateFromComponents:comp]dateByAddingTimeInterval:multiplier*24*60*60];

    //定义本地通知对象
    UILocalNotification *notification = [[[UILocalNotification alloc]init] autorelease];
    //设置时区
    notification.timeZone = [NSTimeZone defaultTimeZone];
    //设置调用时间 通知触发的时间
    notification.fireDate = now;
    NSLog(@"当前时间%@", notification.fireDate);
    //通知重复次数(每周循环)
    notification.repeatInterval = kCFCalendarUnitWeek;
    //循环当前日历
    //notification.repeatCalendar = [NSCalendar currentCalendar];
    //设置通知属性
    notification.alertBody=@"王位之争即将拉开序幕，点击前往！";
    //应用程序图标右上角显示的消息数
    notification.applicationIconBadgeNumber=1;
    //待机界面的滑动动作提示
    notification.alertAction=@"打开游戏";
    //通过点击通知打开应用时的启动图片,这里使用程序启动图片
    notification.alertLaunchImage=@"Default";
    //通知声音
    notification.soundName=@"msg.caf";

    //调用通知
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
}

void LocalNotificationHelp::removeNotification(){
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
}

void LocalNotificationHelp::createLocalNotificationConfig(){
    NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString *plistPath1 = [paths objectAtIndex:0];
    NSString *filename=[plistPath1 stringByAppendingPathComponent:@"systemConfig.plist"];

    NSFileManager *fileManager = [NSFileManager defaultManager];
    if(![fileManager fileExistsAtPath:filename]) //如果不存在
    {
        NSMutableDictionary *data = [NSMutableDictionary dictionaryWithObject:@"1" forKey:@"GameConfigPUSH"];
        [data writeToFile:filename atomically:YES];
        //NSMutableDictionary *data1 = [[NSMutableDictionary alloc] initWithContentsOfFile:filename];
        //NSLog(@"%@", data1);
    }
}

int LocalNotificationHelp::getLocalNotificationConfig(){
    int status = 0;
    NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString *plistPath1 = [paths objectAtIndex:0];
    NSString *filename=[plistPath1 stringByAppendingPathComponent:@"systemConfig.plist"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if([fileManager fileExistsAtPath:filename]){
        NSMutableDictionary *data = [[NSMutableDictionary alloc] initWithContentsOfFile:filename];
        status = [[data objectForKey:@"GameConfigPUSH"] intValue];

    }
    return status;
}

void LocalNotificationHelp::setLocalNotificationConfig(int status){
    NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString *plistPath1 = [paths objectAtIndex:0];
    NSString *filename=[plistPath1 stringByAppendingPathComponent:@"systemConfig.plist"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if([fileManager fileExistsAtPath:filename]){
        NSMutableDictionary *data = [[NSMutableDictionary alloc] initWithContentsOfFile:filename];
        [data setObject:[NSString stringWithFormat:@"%d",status] forKey:@"GameConfigPUSH"];
        [data writeToFile:filename atomically:YES];
    }
}


