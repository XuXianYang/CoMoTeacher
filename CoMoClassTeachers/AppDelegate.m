#import "AppDelegate.h"
#import "XXYGuideController.h"
#import "XXYTabBarController.h"
#import <UserNotifications/UserNotifications.h>
#import <RongIMKit/RongIMKit.h>
#import "BSHttpRequest.h"
#import"XXYClassGroupController.h"
#import "AFNetworking.h"
#import "XXYGroupChatController.h"
#import "XXYJoinSchoolController.h"
#import "XXYNavigationController.h"
#import"XXYNullViewController.h"
#import "XXYLoginController.h"
#import "XXYGroupChatController.h"
@interface AppDelegate ()<UNUserNotificationCenterDelegate,RCIMConnectionStatusDelegate,RCMessageContentView,JPUSHRegisterDelegate>
@end
@implementation AppDelegate
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // Required
    // notice: 3.0.0及以后版本注册可以这样写,也可以继续 旧的注册 式
    JPUSHRegisterEntity * entity = [[JPUSHRegisterEntity alloc] init];
    entity.types = JPAuthorizationOptionAlert|JPAuthorizationOptionBadge|JPAuthorizationOptionSound;
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
        // 可以添加 定义categories
        // NSSet<UNNotificationCategory *> *categories for iOS10 or later
        // NSSet<UIUserNotificationCategory *> *categories for iOS8 and iOS9
    }
    [JPUSHService registerForRemoteNotificationConfig:entity delegate:self];
    
    // NSString *advertisingId = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
    
    //如不需要使用IDFA，advertisingIdentifier 可为nil
    [JPUSHService setupWithOption:launchOptions appKey:appKey
                          channel:channel
                 apsForProduction:isProduction
            advertisingIdentifier:nil];
    
    //2.1.9版本新增获取registration id block接口。
    [JPUSHService registrationIDCompletionHandler:^(int resCode, NSString *registrationID) {
        if(resCode == 0){
             //NSLog(@"registrationID获取成功：%@",registrationID);
        }
        else{
             //NSLog(@"registrationID获取失败，code：%d",resCode);
        }
    }];
    
    CGFloat version = [[[UIDevice currentDevice] systemVersion] floatValue];
    if (version >= 10.0)
    {
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        [center requestAuthorizationWithOptions:UNAuthorizationOptionCarPlay | UNAuthorizationOptionSound | UNAuthorizationOptionBadge | UNAuthorizationOptionAlert completionHandler:^(BOOL granted, NSError * _Nullable error)
        {
            if (granted)
            {
                //NSLog(@" iOS 10 request notification success");
            }
            else
            {
                //NSLog(@" iOS 10 request notification fail");
            }
        }];
    }
    else if (version >= 8.0)
    {
        UIUserNotificationSettings *setting = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeSound | UIUserNotificationTypeBadge | UIUserNotificationTypeAlert categories:nil];
        [application registerUserNotificationSettings:setting];
    }
    else
    {
        UIRemoteNotificationType type = UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound;
        [application registerForRemoteNotificationTypes:type];
    }
    //注册通知
    [[UIApplication sharedApplication] registerForRemoteNotifications];
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    
    //开发: m7ua80gbuu8qm  生产:k51hidwq11irb
    [[RCIM sharedRCIM] initWithAppKey:@"k51hidwq11irb"];
    
    self.window=[[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor=[UIColor whiteColor];
    
    XXYTabBarController*tabbarCon=[[XXYTabBarController alloc]init];
    
    
    XXYNullViewController*nullCon=[[XXYNullViewController alloc]init];
    self.window.rootViewController=nullCon;
    [self.window makeKeyAndVisible];

    XXYGuideController*guideCon=[[XXYGuideController alloc]init];
    XXYNavigationController*navCon=[[XXYNavigationController alloc]initWithRootViewController:guideCon];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString*userSid=[defaults objectForKey:@"userSid"];
    if(userSid)
    {
            //网络监控句柄
            AFNetworkReachabilityManager *manager1 = [AFNetworkReachabilityManager sharedManager];
            //要监控网络连接状态，必须要先调用单例的startMonitoring方法
            [manager1 startMonitoring];
            [manager1 setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
                //status:
                //AFNetworkReachabilityStatusUnknown          = -1,  未知
                //AFNetworkReachabilityStatusNotReachable     = 0,   未连接
                //AFNetworkReachabilityStatusReachableViaWWAN = 1,   3G
                //AFNetworkReachabilityStatusReachableViaWiFi = 2,   无线连接
                if(status==AFNetworkReachabilityStatusNotReachable)
                {
                    self.window.rootViewController=tabbarCon;
                    [self.window makeKeyAndVisible];
                }
                else
                {
                    NSString*requestUrl=[NSString stringWithFormat:@"%@%@",BaseUrl,@"/user/info"];
                    [BSHttpRequest GET:requestUrl parameters:@{@"sid":userSid} success:^(id responseObject){
                        
                         //NSLog(@"145-Success: %@",[[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
                        id objString = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
                        if(objString[@"data"][@"teacherInfo"][@"schoolId"]&&objString[@"data"][@"teacherInfo"][@"schoolName"])
                        {
                            [self getUserToken];
                            self.window.rootViewController=tabbarCon;
                            [self.window makeKeyAndVisible];
                            
                        }
                        else
                        {
                            self.window.rootViewController=navCon;
                            [self.window makeKeyAndVisible];
                            
                        }
                    } failure:^(NSError *error) {
                        self.window.rootViewController=navCon;
                        [self.window makeKeyAndVisible];
                    }];
                }
            }];
    }
    else
    {
        self.window.rootViewController=navCon;
        [self.window makeKeyAndVisible];
    }
    
    [NSThread sleepForTimeInterval:1.5];//设置启动页面时间
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(didReceiveMessageNotification:)
     name:RCKitDispatchMessageNotification
     object:nil];
    
    [[RCIM sharedRCIM] setConnectionStatusDelegate:self];

    // 远程推送的内容
    NSDictionary *remoteNotificationUserInfo = launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey];
    
    if(remoteNotificationUserInfo)
    {
        NSLog(@"remoteNotificationUserInfo==%@",remoteNotificationUserInfo);
    }
    return YES;
}
-(void)connectRongYun:(NSString*)userToken
{
    
    [[RCIM sharedRCIM] connectWithToken:userToken success:^(NSString *userId) {
        NSLog(@"登陆成功。当前登录的用户ID：%@", userId);
        //设置用户信息提供者,页面展现的用户头像及昵称都会从此代理取
        //[self getImUserInfo:userId];
        // [[RCIM sharedRCIM] setUserInfoDataSource:self];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSDictionary*imUserInfo=[defaults objectForKey:@"ImUserInfo"];
        if(imUserInfo)
        {
            RCUserInfo *user = [[RCUserInfo alloc]init];
            user.userId =imUserInfo[@"imUserId"];
            NSLog(@"userId=%@",user.userId);
            user.name = imUserInfo[@"imUserName"];
            user.portraitUri = imUserInfo[@"avatarUrl"];
            
            [[RCIM sharedRCIM] setCurrentUserInfo:user];
            [[RCIM sharedRCIM] setEnableMessageAttachUserInfo:YES];
            [RCIM sharedRCIM].enablePersistentUserInfoCache=YES;
        }
    } error:^(RCConnectErrorCode status) {
        // NSLog(@"登陆的错误码为:%d", status);
    } tokenIncorrect:^{
        //token过期或者不正确。
        //如果设置了token有效期并且token过期，请重新请求您的服务器获取新的token
        //如果没有设置token有效期却提示token错误，请检查您客户端和服务器的appkey是否匹配，还有检查您获取token的流程。
        // NSLog(@"token错误");
    }];
}

