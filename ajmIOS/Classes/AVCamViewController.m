/*
     File: AVCamViewController.m
 Abstract: A view controller that coordinates the transfer of information between the user interface and the capture manager.
  Version: 2.1
 
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple
 Inc. ("Apple") in consideration of your agreement to the following
 terms, and your use, installation, modification or redistribution of
 this Apple software constitutes acceptance of these terms.  If you do
 not agree with these terms, please do not use, install, modify or
 redistribute this Apple software.
 
 In consideration of your agreement to abide by the following terms, and
 subject to these terms, Apple grants you a personal, non-exclusive
 license, under Apple's copyrights in this original Apple software (the
 "Apple Software"), to use, reproduce, modify and redistribute the Apple
 Software, with or without modifications, in source and/or binary forms;
 provided that if you redistribute the Apple Software in its entirety and
 without modifications, you must retain this notice and the following
 text and disclaimers in all such redistributions of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Inc. may
 be used to endorse or promote products derived from the Apple Software
 without specific prior written permission from Apple.  Except as
 expressly stated in this notice, no other rights or licenses, express or
 implied, are granted by Apple herein, including but not limited to any
 patent rights that may be infringed by your derivative works or by other
 works in which the Apple Software may be incorporated.
 
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
 
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
 
 Copyright (C) 2013 Apple Inc. All Rights Reserved.
 
 */

#import "AVCamViewController.h"
#import "AVCamCaptureManager.h"
#import "AVCamRecorder.h"
#import "MainViewController.h"
#import "ResultViewController.h"
#import "MBProgressHUD.h"

#import <AVFoundation/AVFoundation.h>

static void *AVCamFocusModeObserverContext = &AVCamFocusModeObserverContext;

@interface AVCamViewController () <UIGestureRecognizerDelegate>
@end

@interface AVCamViewController (InternalMethods)
- (void)tapToAutoFocus:(UIGestureRecognizer *)gestureRecognizer;
- (void)tapToContinouslyAutoFocus:(UIGestureRecognizer *)gestureRecognizer;
- (void)updateButtonStates;
@end

@interface AVCamViewController (AVCamCaptureManagerDelegate) <AVCamCaptureManagerDelegate>
@end

@implementation AVCamViewController

@synthesize captureManager;
@synthesize cameraToggleButton;
@synthesize recordButton;
@synthesize stillButton;
@synthesize focusModeLabel;
@synthesize videoPreviewView;
@synthesize captureVideoPreviewLayer,currentElementValue;
NSString *result=NULL;
NSString *resultStatus=NULL;
NSString *message=NULL;
- (NSString *)stringForFocusMode:(AVCaptureFocusMode)focusMode
{
	NSString *focusString = @"";
	
	switch (focusMode) {
		case AVCaptureFocusModeLocked:
			focusString = @"locked";
			break;
		case AVCaptureFocusModeAutoFocus:
			focusString = @"auto";
			break;
		case AVCaptureFocusModeContinuousAutoFocus:
			focusString = @"continuous";
			break;
	}
	
	return focusString;
}

- (void)dealloc
{
    [self removeObserver:self forKeyPath:@"captureManager.videoInput.device.focusMode"];
	[captureManager release];
    [videoPreviewView release];
	[captureVideoPreviewLayer release];
    [cameraToggleButton release];
    [recordButton release];
    [stillButton release];	
	[focusModeLabel release];
	
    [super dealloc];
}

