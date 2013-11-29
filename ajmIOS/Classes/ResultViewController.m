//
//  ResultViewController.m
//  AVCam
//
//  Created by Hubino on 20/11/13.
//
//

#import "ResultViewController.h"

#import "MainViewController.h"

@interface ResultViewController ()

@end

@implementation ResultViewController
@synthesize resultStatus;
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
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    // getting an NSString
    NSString *myString = [prefs stringForKey:@"enrolSuccess"];
    NSString *typeSelect = [prefs stringForKey:@"typeSelect"];
    NSString *resultRes = [prefs stringForKey:@"resultRes"];
    
    if([@"Y" isEqualToString:myString])
    {
        if([@"enroll" isEqualToString:typeSelect])
        {
            if([@"E00" isEqualToString:resultRes])
            {
                resultStatus.text=@"Enrollment Success";
            }else
            {
                resultStatus.text=@"Enrollment Failure";
            }
        }
        else
        {
            
            if([@"E00" isEqualToString:resultRes])
            {
                resultStatus.text=@"Authentication Success";
            }else
            {
                resultStatus.text=@"Authentication Failure";
            }
        }
    }
    else{
        resultStatus.text=@"Server busy please try again later";
    }
    
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
