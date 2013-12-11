//
//  OverlayViewController.h
//  GoldenBeautyMeter
//
// Copyright (c) 2013 Hubino  All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol OverlayViewControllerDelegate
- (void)didTakePicture:(UIImage *)picture;
- (void)didFinishWithCamera;
@end

@interface OverlayViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate>
{
    id <OverlayViewControllerDelegate> delegate;
    
    UIImagePickerController *imagePickerController;
}

@property (nonatomic, strong) id <OverlayViewControllerDelegate> delegate;
@property (nonatomic, strong) UIImagePickerController *imagePickerController;

- (void)setupImagePicker:(UIImagePickerControllerSourceType)sourceType;

@end