- (void)viewDidLoad
{
   // [[self cameraToggleButton] setTitle:NSLocalizedString(@"Camera", @"Toggle camera button title")];
   // [[self recordButton] setTitle:NSLocalizedString(@"Record", @"Toggle recording button record title")];
    [[self stillButton] setTitle:NSLocalizedString(@"Capture", @"Capture still image button title")];
    
	if ([self captureManager] == nil) {
		AVCamCaptureManager *manager = [[AVCamCaptureManager alloc] init];
		[self setCaptureManager:manager];
       // [[self captureManager] toggleCamera];

		[manager release];
		
		[[self captureManager] setDelegate:self];

		if ([[self captureManager] setupSession]) {
            // Create video preview layer and add it to the UI
			AVCaptureVideoPreviewLayer *newCaptureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:[[self captureManager] session]];
			UIView *view = [self videoPreviewView];
			CALayer *viewLayer = [view layer];
			[viewLayer setMasksToBounds:YES];
			
			CGRect bounds = [view bounds];
			[newCaptureVideoPreviewLayer setFrame:bounds];

			[newCaptureVideoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
			
			[viewLayer insertSublayer:newCaptureVideoPreviewLayer below:[[viewLayer sublayers] objectAtIndex:0]];
			
			[self setCaptureVideoPreviewLayer:newCaptureVideoPreviewLayer];
            [newCaptureVideoPreviewLayer release];
			
            // Start the session. This is done asychronously since -startRunning doesn't return until the session is running.
			dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
				[[[self captureManager] session] startRunning];
			});
			
            [self updateButtonStates];
			
            // Create the focus mode UI overlay
			UILabel *newFocusModeLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, viewLayer.bounds.size.width - 20, 20)];
			[newFocusModeLabel setBackgroundColor:[UIColor clearColor]];
			[newFocusModeLabel setTextColor:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.50]];
			AVCaptureFocusMode initialFocusMode = [[[captureManager videoInput] device] focusMode];
			[newFocusModeLabel setText:[NSString stringWithFormat:@"focus: %@", [self stringForFocusMode:initialFocusMode]]];
			[view addSubview:newFocusModeLabel];
			[self addObserver:self forKeyPath:@"captureManager.videoInput.device.focusMode" options:NSKeyValueObservingOptionNew context:AVCamFocusModeObserverContext];
			[self setFocusModeLabel:newFocusModeLabel];
            [newFocusModeLabel release];
            
            // Add a single tap gesture to focus on the point tapped, then lock focus
			UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapToAutoFocus:)];
			[singleTap setDelegate:self];
			[singleTap setNumberOfTapsRequired:1];
			[view addGestureRecognizer:singleTap];
			
            // Add a double tap gesture to reset the focus mode to continuous auto focus
			UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapToContinouslyAutoFocus:)];
			[doubleTap setDelegate:self];
			[doubleTap setNumberOfTapsRequired:2];
			[singleTap requireGestureRecognizerToFail:doubleTap];
			[view addGestureRecognizer:doubleTap];
			
			[doubleTap release];
			[singleTap release];
		}		
	}
    //[[self captureManager] toggleCamera];
	
    [super viewDidLoad];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == AVCamFocusModeObserverContext) {
        // Update the focus UI overlay string when the focus mode changes
		[focusModeLabel setText:[NSString stringWithFormat:@"focus: %@", [self stringForFocusMode:(AVCaptureFocusMode)[[change objectForKey:NSKeyValueChangeNewKey] integerValue]]]];
	} else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark Toolbar Actions
- (IBAction)toggleCamera:(id)sender
{
    // Toggle between cameras when there is more than one
    [[self captureManager] toggleCamera];
    
    // Do an initial focus
    [[self captureManager] continuousFocusAtPoint:CGPointMake(.5f, .5f)];
}

- (IBAction)toggleRecording:(id)sender
{
    // Start recording if there isn't a recording running. Stop recording if there is.
    [[self recordButton] setEnabled:NO];
    if (![[[self captureManager] recorder] isRecording])
        [[self captureManager] startRecording];
    else
        [[self captureManager] stopRecording];
}


- (IBAction)cancel:(id)sender
{
    MainViewController *secondCon = [[MainViewController alloc] initWithNibName:@"MainViewController" bundle:nil];
    [self presentViewController:secondCon animated:YES completion:nil];
}


NSInteger photoCount=0;

