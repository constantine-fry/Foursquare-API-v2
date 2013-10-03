//
//  Foursquare_APIAppDelegate.m
//  Foursquare API
//
//  Created by Constantine Fry on 10/10/10.
//  Copyright 2010 Home. All rights reserved.
//

#import "FSAppDelegate.h"
#import "NearbyVenuesViewController.h"
#import "Foursquare2.h"

@implementation FSAppDelegate

@synthesize window;
//@synthesize viewController;


#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [Foursquare2 setupFoursquareWithClientId:@"5P1OVCFK0CCVCQ5GBBCWRFGUVNX5R4WGKHL2DGJGZ32FDFKT"
                                      secret:@"UPZJO0A0XL44IHCD1KQBMAYGCZ45Z03BORJZZJXELPWHPSAR"
                                 callbackURL:@"testapp123://foursquare"];
    return YES;
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    
    return [Foursquare2 handleURL:url];
}


@end