-(void)getUserToken
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString*userSidString=[defaults objectForKey:@"userSid"];
    NSString*requestUrl=[NSString stringWithFormat:@"%@%@",BaseUrl,@"/im/user/token"];
    [BSHttpRequest GET:requestUrl parameters:@{@"sid":userSidString} success:^(id responseObject){
//         NSLog(@"token-Success: %@",[[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
        id objString = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        NSString*tokenString=objString[@"data"];
        //        46UxyNUBCDxF2ARDfh0+7m9ETwx4EMR982FgQVhcAWGA8+HSDvljnFo6z3Q/MwUiDQKX6NF25rUJI048mTmUHBJjjj4dkPfT+hdXU5IGdUfI5Htra1wwPLzP0mxS6M2uAuowLcvmA4s\u003
        if(!tokenString)
        {
            
        }
        else
        {
            [self connectRongYun:tokenString];
        }
        
    } failure:^(NSError *error) {
    }];
}
#pragma mark 注册推送的token
//获取token
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSString *token = [deviceToken description]; //获取
    token =  [token stringByReplacingOccurrencesOfString:@" " withString:@""];
    token =  [token stringByReplacingOccurrencesOfString:@"<" withString:@""];
    token =  [token stringByReplacingOccurrencesOfString:@">" withString:@""];
    [[RCIMClient sharedRCIMClient] setDeviceToken:token];
    [JPUSHService registerDeviceToken:deviceToken];
