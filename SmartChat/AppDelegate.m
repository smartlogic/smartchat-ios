#import "AppDelegate.h"

#import <TestFlightSDK/TestFlight.h>

#import "CameraViewController.h"
#import "Credentials.h"
#import "HTTPClient.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [TestFlight takeOff:@"0f35592b-343e-46c9-9d56-41b308fe2792"];

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    Credentials *credentials = [[Credentials alloc] initWithUserDefaults:defaults];
    HTTPClient *client = [[HTTPClient alloc] initWithBaseURL:[NSURL URLWithString:@"http://roberto.local:9000/"] credentials:credentials];

    CameraViewController *captureViewController = [[CameraViewController alloc] initWithHTTPClient:client];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:captureViewController];
    navigationController.navigationBarHidden = YES;

    self.window.rootViewController = navigationController;
    [self.window makeKeyAndVisible];

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive
    // state.  This can occur for certain types of temporary interruptions
    // (such as an incoming phone call or SMS message) or when the user quits
    // the application and it begins the transition to the background state.
    //
    // Use this method to pause ongoing tasks, disable timers, and throttle
    // down OpenGL ES frame rates. Games should use this method to pause the
    // game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate
    // timers, and store enough application state information to restore your
    // application to its current state in case it is terminated later. 
    //
    // If your application supports background execution, this method is called
    // instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive
    // state; here you can undo many of the changes made on entering the
    // background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the
    // application was inactive. If the application was previously in the
    // background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if
    // appropriate. See also applicationDidEnterBackground:.
}

@end
