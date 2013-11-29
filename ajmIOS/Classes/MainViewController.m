//
//  MainViewController.m
//  AVCam
//
//  Created by Hubino on 20/11/13.
//
//

#import "MainViewController.h"
#import "AVCamViewController.h"


@interface MainViewController ()

@end

@implementation MainViewController
int userIDTest=1;
@synthesize width,height;
@synthesize userId;
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
    NSInteger myInt = [prefs integerForKey:@"userId"];
    if(myInt>=1)
    {
        userId.text=[NSString stringWithFormat: @"%d", myInt];
        

    }
    else
    {
        userId.text=[NSString stringWithFormat: @"%d", userIDTest];
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        [prefs setInteger:userIDTest forKey:@"userId"];
        [prefs synchronize];
    }
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:NULL forKey:@"image1"];
    [defaults setObject:NULL forKey:@"image2"];
    [defaults setObject:NULL forKey:@"image3"];
    [defaults setObject:NULL forKey:@"image4"];
    [defaults setObject:NULL forKey:@"image5"];
    [defaults synchronize];

    // Do any additional setup after loading the view from its nib.
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)enrollment:(id)sender
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    // saving an NSString
    //[prefs setObject:@"TextToSave" forKey:@"keyToLookupString"];
    // saving an NSInteger
    [prefs setInteger:5 forKey:@"photoCount"];
    [prefs setObject:@"enroll" forKey:@"typeSelect"];
    [prefs setInteger:@"5" forKey:@"imageTot"];
    [prefs setInteger:[userId.text intValue] forKey:@"userId"];
    // This is suggested to synch prefs, but is not needed (I didn't put it in my tut)
    [prefs synchronize];
    AVCamViewController *secondCon = [[AVCamViewController alloc] initWithNibName:@"AVCamViewController" bundle:nil];
    [self presentViewController:secondCon animated:YES completion:nil];
}




- (IBAction)authendication:(id)sender
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setObject:@"authen" forKey:@"typeSelect"];
    [prefs setInteger:3 forKey:@"photoCount"];
    [prefs setInteger:NULL forKey:@"imageTot"];
    [prefs setInteger:[userId.text intValue] forKey:@"userId"];
    [prefs synchronize];
    AVCamViewController *secondCon = [[AVCamViewController alloc] initWithNibName:@"AVCamViewController" bundle:nil];
    [self presentViewController:secondCon animated:YES completion:nil];
}

@end
