//
//  CommonFunction.h
//  AMJIOS
//
// Copyright (c) 2013 Hubino  All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CommonFunction : NSObject

extern NSString *strtoken;
extern NSString *checkPhotoLib;
extern BOOL isCompareImageSelected;
extern UIImage *capturedImage;
extern NSMutableArray *userFriendFBlist;
extern BOOL isloadDataFirstTime;
extern double distance_between_eyes;
extern BOOL ImageCaptured;
#define RGBCOLOR(r,g,b) \
[UIColor colorWithRed:r/256.f green:g/256.f blue:b/256.f alpha:1.f]

//#define IS_IPHONE ( [[[UIDevice currentDevice] model] isEqualToString:@"iPhone"] )
//#define IS_IPOD   ( [[[UIDevice currentDevice ] model] isEqualToString:@"iPod touch"] )
#define IS_HEIGHT_GTE_568 [[UIScreen mainScreen ] bounds].size.height >= 568.0f
#define IS_IPHONE_5 (IS_HEIGHT_GTE_568)

#define isRegistered @"ZZZ__IsRegistered_FCwF__ZZZ"

enum FBEvent
{
    FBEventCompareFriends = 0,
    FBEventInviteFriends
};
enum ImageCaptureType
{
    ImageCaptureTypeCamera = 0,
    ImageCaptureTypeLibrary
};

enum UserImageType
{
    UserImageTypeMale = 0,
    UserImageTypeFemale
};

enum listType
{
    listTypeAll = 0,
    listTypeMale,
    listTypeFemale
};

#pragma mark -
#pragma mark - function
+(NSString *) AddItemsenderlist:(int)value InList:(NSString *)list;
+(NSString *) RemoveItemtosenderlist:(int)value FromList:(NSString *)list;
+(BOOL) isValueAvailable:(int)value InList:(NSString *)list;
+(NSMutableArray *) GetItemsListArray:(NSString *)str;
+(UIImage *) GetImageFromName:(NSString *)imageName;
+(UIImage *) GetImageFromUrl:(NSString *)imageName;
@end
