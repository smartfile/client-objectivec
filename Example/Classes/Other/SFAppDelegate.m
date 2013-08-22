#import "SFClient.h"
#import "SFAppDelegate.h"
#import "SFUIAuthViewController.h"
#import "SFUINavigationViewController.h"

@implementation SFAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    NSAssert([SM_API_URL length], @"Api url can not be nil or empty!");
    NSAssert([SM_API_VERSION length], @"Api version can not be nil or empty!");
    
    SFUIAuthViewController *authController = [[SFUIAuthViewController alloc] init];
    self.navContoller = [[SFUINavigationViewController alloc] initWithRootViewController:authController];

    [self.navContoller setNavigationBarHidden:YES];
    [self.navContoller setNavigationBarHidden:YES];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = self.navContoller;
    
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    
}

- (void)applicationDidEnterBackground:(UIApplication *)application{
    
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    
}

- (void)applicationWillTerminate:(UIApplication *)application {
    
}

+ (SFAppDelegate *)sharedDelegate {
    return (SFAppDelegate *)[UIApplication sharedApplication].delegate;
}

@end
