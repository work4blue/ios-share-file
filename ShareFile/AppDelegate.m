//
//  AppDelegate.m
//  ShareFile
//
//  Created by PRO on 19/6/18.
//  Copyright © 2018年 bluedrum. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    return YES;
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

- (UIViewController *)visibleViewController:(UIApplication *) application{
    UIViewController *rootViewController = application.keyWindow.rootViewController;
    return [AppDelegate getVisibleViewControllerFrom:rootViewController];
}

+ (UIViewController *) getVisibleViewControllerFrom:(UIViewController *) vc {
    if ([vc isKindOfClass:[UINavigationController class]]) {
        return [AppDelegate getVisibleViewControllerFrom:[((UINavigationController *) vc) visibleViewController]];
    } else if ([vc isKindOfClass:[UITabBarController class]]) {
        return [AppDelegate getVisibleViewControllerFrom:[((UITabBarController *) vc) selectedViewController]];
    } else {
        if (vc.presentedViewController) {
            return [AppDelegate getVisibleViewControllerFrom:vc.presentedViewController];
        } else {
            return vc;
        }
    }
}

#if __IPHONE_OS_VERSION_MAX_ALLOWED >=__IPHONE_9_0

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url options:(nonnull NSDictionary<NSString *,id> *)options
{
    
    
    
    
    
    NSString * urlPath = [url absoluteString];
    
    NSString * fileName = [urlPath lastPathComponent];
    
    
    NSString *fileExtension = [[fileName pathExtension] lowercaseString];
    
    //file:///private/var/mobile/Containers/Data/Application/0EB380E2-C7AF-4D0C-B396-8426E2C6E9D2/Documents/Inbox/haibo_bitmap-2.tscbas
    
//    //根据后缀名执行不同操作
//    if([fileExtension isEqualToString:@"tscbas"])
//        [ PrinterManager sharedInstance].scriptCmdSet = PrinterCmdTSC;
//    else if([fileExtension isEqualToString:@"cpclbas"])
//        [ PrinterManager sharedInstance].scriptCmdSet = PrinterCmdCPCL;
    
    //取得分享内容
    NSData * data = [NSData dataWithContentsOfURL:url];
    
    NSLog(@"printScript %ld",[data length]);
    
     NSString * strData  =[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    //[UIApplication sharedApplication].keyWindow或者[[[UIApplication sharedApplication] delegate] window]
    
    
    ViewController * vc =  (ViewController *)[self visibleViewController:application];
    
    if(vc != nil)
        vc.textView.text = strData ;
    
                      
                          return YES;
    }
#endif


@end
