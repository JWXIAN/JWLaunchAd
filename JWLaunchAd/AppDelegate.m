//
//  AppDelegate.m
//  JWLaunchAd
//
//  Created by GJW on 16/7/8.
//  Copyright © 2016年 JW. All rights reserved.
//

#import "AppDelegate.h"
#import "JWLaunchAd.h"
#import "ViewController.h"

#define kScreen_Bounds  [UIScreen mainScreen].bounds
#define kScreen_Height  [UIScreen mainScreen].bounds.size.height
#define kScreen_Width   [UIScreen mainScreen].bounds.size.width

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    //  设置RootViewController
    ViewController *view = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"ViewController"];
    self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:view];
    //  清理缓存
    //  [JWLaunchAd clearDiskCache];
    
    //  1.设置启动页广告图片的url
    NSString *imgUrlString =@"http://imgstore.cdn.sogou.com/app/a/100540002/714860.jpg";
    //  GIF
    //  NSString *imgUrlString = @"http://img1.imgtn.bdimg.com/it/u=473895314,616407725&fm=206&gp=0.jpg";
    
    //  2.初始化启动页广告
    [JWLaunchAd initImageWithAttribute:6.0 showSkipType:SkipShowTypeAnimation setLaunchAd:^(JWLaunchAd *launchAd) {
        __block JWLaunchAd *weakSelf = launchAd;
        
        //如果选择 SkipShowTypeAnimation 需要设置动画跳过按钮的属性
        [weakSelf setAnimationSkipWithAttribute:[UIColor redColor] lineWidth:3.0 backgroundColor:nil textColor:nil];
        
        
        [launchAd setWebImageWithURL:imgUrlString options:JWWebImageDefault result:^(UIImage *image, NSURL *url) {
            
            //  3.异步加载图片完成回调(设置图片尺寸)
            weakSelf.launchAdViewFrame = CGRectMake(0, 0, kScreen_Width, kScreen_Height-100);
        } adClickBlock:^{
            
            //  4.点击广告回调
            NSString *url = @"https://www.baidu.com";
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
        }];
    }];
    
    //设置window 根控制器
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
