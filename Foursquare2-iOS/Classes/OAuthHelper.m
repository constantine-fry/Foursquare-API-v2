// 
// OAuthHelper.h
// FoursquareX
//
// Copyright (C) 2010 Eric Butler <eric@codebutler.com>
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.


// Some code in this file is based on code from the OAuth Library Project:
// http://code.google.com/p/oauth/
//
// Created by Jon Crosby on 10/19/07.
// Copyright 2007 Kaboomerang LLC. All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.


#import "OAuthHelper.h"
#import "NSString+URLEncoding.h"
#import <CommonCrypto/CommonHMAC.h>
#import "NSDataAdditions.h"
#import "Base64Transcoder.h"
#import "NSString+EscapingUtils.h"

@interface OAuthHelper(PrivateAPI)
+ (NSString *)generateTimestamp;
+ (NSString *)generateNonce;
+ (NSString *)createParamString:(NSDictionary *)params;
+ (NSString *)createSignature:(NSString *)text 
			   consumerSecret:(NSString *)secret;
+ (NSString *)signClearText:(NSString *)text withSecret:(NSString *)secret ;
@end

@implementation OAuthHelper

+ (NSDictionary *)signRequest:(NSString *)url 
					   method:(NSString *)method 
					   params:(NSDictionary *)params 
				  consumerKey:(NSString *)consumerKey
			   consumerSecret:(NSString *)consumerSecret
				  accessToken:(NSString *)accessToken
				 accessSecret:(NSString *)accessSecret

{
	NSString *timestamp = [self generateTimestamp];
	NSString *nonce     = [self generateNonce];
	NSString *sigMethod = @"HMAC-SHA1";
	
	NSMutableDictionary *dict = [NSMutableDictionary new];
	[dict setObject:consumerKey forKey:@"oauth_consumer_key"];
	[dict setObject:sigMethod   forKey:@"oauth_signature_method"];
	[dict setObject:timestamp   forKey:@"oauth_timestamp"];	
	[dict setObject:nonce       forKey:@"oauth_nonce"];
	[dict setObject:@"1.0"      forKey:@"oauth_version"];
	
	if ([accessToken length] > 0)
		[dict setObject:accessToken forKey:@"oauth_token"];
	
	if (params) {
		for (id key in params) {
			id val = [params objectForKey:key];
			[dict setObject:val forKey:key];
		}
	}
	
	NSString *paramString = [self createParamString:dict];
	//NSLog(@"%@",paramString);
	NSString *baseString = [NSString stringWithFormat:@"%@&%@&%@", 
							method,
						    [url URLEncodedString], 
						    [paramString URLEncodedString]];
	
	NSString *secret = nil;
	if ([accessSecret length] > 0)
		secret = [NSString stringWithFormat:@"%@&%@", consumerSecret, accessSecret];
	else 
		secret = [NSString stringWithFormat:@"%@&", consumerSecret];
	
	//NSString *signature = [self createSignature:baseString consumerSecret:secret];
	NSString *signature = [self signClearText:baseString withSecret:secret];
	[dict setObject:signature forKey:@"oauth_signature"];

	return dict;
}

+ (NSString *)generateTimestamp {
	return [[NSString stringWithFormat:@"%d", time(NULL)] retain];
}

+ (NSString *)generateNonce {
	CFUUIDRef uuidObj = CFUUIDCreate(nil);
	NSString *uuidString = (NSString*)CFUUIDCreateString(nil, uuidObj);
	CFRelease(uuidObj);
	return [uuidString autorelease];	
}

+ (NSString *)createParamString:(NSDictionary *)params
{
	NSMutableArray *paramArray = [NSMutableArray new];
	for (id key in params) {
		id val = [params objectForKey:key];
		[paramArray addObject:[NSString stringWithFormat:@"%@=%@", [key stringByPreparingForURL], [val stringByPreparingForURL]]];
		//[paramArray addObject:[NSString stringWithFormat:@"%@=%@", [key URLEncodedString], [val URLEncodedString]]];
	}
	NSArray *sortedParams = [paramArray sortedArrayUsingSelector:@selector(compare:)];
	[paramArray release];
	return [sortedParams componentsJoinedByString:@"&"];
}

+ (NSString *)createSignature:(NSString *)text consumerSecret:(NSString *)secret
{
    NSData *secretData = [secret dataUsingEncoding:NSUTF8StringEncoding];
    NSData *clearTextData = [text dataUsingEncoding:NSUTF8StringEncoding];
    unsigned char result[20];

	CCHmac(kCCHmacAlgSHA1, [secretData bytes], [secretData length], [clearTextData bytes], [clearTextData length], result);
    
	NSData *hmac = [[[NSData alloc] initWithBytes:result length:sizeof(result)] autorelease];
	NSLog(@"%@",hmac);	
	return [hmac base64Encoding];
}

+ (NSString *)signClearText:(NSString *)text withSecret:(NSString *)secret 
{
	NSData *secretData = [secret dataUsingEncoding:NSUTF8StringEncoding];
    NSData *clearTextData = [text dataUsingEncoding:NSUTF8StringEncoding];
	
    uint8_t digest[CC_SHA1_DIGEST_LENGTH] = {0};
	
    CCHmacContext hmacContext;
    CCHmacInit(&hmacContext, kCCHmacAlgSHA1, secretData.bytes, secretData.length);
    CCHmacUpdate(&hmacContext, clearTextData.bytes, clearTextData.length);
    CCHmacFinal(&hmacContext, digest);
	
    //Base64 Encoding
    
    char base64Result[32];
    size_t theResultLength = 32;
    Base64EncodeData(digest, CC_SHA1_DIGEST_LENGTH, base64Result, &theResultLength);
    NSData *theData = [NSData dataWithBytes:base64Result length:theResultLength];
    
    NSString *base64EncodedResult = [[NSString alloc] initWithData:theData encoding:NSUTF8StringEncoding];
    
    return [base64EncodedResult autorelease];
}

@end
