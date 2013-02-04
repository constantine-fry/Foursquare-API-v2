//
//  Foursquare_APIAppDelegate.m
//  Foursquare API
//
//  Created by Constantine Fry on 10/10/10.
//  Copyright 2010 Home. All rights reserved.
//

#import "FSAppDelegate.h"
#import "NearbyVenuesViewController.h"

@implementation FSAppDelegate

@synthesize window;
//@synthesize viewController;


#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    UIViewController *c = [[NearbyVenuesViewController alloc]init];
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:c];
    window.rootViewController = nav;
    [window makeKeyAndVisible];
	return YES;
}


@end
