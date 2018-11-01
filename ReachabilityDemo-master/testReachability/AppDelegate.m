//
//  AppDelegate.m
//  testReachability
//
//  Created by GrandSu on 2018/8/7.
//  Copyright © 2018年 GrandSu. All rights reserved.
//

#import "AppDelegate.h"
#import "Reachability.h"
#import "AFNetworking.h"


@interface AppDelegate ()
@property (nonatomic, strong) Reachability *hostReachability;
@property (nonatomic, strong) Reachability *interNetReachability;

@property(nonatomic,strong)NSString *  offLine;

@end

@implementation AppDelegate

/** 程序启动器，启动网络监视 */
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    // 监听苹果官方 Reachability
    [self listenNetWorkReachabilityStatus];
    
//    // 监听
//    [self listenAFNetworkReachabilityStatus];
    
    return YES;
}

#pragma mark - 苹果官方 Reachability
/** 初始化并监听网络变化 */
- (void)listenNetWorkReachabilityStatus {
    
    // KVO监听，监听kReachabilityChangedNotification的变化
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    
    // 初始化 Reachability 当前网络环境
    self.interNetReachability = [Reachability reachabilityForInternetConnection];
    // 开始监听
    [self.interNetReachability startNotifier];
    
    
//    /** 或者你也可以监听某一个站点的网络连接情况 */
//    NSString *remoteHostName = @"www.apple.com";
//    self.hostReachability = [Reachability reachabilityWithHostName:remoteHostName];
//    [self.hostReachability startNotifier];
}

/** 网络环境改变时实现的方法 */
- (void) reachabilityChanged:(NSNotification *)note {
    
    // 当前发送通知的 reachability
    Reachability *reachability = [note object];
    
    // 当前网络环境
    NetworkStatus netStatus = [reachability currentReachabilityStatus];
    
    // 断言 如果出错则发送错误信息
    NSParameterAssert([reachability isKindOfClass:[Reachability class]]);
    
    // 不同网络的处理方法
    switch (netStatus) {
        case NotReachable:
            NSLog(@"没有网络连接");
            self.offLine = @"没有网络连接";
            break;
            
        case ReachableViaWiFi:
            NSLog(@"已连接Wi-Fi");
            self.offLine = @"已连接Wi-Fi";
            break;
            
        case ReachableViaWWAN:
            NSLog(@"已连接蜂窝网络");
            self.offLine = @"已连接蜂窝网络";
            break;
            
        default:
            
            break;
    }
    NSDictionary * dic = @{@"offline" : self.offLine};
    [[NSNotificationCenter defaultCenter]postNotification:[NSNotification notificationWithName:@"offline" object:nil userInfo:dic]];
}

/**  移除监听，防止内存泄露 */
- (void)dealloc {
    
    // Reachability停止监听网络， 苹果官方文档上没有实现，所以不一定要实现该方法
    [self.hostReachability stopNotifier];
    
    // 移除Reachability的NSNotificationCenter监听
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
}


- (void)listenAFNetworkReachabilityStatus {
    
    // 实例化 AFNetworkReachabilityManager
    AFNetworkReachabilityManager * afManager = [AFNetworkReachabilityManager sharedManager];
    
    
    /**
     判断网络状态并处理
     @param status 网络状态
     AFNetworkReachabilityStatusUnknown             = 未知网络
     AFNetworkReachabilityStatusNotReachable        = 没有网络
     AFNetworkReachabilityStatusReachableViaWWAN    = 蜂窝网络（3g、4g、wwan）
     AFNetworkReachabilityStatusReachableViaWiFi    = wifi网络
     */
    [afManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        switch (status) {
            case AFNetworkReachabilityStatusUnknown:
                NSLog(@"当前网络状态未知");
                break;
                
            case AFNetworkReachabilityStatusNotReachable:
                NSLog(@"网络已断开");
                break;
                
            default:
                NSLog(@"网络已连接");
                break;
        }
    }];
    
    // 开始监听
    [afManager startMonitoring];
}

//判断是否有网
-(BOOL)isConnectionAvailable {
    
    //创建零地址，0.0.0.0的地址表示查询本机的网络连接状态
    
    struct sockaddr_storage zeroAddress;
    
    bzero(&zeroAddress, sizeof(zeroAddress));
    zeroAddress.ss_len = sizeof(zeroAddress);
    zeroAddress.ss_family = AF_INET;
    
    // Recover reachability flags
    SCNetworkReachabilityRef defaultRouteReachability = SCNetworkReachabilityCreateWithAddress(NULL, (struct sockaddr *)&zeroAddress);
    SCNetworkReachabilityFlags flags;
    
    //获得连接的标志
    BOOL didRetrieveFlags = SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags);
    CFRelease(defaultRouteReachability);
    
    //如果不能获取连接标志，则不能连接网络，直接返回
    if (!didRetrieveFlags)
    {
        return NO;
    }
    //根据获得的连接标志进行判断
    
    BOOL isReachable = flags & kSCNetworkFlagsReachable;
    BOOL needsConnection = flags & kSCNetworkFlagsConnectionRequired;
    return (isReachable&&!needsConnection) ? YES : NO;
}



- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
