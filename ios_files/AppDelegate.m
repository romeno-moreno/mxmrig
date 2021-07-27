#import "AppDelegate.h"
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "LoggerBridge.h"
#import <AVFoundation/AVFoundation.h>
#import <xmrig-Swift.h>

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    UIApplication.sharedApplication.idleTimerDisabled = true;
    application.statusBarStyle = UIStatusBarStyleLightContent;
    return YES;
}

@end
