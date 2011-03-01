//
//  Foursquare_APIAppDelegate.h
//  Foursquare API
//
//  Created by Constantine Fry on 10/10/10.
//  Copyright 2010 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Foursquare2.h"

@interface Foursquare_APIAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    UIViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
-(void)authorizeWithViewController:(UIViewController*)controller
						  Callback:(Foursquare2Callback)callback;
-(void)setCode:(NSString*)code;
-(void)test_method;
@end

