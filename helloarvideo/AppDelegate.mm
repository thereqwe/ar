/**
* Copyright (c) 2015-2016 VisionStar Information Technology (Shanghai) Co., Ltd. All Rights Reserved.
* EasyAR is the registered trademark or trademark of VisionStar Information Technology (Shanghai) Co., Ltd in China
* and other countries for the augmented reality technology developed by VisionStar Information Technology (Shanghai) Co., Ltd.
*/

#import "AppDelegate.h"
#include "easyar/utility.hpp"
#import "ViewController.h"
#import "userTakePhotoViewController.h"
#import "uploadPhotoViewController.h"
@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    (void)application;
    (void)launchOptions;
    _active = true;
    
    /****************/
    UIWindow *window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    window.backgroundColor = [UIColor whiteColor];
    self.window = window;
    
    UINavigationController *left_navi = [UINavigationController new];
    ViewController *vc = [ViewController new];
    vc.title = @"扫扫周围";
    [left_navi pushViewController:vc animated:YES];
  
    UINavigationController *right_navi = [UINavigationController new];
    userTakePhotoViewController *vc2 = [userTakePhotoViewController new];
    vc2.title = @"上传图片";
    [right_navi pushViewController:vc2 animated:YES];
    
    UINavigationController *middle_navi = [UINavigationController new];
    uploadPhotoViewController *vc3 = [uploadPhotoViewController new];
    vc3.title = @"数据录入";
    [middle_navi pushViewController:vc3 animated:YES];
    
    UITabBarController *tabVc = [[UITabBarController alloc]init];
    tabVc.viewControllers =  @[right_navi,left_navi,middle_navi];
    window.rootViewController = tabVc;
    [window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    (void)application;
    _active = false;
    EasyAR::onPause();
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    (void)application;
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    (void)application;
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    (void)application;
    _active = true;
    EasyAR::onResume();
}

- (void)applicationWillTerminate:(UIApplication *)application {
    (void)application;
    _active = false;
}

@end
