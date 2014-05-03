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

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, FSOAuthStatusCode) {
    FSOAuthStatusSuccess,                           // Sucessfully initiated the OAuthRequest
    FSOAuthStatusErrorInvalidClientID,              // An invalid clientId was passed in
    FSOAuthStatusErrorInvalidCallback,              // An invalid callbackUrl was passed in
    FSOAuthStatusErrorFoursquareNotInstalled,       // The Foursquare app is not installed on the user's device
    FSOAuthStatusErrorFoursquareOAuthNotSupported,  // The Foursquare app is installed, but it is not a new enough version to support OAuth
};

// See http://tools.ietf.org/html/rfc6749#section-5.2
typedef NS_ENUM(NSUInteger, FSOAuthErrorCode) {
    FSOAuthErrorNone,
    FSOAuthErrorUnknown,
    FSOAuthErrorInvalidRequest,
    FSOAuthErrorInvalidClient,
    FSOAuthErrorInvalidGrant,
    FSOAuthErrorUnauthorizedClient,
    FSOAuthErrorUnsupportedGrantType
};

/**
 Block signature for auth token request completion.
 
 @param authToken Either the user's auth token or nil if there was an error.
 @param requestCompleted Will be YES if the server was actually contacted and the response successfully downloaded, else NO
 @param errorCode Will be one of the values in the enum above. Only valid if requestCompleted is YES
 */
typedef void (^FSTokenRequestCompletionBlock)(NSString *authToken, BOOL requestCompleted, FSOAuthErrorCode errorCode);

@interface FSOAuthNoAppStore : NSObject

/**
 Attempt to initiate OAuth request by bouncing user out to the native iOS Foursquare app.
 
 May return with an error code if passed in parameters are invalid.
 
 @param clientID Your app's Foursquare clientID ( see http://foursquare.com/developers/apps )
 @param callbackURIString Your app's callback ( must be registered as a Redirect URI with Foursquare, see http://foursquare.com/developers/apps )
 @return Success or one of several failure codes. See enum definition above
 */
+ (FSOAuthStatusCode)authorizeUserUsingClientId:(NSString *)clientID
                              callbackURIString:(NSString *)callbackURIString;

/**
 Given the OAuth response URL, will return the access code for the authorized user, or nil if there was an error in authorization.
 
 For security reasons, it is recommended that you pass the returned accessCode to your own server and have it convert the code to 
 an access token using your secret key instead of including your client secret in your app's binary
 
 You can optionally pass in a FSOAuthErrorCode pointer to have it set to the error (if any) on return (or pass NULL)
 
 @param url The NSURL object to parse
 @param errorCode An FSOAuthErrorCode pointer that will be set to the error code on return. Pass NULL if you are not interested in the error code.
                  See enum definition above for possible error code values.
 @return The access code for this user or nil if there was an error in authorization or parsing the URL.
 */
+ (NSString *)accessCodeForFSOAuthURL:(NSURL *)url error:(FSOAuthErrorCode *)errorCode;


/**
 Given an access code, will request an auth token from the Foursquare servers.
 
 This will initiate an asynchronous request to the Foursquare servers, and call the passed in completion block when it finishes or fails.
 
 For security reasons, it is recommended that you pass the returned accessCode to your own server and have it convert the code to
 an access token using your secret key instead of including your client secret in your app's binary
 
 @param accessCode An accessCode from a successful authorization attempt. Returned by accessCodeForFSOAuthURL:error:
 @param clientID Your app's Foursquare client ID
 @param callbackURIString Your app's callback. Must be identical to the callback used to generate the accessCode, but will not actually be called.
 @param clientSecret Your app's client secret.
 @param completionBlock A block to execute when the transaction is compelted. See the FSTokenRequestCompletionBlock definition above.
 
 @warning For security reasons, it is recommended that you not use this method if possible.
 */
+ (void)requestAccessTokenForCode:(NSString *)accessCode
                         clientId:(NSString *)clientID
                callbackURIString:(NSString *)callbackURIString
                     clientSecret:(NSString *)clientSecret
                  completionBlock:(FSTokenRequestCompletionBlock)completionBlock;

@end
