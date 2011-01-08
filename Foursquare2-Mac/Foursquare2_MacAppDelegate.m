//
//  Foursquare2_MacAppDelegate.m
//  Foursquare2-Mac
//
//  Created by Constantine Fry on 1/8/11.
//  Copyright 2011 Home. All rights reserved.
//

#import "Foursquare2_MacAppDelegate.h"
#import "Foursquare2.h"

@implementation Foursquare2_MacAppDelegate

@synthesize window;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	// Insert code here to initialize your application 
	
	//you need to get access token vie Oauth2
	//please read documentation http://developer.foursquare.com/docs/oauth.html
	//this access token just for testing
	[Foursquare2 setAccessToken:@"0Y05CMDZ1LBMAILF1ZZOXKQUXCEUZT1X0Z55IM0FKMVRXDI5"];
	[Foursquare2 sendFriendRequestToUser:@"2363525"
								callback:^(BOOL success, id result){
					 if (success) {
						 NSLog(@"%@",result);
					 }
				 }];
}

@end
