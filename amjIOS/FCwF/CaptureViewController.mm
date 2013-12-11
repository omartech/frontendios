//
//  DemoVideoCaptureViewController.m
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

#import "UIImage+OpenCV.h"

#import "CaptureViewController.h"
#import "ViewController.h"
#import "OmerPHP.h"
#import "ResultViewController.h"
#import "MBProgressHUD.h"


BOOL isCaptured;

static inline double radians (double degrees) {return degrees * M_PI/180;}

// Number of frames to average for FPS calculation
const int kFrameTimeBufferSize = 5;
int captureStarts =0;
int enRoolImageCount =0;
int totalImage =0;
int finished =0;

NSData *imageData1 =NULL;
NSData *imageData2=NULL;
NSData *imageData3=NULL;
NSData *imageData4=NULL;
NSData *imageData5=NULL;



// Name of face cascade resource file without xml extension
NSString * const kFaceCascadeFilename = @"haarcascade_frontalface_default";
NSString * const kEyeCascadeFilename = @"haarcascade_eye_tree_eyeglasses";

// Options for cv::CascadeClassifier::detectMultiScale
const int kHaarOptions =  CV_HAAR_FIND_BIGGEST_OBJECT | CV_HAAR_DO_ROUGH_SEARCH;

@interface CaptureViewController ()
- (void)displayFaces:(const std::vector<cv::Rect> &)faces :
        forVideoRect:(CGRect)rect
    videoOrientation:(AVCaptureVideoOrientation)videoOrientation;

- (void)displayEyes:(const std::vector<cv::Rect> &)eyes
       forVideoRect:(CGRect)rect
   videoOrientation:(AVCaptureVideoOrientation)videoOrientation;

@end

@implementation CaptureViewController
@synthesize imageView;
@synthesize eyeCascade = _eyeCascade;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.captureGrayscale = YES;
        self.qualityPreset = AVCaptureSessionPreset1280x720;
    }
    return self;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    
    isCaptured = TRUE;
    [super viewDidLoad];
    captureStarts=0;
    imageData1 =NULL;
    imageData2=NULL;
    imageData3=NULL;
    imageData4=NULL;
    imageData5=NULL;
    enRoolImageCount =0;
    totalImage =0;
    finished=0;
    imageView.hidden=YES;
    
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *imageType = [prefs stringForKey:@"typeSelect"];
    if([@"enroll" isEqualToString:imageType])
    {
       NSString *toImageCout=[prefs stringForKey:@"imageToEnrollCount"];
        if(toImageCout!=NULL)
           {
               totalImage=[toImageCout intValue];
           }
           else
           {
               totalImage=5;
           }
        
    }
    else
    {
        NSString *toImageCout=[prefs stringForKey:@"imageToAuthenCount"];
        if(toImageCout!=NULL)
        {
            totalImage=[toImageCout intValue];
        }
        else
        {
            totalImage=3;
        }
    }
    self.camera = 1;
    // Load the face Haar cascade from resources
    NSString *faceCascadePath1 = [[NSBundle mainBundle] pathForResource:kFaceCascadeFilename ofType:@"xml"];
    
    if (!_faceCascade.load([faceCascadePath1 UTF8String])) {
        NSLog(@"Could not load face cascade: %@", faceCascadePath1);
    }
    
    // Load the face Haar cascade from resources
    NSString *faceCascadePath2 = [[NSBundle mainBundle] pathForResource:kEyeCascadeFilename ofType:@"xml"];
    
    if (!_eyeCascade.load([faceCascadePath2 UTF8String])) {
        NSLog(@"Could not load face cascade: %@", faceCascadePath2);
    }
    
}



