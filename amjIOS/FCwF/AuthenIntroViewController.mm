//
//  AuthenIntroViewController.m
//  amjIOS
//
//  Created by Hubino on 09/12/13.
// Copyright (c) 2013 Hubino  All rights reserved.
//

#import "AuthenIntroViewController.h"
#import "CaptureViewController.h"
#import "ViewController.h"

@interface AuthenIntroViewController ()

@end

@implementation AuthenIntroViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)OK:(id)sender
{
    
    CaptureViewController *obj = [[[CaptureViewController alloc] initWithNibName:@"CaptureViewController" bundle:nil]autorelease];
    [self.navigationController pushViewController:obj animated:TRUE];
    obj = nil;
    
}
- (IBAction)Cancel:(id)sender
{
    
    ViewController *obj = [[[ViewController alloc] initWithNibName:@"ViewController" bundle:nil]autorelease];
    [self.navigationController pushViewController:obj animated:TRUE];
    obj = nil;
    
}

@end
