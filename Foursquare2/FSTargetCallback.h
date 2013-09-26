

#import <Foundation/Foundation.h>
typedef void(^callback_block)(BOOL success, id result);

@interface FSTargetCallback : NSObject

@property (weak, nonatomic)	id			targetObject;
@property (assign, nonatomic)	SEL			targetCallback;
@property (assign, nonatomic)	SEL			resultCallback;
@property (copy, nonatomic)		NSString		*requestUrl;		
@property (strong, nonatomic)	NSURLRequest	*request;		
@property (assign, nonatomic)	int			numTries;		
@property (copy,nonatomic)callback_block callback;

@property (strong, nonatomic) NSMutableData	*receivedData;		

- (id) initWithCallback:(callback_block)callback
         resultCallback:(SEL)aResultCallback
             requestUrl:(NSString *)aRequestUrl
               numTries:(int)numberTries;

@end
