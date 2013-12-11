//
//  ViewController.m
//  AMJIOS
//
// Copyright (c) 2013 Hubino  All rights reserved.
//

#import "ViewController.h"
#import "CaptureViewController.h"
#import "EnrollIntroViewController.h"
#import "AuthenIntroViewController.h"

#import "OmerPHP.h"


NSString *kWEBSERVICE_SOAP_HEADER_UPDATE_INVITE = @"<soap:envelope>";

NSString *kWEBSERVICE_SOAP_BODY_UPDATE_INVITE = @"<soapenv:Body>";

@interface ViewController ()
-(void) MoveToOtherEvents:(BOOL)isCompareOrInvite; //TRUE = Compare, FALSE = Invite
@end

@implementation ViewController
@synthesize animationView;
@synthesize camera_libiew,male_femaleView;
@synthesize overlayViewController,status,currentElementValue;
@synthesize userId;
@synthesize enRolButt;
@synthesize authuButt;

NSString *thresholdValue=NULL;
NSString *cameraDistanceValue =NULL;
NSString *eyeDistanceValue =NULL;
NSString *enrollImageTotCount =NULL;
NSString *authenImageTotCount =NULL;



- (void)viewDidLoad
{
    [super viewDidLoad];
    self.overlayViewController = [[[OverlayViewController alloc] initWithNibName:@"OverlayViewController" bundle:nil] autorelease];
    self.overlayViewController.delegate = self;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
   [defaults setObject:NULL forKey:@"imageTotCount"];
    
    [defaults synchronize];
enRolButt.hidden=YES;
    authuButt.hidden=YES;

    OmerPHP* service = [OmerPHP service];
	service.logging = YES;
    
    [service getGlobalValues:self action:@selector(getGlobalValuesHandler:)];
    
}

#pragma mark -


-(IBAction)PhotoButtonClick:(id)sender
{
    
    EnrollIntroViewController *obj = [[[EnrollIntroViewController alloc] initWithNibName:@"EnrollIntroViewController" bundle:nil]autorelease];
    [self.navigationController pushViewController:obj animated:TRUE];
    obj = nil;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:@"enroll" forKey:@"typeSelect"];
    [defaults setInteger:[userId.text intValue] forKey:@"userId"];
   // [defaults setObject:enrollImageTotCount forKey:@"imageTotWebCount"];

    [defaults synchronize];
    
}

-(IBAction)AuthendicationPhotoButtonClick:(id)sender
{
    
    AuthenIntroViewController *obj = [[[AuthenIntroViewController alloc] initWithNibName:@"AuthenIntroViewController" bundle:nil]autorelease];
    [self.navigationController pushViewController:obj animated:TRUE];
    obj = nil;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:@"authen" forKey:@"typeSelect"];
    [defaults setInteger:[userId.text intValue] forKey:@"userId"];
    //[defaults setObject:authenImageTotCount forKey:@"imageTotWebCount"];

    [defaults synchronize];
}


-(IBAction)AnimationClick:(int)type
{
    if(type == 0)
    {
        male_femaleView.hidden = TRUE;
        camera_libiew.hidden = FALSE;
    }
    else  if(type == 1)
    {
        male_femaleView.hidden = FALSE;
        camera_libiew.hidden = TRUE;
    }
    animationView.hidden = FALSE;
    [self.view bringSubviewToFront:animationView];
    animationView.transform = CGAffineTransformMakeScale(0, 0);
    [UIView transitionWithView:[self view]
                      duration:0.3f
                       options:UIViewAnimationOptionCurveEaseInOut
                    animations:^{
                        animationView.transform = CGAffineTransformMakeScale(1, 1);
                    }
                    completion:^(BOOL finished){
                        animationView.transform = CGAffineTransformIdentity;
                        
                    }
     ];
}

// Handle the response from getGlobalValues.

- (void) getGlobalValuesHandler: (id) value {
    
	// Handle errors
	if([value isKindOfClass:[NSError class]]) {
		NSLog(@"%@", value);
		return;
	}
    
	// Handle faults
	if([value isKindOfClass:[SoapFault class]]) {
		NSLog(@"%@", value);
		return;
	}
    
    
	// Do something with the GlobalResponse* result
    GlobalResponse* result = (GlobalResponse*)value;
	enrollImageTotCount= result.enrollImageCount;
    authenImageTotCount= result.authImageCount;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:enrollImageTotCount forKey:@"imageToEnrollCount"];
    [defaults setObject:result.authImageCount forKey:@"imageToAuthenCount"];
    [defaults setObject:result.cameraDistanceValue forKey:@"cameraDistanceValue"];
    [defaults synchronize];
    enRolButt.hidden=NO;
    authuButt.hidden=NO;
    
    NSLog(@"getGlobalValues returned the value: %@", result);
    
}



-(IBAction)CloseAniamtionScreen:(id)sender
{
    [UIView transitionWithView:[self view]
                      duration:0.3f
                       options:UIViewAnimationOptionCurveEaseInOut
                    animations:^{
                        animationView.transform = CGAffineTransformMakeScale(0, 0);
                    }
                    completion:^(BOOL finished){
                        animationView.transform = CGAffineTransformIdentity;
                        animationView.hidden = TRUE;
                    }
     ];
}

-(IBAction)male_femaleClick:(id)sender
{
    switch ([sender tag]) {
        case 0: //Male
            //            NSLog(@"Male");
            break;
        case 1: //Female
            //            NSLog(@"FeMale");
            break;
        default:
            break;
    }
    [self CloseAniamtionScreen:nil];
    
	//Stay Here until Animation Close.
	NSRunLoop *rl = [NSRunLoop currentRunLoop];
	NSDate *d;
    while (!animationView.hidden) {
        d = [NSDate date];
        [rl runUntilDate:d];
    }
	//
    [self AnimationClick:0]; // For Camera/Library
}

-(IBAction)camera_libClick:(id)sender
{
    switch ([sender tag]) {
        case 0: //Camera
            
            //            NSLog(@"Camera");
            [self showVideo];
            
            break;
        case 1: //Library
            //            NSLog(@"Library");
            [self showImagePicker:UIImagePickerControllerSourceTypePhotoLibrary];
            
            break;
        default:
            break;
    }
    [self CloseAniamtionScreen:nil];
    
}

- (void)showVideo{
    CaptureViewController *obj = [[[CaptureViewController alloc] initWithNibName:@"CaptureViewController" bundle:nil]autorelease];
    [self.navigationController pushViewController:obj animated:TRUE];
    obj = nil;
}

#pragma mark -
#pragma mark Toolbar Actions

- (void)showImagePicker:(UIImagePickerControllerSourceType)sourceType
{
    if ([UIImagePickerController isSourceTypeAvailable:sourceType])
    {
        [self.overlayViewController setupImagePicker:sourceType];
        [self presentModalViewController:self.overlayViewController.imagePickerController animated:YES];
    }
}

#pragma mark -
#pragma mark OverlayViewControllerDelegate

// as a delegate we are being told a picture was taken
- (void)didTakePicture:(UIImage *)picture
{
    [capturedImage = picture retain];
    checkPhotoLib  = @"photoLib";
}

// as a delegate we are told to finished with the camera
- (void)didFinishWithCamera
{
    [self dismissModalViewControllerAnimated:YES];
    
    if (capturedImage) {
        isCompareImageSelected = TRUE;
        [self FaceLibraryButtonClick:nil];
    }
}

@end
