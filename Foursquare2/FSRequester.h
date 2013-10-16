

//#import <UIKit/UIKit.h>
#define TIMEOUT_INTERVAL 45

@class FSTargetCallback;
@interface FSRequester : NSObject

@property (strong,nonatomic) NSMutableArray *requestHistory;
@property (strong, nonatomic)	NSMutableDictionary *asyncConnDict;

- (void) makeAsyncRequestWithRequest:(NSURLRequest *)urlRequest target:(FSTargetCallback *)target;
@end