//    NSLog(@"request notificatoin token success. %@",token);
}

#ifdef NSFoundationVersionNumber_iOS_9_x_Max
#pragma mark- JPUSHRegisterDelegate
- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(NSInteger))completionHandler {
    NSDictionary * userInfo = notification.request.content.userInfo;
    UNNotificationRequest *request = notification.request; // 收到推送的请求
    UNNotificationContent *content = request.content; // 收到推送的消息内容
    NSNumber *badge = content.badge;  // 推送消息的角标
    NSString *body = content.body;    // 推送消息体
    UNNotificationSound *sound = content.sound;  // 推送消息的声音
    NSString *subtitle = content.subtitle;  // 推送消息的副标题
    NSString *title = content.title;  // 推送消息的标题
    
    if([notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        [JPUSHService handleRemoteNotification:userInfo];
        NSLog(@"iOS10 前台收到远程通知:%@", [self logDic:userInfo]);
        //  [rootViewController addNotificationCount];
    }
    else {
        // 判断为本地通知
        NSLog(@"iOS10 前台收到本地通知:{\nbody:%@，\ntitle:%@,\nsubtitle:%@,\nbadge：%@，\nsound：%@，\nuserInfo：%@\n}",body,title,subtitle,badge,sound,userInfo);
    }
    completionHandler(UNNotificationPresentationOptionBadge|UNNotificationPresentationOptionSound|UNNotificationPresentationOptionAlert); // 需要执行这个方法，选择是否提醒用户，有Badge、Sound、Alert三种类型可以设置
}

- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)())completionHandler {
    
    NSDictionary * userInfo = response.notification.request.content.userInfo;
    UNNotificationRequest *request = response.notification.request; // 收到推送的请求
    UNNotificationContent *content = request.content; // 收到推送的消息内容
    
//    NSNumber *badge = content.badge;  // 推送消息的角标
//    NSString *body = content.body;    // 推送消息体
//    UNNotificationSound *sound = content.sound;  // 推送消息的声音
//    NSString *subtitle = content.subtitle;  // 推送消息的副标题
    NSString *title = content.title;  // 推送消息的标题
    
    if([response.notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        [JPUSHService handleRemoteNotification:userInfo];
        NSLog(@"iOS10 收到远程通知:%@", [self logDic:userInfo]);
        //[rootViewController addNotificationCount];
    }
    else {
        // 判断为本地通知
       // NSLog(@"iOS10 收到本地通知:{\nbody:%@，\ntitle:%@,\nsubtitle:%@,\nbadge：%@，\nsound：%@，\nuserInfo：%@\n}",body,title,subtitle,badge,sound,userInfo);
        
        NSArray*array =[BSHttpRequest unarchiverObjectByKey:@"chatGroupList" WithPath:@"chatGroupList.plist"];
        NSDictionary*groupInfo=[NSDictionary dictionary];
        
        if(array)
        {
            for (NSDictionary*dict in array)
            {
                NSString*string=[XXYMyTools replaceUnicode:dict[@"name"]];
                
                if([[NSString stringWithFormat:@"%@",string] isEqual:[NSString stringWithFormat:@"%@",title]])
                {
                    groupInfo=dict;
                    break;
                }
            }
        }
        
        if(groupInfo)
        {
            XXYGroupChatController *chat = [[XXYGroupChatController alloc]init];
            chat.hidesBottomBarWhenPushed=YES;
            //设置会话的类型，如单聊、讨论组、群聊、聊天室、客服、公众服务会话等
            chat.conversationType = ConversationType_GROUP;
            //设置会话的目标会话ID。（单聊、客服、公众服务会话为对方的ID，讨论组、群聊、聊天室为会话的ID）
            chat.targetId =[NSString stringWithFormat:@"%@",groupInfo[@"imGroupId"]];
            //设置聊天会话界面要显示的标题
            chat.isPush=YES;
            chat.title = groupInfo[@"name"];
            UINavigationController *na = [[UINavigationController alloc] initWithRootViewController:chat];
            [self.window.rootViewController presentViewController:na animated:YES completion:nil];
        }
    }
    completionHandler();  // 系统要求执行这个方法
}
#endif

// log NSSet with UTF8
// if not ,log will be \Uxxx
- (NSString *)logDic:(NSDictionary *)dic {
    if (![dic count]) {
        return nil;
    }
    NSString *tempStr1 =
    [[dic description] stringByReplacingOccurrencesOfString:@"\\u"
                                                 withString:@"\\U"];
    NSString *tempStr2 =
    [tempStr1 stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    NSString *tempStr3 =
    [[@"\"" stringByAppendingString:tempStr2] stringByAppendingString:@"\""];
    NSData *tempData = [tempStr3 dataUsingEncoding:NSUTF8StringEncoding];
    NSString *str =
    [NSPropertyListSerialization propertyListFromData:tempData
                                     mutabilityOption:NSPropertyListImmutable
                                               format:NULL
                                     errorDescription:NULL];
    return str;
}


//注册失败
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
//    NSLog(@"request notification Token fail. %@",error.localizedDescription);
}
#pragma mark  iOS 10 获取推送信息 UNUserNotificationCenterDelegate
//APP在前台的时候收到推送的回调
- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler
{
    UNNotificationContent *content =  notification.request.content;
    NSDictionary *userInfo = content.userInfo;
    [self handleRemoteNotificationContent:userInfo];
    NSLog(@"APP在前台的时候收到推送的回调");
    //可以执行设置 弹窗 和 声音
    completionHandler(UNNotificationPresentationOptionAlert | UNNotificationPresentationOptionSound);
}
//APP在后台，点击推送信息，进入APP后执行的回调
- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)())completionHandler
{
    UNNotificationContent *content  = response.notification.request.content;
    NSDictionary *userInfo = content.userInfo;
    [self handleRemoteNotificationContent:userInfo];
   NSLog(@"APP在后台，点击推送信息，进入APP后执行的回调");
    completionHandler();
}
- (void)handleRemoteNotificationContent:(NSDictionary *)userInfo
{
   NSLog(@" iOS 10 after Notificatoin message:\n %@",userInfo);
}