- (void)viewDidUnload
{
    captureStarts=0;
    imageData1 =NULL;
    imageData2=NULL;
    imageData3=NULL;
    imageData4=NULL;
    imageData5=NULL;
    enRoolImageCount =0;
    totalImage =0;
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

// MARK: IBActions

// Toggles display of FPS
- (IBAction)toggleFps:(id)sender
{
    self.showDebugInfo = !self.showDebugInfo;
}

// Turn torch on and off
- (IBAction)toggleTorch:(id)sender
{
    ViewController *obj = [[[ViewController alloc] initWithNibName:@"ViewController" bundle:nil]autorelease];
    [self.navigationController pushViewController:obj animated:TRUE];
    obj = nil;
    
}

// Turn torch on and off
- (IBAction)capturedImage:(id)sender
{
    captureStarts=1;
}


// Turn torch on and off
- (IBAction)AuthenticationImage:(id)sender
{
    captureStarts=1;
}

// Turn torch on and off
- (IBAction)cancel:(id)sender
{
    [_captureSession stopRunning];
    
    [_videoPreviewLayer removeFromSuperlayer];
    [_videoPreviewLayer release];
    [_videoOutput release];
    [_captureDevice release];
    [_captureSession release];
    
    _videoPreviewLayer = nil;
    _videoOutput = nil;
    _captureDevice = nil;
    _captureSession = nil;
    
    ViewController *obj = [[[ViewController alloc] initWithNibName:@"ViewController" bundle:nil]autorelease];
    [self.navigationController pushViewController:obj animated:TRUE];
    obj = nil;
    
}
// Switch between front and back camera
- (IBAction)toggleCamera:(id)sender
{
    if (self.camera == 1) {
        self.camera = 0;
    }
    else
    {
        self.camera = 1;
    }
}

// MARK: VideoCaptureViewController overrides

- (void)processFrame:(cv::Mat &)mat videoRect:(CGRect)rect videoOrientation:(AVCaptureVideoOrientation)videOrientation
{
    // Shrink video frame to 320X240
    cv::resize(mat, mat, cv::Size(640, 480), 0.5f, 0.5f, CV_INTER_LINEAR);
    
    rect.size.width = 640;
    rect.size.height = 480;
    NSLog(@"%f",rect.size.width);
        NSLog(@"%f",rect.size.height);
    // Rotate video frame by 90deg to portrait by combining a transpose and a flip
    // Note that AVCaptureVideoDataOutput connection does NOT support hardware-accelerated
    // rotation and mirroring via videoOrientation and setVideoMirrored properties so we
    // need to do the rotation in software here.
    cv::transpose(mat, mat);
    CGFloat temp = rect.size.width;
    rect.size.width = rect.size.height;
    rect.size.height = temp;
    
    if (videOrientation == AVCaptureVideoOrientationLandscapeRight)
    {
        // flip around y axis for back camera
        cv::flip(mat, mat, 1);
    }
    else {
        // Front camera output needs to be mirrored to match preview layer so no flip is required here
    }
    
    videOrientation = AVCaptureVideoOrientationPortrait;
    
    // Detect faces
    std::vector<cv::Rect> faces;
    std::vector<cv::Rect> eyes;
    std::vector<cv::Rect> eyes_param;
    
    NSLog(@"MAtCols = %d", mat.cols);
    NSLog(@"MAtRows = %d", mat.rows);
    
    
    _faceCascade.detectMultiScale(mat, faces, 1.1, 2, kHaarOptions, cv::Size(40, 40));

    
    // Dispatch updating of face markers to main queue
    dispatch_sync(dispatch_get_main_queue(), ^{
        [self displayFaces:faces
              forVideoRect:rect
          videoOrientation:videOrientation];
    });
    
    
    
    cv :: Mat frame_gray;
    
    cv :: cvtColor( mat, frame_gray, CV_BGR2GRAY );
    equalizeHist( frame_gray, frame_gray );
    
    
    /*if ( faces.size() == 1 ) {
     
     _eyeCascade.detectMultiScale ( frame_gray, eyes, 1.1, 2, 0|CV_HAAR_SCALE_IMAGE, cv:: Size (5,5));
     
     // Dispatch updating of face markers to main queue
     dispatch_sync(dispatch_get_main_queue(), ^{
     
     
     [self displayEyes:eyes
     forVideoRect:rect
     videoOrientation:videOrientation];
     });
     
     }*/
    
}



// MARK: AVCaptureVideoDataOutputSampleBufferDelegate delegate methods

// AVCaptureVideoDataOutputSampleBufferDelegate delegate method called when a video frame is available
//
// This method is called on the video capture GCD queue. A cv::Mat is created from the frame data and
// passed on for processing with OpenCV.
- (void)captureOutput:(AVCaptureOutput *)captureOutput
didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
       fromConnection:(AVCaptureConnection *)connection
{
    NSAutoreleasePool* localpool = [[NSAutoreleasePool alloc] init];
    
    CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    OSType format = CVPixelBufferGetPixelFormatType(pixelBuffer);
    CGRect videoRect = CGRectMake(0.0f, 0.0f, CVPixelBufferGetWidth(pixelBuffer), CVPixelBufferGetHeight(pixelBuffer));
    
    
    AVCaptureVideoOrientation videoOrientation = [[[_videoOutput connections] objectAtIndex:0] videoOrientation];
    
    
    
    
    
    if (format == kCVPixelFormatType_420YpCbCr8BiPlanarFullRange) {
        // For grayscale mode, the luminance channel of the YUV data is used
        CVPixelBufferLockBaseAddress(pixelBuffer, 0);
        void *baseaddress = CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 0);
        
        cv::Mat mat(videoRect.size.height, videoRect.size.width, CV_8UC1, baseaddress, 0);
        
        [self processFrame:mat videoRect:videoRect videoOrientation:videoOrientation];
        
        CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
        if(iImage == 1){
            [self imageFromSampleBuffer:sampleBuffer];
        }
    }
    else if (format == kCVPixelFormatType_32BGRA) {
        // For color mode a 4-channel cv::Mat is created from the BGRA data
        CVPixelBufferLockBaseAddress(pixelBuffer, 0);
        void *baseaddress = CVPixelBufferGetBaseAddress(pixelBuffer);
        
        cv::Mat mat(videoRect.size.height, videoRect.size.width, CV_8UC4, baseaddress, 0);
        
        [self processFrame:mat videoRect:videoRect videoOrientation:videoOrientation];
        
        CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
        
        
        self.storeImage =  [self imageFromSampleBuffer:sampleBuffer];
        
        
        
        
        //UIImageWriteToSavedPhotosAlbum(self.storeImage, self,  nil,nil);
        
    }
    else {
        NSLog(@"Unsupported video format");
    }
    
    // Update FPS calculation
    CMTime presentationTime = CMSampleBufferGetOutputPresentationTimeStamp(sampleBuffer);
    
    if (_lastFrameTimestamp == 0) {
        _lastFrameTimestamp = presentationTime.value;
        _framesToAverage = 1;
    }
    else {
        float frameTime = (float)(presentationTime.value - _lastFrameTimestamp) / presentationTime.timescale;
        _lastFrameTimestamp = presentationTime.value;
        
        _frameTimes[_frameTimesIndex++] = frameTime;
        
        if (_frameTimesIndex >= kFrameTimeBufferSize) {
            _frameTimesIndex = 0;
        }
        
        float totalFrameTime = 0.0f;
        for (int i = 0; i < _framesToAverage; i++) {
            totalFrameTime += _frameTimes[i];
        }
        
        float averageFrameTime = totalFrameTime / _framesToAverage;
        float fps = 1.0f / averageFrameTime;
        
        if (fabsf(fps - _captureQueueFps) > 0.1f) {
            _captureQueueFps = fps;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self setFps:fps];
            });
        }
        
        _framesToAverage++;
        if (_framesToAverage > kFrameTimeBufferSize) {
            _framesToAverage = kFrameTimeBufferSize;
        }
    }
    
    [localpool drain];
}

