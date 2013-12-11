//
//  AppDelegate.h
//  AMJIOS
//
// Copyright (c) 2013 Hubino  All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString *const FCwFSessionStateChangedNotification;

@class ViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
    NSString *concatName;
    NSString *currentElementValue;
    NSString *registerationStatus;
    NSString *userId;
}

@property (strong, nonatomic) NSString *concatName;
@property (nonatomic, retain) NSString *currentElementValue;
@property (nonatomic, retain) NSString *registerationStatus;
@property (nonatomic, retain) NSString *userId;
@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) ViewController *viewController;
@property (nonatomic, readwrite) BOOL isPurchasedAdFree;
@property (strong, nonatomic) UINavigationController *navigationController;




-(void) FetchUserFriendList;

-(void)saveDeviceTokenToUserDefaults:(NSString *)myString;
-(NSString *)retrieveDeviceTokenFromUserDefaults;

@end
