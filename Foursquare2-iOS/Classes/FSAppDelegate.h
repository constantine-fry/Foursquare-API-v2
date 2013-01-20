//
//  Foursquare_APIAppDelegate.h
//  Foursquare API
//
//  Created by Constantine Fry on 10/10/10.
//  Copyright 2010 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Foursquare2.h"

@interface FSAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;

-(void)test_method;
@end

