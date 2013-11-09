    //
//  ElanceWebLogin.m
//  elance
//
//  Created by Constantine Fry on 12/20/10.
//  Copyright 2010 Home. All rights reserved.
//

#import "FSWebLogin.h"
#import "Foursquare2.h"

@interface Foursquare2 (InterfaceTick)
+ (void)setAccessToken:(NSString *)token;
@end

@interface FSWebLogin () <UIWebViewDelegate>

@property (nonatomic, strong) NSString *url;
@property (nonatomic, weak) IBOutlet UIWebView *webView;

@end

@implementation FSWebLogin

- (id) initWithUrl:(NSString *)url {
	self = [super init];
	if (self != nil) {
		self.url = url;
	}
	return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"Login", nil);
    self.navigationItem.leftBarButtonItem =
    [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Cancel", nil)
                                     style:UIBarButtonSystemItemCancel
                                    target:self
                                    action:@selector(cancel)];
	
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:self.url]];
	[self.webView loadRequest:request];
}




- (void)cancel {
	[self dismissViewControllerAnimated:YES completion:^{
        [self.delegate performSelector:self.selector withObject:nil afterDelay:0];
    }];
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"

- (BOOL)webView:(UIWebView *)webView
shouldStartLoadWithRequest:(NSURLRequest *)request
 navigationType:(UIWebViewNavigationType)navigationType {
	NSString *url =[[request URL] absoluteString];
	if ([url rangeOfString:@"access_token="].length != 0) {
		NSHTTPCookie *cookie;
		NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
		for (cookie in [storage cookies]) {

			if ([[cookie domain]isEqualToString:@"foursquare.com"]) {
				[storage deleteCookie:cookie];
			}
		}
		
		NSArray *arr = [url componentsSeparatedByString:@"="];
        [Foursquare2 setAccessToken:arr[1]];
		[self dismissViewControllerAnimated:YES completion:^{
            [self.delegate performSelector:self.selector withObject:nil];
        }];
	}else if ([url rangeOfString:@"error="].length != 0) {
		NSArray *arr = [url componentsSeparatedByString:@"="];
		[self.delegate performSelector:self.selector withObject:arr[1]];
	} 

	return YES;
}
#pragma clang diagnostic pop
- (void)webViewDidStartLoad:(UIWebView *)webView {
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
}

@end
