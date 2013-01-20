

//#import <UIKit/UIKit.h>
#define TIMEOUT_INTERVAL 45

@class FSTargetCallback;
@interface FSRequester : NSObject{
    BOOL needToShowErrorAlert;
}

@property (strong,nonatomic) NSMutableArray *requestHistory;
@property (strong, nonatomic)	NSMutableDictionary *asyncConnDict;


- (void)handleConnectionError:(NSError *)error;
- (void) makeAsyncRequest:(NSURL *)url target:(FSTargetCallback *)target;
- (void) makeAsyncRequestWithRequest:(NSURLRequest *)urlRequest target:(FSTargetCallback *)target;
@end