- (IBAction)captureStillImage:(id)sender
{
    // Capture a still image
    NSInteger tag = [sender tag];
    
    
    if (tag==0) {
        photoCount =0;
        // Capture a still image
        
        cameraTimer = [NSTimer scheduledTimerWithTimeInterval:0.6   // fire every 2 seconds
                                                       target:self
                                                     selector:@selector(timedPhotoFire:)
                                                     userInfo:[NSNumber numberWithInt:5]
                                                      repeats:YES];
        
    }
   
}

/* This method captures the images and determines to pass whether to call entrollment OR authentication WS based on image count.
* It a Proof Of Concept method and we can enhance from here.
*/

- (void)timedPhotoFire:(NSTimer *)timer
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *imageTot = [prefs stringForKey:@"imageTot"];
       if(![imageTot isEqualToString:@"3"] && ![imageTot isEqualToString:@"5"])
    {
    
        [[self stillButton] setEnabled:NO];
        [[self captureManager] captureStillImage];
        // Flash the screen white and fade it out to give UI feedback that a still image was taken
        UIView *flashView = [[UIView alloc] initWithFrame:[[self videoPreviewView] frame]];
        [flashView setBackgroundColor:[UIColor whiteColor]];
        [[[self view] window] addSubview:flashView];
    
        [UIView animateWithDuration:.4f
                     animations:^{
                         [flashView setAlpha:0.f];
                     }
                     completion:^(BOOL finished){
                         [flashView removeFromSuperview];
                         [flashView release];
                     }
         ];
           photoCount= photoCount +1;
    }
    

    //NSInteger myInt = [prefs integerForKey:@"photoCount"];
   // photoCount=myInt;
    if([imageTot isEqualToString:@"3"])
    {
        switch (photoCount)
        {
            case 3:
            {
                [cameraTimer invalidate];
                cameraTimer = nil;
                NSLog(@"Authentication *** Before WS call ***");
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                NSData *imageData1 = [defaults dataForKey:@"image1"];
                NSData *imageData2 = [defaults dataForKey:@"image2"];
                NSData *imageData3 = [defaults dataForKey:@"image3"];
                
                
                NSString *encodedString0 =NULL;
                NSString *encodedString1 =NULL;
                NSString *encodedString2 =NULL;
                encodedString0 = [self base64forData:imageData1];
                encodedString1 = [self base64forData:imageData2];
                encodedString2 = [self base64forData:imageData3];
                
                NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];

                NSInteger userId = [prefs integerForKey:@"userId"];
                
                MBProgressHUD *hud =[MBProgressHUD showHUDAddedTo:self.view animated:YES];
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.01 * NSEC_PER_SEC);
                hud.labelText = @"Loading";

                
                
               /* NSString *soapMessage = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"no\"?> \n"
                                         "<soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\">\n"
                                         "<soapenv:Body> <validateFace xmlns=\"http://services.hubino.omar.com\"> \n"
                                         "<dataSet> <ns1:data xmlns:ns1=\"http://bo.hubino.omar.com\">%@</ns1:data>\n"
                                         "<ns2:userId xmlns:ns2=\"http://bo.hubino.omar.com\">%u</ns2:userId>\n"
                                         "</dataSet>\n"
                                         "<dataSet>\n"
                                         "<ns3:data xmlns:ns3=\"http://bo.hubino.omar.com\"> %@</ns3:data>\n"
                                         "<ns4:userId xmlns:ns4=\"http://bo.hubino.omar.com\">%u</ns4:userId>\n"
                                         "</dataSet>\n"
                                         "<dataSet> <ns5:data xmlns:ns5=\"http://bo.hubino.omar.com\">%@</ns5:data>\n"
                                         "<ns6:userId xmlns:ns6=\"http://bo.hubino.omar.com\">%u</ns6:userId>\n"
                                         "</dataSet>\n"
                                         "</validateFace> \n"
                                         "</soapenv:Body> </soapenv:Envelope>",encodedString0,userId,encodedString1,userId,encodedString2,userId];*/
                NSString *soapMessage = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"no\"?> \n"
                                         "<soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\">\n"
                                         "<soapenv:Body> <initiateFaceEngine xmlns=\"http://services.hubino.omar.com\">\n"
                                         "<images>%@</images>\n"
                                         "<images>%@</images>\n"
                                         "<images>%@</images>\n"
                                         "<userId>%u</userId>\n"
                                         "<serviceType>validateFace</serviceType>\n"
                                         "</initiateFaceEngine> \n"
                                         "</soapenv:Body> </soapenv:Envelope>",encodedString0,encodedString1,encodedString2,userId];

                
                   NSLog(@"%@==========================================",soapMessage);
                
                NSURL *url = [NSURL URLWithString:@"http://146.185.160.54:8080/ajmWeb/services/OmerWeb?wsdl"];
                NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:url];
                //NSString *msgLength = [NSString stringWithFormat:@"%d", [soapMessage length]];
                NSData *bodyData = [soapMessage dataUsingEncoding:NSUTF8StringEncoding];
                NSUInteger bodyDataLen = [bodyData length];
                NSString *bodyDataLength = [NSString stringWithFormat:@"%d", bodyDataLen];
                [theRequest addValue:@"application/soap+xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
                [theRequest addValue:@"http://bo.hubino.omar.com/" forHTTPHeaderField:@"SOAPAction"];
                [theRequest addValue:bodyDataLength forHTTPHeaderField:@"Content-Length"];
                [theRequest setHTTPMethod:@"POST"];
                [theRequest setHTTPBody: bodyData];
                
                NSURLConnection *theConnection = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
                if(theConnection) {
                    NSLog(@"Authendication Based on count, WS will be invoked");
                    conWebData = [[NSMutableData alloc] init];
                }
                else {
                    NSLog(@"theConnection is NULL");
                }

                NSUserDefaults *prefs1 = [NSUserDefaults standardUserDefaults];
                userId=userId+1;
                [prefs1 setInteger:userId forKey:@"userId"];
                [prefs1 synchronize];
                
                break;
            }
        }
    }
    if([imageTot isEqualToString:@"5"])
    {
        switch (photoCount)
        {
            
            case 5:
            {
                NSLog(@"Enrollment *** Before WS call ***");
                [cameraTimer invalidate];
                cameraTimer = nil;
            
                
                
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                NSData *imageData1 = [defaults dataForKey:@"image1"];
                NSData *imageData2 = [defaults dataForKey:@"image2"];
                NSData *imageData3 = [defaults dataForKey:@"image3"];
                NSData *imageData4 = [defaults dataForKey:@"image4"];
                NSData *imageData5 = [defaults dataForKey:@"image5"];
                
                
                NSString *encodedString0 =NULL;
                NSString *encodedString1 =NULL;
                NSString *encodedString2 =NULL;
                NSString *encodedString3 =NULL;
                NSString *encodedString4 =NULL;
                encodedString0 = [self base64forData:imageData1];
                encodedString1 = [self base64forData:imageData2];
                encodedString2 = [self base64forData:imageData3];
                encodedString3 = [self base64forData:imageData4];
                encodedString4 = [self base64forData:imageData5];
                NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
                
                // getting an NSString
                
                // getting an NSInteger
                NSInteger userId = [prefs integerForKey:@"userId"];
                
                
                
               /* NSString *soapMessage = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"no\"?> \n"
                                         "<soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\">\n"
                                         "<soapenv:Body> <prepareMetadata xmlns=\"http://services.hubino.omar.com\"> \n"
                                         "<dataSet> <ns1:data xmlns:ns1=\"http://bo.hubino.omar.com\">%@</ns1:data>\n"
                                         "<ns2:userId xmlns:ns2=\"http://bo.hubino.omar.com\">%u</ns2:userId>\n"
                                         "</dataSet>\n"
                                         "<dataSet>\n"
                                         "<ns3:data xmlns:ns3=\"http://bo.hubino.omar.com\"> %@</ns3:data>\n"
                                         "<ns4:userId xmlns:ns4=\"http://bo.hubino.omar.com\">%u</ns4:userId>\n"
                                         "</dataSet>\n"
                                         "<dataSet> <ns5:data xmlns:ns5=\"http://bo.hubino.omar.com\">%@</ns5:data>\n"
                                         "<ns6:userId xmlns:ns6=\"http://bo.hubino.omar.com\">%u</ns6:userId>\n"
                                         "</dataSet>\n"
                                         "<dataSet>\n"
                                         "<ns7:data xmlns:ns7=\"http://bo.hubino.omar.com\">%@</ns7:data>\n"
                                         "<ns8:userId xmlns:ns8=\"http://bo.hubino.omar.com\">%u</ns8:userId>\n"
                                         "</dataSet>\n"
                                         "<dataSet> <ns9:data xmlns:ns9=\"http://bo.hubino.omar.com\">%@</ns9:data>\n"
                                         "<ns10:userId xmlns:ns10=\"http://bo.hubino.omar.com\">%u</ns10:userId> </dataSet>\n"
                                         "</prepareMetadata> \n"
                                         "</soapenv:Body> </soapenv:Envelope>",encodedString0,userId,encodedString1,userId,encodedString2,userId,encodedString3,userId,encodedString4,userId];*/
                
                
                NSString *soapMessage = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"no\"?> \n"
                                         "<soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\">\n"
                                         "<soapenv:Body> <initiateFaceEngine xmlns=\"http://services.hubino.omar.com\">\n"
                                         "<images>%@</images>\n"
                                         "<images>%@</images>\n"
                                         "<images>%@</images>\n"
                                         "<images>%@</images>\n"
                                         "<images>%@</images>\n"
                                         "<userId>%u</userId>\n"
                                         "<serviceType>prepareMetadata</serviceType>\n"
                                         "</initiateFaceEngine> \n"
                                         "</soapenv:Body> </soapenv:Envelope>",encodedString0,encodedString1,encodedString2,encodedString3,encodedString4,userId];
                
                
                
                NSLog(@"%@==========================================",soapMessage);
                
                NSURL *url = [NSURL URLWithString:@"http://146.185.160.54:8080/ajmWeb/services/OmerWeb?wsdl"];
                NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:url];
                //NSString *msgLength = [NSString stringWithFormat:@"%d", [soapMessage length]];
                NSData *bodyData = [soapMessage dataUsingEncoding:NSUTF8StringEncoding];
                NSUInteger bodyDataLen = [bodyData length];
                NSString *bodyDataLength = [NSString stringWithFormat:@"%d", bodyDataLen];
                /* [theRequest addValue: @"application/soap+xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
                 [theRequest addValue: @"http://bo.hubino.omar.com/prepareMetadata" forHTTPHeaderField:@"SOAPAction"];
                 [theRequest addValue: bodyDataLength forHTTPHeaderField:@"Content-Length"];
                 [theRequest setHTTPMethod:@"POST"];
                 [theRequest setHTTPBody: bodyData];*/
                [theRequest addValue:@"application/soap+xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
                [theRequest addValue:@"http://bo.hubino.omar.com/" forHTTPHeaderField:@"SOAPAction"];
                [theRequest addValue:bodyDataLength forHTTPHeaderField:@"Content-Length"];
                [theRequest setHTTPMethod:@"POST"];
                [theRequest setHTTPBody: bodyData];
                
                NSURLConnection *theConnection = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
                 if(theConnection) {
                    NSLog(@"Enrollment Based on count, WS will be invoked");
                    conWebData = [[NSMutableData alloc] init];
                }
                else {
                    NSLog(@"theConnection is NULL");
                }

                MBProgressHUD *hud =[MBProgressHUD showHUDAddedTo:self.view animated:YES];
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.01 * NSEC_PER_SEC);
                hud.labelText = @"Loading";
                break;
                
            }
        }
    }
    
    //    NSLog(@"Photocount : %d",photoCount);
}