// MARK: Accessors
- (void)setFps:(float)fps
{
    [self willChangeValueForKey:@"fps"];
    _fps = fps;
    [self didChangeValueForKey:@"fps"];
    
    [self updateDebugInfo];
}

// Create a UIImage from sample buffer data
- (UIImage *) imageFromSampleBuffer:(CMSampleBufferRef) sampleBuffer
{
    // Get a CMSampleBuffer's Core Video image buffer for the media data
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    // Lock the base address of the pixel buffer
    CVPixelBufferLockBaseAddress(imageBuffer, 0);
    
    // Get the number of bytes per row for the pixel buffer
    void *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer);
    
    // Get the number of bytes per row for the pixel buffer
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    // Get the pixel buffer width and height
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    
    // Create a device-dependent RGB color space
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    // Create a bitmap graphics context with the sample buffer data
    CGContextRef context = CGBitmapContextCreate(baseAddress, width, height, 8,
                                                 bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    // Create a Quartz image from the pixel data in the bitmap graphics context
    
    
    CGImageRef quartzImage = CGBitmapContextCreateImage(context);
    // Unlock the pixel buffer
    CVPixelBufferUnlockBaseAddress(imageBuffer,0);
    
    // Free up the context and color space
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    
    // Create an image object from the Quartz image
    UIImage *image = [UIImage imageWithCGImage:quartzImage];
    
    
    
    //       UIImageWriteToSavedPhotosAlbum(image, self,  nil,nil);
    
    
    //    [self.imageView setImage:image];
    //    [self.view setNeedsDisplay];
    
    //    UIImageWriteToSavedPhotosAlbum(image, self, nil, nil);
    // Release the Quartz image
    CGImageRelease(quartzImage);
    
    //    UIGraphicsBeginImageContext(image.size);
    //
    //
    //    CGContextRotateCTM (context, radians(180));
    //    [image drawAtPoint:CGPointMake(0, 0)];
    //
    //    UIImageWriteToSavedPhotosAlbum(image, self,  nil,nil);
    //
    //    image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIImage *rotateImage = [[UIImage alloc] initWithCGImage: image.CGImage
                                                      scale: 1.0
                                                orientation: UIImageOrientationRight];
    
    return (rotateImage);
}

- (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    UIGraphicsBeginImageContext( newSize );
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    
    return newImage;
}

