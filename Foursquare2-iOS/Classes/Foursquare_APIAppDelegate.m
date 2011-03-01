//
//  Foursquare_APIAppDelegate.m
//  Foursquare API
//
//  Created by Constantine Fry on 10/10/10.
//  Copyright 2010 Home. All rights reserved.
//

#import "Foursquare_APIAppDelegate.h"
#import "FoursquareWebLogin.h"


@implementation Foursquare_APIAppDelegate

@synthesize window;
//@synthesize viewController;


#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]]; 
    viewController = [[UIViewController alloc]init];
	viewController.view.frame =CGRectMake(0, 0, 320, 480);
	viewController.view.backgroundColor = [UIColor grayColor];
    [window addSubview:viewController.view];
	[viewController viewWillAppear:YES];
    [window makeKeyAndVisible];

//	[Foursquare2 removeAccessToken];
	if ([Foursquare2 isNeedToAuthorize]) {
		[self authorizeWithViewController:viewController 
                                 Callback:^(BOOL success,id result){
			if (success) {
				[Foursquare2  getDetailForUser:@"self"
									  callback:^(BOOL success, id result){
										  if (success) {
											  [self test_method];
										  }
									  }];
			}
		}];
	}else {
		
		[Foursquare2  getDetailForUser:@"self"
							  callback:^(BOOL success, id result){
								  if (success) {
									  [self test_method];
								  }
							  }];

//		Example check-in 
//		[Foursquare2  createCheckinAtVenue:@"6522771"
//									 venue:nil
//									 shout:@"Testing"
//								 broadcast:broadcastPublic
//								  latitude:nil
//								 longitude:nil
//								accuracyLL:nil
//								  altitude:nil
//							   accuracyAlt:nil
//								  callback:^(BOOL success, id result){
//								if (success) {
//									NSLog(@"%@",result);
//								}
//							}];
	}
	return YES;
}

-(void)test_method{
    NSLog(@"test");
}

Foursquare2Callback authorizeCallbackDelegate;
-(void)authorizeWithViewController:(UIViewController*)controller
						  Callback:(Foursquare2Callback)callback{
	authorizeCallbackDelegate = [callback copy];
	NSString *url = [NSString stringWithFormat:@"https://foursquare.com/oauth2/authenticate?display=touch&client_id=%@&response_type=code&redirect_uri=%@",OAUTH_KEY,REDIRECT_URL];
	FoursquareWebLogin *loginCon = [[FoursquareWebLogin alloc] initWithUrl:url];
	loginCon.delegate = self;
	loginCon.selector = @selector(setCode:);
	UINavigationController *navCon = [[UINavigationController alloc]initWithRootViewController:loginCon];
	
	[controller presentModalViewController:navCon animated:YES];
	[navCon release];
	[loginCon release];	
}

-(void)setCode:(NSString*)code{
	[Foursquare2 getAccessTokenForCode:code callback:^(BOOL success,id result){
		if (success) {
			[Foursquare2 setBaseURL:[NSURL URLWithString:@"https://api.foursquare.com/v2/"]];
			[Foursquare2 setAccessToken:[result objectForKey:@"access_token"]];
			authorizeCallbackDelegate(YES,result);
            [authorizeCallbackDelegate release];
		}
	}];
}


- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}


- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     See also applicationDidEnterBackground:.
     */
}


#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}


- (void)dealloc {
    [viewController release];
    [window release];
    [super dealloc];
}


@end
