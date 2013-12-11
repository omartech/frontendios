//
//  CommonFunction.m
//  AMJIOS
//
// Copyright (c) 2013 Hubino  All rights reserved.
//

#import "CommonFunction.h"

@implementation CommonFunction

NSString *strtoken;
NSString *retValue;
BOOL isCompareImageSelected;
UIImage *capturedImage;
NSMutableArray *userFriendFBlist;
BOOL isloadDataFirstTime;
NSString *checkPhotoLib;
double distance_between_eyes;
BOOL ImageCaptured;

#pragma mark -
#pragma mark - selected friend function

+(NSString *) AddItemsenderlist:(int)value InList:(NSString *)list
{
    retValue = [[NSString stringWithFormat:@"%@:%d:",list,value]retain];
    
    return retValue;
    
}
+(NSString *) RemoveItemtosenderlist:(int)value FromList:(NSString *)list
{
    
    retValue = [[list stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@":%d:",value] withString:@""] retain];
    return retValue;
}
+(BOOL) isValueAvailable:(int)value InList:(NSString *)list
{
    NSRange range = [list rangeOfString:[NSString stringWithFormat:@":%d:",value]];
	if(range.length > 0)
	{
		return TRUE;
	}
	return FALSE;
}
+(NSMutableArray *) GetItemsListArray:(NSString *)str
{
    
	return nil;
}

#pragma mark -
//-(UIImage *) CropImageFromTop:(UIImage *)image
//{
//    CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], CGRectMake(0, 12, image.size.width, image.size.height - 12));
//    UIImage *cropimage = [[[UIImage alloc] initWithCGImage:imageRef] autorelease];
//    CGImageRelease(imageRef);
//    return cropimage;
//}
+(UIImage *) GetImageFromName:(NSString *)imageName
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *filePath = [NSString stringWithFormat:@"%@/%@",[paths objectAtIndex:0],imageName];
    UIImage *image = nil;
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        image = [UIImage imageWithContentsOfFile:filePath];
    }
    else
    {
        image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:imageName ofType:nil]];
    }
    return image;
    
}

+(UIImage *) GetImageFromUrl:(NSString *)imageName
{
//    NSLog(@"%@",imageName);
    UIImage *image = nil;
    image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:imageName]]];
//    [self performSelectorOnMainThread:@selector(placeImageInUI:) withObject:image waitUntilDone:YES];
    return image;
}

@end