// Update face markers given vector of face rectangles
- (void)displayFaces:(const std::vector<cv::Rect> &)faces
        forVideoRect:(CGRect)rect
    videoOrientation:(AVCaptureVideoOrientation)videoOrientation
{
    NSArray *sublayers = [NSArray arrayWithArray:[self.view.layer sublayers]];
    int sublayersCount = [sublayers count];
    int currentSublayer = 0;
    
    
	[CATransaction begin];
	[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
	
	// hide all the face layers
	for (CALayer *layer in sublayers) {
        NSString *layerName = [layer name];
		if ([layerName isEqualToString:@"FaceLayer"])
			[layer setHidden:YES];
	}
    
    // Create transform to convert from vide frame coordinate space to view coordinate space
    CGAffineTransform t = [self affineTransformForVideoFrame:rect orientation:videoOrientation];
    
    for (int i = 0; i < faces.size(); i++) {
        
        CGRect faceRect;
        faceRect.origin.x = faces[i].x;
        faceRect.origin.y = faces[i].y;
        
        faceRect.size.width = faces[i].width;
        faceRect.size.height = faces[i].height;
        
        /**************************************************/
        //    NSString *appendArea = @"Area = ";
        
        //  NSString *appendRes = @"Res = ";
        
        //  NSString *appendBri = @"Brightness = ";
        
        //  NSString *appendCont = @"Cntrst = ";
        
        //  NSString *appendDR = @"DR = ";
        
        //  NSString *appendBlur = @"Blur = ";
        
        //  NSString *appendEyeDist = @"Eye Dist = ";
        
        float area= (faceRect.size.height * faceRect.size.width) / 1000;
        //   NSString *strArea = [NSString stringWithFormat:@"%.2f", area];
        
        
        
        //NSString *result = [appendArea stringByAppendingString:strArea];
        
       // self.displayArea.text =  [NSString stringWithFormat:@"%f", faceRect.size.width];;
        
        //self.displayArea.textColor = [UIColor redColor];
        //self.displayArea.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.5f];
        
        
        // NSString *Resolution = [[NSString stringWithFormat:@"%.2f X ", faceRect.size.height] stringByAppendingString :[NSString stringWithFormat:@"%.2f", faceRect.size.height]];
        
        // NSString *finalRes = [appendRes stringByAppendingString:Resolution];
        
       // self.displayResolution.text =[NSString stringWithFormat:@"%f", faceRect.size.height ];;
        
        //self.displayResolution.textColor = [UIColor redColor];
        //self.displayResolution.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.5f];
        
        std::vector<cv::Mat> hsvChannels(3);
        cv::Mat inputMat;
        
        cv::Mat testMat = [CaptureViewController cvMatWithImage:self.storeImage];
        
        
        // Calcualte Brightness of an image
        cv :: cvtColor (testMat, inputMat, CV_BGR2HSV);
        cv:: split(inputMat, hsvChannels);
        cv :: Scalar m = mean(hsvChannels[2]);
        NSLog(@"height = %f", m[0]);
        float brightness;
        brightness = ( m[0] * 100 ) / 255;
        NSLog ( @"Brightness = %f", brightness);
        
        //NSString *strBrightness = [NSString stringWithFormat:@"%.2f", brightness];
        
        //NSString *result_bri = [appendBri stringByAppendingString:strBrightness];
        
        // self.displayBrightness.text = result_bri;
        
        //self.displayBrightness.textColor = [UIColor whiteColor];
        //self.displayBrightness.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.5f];
        
        
        //Calcualte Coantrast of an image
        
        cv :: cvtColor (testMat, inputMat, CV_BGR2GRAY);
        cv :: Scalar mean;
        cv :: Scalar StandardDeviation;
        cv :: meanStdDev ( inputMat,mean,StandardDeviation);
        
        NSLog ( @"Contrast = : %.2f\n", StandardDeviation.val[0] );
        NSLog ( @"SD = : %.2f\n", StandardDeviation.val[0] );
        
        
        float contrast;
        
        contrast =  ( (StandardDeviation.val[0] * 100)  / 127.50 );
        
        
        // NSString *strContrast = [NSString stringWithFormat:@"%.2f", contrast];
        
        // NSString *result_Cont = [appendCont stringByAppendingString:strContrast];
        
        // self.displayContrast.text = result_Cont;
        
        // self.displayContrast.textColor = [UIColor whiteColor];
        // self.displayContrast.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.5f];
        
        
        //Calculate Dynamic-Range of an image
        double min, max;
        int minInd, maxInd;
        double log2;
        double Dyr,DynamicRange;
        cv :: Mat MatDyr;
        
        cv :: cvtColor (testMat, MatDyr, CV_RGB2GRAY);
        
        cv :: minMaxIdx(MatDyr, &min, &max, &minInd, &maxInd, cv :: noArray());
        
        NSLog ( @"Min Val = : %f\n", min );
        NSLog ( @"Max Val = : %f\n", max );
        
        log2 = cv :: log ( max - min );
        Dyr = log2 * 1.44269504088896340736;
        
        DynamicRange = ( Dyr * 10 ) / ( log(255) * 1.44269504088896340736 );
        
        
        // NSString *strDR = [NSString stringWithFormat:@"%.2f", DynamicRange];
        
        // NSString *result_DR = [appendDR stringByAppendingString:strDR];
        
        //self.displayDR.text = result_DR;
        
        //self.displayDR.textColor = [UIColor whiteColor];
        // self.displayDR.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.5f];
        
        NSLog ( @"Dyr Val = : %.2f\n", Dyr );
        
        
        float height= faceRect.size.height;
        float weight=faceRect.size.width;
        
        faceRect = CGRectApplyAffineTransform(faceRect, t);
        
        NSUserDefaults *sessionVal = [NSUserDefaults standardUserDefaults];

        NSString *cameraDistanceValue = [sessionVal stringForKey:@"cameraDistanceValue"];
        int cedistance=0;
        if(cameraDistanceValue!=NULL)
        {
            cedistance=[cameraDistanceValue intValue];
        }
        else
        {
            cedistance=360;
        }
        
        
        
        if( captureStarts==1 && height>cedistance &&  weight>cedistance){

            //self.displayCapture.text = @"Captured";
            isCaptured = FALSE;
            
            //UIImage *img = [ CaptureViewController getSubImageFrom: self.storeImage WithRect: faceRect ];
            
            UIImage *imga = self.storeImage;
            
            UIImage* smallImage = [self imageWithImage:imga scaledToSize:CGSizeMake(480, 640)];
            // UIImageWriteToSavedPhotosAlbum(smallImage, nil, nil, nil);
            
            [NSThread sleepForTimeInterval:2.0];
            

            // NSData *imageData = [NSData dataWithData:UIImagePNGRepresentation(smallImage)];
            enRoolImageCount= enRoolImageCount+1;
            
            NSData *imageData = UIImageJPEGRepresentation(smallImage, 0.3f);
            if(enRoolImageCount==1)
            {
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                [defaults setObject:imageData forKey:@"image1"];
                [defaults synchronize];
            }
            if(enRoolImageCount==2)
            {
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                [defaults setObject:imageData forKey:@"image2"];
                [defaults synchronize];
            }
            if(enRoolImageCount==3)
            {
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                [defaults setObject:imageData forKey:@"image3"];
                [defaults synchronize];
            }
            if(enRoolImageCount==4)
            {
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                [defaults setObject:imageData forKey:@"image4"];
                [defaults synchronize];            }
            if(enRoolImageCount==5)
            {
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                [defaults setObject:imageData forKey:@"image5"];
                [defaults synchronize];
            }
            
            // UIImageWriteToSavedPhotosAlbum( img, self,  nil,nil);
            // UIImageWriteToSavedPhotosAlbum(self.storeImage, self,  nil,nil);
            
            if(enRoolImageCount==totalImage)
            {
                
              //  NSLog(@"%@aaadd",imga);
                @autoreleasepool {
                    
                    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
                    NSInteger userId = [prefs integerForKey:@"userId"];
                    
                    
                    NSString *inStr = [@(userId) stringValue];
                    OmerPHP* service = [OmerPHP service];
                    service.logging = YES;
                    
                    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                    imageData1 = [defaults dataForKey:@"image1"];
                    imageData2 = [defaults dataForKey:@"image2"];
                    imageData3 = [defaults dataForKey:@"image3"];
                    imageData4 = [defaults dataForKey:@"image4"];
                    imageData5 = [defaults dataForKey:@"image5"];
                    NSString *encodedString0 = [self base64forData:imageData1];
                    NSString *encodedString1 = [self base64forData:imageData2];
                    NSString *encodedString2 = [self base64forData:imageData3];
                    NSString *imageType = [prefs stringForKey:@"typeSelect"];
                    
               
                    
                    if([@"enroll" isEqualToString:imageType])
                    {
                        NSString *encodedString3 = [self base64forData:imageData4];
                        NSString  *encodedString4 = [self base64forData:imageData5];
                        
                        // Find the device type then pass the variable name of "deviceType" like(iphone4,ipad and etc)
                        [service initiateFaceEngine:self action:@selector(initiateFaceEngineHandler:) userId: inStr serviceType: @"prepareMetadata" deviceType: @"IOS" facialImageOne: encodedString0 facialImageTwo: encodedString1  facialImageThree:encodedString2 facialImageFour: encodedString3 facialImageFive:encodedString4 facialImageSix: @"" facialImageSeven: @"" facialImageEight: @"" facialImageNine: @"" facialImageTen: @"" facialImageEleven: @"" facialImageTwelve: @"" facialImageThirteen: @"" facialImageFourteen: @"" facialImageFifteen: @"" facialImageSixteen: @"" facialImageSeventeen: @"" facialImageEighteen: @"" facialImageNineteen: @"" facialImageTwenty: @""];
                        
                        
                        finished=1;
                        [_captureSession stopRunning];
                        
                        [_videoPreviewLayer removeFromSuperlayer];
                        [_videoPreviewLayer release];
                        [_videoOutput release];
                        [_captureDevice release];
                        [_captureSession release];
                        
                        _videoPreviewLayer = nil;
                        _videoOutput = nil;
                        _captureDevice = nil;
                        _captureSession = nil;
                        MBProgressHUD *hud =[MBProgressHUD showHUDAddedTo:self.view animated:YES];
                        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.01 * NSEC_PER_SEC);
                          imageView.hidden=NO;
                        hud.labelText = @"Loading";
                        
                      
                        
                    }
                    else
                    {
                            finished=1;
                        // Find the device type then pass the variable name of "deviceType" like(iphone4,ipad and etc)

                                [service initiateFaceEngine:self action:@selector(initiateFaceEngineHandler:) userId: inStr serviceType: @"validateFace" deviceType: @"IOS" facialImageOne: encodedString0 facialImageTwo: encodedString1  facialImageThree:encodedString2 facialImageFour: @"" facialImageFive:@"" facialImageSix: @"" facialImageSeven: @"" facialImageEight: @"" facialImageNine: @"" facialImageTen: @"" facialImageEleven: @"" facialImageTwelve: @"" facialImageThirteen: @"" facialImageFourteen: @"" facialImageFifteen: @"" facialImageSixteen: @"" facialImageSeventeen: @"" facialImageEighteen: @"" facialImageNineteen: @"" facialImageTwenty: @""];
                        [_captureSession stopRunning];
                        
                        [_videoPreviewLayer removeFromSuperlayer];
                        [_videoPreviewLayer release];
                        [_videoOutput release];
                        [_captureDevice release];
                        [_captureSession release];
                        
                        _videoPreviewLayer = nil;
                        _videoOutput = nil;
                        _captureDevice = nil;
                        _captureSession = nil;
                             imageView.hidden=NO;
                        MBProgressHUD *hud =[MBProgressHUD showHUDAddedTo:self.view animated:YES];
                        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.01 * NSEC_PER_SEC);
                        hud.labelText = @"Loading";
                        
                   
                    }
                }
            }
            
            ImageCaptured = TRUE;
            
        }
        NSLog(@"%f",height);
         NSLog(@"%f",weight);
        if(enRoolImageCount!=totalImage  && height>cedistance &&  weight>cedistance)
        {
            CALayer *featureLayer = nil;
            while (!featureLayer && (currentSublayer < sublayersCount)) {
			CALayer *currentLayer = [sublayers objectAtIndex:currentSublayer++];
			if ([[currentLayer name] isEqualToString:@"FaceLayer"]) {
				featureLayer = currentLayer;
				[currentLayer setHidden:NO];
			}
		}
        
        if (!featureLayer) {
            // Create a new feature marker layer
			featureLayer = [[CALayer alloc] init];
            featureLayer.name = @"FaceLayer";
            featureLayer.borderColor = [[UIColor greenColor] CGColor];
            featureLayer.borderWidth = 2.0f;
			[self.view.layer addSublayer:featureLayer];
			[featureLayer release];
		}
            featureLayer.frame = faceRect;
        }
    }
    
    
    [CATransaction commit];
}


