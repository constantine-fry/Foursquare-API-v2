//
//  Foursquare2.h
//  Foursquare API
//
//  Created by Constantine Fry on 1/7/11.
//  Copyright 2011 Home. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Constants.h"
#import "HTTPRiot.h"

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


@interface Foursquare2 : HRRestModel {
	
}


+(void)getAccessTokenForCode:(NSString*)code callback:(id)callback;
+(void)setAccessToken:(NSString*)token;
+(void)removeAccessToken;
+(BOOL)isNeedToAuthorize;
#pragma mark -

#pragma mark ---------------------------- Users ------------------------------------------------------------------------
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

+(void)searchVenuesNearByLatitude:(NSString*) lat
						longitude:(NSString*)lon
					   accuracyLL:(NSString*)accuracyLL
						 altitude:(NSString*)altitude
					  accuracyAlt:(NSString*)accuracyAlt
							query:(NSString*)query
							limit:(NSString*)limit
						   intent:(NSString*)intent
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
			tip:(NSString*)tipID
		  venue:(NSString*)venueID
	  broadcast:(FoursquareBroadcastType)broadcast
	   latitude:(NSString*)lat
	  longitude:(NSString*)lon
	 accuracyLL:(NSString*)accuracyLL
	   altitude:(NSString*)altitude
	accuracyAlt:(NSString*)accuracyAlt
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
