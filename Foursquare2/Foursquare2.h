//
//  Foursquare2.h
//  Foursquare API
//
//  Created by Constantine Fry on 1/7/11.
//  Copyright 2011 Home. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FSRequester.h"
#ifndef __MAC_OS_X_VERSION_MAX_ALLOWED
#import "FSWebLogin.h"
#endif

//update this date to use up-to-date Foursquare API
#ifndef FS2_API_VERSION
#define FS2_API_VERSION (@"20130117")
#endif


#define FS2_API_BaseUrl @"https://api.foursquare.com/v2/"

typedef void(^Foursquare2Callback)(BOOL success, id result);

typedef enum {
	sortRecent,
	sortNearby,
	sortPopular
} FoursquareSortingType;

typedef enum {
	problemMislocated,
	problemClosed,
	problemDuplicate
} FoursquareProblemType;

typedef enum {
	broadcastPrivate,
	broadcastPublic,
	broadcastFacebook,
	broadcastTwitter,
	broadcastBoth
} FoursquareBroadcastType;

typedef enum {
	intentCheckin,
	intentBrowse,
	intentGlobal,
	intentMatch
} FoursquareIntentType;

@interface Foursquare2 : FSRequester {
	
}

+ (void)setBaseURL:(NSString *)uri;
+(void)setAccessToken:(NSString*)token;
+(void)removeAccessToken;
+(BOOL)isNeedToAuthorize;
+(BOOL)isAuthorized;
#pragma mark -

+ (void)setupFoursquareWithKey:(NSString *)key
                        secret:(NSString *)secret
                   callbackURL:(NSString *)callbackURL;
#pragma mark ---------------------------- Users ------------------------------------------------------------------------
+(void)authorizeWithCallback:(Foursquare2Callback)callback;
 
// !!!: 1. userID is a valid user ID or "self" 
+(void)getDetailForUser:(NSString*)userID
			  callback:(Foursquare2Callback)callback;

+(void)searchUserPhone:(NSArray*)phones
				 email:(NSArray*)emails
			   twitter:(NSArray*)twitters
		 twitterSource:(NSString*)twitterSource
		   facebookIDs:(NSArray*)bdids
				  name:(NSString*)name
			  callback:(Foursquare2Callback)callback;

+(void)getFriendRequestsCallback:(Foursquare2Callback)callback;



#pragma mark Aspects

+(void)getBadgesForUser:(NSString*)userID
			   callback:(Foursquare2Callback)callback;

//For now, only "self" is supported
+(void)getCheckinsByUser:(NSString*)userID
				   limit:(NSString*)limit
				  offset:(NSString*)offset
		  afterTimestamp:(NSString*)afterTimestamp
		 beforeTimestamp:(NSString*)beforeTimestamp
				callback:(Foursquare2Callback)callback;

+(void)getFriendsOfUser:(NSString*)userID
			   callback:(Foursquare2Callback)callback;

//sort: One of recent, nearby, or popular. Nearby requires geolat and geolong to be provided.
+(void)getTipsFromUser:(NSString*)userID
				  sort:(FoursquareSortingType)sort
			  latitude:(NSString*)lat
			 longitude:(NSString*)lon
			  callback:(Foursquare2Callback)callback;

//sort: One of recent or popular. Nearby requires geolat and geolong to be provided.
+(void)getTodosFromUser:(NSString*)userID
				   sort:(FoursquareSortingType)sort
			   latitude:(NSString*)lat
			  longitude:(NSString*)lon
			   callback:(Foursquare2Callback)callback;

//For now, only "self" is supported
+(void)getVenuesVisitedByUser:(NSString*)userID
					 callback:(Foursquare2Callback)callback;

#pragma mark Actions

+(void)sendFriendRequestToUser:(NSString*)userID
					  callback:(Foursquare2Callback)callback;

+(void)removeFriend:(NSString*)userID
		   callback:(Foursquare2Callback)callback;