- (void) initiateFaceEngineHandler: (id) value {
    
	// Handle errors
	if([value isKindOfClass:[NSError class]]) {
        NSLog(@"%@", value);
        NSLog(@"ERROR with theConenction");
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        
        // saving an NSString
        [prefs setObject:@"N" forKey:@"enrolSuccess"];
        
        // This is suggested to synch prefs, but is not needed (I didn't put it in my tut)
        [prefs synchronize];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            dispatch_sync(dispatch_get_main_queue(), ^{
                // Show the alert view
            });
        });
        ResultViewController *obj = [[[ResultViewController alloc] initWithNibName:@"ResultViewController" bundle:nil]autorelease];
        [self.navigationController pushViewController:obj animated:TRUE];
        obj = nil;
        
		return;
	}
    
	// Handle faults
	if([value isKindOfClass:[SoapFault class]]) {
		NSLog(@"%@", value);
        NSLog(@"ERROR with theConenction");
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        
        // saving an NSString
        [prefs setObject:@"N" forKey:@"enrolSuccess"];
        
        // This is suggested to synch prefs, but is not needed (I didn't put it in my tut)
        [prefs synchronize];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            dispatch_sync(dispatch_get_main_queue(), ^{
                // Show the alert view
            });
        });
        
        ResultViewController *obj = [[[ResultViewController alloc] initWithNibName:@"ResultViewController" bundle:nil]autorelease];
        [self.navigationController pushViewController:obj animated:TRUE];
        obj = nil;
        
        
		return;
	}
    
    
	// Do something with the ServiceResponse* result
    ServiceResponse* resulta = (ServiceResponse*)value;
	NSLog(@"initiateFaceEngineAndroid returned the message: %@", resulta.message);
    NSLog(@"initiateFaceEngineAndroid returned the result: %hhd", resulta.result);
    NSString *message =resulta.message;
    BOOL resultOne =resulta.result;
    
    if([message isEqualToString:@"E00"])
    {
        // NSLog(@"E00");
        NSLog(@"%@ errorCode:",message);
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        [prefs setObject:message forKey:@"resultRes"];
        [prefs synchronize];
    }
    else if([message isEqualToString:@"E01"])
    {
        NSLog(@"%@ errorCode:",message);
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        [prefs setObject:message forKey:@"resultRes"];
        [prefs synchronize];
    }
    else
    {
        NSLog(@"%@ errorCode:",message);
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        [prefs setObject:message forKey:@"resultRes"];
        [prefs synchronize];
        
        
    }
    
    if(resultOne)
    {
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        // saving an NSString
        [prefs setObject:@"Y" forKey:@"enrolSuccess"];
        // This is suggested to synch prefs, but is not needed (I didn't put it in my tut)
        [prefs synchronize];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            dispatch_sync(dispatch_get_main_queue(), ^{
                // Show the alert view
            });
        });
        ResultViewController *obj = [[[ResultViewController alloc] initWithNibName:@"ResultViewController" bundle:nil]autorelease];
        [self.navigationController pushViewController:obj animated:TRUE];
        obj = nil;
        
    }
    else
    {
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        // saving an NSString
        [prefs setObject:@"N" forKey:@"enrolSuccess"];
        // This is suggested to synch prefs, but is not needed (I didn't put it in my tut)
        [prefs synchronize];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            dispatch_sync(dispatch_get_main_queue(), ^{
                // Show the alert view
            });
        });
        ResultViewController *obj = [[[ResultViewController alloc] initWithNibName:@"ResultViewController" bundle:nil]autorelease];
        [self.navigationController pushViewController:obj animated:TRUE];
        obj = nil;
        
    }
    
    
    
}




