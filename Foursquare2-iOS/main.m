//
//  main.m
//  Foursquare API
//
//  Created by Constantine Fry on 10/10/10.
//  Copyright 2010 Home. All rights reserved.
//

#import <UIKit/UIKit.h>

int main(int argc, char *argv[]) {
    
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    int retVal = UIApplicationMain(argc, argv, @"UIApplication", @"Foursquare_APIAppDelegate");
    [pool release];
    return retVal;
}