-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    [conWebData setLength: 0];
}


-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [conWebData appendData:data];
}


-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"ERROR with theConenction");
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    // saving an NSString
    [prefs setObject:@"N" forKey:@"enrolSuccess"];
    
    // This is suggested to synch prefs, but is not needed (I didn't put it in my tut)
    [prefs synchronize];
    
    
    ResultViewController *secondCon = [[ResultViewController alloc] initWithNibName:@"ResultViewController" bundle:nil];
    [self presentViewController:secondCon animated:YES completion:nil];
}


-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{

    
    NSLog(@"*** After WS call ***");
    // NSLog(@"DONE. Received Bytes: %d", [conWebData length]);
    NSString *theXML = [[NSString alloc] initWithBytes: [conWebData mutableBytes] length:[conWebData length] encoding:NSUTF8StringEncoding];
    //NSLog(@"%@",theXML);
    NSLog(@"%@*** After WS call ***",theXML);
    xmlParser = [[NSXMLParser alloc] initWithData: conWebData];
    [xmlParser setDelegate: self];
    [xmlParser setShouldResolveExternalEntities: YES];
    [xmlParser parse];
    
  
   // [MBProgressHUD hideHUDForView:self.view animated:YES];
    

    
}



-(void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    self.currentElementValue = string;
}
/*
 * This part is for managing the error handling
 * E00 is success then you can proceed further steps involved in the app.
 * If E01 then display the message from WS
 */