// Update face markers given vector of face rectangles
- (void)displayEyes:(const std::vector<cv::Rect> &)eyes
       forVideoRect:(CGRect)rect
   videoOrientation:(AVCaptureVideoOrientation)videoOrientation
{
    NSArray *sublayers = [NSArray arrayWithArray:[self.view.layer sublayers]];
    int sublayersCount = [sublayers count];
    int currentSublayer = 0;
    
	[CATransaction begin];
	[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
	
	// hide all the face layers
	for (CALayer *layer in sublayers) {
        NSString *layerName = [layer name];
		if ([layerName isEqualToString:@"EyeLayer"])
			[layer setHidden:YES];
	}
    
    // Create transform to convert from vide frame coordinate space to view coordinate space
    CGAffineTransform t = [self affineTransformForVideoFrame:rect orientation:videoOrientation];
    
    NSLog ( @"No of Eyes = : %ld", eyes.size() );
    
    if ( eyes.size() == 2 ) {
        
        double ValTosqrt = (eyes[0].x - eyes[1].x)^2 + (eyes[0].y - eyes[1].y) ^2;
        if ( ValTosqrt > 0 ) {
            distance_between_eyes = sqrt( ValTosqrt );
        }
        
        NSLog ( @"Distance Between Two Eyes = : %f", distance_between_eyes );
        
    } else {
        distance_between_eyes = 0.00;
    }
    
    for (int i = 0; i < eyes.size(); i++) {
        
        CGRect eyeRect;
        eyeRect.origin.x = eyes[i].x;
        eyeRect.origin.y = eyes[i].y;
        eyeRect.size.width = eyes[i].width;
        eyeRect.size.height = eyes[i].height;
        
        
        eyeRect = CGRectApplyAffineTransform(eyeRect, t);
        
        CALayer *featureLayer = nil;
        
        while (!featureLayer && (currentSublayer < sublayersCount)) {
			CALayer *currentLayer = [sublayers objectAtIndex:currentSublayer++];
			if ([[currentLayer name] isEqualToString:@"EyeLayer"]) {
				featureLayer = currentLayer;
				[currentLayer setHidden:NO];
			}
		}
        
        if (!featureLayer) {
            // Create a new feature marker layer
			featureLayer = [[CALayer alloc] init];
            featureLayer.name = @"EyeLayer";
            featureLayer.borderColor = [[UIColor blueColor] CGColor];
            featureLayer.borderWidth = 3.0f;
			[self.view.layer addSublayer:featureLayer];
			[featureLayer release];
		}
        
        featureLayer.frame = eyeRect;
    }
    
    
    
    [CATransaction commit];
}

- (void)updateDebugInfo {
    if (_fpsLabel) {
        _fpsLabel.text = [NSString stringWithFormat:@"FPS: %0.1f", _fps];
    }
}

+ (cv::Mat)cvMatWithImage:(UIImage *)image
{
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(image.CGImage);
    CGFloat cols = image.size.width;
    CGFloat rows = image.size.height;
    
    cv::Mat cvMat(rows, cols, CV_8UC4); // 8 bits per component, 4 channels
    
    CGContextRef contextRef = CGBitmapContextCreate(cvMat.data,                 // Pointer to backing data
                                                    cols,                       // Width of bitmap
                                                    rows,                       // Height of bitmap
                                                    8,                          // Bits per component
                                                    cvMat.step[0],              // Bytes per row
                                                    colorSpace,                 // Colorspace
                                                    kCGImageAlphaNoneSkipLast |
                                                    kCGBitmapByteOrderDefault); // Bitmap info flags
    
    CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), image.CGImage);
    CGContextRelease(contextRef);
    
    return cvMat;
}


