//
//  EnrollmentDoneViewController.m
//  AVCam
//
//  Created by Hubino on 20/11/13.
//
//

#import "EnrollmentDoneViewController.h"
#import "MainViewController.h"

@interface EnrollmentDoneViewController ()

@end

@implementation EnrollmentDoneViewController

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
- (IBAction)home:(id)sender
{
    MainViewController *secondCon = [[MainViewController alloc] initWithNibName:@"MainViewController" bundle:nil];
    [self presentViewController:secondCon animated:YES completion:nil];
}

@end