#pragma mark iOS 10 之前 获取通知的信息
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    [JPUSHService handleRemoteNotification:userInfo];
//    NSLog(@"iOS 10 before Notification message。\n  %@",userInfo);
}
-(NSDictionary*)turnGroupIdToGroupName:(NSString*)groupId
{
//    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//    NSArray*array=[defaults objectForKey:@"ImGroupList"];
    NSArray*array =[BSHttpRequest unarchiverObjectByKey:@"chatGroupList" WithPath:@"chatGroupList.plist"];
    NSDictionary*groupInfo=[NSDictionary dictionary];
    if(array)
    {
        for (NSDictionary*dict in array)
        {
            if([dict[@"imGroupId"] isEqualToString:groupId])
            {
                groupInfo=dict;
                break ;
            }
        }
    }
    return groupInfo;
}
#pragma mark - UNUserNotificationCenterDelegate
//在展示通知前进行处理，即有机会在展示通知前再修改通知内容。
//-(void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler{
//    //1. 处理通知
//    
//    //2. 处理完成后条用 completionHandler ，用于指示在前台显示通知的形式
//    completionHandler(UNNotificationPresentationOptionAlert);
//}

//使用 UNNotification 本地通知
-(void)registerNotification:(NSInteger )alerTime userInfo:(NSDictionary*)userInfo title:(NSDictionary*)title body:(NSString*)body{
    // 使用 UNUserNotificationCenter 来管理通知
    UNUserNotificationCenter* center = [UNUserNotificationCenter currentNotificationCenter];
    //需创建一个包含待通知内容的 UNMutableNotificationContent 对象，注意不是 UNNotificationContent ,此对象为不可变对象。
    UNMutableNotificationContent* content = [[UNMutableNotificationContent alloc] init];
    content.title = [NSString localizedUserNotificationStringForKey:title[@"name"] arguments:nil];
    content.body = [NSString localizedUserNotificationStringForKey:body
                                                    arguments:nil];
    content.sound = [UNNotificationSound defaultSound];
    content.userInfo=userInfo;
    // 在 alertTime 后推送本地推送
    UNTimeIntervalNotificationTrigger* trigger = [UNTimeIntervalNotificationTrigger
                                                  triggerWithTimeInterval:alerTime repeats:NO];
    UNNotificationRequest* request = [UNNotificationRequest requestWithIdentifier:@"FiveSecond"
                                                                          content:content trigger:trigger];
    //添加推送成功后的处理！
    [center addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error)
     {         
//        if([self.window.rootViewController isKindOfClass:[XXYTabBarController class]])
//        {
//            ((XXYTabBarController*)self.window.rootViewController).selectedIndex=2;
//         }
    }];
}
/**
 *  网络状态变化。
 *
 *  @param status 网络状态。
 */
