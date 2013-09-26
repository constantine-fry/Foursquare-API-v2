

#import "FSTargetCallback.h"


@implementation FSTargetCallback

- (id)initWithCallback:(callback_block)callback
        resultCallback:(SEL)aResultCallback
            requestUrl:(NSString *)aRequestUrl
              numTries:(int)numberTries {
    self = [super init];
    if (self) {
        self.callback = callback;
        self.resultCallback = aResultCallback;
        self.requestUrl = aRequestUrl;
        self.numTries = numberTries;
    }
	return self;
}



@end
