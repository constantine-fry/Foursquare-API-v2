    //
//  ElanceWebLogin.m
//  elance
//
//  Created by Constantine Fry on 12/20/10.
//  Copyright 2010 Home. All rights reserved.
//

#import "FoursquareWebLogin.h"
#import "Foursquare2.h"


@implementation FoursquareWebLogin
@synthesize delegate,selector;
// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
    }
    return self;
}
*/

- (id) initWithUrl:(NSString*)url
{
	self = [super init];
	if (self != nil) {
		_url = url;
	}
	return self;
}



// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
	[super loadView];
	webView = [[UIWebView alloc]initWithFrame:CGRectMake(0, 0, 320, 480)];
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:_url]];
	[webView loadRequest:request];
	[webView setDelegate:self];
	[self.view addSubview:webView];
	[webView release];
	

}

-(void)cancel{
	[self dismissModalViewControllerAnimated:YES];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
	NSString *url =[[request URL] absoluteString];
	if ([url rangeOfString:@"code="].length != 0) {
		
		NSHTTPCookie *cookie;
		NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
		for (cookie in [storage cookies]) {
			if ([[cookie domain]isEqualToString:@"foursquare.com"]) {
				[storage deleteCookie:cookie];
			}
		}
		
		NSArray *arr = [url componentsSeparatedByString:@"="];
		[delegate performSelector:selector withObject:[arr objectAtIndex:1]];
		[self cancel];
	}else if ([url rangeOfString:@"error="].length != 0) {
		NSArray *arr = [url componentsSeparatedByString:@"="];
		[delegate performSelector:selector withObject:[arr objectAtIndex:1]];
		NSLog(@"Foursquare: %@",[arr objectAtIndex:1]);
	} 
	return YES;
}
- (void)webViewDidStartLoad:(UIWebView *)webView{
}
- (void)webViewDidFinishLoad:(UIWebView *)webView{
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
}

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end