- (void)onRCIMConnectionStatusChanged:(RCConnectionStatus)status {
    
    if (status == ConnectionStatus_KICKED_OFFLINE_BY_OTHER_CLIENT) {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"提示"
                              message:@"您"
                              @"的帐号在别的设备上登录，您被迫下线！"
                              delegate:nil
                              cancelButtonTitle:@"知道了"
                              otherButtonTitles:nil, nil];
        [alert show];
        
        [self showWindowHome:@"loginOut"];
    }
}
- (void)application:(UIApplication *)application
didReceiveLocalNotification:(UILocalNotification *)notification {
    [JPUSHService showLocalNotificationAtFront:notification identifierKey:nil];
}
- (void)didReceiveMessageNotification:(NSNotification *)notification {
    
    RCMessage*message=notification.object;
    NSDictionary*groupInfo=[self turnGroupIdToGroupName:message.targetId];
    NSString*messageType=message.objectName;
    //TxtMsg  ImgMsg  VcMsg
    NSString*content;
    if([messageType isEqualToString:@"RC:TxtMsg"])
    {
        content=[message.content conversationDigest];
    }
    else
    {
        content=@"来消息了";
    }
    NSString*body=[NSString stringWithFormat:@"%@:%@",message.content.senderUserInfo.name,content];
    if(message.content.senderUserInfo.name)
    [self registerNotification:1 userInfo:@{@"name":message.content.senderUserInfo.name} title:groupInfo body:body];
    [UIApplication sharedApplication].applicationIconBadgeNumber =
    [UIApplication sharedApplication].applicationIconBadgeNumber + 1;
}