+(void)approveFriend:(NSString*)userID
			callback:(Foursquare2Callback)callback;

+(void)denyFriend:(NSString*)userID
		 callback:(Foursquare2Callback)callback;

+(void)setPings:(BOOL)value
	  forFriend:(NSString*)userID
	   callback:(Foursquare2Callback)callback;

#pragma mark -


#pragma mark ---------------------------- Venues ------------------------------------------------------------------------

+(void)getDetailForVenue:(NSString*)venueID
				callback:(Foursquare2Callback)callback;

+(void)addVenueWithName:(NSString*)name
				address:(NSString*)address
			crossStreet:(NSString*)crossStreet
				   city:(NSString*)city
				  state:(NSString*)state
					zip:(NSString*)zip
				  phone:(NSString*)phone
			   latitude:(NSString*)lat
			  longitude:(NSString*)lon
	  primaryCategoryId:(NSString*)primaryCategoryId
			   callback:(Foursquare2Callback)callback;

+(void)getVenueCategoriesCallback:(Foursquare2Callback)callback;

+(void)searchVenuesNearByLatitude:(NSNumber*) lat
						longitude:(NSNumber*)lon
					   accuracyLL:(NSNumber*)accuracyLL
						 altitude:(NSNumber*)altitude
					  accuracyAlt:(NSNumber*)accuracyAlt
							query:(NSString*)query
							limit:(NSNumber*)limit
						   intent:(FoursquareIntentType)intent
                           radius:(NSNumber*)radius
                       categoryId:(NSString*)categoryId
						 callback:(Foursquare2Callback)callback;

+(void)searchVenuesInBoundingQuadrangleS:(NSNumber*)s
                                       w:(NSNumber*)w
                                       n:(NSNumber*)n
                                       e:(NSNumber*)e
                                   query:(NSString*)query
                                   limit:(NSNumber*)limit
                                callback:(Foursquare2Callback)callback;
#pragma mark Aspects
// !!!: please read comment
//This is an experimental API. We're excited about the innovation we think it enables as a 
//much more efficient version of fetching all data about a venue, but we're also still learning 
//if this right approach. Please give it a shot and provide feedback on the mailing list.

+(void)getVenueHereNow:(NSString*)venueID
				 limit:(NSString*)limit
				offset:(NSString*)offset
		afterTimestamp:(NSString*)afterTimestamp
			  callback:(Foursquare2Callback)callback;

+(void)getTipsFromVenue:(NSString*)venueID
				   sort:(FoursquareSortingType)sort
			   callback:(Foursquare2Callback)callback;

#pragma mark Actions

+(void)markVenueToDo:(NSString*)venueID
				text:(NSString*)text
			callback:(Foursquare2Callback)callback;

+(void)flagVenue:(NSString*)venueID
		 problem:(FoursquareProblemType)problem
		callback:(Foursquare2Callback)callback;

+(void)proposeEditVenue:(NSString*)venueID
				   name:(NSString*)name
				address:(NSString*)address
			crossStreet:(NSString*)crossStreet
				   city:(NSString*)city
				  state:(NSString*)state
					zip:(NSString*)zip
				  phone:(NSString*)phone
			   latitude:(NSString*)lat
			  longitude:(NSString*)lon
	  primaryCategoryId:(NSString*)primaryCategoryId
			   callback:(Foursquare2Callback)callback;
#pragma mark -

#pragma mark ---------------------------- Checkins ---------------------------------------------------------------------

+(void)getDetailForCheckin:(NSString*)checkinID
			   callback:(Foursquare2Callback)callback;


+(void)createCheckinAtVenue:(NSString*)venueID
					  venue:(NSString*)venue
					  shout:(NSString*)shout
				   callback:(Foursquare2Callback)callback;


