

#import "FSTargetCallback.h"


@implementation FSTargetCallback

@synthesize targetObject;
@synthesize targetCallback;
@synthesize resultCallback;
@synthesize requestUrl;
@synthesize request;
@synthesize numTries;
@synthesize callback;
@synthesize receivedData;


- (id) initWithCallback: (callback_block )callback_ 
         resultCallback: (SEL) aResultCallback
             requestUrl: (NSString *) aRequestUrl
               numTries: (int) numberTries
{

	
    self = [super init];
    if (self) {
        self.callback = callback_;
        self.resultCallback = aResultCallback;
        self.requestUrl = aRequestUrl;
        
        self.numTries = numberTries;

        
    }

	
	return self;
}



@end