-(void)setUpLogOutAppAlert
{
    UIAlertController*alertCon = [UIAlertController alertControllerWithTitle:@"提示" message:@"账号信息已经过期,请重新登录" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [self showWindowHome:@"loginOut"];
    }];
    [action2 setValue:[UIColor colorWithRed:10.0/255 green:188.0/255 blue:180.0/255 alpha:1] forKey:@"titleTextColor"];
    [alertCon addAction:action2];
    [self.window.rootViewController presentViewController:alertCon animated:YES completion:nil];
}

//退出app
-(void)showWindowHome:(NSString *)windowType{
    if([windowType isEqualToString:@"loginOut"])
    {
        //XXYGuideController *loginVC = [[XXYGuideController alloc] init];
        XXYLoginController *loginVC = [[XXYLoginController alloc] init];
        loginVC.index=1;
        XXYNavigationController*navCon = [[XXYNavigationController alloc] initWithRootViewController:loginVC];
        self.window.rootViewController = navCon;
        [self.window makeKeyAndVisible];
        
        //断开融云
        [[RCIM sharedRCIM]disconnect:YES];
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString*userSidString=[defaults objectForKey:@"userSid"];
        
        NSString*requestUrl=[NSString stringWithFormat:@"%@%@",BaseUrl,@"/user/loginOut"];
        //通知服务器消除sid
        if(userSidString)
        {
            [BSHttpRequest GET:requestUrl parameters:@{@"sid":userSidString} success:^(id responseObject){
//                NSLog(@"成功");
            } failure:^(NSError *error) {}];
        }
        //删除缓存
        [defaults removeObjectForKey:@"firstClassInfo"];
        [defaults removeObjectForKey:@"userToken"];
        [defaults removeObjectForKey:@"userSid"];
        [defaults removeObjectForKey:@"ImUserInfo"];
        [defaults removeObjectForKey:@"teacherClassList"];//aliasString
        [defaults removeObjectForKey:@"aliasString"];
        [defaults removeObjectForKey:@"courseIdOfClass"];
        [defaults removeObjectForKey:@"teacherAllCourse"];
        
    }
    if([windowType isEqualToString:@"login"])
    {
        XXYTabBarController*tabbarCon=[[XXYTabBarController alloc]init];
        self.window.rootViewController = tabbarCon;
        [self.window makeKeyAndVisible];
    }
}
- (void)applicationWillResignActive:(UIApplication *)application {
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}
- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}
- (void)applicationWillEnterForeground:(UIApplication *)application {
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}
- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}
- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}
#pragma mark - Core Data stack
@synthesize persistentContainer = _persistentContainer;
- (NSPersistentContainer *)persistentContainer {
    // The persistent container for the application. This implementation creates and returns a container, having loaded the store for the application to it.
    @synchronized (self) {
        if (_persistentContainer == nil) {
            _persistentContainer = [[NSPersistentContainer alloc] initWithName:@"CoMoClassTeachers"];
            [_persistentContainer loadPersistentStoresWithCompletionHandler:^(NSPersistentStoreDescription *storeDescription, NSError *error) {
                if (error != nil) {
                    // Replace this implementation with code to handle the error appropriately.
                    // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    
                    /*
                     Typical reasons for an error here include:
                     * The parent directory does not exist, cannot be created, or disallows writing.
                     * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                     * The device is out of space.
                     * The store could not be migrated to the current model version.
                     Check the error message to determine what the actual problem was.
                    */
                    NSLog(@"Unresolved error %@, %@", error, error.userInfo);
                    abort();
                }
            }];
        }
    }
    
    return _persistentContainer;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *context = self.persistentContainer.viewContext;
    NSError *error = nil;
    if ([context hasChanges] && ![context save:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, error.userInfo);
        abort();
    }
}

@end
