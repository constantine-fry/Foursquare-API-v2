//
//  ElanceWebLogin.h
//  elance
//
//  Created by Constantine Fry on 12/20/10.
//  Copyright 2010 Home. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FSWebLogin;

@protocol FSWebLoginDelegate <NSObject>
@required

- (void)webLogin:(FSWebLogin *)loginViewController didFinishWithError:(NSError *)error;

@end

@interface FSWebLogin : UIViewController


- (id) initWithUrl:(NSString *)url
       andDelegate:(id<FSWebLoginDelegate>)delegate;

@end
