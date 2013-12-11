/*
	ServiceResponse.h
	The implementation of properties and methods for the ServiceResponse object.
	Generated by SudzC.com
*/
#import "ServiceResponse.h"

@implementation ServiceResponse
	@synthesize message = _message;
	@synthesize result = _result;
	@synthesize faceAuthKey = _faceAuthKey;

	- (id) init
	{
		if(self = [super init])
		{
			self.message = nil;
			self.faceAuthKey = nil;

		}
		return self;
	}

	+ (ServiceResponse*) createWithNode: (CXMLNode*) node
	{
		if(node == nil) { return nil; }
		return [[[self alloc] initWithNode: node] autorelease];
	}

	- (id) initWithNode: (CXMLNode*) node {
		if(self = [super initWithNode: node])
		{
			self.message = [Soap getNodeValue: node withName: @"message"];
			self.result = [[Soap getNodeValue: node withName: @"result"] boolValue];
			self.faceAuthKey = [Soap getNodeValue: node withName: @"faceAuthKey"];
		}
		return self;
	}

	- (NSMutableString*) serialize
	{
		return [self serialize: @"ServiceResponse"];
	}
  
	- (NSMutableString*) serialize: (NSString*) nodeName
	{
		NSMutableString* s = [NSMutableString string];
		[s appendFormat: @"<%@", nodeName];
		[s appendString: [self serializeAttributes]];
		[s appendString: @">"];
		[s appendString: [self serializeElements]];
		[s appendFormat: @"</%@>", nodeName];
		return s;
	}
	
	- (NSMutableString*) serializeElements
	{
		NSMutableString* s = [super serializeElements];
		if (self.message != nil) [s appendFormat: @"<message>%@</message>", [[self.message stringByReplacingOccurrencesOfString:@"\"" withString:@"&quot;"] stringByReplacingOccurrencesOfString:@"&" withString:@"&amp;"]];
		[s appendFormat: @"<result>%@</result>", (self.result)?@"true":@"false"];
		if (self.faceAuthKey != nil) [s appendFormat: @"<faceAuthKey>%@</faceAuthKey>", [[self.faceAuthKey stringByReplacingOccurrencesOfString:@"\"" withString:@"&quot;"] stringByReplacingOccurrencesOfString:@"&" withString:@"&amp;"]];

		return s;
	}
	
	- (NSMutableString*) serializeAttributes
	{
		NSMutableString* s = [super serializeAttributes];

		return s;
	}
	
	-(BOOL)isEqual:(id)object{
		if(object != nil && [object isKindOfClass:[ServiceResponse class]]) {
			return [[self serialize] isEqualToString:[object serialize]];
		}
		return NO;
	}
	
	-(NSUInteger)hash{
		return [Soap generateHash:self];

	}
	
	- (void) dealloc
	{
		self.message = nil;
		self.faceAuthKey = nil;
		[super dealloc];
	}

@end