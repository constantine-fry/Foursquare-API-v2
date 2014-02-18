//
//  FSKeychain.m
//  Foursquare2
//
//  Created by Constantine Fry on 18/02/14.
//
//

#import "FSKeychain.h"
#import <Security/Security.h>

@implementation FSKeychain

+ (instancetype)sharedKeychain {
    static FSKeychain *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[FSKeychain alloc] init];
    });
    return instance;
}

+ (NSDictionary *)keychainQueryWithClientId:(NSString *)clientId {
    if (clientId == nil || clientId.length == 0) {
        NSAssert(NO, @"client id could not be nil");
    }
    NSDictionary *keychainQuery =
    @{(__bridge id)kSecClass          : (__bridge id)kSecClassGenericPassword,
      // use clientId to "invalidate" access token if developer changed clientId
      (__bridge id)kSecAttrAccount    : clientId,
      (__bridge id)kSecAttrService    : @"Foursquare2API-FSKeychain",
      (__bridge id)kSecAttrAccessible :(__bridge id)kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly};
    return keychainQuery;
}

- (void)removeAccessTokenFromKeychainWithClientId:(NSString *)clientId {
    NSDictionary *keychainQuery = [self.class keychainQueryWithClientId:clientId];
    OSStatus status = SecItemDelete((__bridge CFDictionaryRef)keychainQuery);
    if (status != errSecSuccess && status != errSecItemNotFound) {
        NSLog(@"Error deleting access token from keyching %li", (long int)status);
    }
}

- (void)saveAccessTokenInKeychain:(NSString *)accessToken forClientId:(NSString *)clientId {
    if (accessToken == nil || accessToken.length == 0) {
        return;
    }
    
    [self removeAccessTokenFromKeychainWithClientId:clientId];
    NSMutableDictionary *keychainQuery = [[self.class keychainQueryWithClientId:clientId] mutableCopy];
    NSData *passwordData = [accessToken dataUsingEncoding:NSUTF8StringEncoding];
    [keychainQuery setObject:passwordData forKey:(__bridge id)kSecValueData];
    OSStatus status = SecItemAdd((__bridge CFDictionaryRef)keychainQuery, NULL);
    if (status != noErr) {
        NSLog(@"Error saving access token in keyching %li", (long int)status);
    }
}

- (NSString *)readAccessTokenFromKeychainWithClientId:(NSString *)clientId {
    NSMutableDictionary *keychainQuery = [[self.class keychainQueryWithClientId:clientId] mutableCopy];
    [keychainQuery setObject:(__bridge id)kCFBooleanTrue forKey:(__bridge id)kSecReturnData];
    [keychainQuery setObject:(__bridge id)kSecMatchLimitOne forKey:(__bridge id)kSecMatchLimit];
    CFDataRef passwordData = NULL;
    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)keychainQuery,
                                          (CFTypeRef *)&passwordData);
    NSString *acessToken = nil;
    if (status == noErr && 0 < [(__bridge NSData *)passwordData length]) {
        acessToken = [[NSString alloc] initWithData:(__bridge NSData *)passwordData
                                           encoding:NSUTF8StringEncoding];
    }
    if (passwordData != NULL) {
        CFRelease(passwordData);
    }
    return acessToken;
}

@end
