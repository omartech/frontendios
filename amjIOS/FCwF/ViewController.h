//
//  ViewController.h
//  AMJIOS
//
// Copyright (c) 2013 Hubino  All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OverlayViewController.h"


@interface ViewController : UIViewController <OverlayViewControllerDelegate>
@property (nonatomic,strong) OverlayViewController *overlayViewController;

-(IBAction)InfoButtonClick:(id)sender;
-(IBAction)FaceLibraryButtonClick:(id)sender;
-(IBAction)ChallengeFriendsButtonClick:(id)sender;
-(IBAction)CompareFriendsButtonClick:(id)sender;
-(IBAction)PhotoButtonClick:(id)sender;


#pragma mark -
@property (nonatomic,strong) IBOutlet UIView *animationView;
@property (nonatomic,strong) IBOutlet UIView *male_femaleView;
@property (nonatomic,strong) IBOutlet UIView *camera_libiew;

@property (nonatomic,retain) NSString *currentElementValue;
@property (nonatomic,retain) NSString *status;

@property (nonatomic,retain) NSString *imageName;
@property (nonatomic,retain) NSString *imagePath;
@property (nonatomic,retain) NSString *resultPer;

@property (nonatomic,retain) NSString *challengeImageName;
@property (nonatomic,retain) NSString *challengeImagePath;

@property (nonatomic,strong) IBOutlet UIButton *authuButt;
@property (nonatomic,strong) IBOutlet UIButton *enRolButt;

-(IBAction)AnimationClick:(int)type;
-(IBAction)CloseAniamtionScreen:(id)sender;
-(IBAction)male_femaleClick:(id)sender;
-(IBAction)camera_libClick:(id)sender;

@property (nonatomic,retain) IBOutlet UITextField *userId;
@end