+ (UIImage *)imageWithCVMat:(const cv::Mat&)cvMat
{
    NSData *data = [NSData dataWithBytes:cvMat.data length:cvMat.elemSize() * cvMat.total()];
    
    CGColorSpaceRef colorSpace;
    
    if (cvMat.elemSize() == 1) {
        colorSpace = CGColorSpaceCreateDeviceGray();
    } else {
        colorSpace = CGColorSpaceCreateDeviceRGB();
    }
    
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
    
    CGImageRef imageRef = CGImageCreate(cvMat.cols,                                     // Width
                                        cvMat.rows,                                     // Height
                                        8,                                              // Bits per component
                                        8 * cvMat.elemSize(),                           // Bits per pixel
                                        cvMat.step[0],                                  // Bytes per row
                                        colorSpace,                                     // Colorspace
                                        kCGImageAlphaNone | kCGBitmapByteOrderDefault,  // Bitmap info flags
                                        provider,                                       // CGDataProviderRef
                                        NULL,                                           // Decode
                                        false,                                          // Should interpolate
                                        kCGRenderingIntentDefault);                     // Intent
    
    UIImage *image = [[UIImage alloc] initWithCGImage:imageRef];
    CGImageRelease(imageRef);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);
    
    return image;
}

// NOTE you SHOULD cvReleaseImage() for the return value when end of the code.
+ (IplImage *)CreateIplImageFromUIImage:(UIImage *)image {
    // Getting CGImage from UIImage
    CGImageRef imageRef = image.CGImage;
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    // Creating temporal IplImage for drawing
    IplImage *iplimage = cvCreateImage(
                                       cvSize(image.size.width,image.size.height), IPL_DEPTH_8U, 4
                                       );
    // Creating CGContext for temporal IplImage
    CGContextRef contextRef = CGBitmapContextCreate(
                                                    iplimage->imageData, iplimage->width, iplimage->height,
                                                    iplimage->depth, iplimage->widthStep,
                                                    colorSpace, kCGImageAlphaPremultipliedLast|kCGBitmapByteOrderDefault
                                                    );
    // Drawing CGImage to CGContext
    CGContextDrawImage(
                       contextRef,
                       CGRectMake(0, 0, image.size.width, image.size.height),
                       imageRef
                       );
    CGContextRelease(contextRef);
    CGColorSpaceRelease(colorSpace);
    
    // Creating result IplImage
    IplImage *ret = cvCreateImage(cvGetSize(iplimage), IPL_DEPTH_8U, 3);
    cvCvtColor(iplimage, ret, CV_RGBA2BGR);
    cvReleaseImage(&iplimage);
    
    return ret;
}

