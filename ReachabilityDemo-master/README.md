### 一、前言
在做项目的过程中常常需要对用户设备的网络状态进行实时监听，判断用户是以哪种上网方式，有两个目的：
 （1）让用户了解自己的网络状态，防止一些误会（比如怪应用无能）
 （2）根据用户的网络状态进行智能处理，节省用户流量，提高用户体验 
　　WIFI网络：自动下载高清图片 
　　4G/3G网络：只下载缩略图 
　　没有网络：只显示离线的缓存数据 

常用的方法有以下两种
* 使用苹果官方提供的专门检测iOS设备网络环境的库 Reachability
* 使用AFNetworking库中的AFNetworkReachabilityManager来进行iOS设备的网络环境监听

### 二、使用

##### 1、Reachability
* 使用之前请从Apple网站下载示例：[Reachability](https://developer.apple.com/library/archive/samplecode/Reachability/Reachability.zip)
* **Reachability** 中定义了3种网络状态: 
```
typedef enum : NSInteger {
    NotReachable = 0,  //无网络连接
    ReachableViaWiFi,  //使用 WiFi 网络
    ReachableViaWWAN   //使用移动数据网络
} NetworkStatus;
```
* 将 **Reachability.h** 和 **Reachability.m** 导入到你的项目中

* 在你要检测的**ViewController**中添加头文件 或者 直接添加在**AppDelegate**中
```
#import "Reachability.h"
```

* 我们可以在程序启动以后启动实时监测 AppDelegate
```
//  AppDelegate.m
//  testReachability
//
//  Created by GrandSu on 2018/8/7.
//  Copyright © 2018年 GrandSu. All rights reserved.
//

#import "AppDelegate.h"
#import "Reachability.h"

@interface AppDelegate ()
@property (nonatomic, strong) Reachability *hostReachability;
@property (nonatomic, strong) Reachability *interNetReachability;

@end

@implementation AppDelegate

/** 程序启动器，启动网络环境监听 */
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [self listenNetWorkStatus];
    
    return YES;
}

/** 初始化并监听网络变化 */
- (void)listenNetWorkStatus {
    
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
    
    // 当前网络环境（在其它需要获取网络连接状态的地方调用 currentReachabilityStatus 方法）
    NetworkStatus netStatus = [reachability currentReachabilityStatus];
    
    // 断言 如果出错则发送错误信息
    NSParameterAssert([reachability isKindOfClass:[Reachability class]]);
    
    // 不同网络的处理方法
    switch (netStatus) {
        case NotReachable:
            NSLog(@"没有网络连接");
            break;
            
        case ReachableViaWiFi:
            NSLog(@"已连接Wi-Fi");
            break;
            
        case ReachableViaWWAN:
            NSLog(@"已连接蜂窝网络");
            break;
            
        default:
            
            break;
    }
}

/**  移除监听，防止内存泄露 */
- (void)dealloc {
    
    // Reachability停止监听网络， 苹果官方文档上没有实现，所以不一定要实现该方法
    [self.hostReachability stopNotifier];
    
    // 移除Reachability的NSNotificationCenter监听
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
}
```

##### 2、AFNetworkReachabilityManager
* 导入第三方库AFNetworking
* 在你要检测的ViewController中添加头文件 或者 直接添加在AppDelegate中
```
#import "AFNetworking.h"
```
* 一般我们可以在程序启动以后启动实时监测 AppDelegate
```
//  AppDelegate.m
//  WebView
//
//  Created by GrandSu on 2018/8/1.
//  Copyright © 2018年 GrandSu. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    // 监听网络状态
    [self listenNetworkReachabilityStatus];

    return YES;
}

- (void)listenNetworkReachabilityStatus {
    
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
```

##### 3、RealReachability
听说还有一个封装苹果官方 Reachability 的库 RealReachability，由于还没用过，所以就不再这边示例了，发一下该库的GitHub地址  [RealReachability](https://github.com/dustturtle/RealReachability.git)

参考demo：[实时监控网络状态的改变Reachability](https://github.com/GrandSu/ReachabilityDemo.git)
