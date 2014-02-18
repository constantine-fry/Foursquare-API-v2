//
//  FSKeychain.h
//  Foursquare2
//
//  Created by Constantine Fry on 18/02/14.
//
//

#import <Foundation/Foundation.h>

@interface FSKeychain : NSObject

+ (instancetype)sharedKeychain;

- (NSString *)readAccessTokenFromKeychain;

- (void)saveAccessTokenInKeychain:(NSString *)accessToken;

- (void)removeAccessTokenFromKeychain;

@end