+(void)createCheckinAtVenue:(NSString*)venueID
					  venue:(NSString*)venue
					  shout:(NSString*)shout
				  broadcast:(FoursquareBroadcastType)broadcast
				   latitude:(NSString*)lat
				  longitude:(NSString*)lon
				 accuracyLL:(NSString*)accuracyLL
				   altitude:(NSString*)altitude
				accuracyAlt:(NSString*)accuracyAlt
				   callback:(Foursquare2Callback)callback;

+(void)getRecentCheckinsByFriendsNearByLatitude:(NSString*)lat
									  longitude:(NSString*)lon
										  limit:(NSString*)limit
										 offset:(NSString*)offset
								 afterTimestamp:(NSString*)afterTimestamp
									   callback:(Foursquare2Callback)callback;

#pragma mark Actions

+(void)addCommentToCheckin:(NSString*)checkinID
					  text:(NSString*)text
				  callback:(Foursquare2Callback)callback;

+(void)deleteComment:(NSString*)commentID
		  forCheckin:(NSString*)checkinID
			callback:(Foursquare2Callback)callback;

#pragma mark -
#pragma mark ---------------------------- Tips ------------------------------------------------------------------------

+(void)getDetailForTip:(NSString*)tipID
			callback:(Foursquare2Callback)callback;

+(void)addTip:(NSString*)tip
	 forVenue:(NSString*)venueID
	  withURL:(NSString*)url
	 callback:(Foursquare2Callback)callback;

+(void)searchTipNearbyLatitude:(NSString*)lat
					 longitude:(NSString*)lon
						 limit:(NSString*)limit
						offset:(NSString*)offset
				   friendsOnly:(BOOL)friendsOnly
						 query:(NSString*)query
					  callback:(Foursquare2Callback)callback;

#pragma mark Actions
+(void)markTipTodo:(NSString*)tipID
		  callback:(Foursquare2Callback)callback;

+(void)markTipDone:(NSString*)tipID
		  callback:(Foursquare2Callback)callback;

+(void)unmarkTipTodo:(NSString*)tipID
			callback:(Foursquare2Callback)callback;
#pragma mark -


#pragma mark ---------------------------- Photos ------------------------------------------------------------------------

+(void)getDetailForPhoto:(NSString*)photoID
			callback:(Foursquare2Callback)callback;


#ifdef __MAC_OS_X_VERSION_MAX_ALLOWED
+(void)addPhoto:(NSImage*)photo
#else
+(void)addPhoto:(UIImage*)photo
#endif
      toCheckin:(NSString*)checkinID
       callback:(Foursquare2Callback)callback;

#ifdef __MAC_OS_X_VERSION_MAX_ALLOWED
+(void)addPhoto:(NSImage*)photo
#else
+(void)addPhoto:(UIImage*)photo
#endif
	  toCheckin:(NSString*)checkinID
			tip:(NSString*)tipID
		  venue:(NSString*)venueID
	  broadcast:(FoursquareBroadcastType)broadcast
	   latitude:(NSString*)lat
	  longitude:(NSString*)lon
	 accuracyLL:(NSString*)accuracyLL
	   altitude:(NSString*)altitude
	accuracyAlt:(NSString*)accuracyAlt
	   callback:(Foursquare2Callback)callback;

+(void)getPhotosForVenue:(NSString *)venueID
                     limit:(NSNumber *)limit
                    offset:(NSNumber *)offset
                  callback:(Foursquare2Callback)callback;

#pragma mark -

#pragma mark ---------------------------- Settings ------------------------------------------------------------------------

+(void)getAllSettingsCallback:(Foursquare2Callback)callback;

+(void)setSendToTwitter:(BOOL)value
			   callback:(Foursquare2Callback)callback;

+(void)setSendToFacebook:(BOOL)value
				callback:(Foursquare2Callback)callback;

+(void)setReceivePings:(BOOL)value
			  callback:(Foursquare2Callback)callback;
#pragma mark -

@end
