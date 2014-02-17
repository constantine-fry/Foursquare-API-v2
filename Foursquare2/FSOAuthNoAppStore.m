//
// Copyright 2013 Foursquare
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#import "FSOAuthNoAppStore.h"

#define kFoursquareNoAppstoreOAuthRequiredVersion @"20130509"


@implementation FSOAuthNoAppStore

+ (FSOAuthStatusCode)authorizeUserUsingClientId:(NSString *)clientID
                              callbackURIString:(NSString *)callbackURIString {
    if ([clientID length] <= 0) {
        return FSOAuthStatusErrorInvalidClientID;
    }

    UIApplication *sharedApplication = [UIApplication sharedApplication];
    if ([callbackURIString length] <= 0 || ![sharedApplication canOpenURL:[NSURL URLWithString:callbackURIString]]) {
        return FSOAuthStatusErrorInvalidCallback;
    }
    
    if (![sharedApplication canOpenURL:[NSURL URLWithString:@"foursquare://"]]) {
        return FSOAuthStatusErrorFoursquareNotInstalled;
    }
    
    NSString *urlEncodedCallbackString = (__bridge_transfer NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                                                               (CFStringRef)callbackURIString,
                                                                                                               NULL,
                                                                                                               (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                                               kCFStringEncodingUTF8);
    
    NSURL *authURL = [NSURL URLWithString:[NSString stringWithFormat:@"foursquareauth://authorize?client_id=%@&v=%@&redirect_uri=%@", clientID, kFoursquareNoAppstoreOAuthRequiredVersion, urlEncodedCallbackString]];
    
    if (![sharedApplication canOpenURL:authURL]) {        
        return FSOAuthStatusErrorFoursquareOAuthNotSupported;
    }
    
    [sharedApplication openURL:authURL];
    
    return FSOAuthStatusSuccess;
}

+ (FSOAuthErrorCode)errorCodeForString:(NSString *)value {
    if ([value isEqualToString:@"invalid_request"]) {
        return FSOAuthErrorInvalidRequest;
    }
    else if ([value isEqualToString:@"invalid_client"]) {
        return FSOAuthErrorInvalidClient;
    }
    else if ([value isEqualToString:@"invalid_grant"]) {
        return FSOAuthErrorInvalidGrant;
    }
    else if ([value isEqualToString:@"unauthorized_client"]) {
        return FSOAuthErrorUnauthorizedClient;
    }
    else if ([value isEqualToString:@"unsupported_grant_type"]) {
        return FSOAuthErrorUnsupportedGrantType;
    }
    else {
        return FSOAuthErrorUnknown;
    }
}

+ (NSString *)accessCodeForFSOAuthURL:(NSURL *)url error:(FSOAuthErrorCode *)errorCode {
    NSString *accessCode = nil;
    
    if (errorCode != NULL) {
        *errorCode = FSOAuthErrorUnknown;
    }
    
    if (url) {
        NSArray *parameterPairs = [[url query] componentsSeparatedByString:@"&"];

        for (NSString *pair in parameterPairs) {
            NSArray *keyValue = [pair componentsSeparatedByString:@"="];
            if ([keyValue count] == 2) {
                NSString *param = keyValue[0];
                NSString *value = keyValue[1];
                
                if ([param isEqualToString:@"code"]) {
                    accessCode = value;
                    
                    if (errorCode != NULL) {
                        if (*errorCode == FSOAuthErrorUnknown) { // don't clobber any previously found real error value
                            *errorCode = FSOAuthErrorNone;
                        }
                    }
                }
                else if ([param isEqualToString:@"error"]) {
                    if (errorCode != NULL) {
                        *errorCode = [self errorCodeForString:value];
                    }   
                }
            }
        }
    }
    return accessCode;
}

+ (void)requestAccessTokenForCode:(NSString *)accessCode clientId:(NSString *)clientID callbackURIString:(NSString *)callbackURIString clientSecret:(NSString *)clientSecret completionBlock:(FSTokenRequestCompletionBlock)completionBlock {
    if ([accessCode length] > 0
        && [clientID length] > 0
        && [callbackURIString length] > 0
        && [clientSecret length] > 0
        && completionBlock) {
        
        NSString *urlEncodedCallbackString = (__bridge_transfer NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                                                                   (CFStringRef)callbackURIString,
                                                                                                                   NULL,
                                                                                                                   (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                                                   kCFStringEncodingUTF8);
        
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://foursquare.com/oauth2/access_token?client_id=%@&client_secret=%@&grant_type=authorization_code&redirect_uri=%@&code=%@", clientID, clientSecret, urlEncodedCallbackString, accessCode]]];
        
        [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue currentQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
            if (data && [[response MIMEType] isEqualToString:@"application/json"]) {
                id jsonObj = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
                if ([jsonObj isKindOfClass:[NSDictionary class]]) {
                    NSDictionary *jsonDict = (NSDictionary *)jsonObj;

                    FSOAuthErrorCode errorCode = FSOAuthErrorNone;
                    
                    if (jsonDict[@"error"]) {
                        errorCode = [self errorCodeForString:jsonDict[@"error"]];
                    }
                    
                    completionBlock(jsonDict[@"access_token"], YES, errorCode);
                    return;
                }
            }
            completionBlock(nil, NO, FSOAuthErrorNone);
        }];
    }
}
@end
