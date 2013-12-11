//
//  DemoVideoCaptureViewController.h
//  FaceTracker
//
// Copyright (c) 2013 Hubino  All rights reserved.
//
//  Permission is given to use this source code file without charge in any
//  project, commercial or otherwise, entirely at your risk, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in compiled projects is
//  appreciated but not required.
//

#import "VideoCaptureViewController.h"

@interface CaptureViewController : VideoCaptureViewController
{
    cv::CascadeClassifier _faceCascade;
    CaptureViewController * capture;
    //cv::CascadeClassifier _eyeCascade;
    
}

@property (nonatomic, readonly) cv::CascadeClassifier eyeCascade;
@property (nonatomic, retain) UIImage *storeImage;
@property (nonatomic, retain) UIImage *CroppedImage;

@property (nonatomic, retain) IBOutlet UIButton *captureBut;

@property (nonatomic, retain) IBOutlet UILabel *displayArea;

@property (nonatomic, retain) IBOutlet UILabel *displayResolution;

@property (nonatomic, retain) IBOutlet UILabel *displayCapture;

@property (nonatomic, retain) IBOutlet UILabel *displayBrightness;

@property (nonatomic, retain) IBOutlet UILabel *displayContrast;

@property (nonatomic, retain) IBOutlet UILabel *displayDR;

@property (nonatomic, retain) IBOutlet UILabel *displayBlur;

@property (nonatomic, retain) IBOutlet UILabel *displayEyeDist;

@property (nonatomic, retain) IBOutlet UIImageView *imageView;

@property (nonatomic, retain) IBOutlet UIButton *closeBut;


- (IBAction)toggleFps:(id)sender;
- (IBAction)closeBut:(id)sender;
- (IBAction)toggleCamera:(id)sender;
+ (IplImage *)CreateIplImageFromUIImage:(UIImage *)image;
+ (UIImage *)UIImageFromIplImage:(IplImage *)image ;

+ (cv::Mat)cvMatWithImage:(UIImage *)image;
+ (UIImage *)imageWithCVMat:(const cv::Mat&)cvMat;

+ (float)CalulateBlur:(const cv::Mat&)cvMat;

+ (UIImage*) getSubImageFrom: (UIImage*) img WithRect: (CGRect) rect;

@end