+ (UIImage *)UIImageFromIplImage:(IplImage *)image {
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    // Allocating the buffer for CGImage
    NSData *data =
    [NSData dataWithBytes:image->imageData length:image->imageSize];
    CGDataProviderRef provider =
    CGDataProviderCreateWithCFData((CFDataRef)data);
    // Creating CGImage from chunk of IplImage
    CGImageRef imageRef = CGImageCreate(
                                        image->width, image->height,
                                        image->depth, image->depth * image->nChannels, image->widthStep,
                                        colorSpace, kCGImageAlphaNone|kCGBitmapByteOrderDefault,
                                        provider, NULL, false, kCGRenderingIntentDefault
                                        );
    // Getting UIImage from CGImage
    UIImage *ret = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);
    return ret;
}

+ (float)CalulateBlur:(const cv::Mat&)cvMat {
    
    cv::Mat src,dst,src_gray,src_hsv; // declaring Mat functions to hold Image data
    
	int kernel_size = 3;
	int scale = 1;
	int delta = 0;
	int ddepth = CV_16S;
	
	
	
	cv::vector<cv :: Mat>channel_hist(1); // Mat channels to hold specific channels of Image data (i.e.) R channel, G channel etc
	cv::vector< cv :: Mat>channel_hsv(3);
    
	// Variables declared to use in calculating histogram
	cv::MatND hist;
    int hbins = 30, sbins = 32; // hue and saturation bins
    int histSize[] = {hbins,sbins};
    float hranges[] = {0,180}; // hue varies from 0 to 180 degrees, each depicting a color intensity for a pixel
    float sranges[] = {0,256}; // Saturation varies from 0 to 255
    const float *ranges[] = {hranges,sranges};
    int channels[] = {2}; // 2nd channel of HSV image - Value (V) channel (0,1,2 - H,S,V)
    
    double estimate=0,min=0,sharpmes = 0;
    
    cvtColor(cvMat,src_gray,CV_RGB2GRAY); // gray-scale image
	cvtColor(cvMat,src_hsv,CV_BGR2HSV); // HSV image
	
	cv :: calcHist(&src_hsv,1,channels,cv :: Mat(),hist,1,histSize,ranges,true,false); // Calculate Hist
	
	split(hist,channel_hist);
	cv :: Scalar Brightness_hist = mean(channel_hist[0]);	// Obtain the Hue values in each Bin
    
	cv :: split(src_hsv,channel_hsv);
	cv :: Scalar Brightness_hsv = mean(channel_hsv[2]); // average brightness values
    
	cv :: Laplacian(src_gray,dst,ddepth,kernel_size,scale,delta,cv::BORDER_DEFAULT);
	cv :: minMaxLoc(dst, &min, &estimate); // obtain the highest edge sharpness value
    
	sharpmes = (estimate*Brightness_hsv[0]/Brightness_hist[0]);
    //sharpmes = estimate;
    
    return sharpmes;
    
}

// get sub image
+ (UIImage*) getSubImageFrom: (UIImage*) img WithRect: (CGRect) rect {
    
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // translated rectangle for drawing sub image
    CGRect drawRect = CGRectMake(-rect.origin.x - 15, -rect.origin.y -20, img.size.width-1.5, img.size.height+20);
    
    // clip to the bounds of the image context
    // not strictly necessary as it will get clipped anyway?
    CGContextClipToRect(context, CGRectMake(0, 0, rect.size.width, rect.size.height));
    
    // draw image
    [img drawInRect:drawRect];
    
    // grab image
    UIImage* subImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return subImage;
}




- (NSString*)base64forData:(NSData*)theData {
    
    const uint8_t* input = (const uint8_t*)[theData bytes];
    NSInteger length = [theData length];
    
    static char table[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";
    
    NSMutableData* data = [NSMutableData dataWithLength:((length + 2) / 3) * 4];
    uint8_t* output = (uint8_t*)data.mutableBytes;
    
    NSInteger i;
    for (i=0; i < length; i += 3) {
        NSInteger value = 0;
        NSInteger j;
        for (j = i; j < (i + 3); j++) {
            value <<= 8;
            
            if (j < length) {
                value |= (0xFF & input[j]);
            }
        }
        
        NSInteger theIndex = (i / 3) * 4;
        output[theIndex + 0] =                    table[(value >> 18) & 0x3F];
        output[theIndex + 1] =                    table[(value >> 12) & 0x3F];
        output[theIndex + 2] = (i + 1) < length ? table[(value >> 6)  & 0x3F] : '=';
        output[theIndex + 3] = (i + 2) < length ? table[(value >> 0)  & 0x3F] : '=';
    }
    
    return [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
}





@end
