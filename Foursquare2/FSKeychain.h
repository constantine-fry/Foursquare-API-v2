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

- (NSString *)readAccessTokenFromKeychainWithClientId:(NSString *)clientId;

- (void)saveAccessTokenInKeychain:(NSString *)accessToken forClientId:(NSString *)clientId;

- (void)removeAccessTokenFromKeychainWithClientId:(NSString *)clientId;

@end
