//
//  FSOperation.m
//  Foursquare2
//
//  Created by Constantine Fry on 16/02/14.
//
//

#import "FSOperation.h"

@interface FSOperation ()

@property (nonatomic, copy) Foursquare2Callback callbackBlock;
@property (nonatomic, strong) NSURLRequest *request;

@end

@implementation FSOperation

- (id)initWithRequest:(NSURLRequest *)request
             callback:(Foursquare2Callback)block {
    self = [super init];
    if (self) {
        self.callbackBlock = block;
        self.request = request;
    }
    return self;
}

- (void)main {
    NSError *error;
    id result;
    
    NSURLResponse *response;
    NSData *receivedData = [NSURLConnection sendSynchronousRequest:self.request
                                                 returningResponse:&response
                                                             error:&error];
    
    if (receivedData) {
        result = [NSJSONSerialization JSONObjectWithData:receivedData
                                                 options:0
                                                   error:&error];
        if (result) {
            if ([result isKindOfClass:[NSError class]]) {
                error = result;
            } else if ([result valueForKeyPath:@"meta.errorDetail"]) {
#warning THINK about it.
                error = [NSError errorWithDomain:@"Foursquare2"
                                            code:-1
                                        userInfo:nil];
                //                target.callback(NO, [result valueForKeyPath:@"meta.errorDetail"]);
            }
        }
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (error) {
            self.callbackBlock(NO, error);
        } else {
            self.callbackBlock(YES, result);
        }
    });
    
}

- (BOOL)isConcurrent {
    return YES;
}

@end