-(void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    
   /* if( [elementName isEqualToString:@"ns2:result"])
    {
         //NSLog(@"%@ message:",resultStatus);
        recordResults = FALSE;
        resultStatus=result;
        //for debugging
        if([@"true" isEqualToString:resultStatus])
        {
           soapResults = nil;
           ResultViewController *secondCon = [[ResultViewController alloc] initWithNibName:@"ResultViewController" bundle:nil];
           [self presentViewController:secondCon animated:YES completion:nil];
        }
        else
        {
            NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
            // saving an NSString
            [prefs setObject:@"N" forKey:@"enrolSuccess"];
            // This is suggested to synch prefs, but is not needed (I didn't put it in my tut)
            [prefs synchronize];
            ResultViewController *secondCon = [[ResultViewController alloc] initWithNibName:@"ResultViewController" bundle:nil];
            [self presentViewController:secondCon animated:YES completion:nil];
        }
        
    }
    if( [elementName isEqualToString:@"ns1:message"])
    {
         NSLog(@"%@ errorCode:",resultStatus);
        if([resultStatus isEqualToString:@"E00"])
        {
            NSLog(@"E00");
            NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
            [prefs setObject:resultStatus forKey:@"resultRes"];
            [prefs synchronize];
        }
        if([resultStatus isEqualToString:@"E01"])
        {
            NSLog(@"E01");
            NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
            [prefs setObject:resultStatus forKey:@"resultRes"];
            [prefs synchronize];
        }

    }*/
    
    if( [elementName isEqualToString:@"ns1:message"])
    {
        message= self.currentElementValue;
        //  NSLog(@"%@ message:",message);
        
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
        recordResults = TRUE;
    }
    if( [elementName isEqualToString:@"ns2:result"])
    {
        resultStatus= self.currentElementValue;
        //    NSLog(@"%@ resultStatus:",resultStatus);
         NSLog(@"%@ message:",resultStatus);
        if([@"true" isEqualToString:resultStatus])
        {
            soapResults = nil;
            NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
            // saving an NSString
            [prefs setObject:@"Y" forKey:@"enrolSuccess"];
            // This is suggested to synch prefs, but is not needed (I didn't put it in my tut)
            [prefs synchronize];
            ResultViewController *secondCon = [[ResultViewController alloc] initWithNibName:@"ResultViewController" bundle:nil];
            [self presentViewController:secondCon animated:YES completion:nil];
        }
        else
        {
            NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
            // saving an NSString
            [prefs setObject:@"N" forKey:@"enrolSuccess"];
            // This is suggested to synch prefs, but is not needed (I didn't put it in my tut)
            [prefs synchronize];
            ResultViewController *secondCon = [[ResultViewController alloc] initWithNibName:@"ResultViewController" bundle:nil];
            [self presentViewController:secondCon animated:YES completion:nil];
        }

      
        recordResults = TRUE;
        
    }
    
    
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

@implementation AVCamViewController (InternalMethods)

// Auto focus at a particular point. The focus mode will change to locked once the auto focus happens.
- (void)tapToAutoFocus:(UIGestureRecognizer *)gestureRecognizer
{
    if ([[[captureManager videoInput] device] isFocusPointOfInterestSupported]) {
        CGPoint tapPoint = [gestureRecognizer locationInView:[self videoPreviewView]];
		CGPoint convertedFocusPoint = [captureVideoPreviewLayer captureDevicePointOfInterestForPoint:tapPoint];
        [captureManager autoFocusAtPoint:convertedFocusPoint];
    }
}

// Change to continuous auto focus. The camera will focus as needed at the point choosen.
- (void)tapToContinouslyAutoFocus:(UIGestureRecognizer *)gestureRecognizer
{
    if ([[[captureManager videoInput] device] isFocusPointOfInterestSupported])
        [captureManager continuousFocusAtPoint:CGPointMake(.5f, .5f)];
}

// Update button states based on the number of available cameras and mics
- (void)updateButtonStates
{
	NSUInteger cameraCount = [[self captureManager] cameraCount];
	NSUInteger micCount = [[self captureManager] micCount];
    
    CFRunLoopPerformBlock(CFRunLoopGetMain(), kCFRunLoopCommonModes, ^(void) {
        if (cameraCount < 2) {
            [[self cameraToggleButton] setEnabled:NO]; 
            
            if (cameraCount < 1) {
                [[self stillButton] setEnabled:NO];
                
                if (micCount < 1)
                    [[self recordButton] setEnabled:NO];
                else
                    [[self recordButton] setEnabled:YES];
            } else {
                [[self stillButton] setEnabled:YES];
                [[self recordButton] setEnabled:YES];
            }
        } else {
            [[self cameraToggleButton] setEnabled:YES];
            [[self stillButton] setEnabled:YES];
            [[self recordButton] setEnabled:YES];
        }
    });
}

@end

@implementation AVCamViewController (AVCamCaptureManagerDelegate)

- (void)captureManager:(AVCamCaptureManager *)captureManager didFailWithError:(NSError *)error
{
    CFRunLoopPerformBlock(CFRunLoopGetMain(), kCFRunLoopCommonModes, ^(void) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[error localizedDescription]
                                                            message:[error localizedFailureReason]
                                                           delegate:nil
                                                  cancelButtonTitle:NSLocalizedString(@"OK", @"OK button title")
                                                  otherButtonTitles:nil];
        [alertView show];
        [alertView release];
    });
}

- (void)captureManagerRecordingBegan:(AVCamCaptureManager *)captureManager
{
    CFRunLoopPerformBlock(CFRunLoopGetMain(), kCFRunLoopCommonModes, ^(void) {
        [[self recordButton] setTitle:NSLocalizedString(@"Stop", @"Toggle recording button stop title")];
        [[self recordButton] setEnabled:YES];
    });
}

- (void)captureManagerRecordingFinished:(AVCamCaptureManager *)captureManager
{
    CFRunLoopPerformBlock(CFRunLoopGetMain(), kCFRunLoopCommonModes, ^(void) {
        [[self recordButton] setTitle:NSLocalizedString(@"Record", @"Toggle recording button record title")];
        [[self recordButton] setEnabled:YES];
    });
}

- (void)captureManagerStillImageCaptured:(AVCamCaptureManager *)captureManager
{
    CFRunLoopPerformBlock(CFRunLoopGetMain(), kCFRunLoopCommonModes, ^(void) {
        [[self stillButton] setEnabled:YES];
    });
}

- (void)captureManagerDeviceConfigurationChanged:(AVCamCaptureManager *)captureManager
{
	[self updateButtonStates];
}

@end
