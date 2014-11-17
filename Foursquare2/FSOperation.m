//
//  FSOperation.m
//  Foursquare2
//
//  Created by Constantine Fry on 16/02/14.
//
//

#import "FSOperation.h"
#import "Foursquare2.h"

@interface FSOperation ()

@property (nonatomic, copy) Foursquare2Callback callbackBlock;
@property (nonatomic, strong) NSURLRequest *request;
@property (nonatomic) dispatch_queue_t callbackQueue;

@end

@implementation FSOperation

- (id)initWithRequest:(NSURLRequest *)request
             callback:(Foursquare2Callback)block 
        callbackQueue:(dispatch_queue_t)callbackQueue {
                     
    self = [super init];
    if (self) {
        self.callbackBlock = block;
        self.request = request;
        self.callbackQueue = callbackQueue;
    }
    return self;
}

- (void)main {
    NSError *error;
    id result;
    
    NSHTTPURLResponse *response;
    
    if ([self isCancelled]) {
        return;
    }
    
    NSData *receivedData = [NSURLConnection sendSynchronousRequest:self.request
                                                 returningResponse:&response
                                                             error:&error];
    
    if ([self isCancelled]) {
        return;
    }
    
    if (receivedData) {
        result = [NSJSONSerialization JSONObjectWithData:receivedData
                                                 options:0
                                                   error:&error];
        if (result) {
            if ([result isKindOfClass:[NSError class]]) {
                error = result;
            } else if ([result valueForKeyPath:@"meta.errorDetail"]) {
                NSString *detail = [result valueForKeyPath:@"meta.errorDetail"];
                NSDictionary *userInfo = @{NSLocalizedDescriptionKey:detail};
                error = [NSError errorWithDomain:kFoursquare2ErrorDomain
                                            code:[result[@"meta"][@"code"] integerValue]
                                        userInfo:userInfo];
            } else { // NIL the error in the other case
                error = nil;
            }
            
            if ([[response allHeaderFields] objectForKey:@"X-RateLimit-Limit"] && [[response allHeaderFields] objectForKey:@"X-RateLimit-Remaining"]) {
                NSMutableDictionary *mutableResult = [result mutableCopy];
                NSMutableDictionary *mutableMeta = [[result objectForKey:@"meta"] mutableCopy];
                [mutableMeta setObject:[[response allHeaderFields] objectForKey:@"X-RateLimit-Limit"] forKey:@"RateLimit"];
                [mutableMeta setObject:[[response allHeaderFields] objectForKey:@"X-RateLimit-Remaining"] forKey:@"RateLimit-Remaining"];
                [mutableResult setObject:[NSDictionary dictionaryWithDictionary:mutableMeta] forKey:@"meta"];
                result = [NSDictionary dictionaryWithDictionary:mutableResult];
            }
        }
    }
    
    if ([self isCancelled]) {
        return;
    }
    
    
    dispatch_async(self.callbackQueue, ^{
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
