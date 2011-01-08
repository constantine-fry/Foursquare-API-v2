#import "NSURLAdditions.h"

@implementation NSURL (Additions)

// http://stackoverflow.com/questions/2579544/nsstrings-stringbyappendingpathcomponent-removes-a-in-http
- (NSURL *)URLBySmartlyAppendingPathComponent:(NSString *)component 
{
    NSString *newPath = [[self path] stringByAppendingPathComponent:component];
    return [[[NSURL alloc] initWithScheme: [self scheme] 
                                     host: [self host] 
                                     path: newPath]
			autorelease];
}	

@end
