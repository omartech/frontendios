//
//  AppDelegate.m
//  AMJIOS
//
// Copyright (c) 2013 Hubino  All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import "AppDelegate.h"

AppDelegate *AppDel;
NSString *const FCwFSessionStateChangedNotification = @"com.facebook.FCwF:SCSessionStateChangedNotification";

NSString *kWEBSERVICE_SOAP_HEADER = @"<soap:envelope>";

NSString *kWEBSERVICE_SOAP_BODY = @"<soapenv:Body>";

@interface AppDelegate ()

- (void)showLoginView;

@end

@implementation AppDelegate
@synthesize isPurchasedAdFree;
@synthesize navigationController,concatName,userId,registerationStatus,currentElementValue;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    AppDel = (AppDelegate *)[[UIApplication sharedApplication] delegate];

    // register For Remote Notification (PUSH NOTIFICATION)
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    
    // instead of call WS in a day, we will call every time when app run.
    // NSDate *now = [NSDate date];
    // NSDate *yesterday = [now dateByAddingTimeInterval:-86400];
    //  if ([yesterday compare:[[DataManager sharedManager] lastSyncTime]] == NSOrderedDescending) {
    
    
//    NSLog(@"%@",[[UIFont fontNamesForFamilyName:@"helvetica"] description]);
    //initialize DB and WS classes
//    self.objDB = [[[DBFile alloc] init] autorelease];    
    
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    // Override point for customization after application launch.
    self.viewController = [[[ViewController alloc] initWithNibName:IS_IPHONE_5?@"ViewController":@"ViewController_old" bundle:nil] autorelease];
    self.navigationController =[[[UINavigationController alloc] initWithRootViewController: self.viewController] autorelease];
    self.window.rootViewController = self.navigationController;
    [self.window makeKeyAndVisible];
    self.navigationController.navigationBarHidden = TRUE;
    // FBSample logic
    // See if we have a valid token for the current state.

    /*
     Appirator
     */
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    /*
     Appirator
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.

}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.


}


- (void)createAndPresentLoginView {
  
}

- (void)showLoginView
{
 
}

#pragma mark Notifaction Method
- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)devToken
{
	
    NSString *deviceToken = [[[devToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]] stringByReplacingOccurrencesOfString:@" " withString:@""];
	[self saveDeviceTokenToUserDefaults:deviceToken];
	
}
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
	
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
	[[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
	
    
}
#pragma -
#pragma mark - Device Token
-(void)saveDeviceTokenToUserDefaults:(NSString *)myString
{
	NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
	
	if (standardUserDefaults) {
		[standardUserDefaults setObject:myString forKey:@"ZZZ_DeviceToken_ZZZ"];
		[standardUserDefaults synchronize];
	}
}
//retrieveFromUserDefaults is used to retrive date from memory

-(NSString *)retrieveDeviceTokenFromUserDefaults
{
	NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
	NSString *val = @"";
	
	if (standardUserDefaults)
		val = [standardUserDefaults objectForKey:@"ZZZ_DeviceToken_ZZZ"];
	return val;
}


@end
