//
//  ElanceWebLogin.h
//  elance
//
//  Created by Constantine Fry on 12/20/10.
//  Copyright 2010 Home. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface FSWebLogin : UIViewController<UIWebViewDelegate> {
	NSString *_url;
	IBOutlet UIWebView *webView;
	SEL selector;
}

@property(nonatomic,weak) id delegate;
@property (nonatomic,assign)SEL selector;
- (id) initWithUrl:(NSString*)url;
@end
