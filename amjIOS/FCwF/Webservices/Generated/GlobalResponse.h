/*
	GlobalResponse.h
	The interface definition of properties and methods for the GlobalResponse object.
	Generated by SudzC.com
*/

#import "Soap.h"
	

@interface GlobalResponse : SoapObject
{
	NSString* _enrollImageCount;
	NSString* _authImageCount;
	NSString* _eyeDistanceValue;
	NSString* _cameraDistanceValue;
	NSString* _thresholdValue;
	NSString* _message;
	BOOL _result;
	
}
		
	@property (retain, nonatomic) NSString* enrollImageCount;
	@property (retain, nonatomic) NSString* authImageCount;
	@property (retain, nonatomic) NSString* eyeDistanceValue;
	@property (retain, nonatomic) NSString* cameraDistanceValue;
	@property (retain, nonatomic) NSString* thresholdValue;
	@property (retain, nonatomic) NSString* message;
	@property BOOL result;

	+ (GlobalResponse*) createWithNode: (CXMLNode*) node;
	- (id) initWithNode: (CXMLNode*) node;
	- (NSMutableString*) serialize;
	- (NSMutableString*) serialize: (NSString*) nodeName;
	- (NSMutableString*) serializeAttributes;
	- (NSMutableString*) serializeElements;

@end