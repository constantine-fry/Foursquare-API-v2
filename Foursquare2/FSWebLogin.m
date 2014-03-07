    //
//  ElanceWebLogin.m
//  elance
//
//  Created by Constantine Fry on 12/20/10.
//  Copyright 2010 Home. All rights reserved.
//

#import "FSWebLogin.h"
#import "Foursquare2.h"

@interface FSWebLogin () <UIWebViewDelegate>

@property (nonatomic, strong) NSString *url;
@property (nonatomic, weak) IBOutlet UIWebView *webView;
@property (nonatomic, weak) id<FSWebLoginDelegate> delegate;
@end

@implementation FSWebLogin

- (id) initWithUrl:(NSString *)url andDelegate:(id<FSWebLoginDelegate>)delegate{
	self = [super init];
	if (self != nil) {
		self.url = url;
        self.delegate = delegate;
        [self removeCookiesFromPreviousLogin];
	}
	return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"Login", nil);
    self.navigationItem.leftBarButtonItem =
    [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                  target:self
                                                  action:@selector(cancelButtonTapped)];
	
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:self.url]];
	[self.webView loadRequest:request];
}

- (void)cancelButtonTapped {
    NSError *error = [NSError errorWithDomain:kFoursquare2ErrorDomain code:Foursquare2ErrorCancelled userInfo:@{ NSLocalizedFailureReasonErrorKey : @"Web login cancelled"}];
    [self.delegate webLogin:self didFinishWithError:error];
}

- (BOOL)webView:(UIWebView *)webView
shouldStartLoadWithRequest:(NSURLRequest *)request
 navigationType:(UIWebViewNavigationType)navigationType {
    NSString *urlString = [[request URL] absoluteString];
    if ([urlString rangeOfString:@"error"].length == 0 &&
        [urlString rangeOfString:@"access_token"].length == 0) {
        return YES;
    }
    
    NSError *error;
	if ([urlString rangeOfString:@"error="].length != 0) {
		NSArray *array = [urlString componentsSeparatedByString:@"="];
        NSDictionary *userInfo = @{NSLocalizedFailureReasonErrorKey:array[1]};
        error = [NSError errorWithDomain:kFoursquare2ErrorDomain code:Foursquare2ErrorUnknown userInfo:userInfo];
	}
    [self.delegate webLogin:self didFinishWithError:error];
	return YES;
}

- (void)removeCookiesFromPreviousLogin {
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (NSHTTPCookie *cookie in [storage cookies]) {
        if ([[cookie domain] rangeOfString:@"foursquare.com"].length) {
            [storage deleteCookie:cookie];
        }
    }
}

@end
