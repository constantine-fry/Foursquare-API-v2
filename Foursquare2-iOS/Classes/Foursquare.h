// 
// Foursquare.h
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

#import <UIKit/UIKit.h>
//#import <HTTPRiot/HTTPRiot.h>
#import "HTTPRiot.h"
//#define OAUTH_REQUEST_TOKEN_URL @"http://foursquare.com/oauth/request_token"
//#define OAUTH_ACCESS_TOKEN_URL  @"http://foursquare.com/oauth/access_token"
//#define OAUTH_AUTHORIZE_URL     @"http://foursquare.com/oauth/authorize"

//#define OAUTH_KEY    (@"5P1OVCFK0CCVCQ5GBBCWRFGUVNX5R4WGKHL2DGJGZ32FDFKT")
//#define OAUTH_SECRET (@"UPZJO0A0XL44IHCD1KQBMAYGCZ45Z03BORJZZJXELPWHPSAR")
//#define OAUTH_KEY    @"I32ZKHLLPIWIXDFJCOTC3F1CHLL2VRUCV4GYEFAPFVJBSOD3"
//#define OAUTH_SECRET @"CT5W2PBYH4N35DZFFPPDUYVGHAJOOBUGUKBEUX5K2VNDHKN4"

#import "Constants.h"
typedef void(^FoursquareCallback)(BOOL success, id result);

@interface Foursquare : HRRestModel {
}

+ (void)getOAuthAccessTokenForUsername:(NSString *)username password:(NSString *)password callback:(id)callback;
+ (void)setOAuthAccessToken:(NSString *)token secret:(NSString *)secret;
+ (void)removeOAUthAccessTokenAndSecret;

+ (void)listCities:(FoursquareCallback)callback;

+ (void)cityNearestLatitude:(NSString *)geoLat 
				  longitude:(NSString *)geoLong 
				   callback:(FoursquareCallback)callback;

+ (void)switchToCity:(NSNumber *)cityId 
			callback:(FoursquareCallback)callback;

+ (void)recentFriendCheckinsNearLatitude:(NSNumber *)geoLat
							   longitude:(NSNumber *)geoLong
								callback:(FoursquareCallback)callback;

+ (void)checkinAtVenueId:(NSString *)venueId 
			   venueName:(NSString *)venueName 
				   shout:(NSString *)shout 
			 showFriends:(BOOL)showFriends 
			   sendTweet:(BOOL)sendTweet
			tellFacebook:(BOOL)tellFacebook
				latitude:(NSString *)geolat
			   longitude:(NSString *)geolong
				callback:(FoursquareCallback)callback;

+ (void)checkinHistoryWithLimit:(NSNumber *)limit 
					   callback:(FoursquareCallback)callback;

+(void)detailForCurrentUser:(BOOL)showbadges 
				  showMayor:(BOOL)showMayor
				   callback:(FoursquareCallback)callback;

+ (void)detailForUser:(NSNumber *)userId 
		   showBadges:(BOOL)showBadges 
			showMayor:(BOOL)showMayor 
			 callback:(FoursquareCallback)callback;

+ (void)friendsForUser:(NSNumber *)userId  			 
			  callback:(FoursquareCallback)callback;

+ (void)venuesNearLatitude:(NSString*)geoLat 
				 longitude:(NSString*)geoLong
				  matching:(NSString *)keywordSearch  
					 limit:(NSNumber *)limit   
				  callback:(FoursquareCallback)callback;

+ (void)detailForVenue:(NSString *)venueId
			  callback:(FoursquareCallback)callback;

+ (void)addVenue:(NSString *)name 
		 address:(NSString *)address 
	 crossStreet:(NSString *)crossStreet 
			city:(NSString *)city
		   state:(NSString *)state
			 zip:(NSString *)zip
		   phone:(NSString *)phone
			 lat:(NSString *)geolat
			 lon:(NSString *)geoLong
		category:(NSString *)category
		callback:(FoursquareCallback)callback;

+ (void)tipsNearLatitude:(NSString *)geoLat
			   longitude:(NSString *)geoLong
				   limit:(NSNumber *)limit 			
				callback:(FoursquareCallback)callback;

+ (void)addTip:(NSString *)tip 
	  forVenue:(NSString *)venueId 
	  callback:(FoursquareCallback)callback;

+ (void)addTodo:(NSString *)todo 
	   forVenue:(NSNumber *)venueId 		
	   callback:(FoursquareCallback)callback;

+ (void)userFriends:(FoursquareCallback)callback;

+ (void)friendRequests:(FoursquareCallback)callback;

+ (void)approveFriendRequest:(NSString *)userId 
					callback:(FoursquareCallback)callback;

+ (void)denyFriendRequest:(NSString*)userId 
				 callback:(FoursquareCallback)callback;

+ (void)sendFriendRequest:(NSNumber *)userId
				 callback:(FoursquareCallback)callback;

+ (void)findFriendsByName:(NSString *)nameQuery
				 callback:(FoursquareCallback)callback;

+ (void)findFriendsByPhone:(NSString *)phoneNumberQuery
				  callback:(FoursquareCallback)callback;

+ (void)findFriendsByTwitter:(NSString *)twitterQuery
					callback:(FoursquareCallback)callback;

+ (void)setPingsOff:(FoursquareCallback)callback;

+ (void)setPingsOffFor:(NSNumber *)userId callback:(FoursquareCallback)callback;

+ (void)setPingsOn:(FoursquareCallback)callback;

+ (void)setPingsOnFor:(NSNumber *)userId callback:(FoursquareCallback)callback;

+ (void)goodnight:(FoursquareCallback)callback;

+ (void)test:(FoursquareCallback)callback;

+ (NSString *)fullAddressForVenue:(NSDictionary *)venueDict;

@end
