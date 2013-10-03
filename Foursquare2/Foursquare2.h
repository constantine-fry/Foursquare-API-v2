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

typedef enum {
	FoursquareCheckinsNewestFirst,
	FoursquareCheckinsOldestFirst,
} FoursquareCheckinsSort;

typedef enum {
    FoursquareListGroupNone,
	FoursquareListGroupCreated,
	FoursquareListGroupEdited,
    FoursquareListGroupFollowed,
    FoursquareListGroupFriends,
    FoursquareListGroupSuggested
} FoursquareListGroupType;


@interface Foursquare2 : FSRequester

/**
    Setup Foursqare2 with clientId, secret and callbackURL.
    This parameters you can get on https://foursquare.com/developers/apps
 */

+ (void)setupFoursquareWithClientId:(NSString *)clientId
                             secret:(NSString *)secret
                        callbackURL:(NSString *)callbackURL;
/**
    @return YES if user authorised, otherwise NO.
 */
+ (BOOL)isAuthorized;

/**
    Authorize user with native foursquare if this application exist on his device, otherwise open in-app web dialog.
 */
+ (void)authorizeWithCallback:(Foursquare2Callback)callback;

/**
    Remove access token from user defaults. In other words logout.
 */
+ (void)removeAccessToken;

/**
    @abstract Handle URL. You must call this method in
    @link application:openURL:sourceApplication:annotation: @/link

    @returns YES if link has been handled, otherwise NO.
 */
+ (BOOL)handleURL:(NSURL *)url;








#pragma mark ---------------------------- Users ------------------------------------------------------------------------

/**
    @param userID Valid user ID to get detail for. Pass "self" to get detail of the acting user.
    @returns "user" field. User detail for user with userID: https://developer.foursquare.com/docs/responses/user
 */
+ (void)userGetDetail:(NSString *)userID
             callback:(Foursquare2Callback)callback;

#pragma mark General
/**
    @returns "results" and "unmatched" fields. Where "results" is an array of compact user objects:
    https://developer.foursquare.com/docs/responses/user
 */
+ (void)userSearchWithPhone:(NSArray *)phones
                      email:(NSArray *)emails
                    twitter:(NSArray *)twitters
              twitterSource:(NSString *)twitterSource
                facebookIDs:(NSArray *)bdids
                       name:(NSString *)name
                   callback:(Foursquare2Callback)callback;
/**
    @returns "requests" field. Array of compact user object: https://developer.foursquare.com/docs/responses/user
 */
+ (void)userGetFriendRequestsCallback:(Foursquare2Callback)callback;

/**
    @returns "leaderboard" field with "count" and "items". API explorer:
    https://developer.foursquare.com/docs/explore#req=users/leaderboard
 */
+ (void)userGetLeaderboardCallback:(Foursquare2Callback)callback;


#pragma mark Aspects

/**
    @param userID Valid user ID to get badges for. Pass "self" to get badges of the acting user.
    @returns "sets" and "badges" fields. API explorer:
    https://developer.foursquare.com/docs/explore#req=users/self/badges
 */
+ (void)userGetBadges:(NSString *)userID
             callback:(Foursquare2Callback)callback;

/**
    @param userID For now, only "self" is supported.
    @param limit Number of result to return, up to 250.
    @param offset The number of results to skip. Used for paging.
    @param sort How to sort return checkins.
    @param after Retrieve the first results to follow these seconds since epoch.
    @param before Retrieve the first results prior to these seconds since epoch. Useful for paging backward in time.
    @returns "checkings" field. A "count" and "items" of check-ins:
    https://developer.foursquare.com/docs/responses/checkin
 */
+ (void)userGetCheckins:(NSString *)userID
                  limit:(NSNumber *)limit
                 offset:(NSNumber *)offset
                   sort:(FoursquareCheckinsSort)sort
                  after:(NSDate *)after
                 before:(NSDate *)before
               callback:(Foursquare2Callback)callback;

/**
    @param userID Valid user ID to get friends for. Pass "self" to get friends of the acting user.
    @param limit Number of results to return, up to 500.
    @param offset The number of results to skip. Used for paging.
    @returns "friends" field. A "count" and "items" of compact user objects: 
    https://developer.foursquare.com/docs/responses/user
 */
+ (void)userGetFriends:(NSString *)userID
                 limit:(NSNumber *)limit
                offset:(NSNumber *)offset
              callback:(Foursquare2Callback)callback;

/**
    @param userID Valid user ID to get tips from. Pass "self" to get tips of the acting user.
    @param limit Number of result to return, up to 250.
    @param offset The number of results to skip. Used for paging.
    @param sort sortNearby requires latitude and longitude to be provided.
    @returns "tips" field. A count and items of tips: https://developer.foursquare.com/docs/responses/tip
 */
+ (void)userGetTips:(NSString *)userID
              limit:(NSNumber *)limit
             offset:(NSNumber *)offset
               sort:(FoursquareSortingType)sort
           latitude:(NSNumber *)latitude
          longitude:(NSNumber *)longitude
           callback:(Foursquare2Callback)callback;


/**
    @param userID Valid user ID to get todos from. Pass "self" to get todos of the acting user.
    @param sort Only sortNearby and sortRecent are supported. sortNearby requires latitude and longitude to be provided.
    @returns "todos" field. A count and items of todos: https://developer.foursquare.com/docs/responses/todo
 */
+ (void)userGetTodos:(NSString *)userID
                sort:(FoursquareSortingType)sort
            latitude:(NSNumber *)latitude
           longitude:(NSNumber *)longitude
            callback:(Foursquare2Callback)callback;

/**
    Returns a list of all venues visited by the specified user, along with how many visits and when they were
    last there.
    @param userID Valid user ID to get venues from. Only "self" is supported.
    @param categoryID Limits returned venues to those in this category. If specifying a top-level category, all 
    sub-categories will also match the query.
    @returns "venues" field. A count and items of objects containing a beenHere count and venue compact venues: 
    https://developer.foursquare.com/docs/responses/venue
 */
+ (void)userGetVenueHistory:(NSString *)userID
                      after:(NSDate *)after
                     before:(NSDate *)before
                 categoryID:(NSString *)categoryID
                   callback:(Foursquare2Callback)callback;
/**
    A User's Lists.
    @param userID Valid user ID to get lists for. Pass "self" to get lists of the acting user.
    @returns "lists" field. If group is specified, contains a count and items of lists: 
    https://developer.foursquare.com/docs/responses/list
    If FoursquareListGroupNone is specified, it contains a groups array containing elements.
 */
+ (void)userGetLists:(NSString *)userID
               group:(FoursquareListGroupType)groupType
            latitude:(NSNumber *)latitude
           longitude:(NSNumber *)longitude
            callback:(Foursquare2Callback)callback;

/**
    Returns a user's mayorships.
    @param userID Valid user ID to get mayorships for. Pass "self" to get mayorships of the acting user.
    @returns "mayorships" field. A count and items of objects which currently only contain compact venue objects:
    https://developer.foursquare.com/docs/responses/venue
 */
+ (void)userGetMayorships:(NSString *)userID
                 callback:(Foursquare2Callback)callback;

/**
    Returns photos from a user.
    @param userID For now, only self is supported.
    @returns "photos" field. A count and items of photos: https://developer.foursquare.com/docs/responses/photo
 */
+ (void)userGetPhotos:(NSString *)userID
                limit:(NSNumber *)limit
               offset:(NSNumber *)offset
             callback:(Foursquare2Callback)callback;

#pragma mark Actions
/**
    Sends a friend request to another user. If the other user is a page then the requesting user
    will automatically start following the page.
    @params userID required The user ID to which a request will be sent.
    @returns "user" field. A "user" object for pending user:
    https://developer.foursquare.com/docs/responses/user
 */
+ (void)userSendFriendRequest:(NSString *)userID
                     callback:(Foursquare2Callback)callback;

/**
    Unfriend user with userID.
    @params userID The user ID to unfriend.
    @returns "user" field.
    https://developer.foursquare.com/docs/responses/user
 */
+ (void)userUnfriend:(NSString *)userID
            callback:(Foursquare2Callback)callback;

/**
    Approve pending friend request.
    @param userId User ID to approve friendship.
    @returns "user" field. User object of approved user.
    https://developer.foursquare.com/docs/responses/user
 */
+ (void)userApproveFriend:(NSString *)userID
                 callback:(Foursquare2Callback)callback;

/**
    Deny pending friend reques.
    @param userId User ID to deny friendship.
    @returns "user" field. User object of denied user.
    https://developer.foursquare.com/docs/responses/user
 */
+ (void)userDenyFriend:(NSString *)userID
              callback:(Foursquare2Callback)callback;
/**
    Changes whether the acting user will receive pings (phone notifications) when the specified user checks in.
    @returns "user" field. User object of the user.
    https://developer.foursquare.com/docs/responses/user
 */
+ (void)userSetPings:(BOOL)value
           forFriend:(NSString *)userID
            callback:(Foursquare2Callback)callback;


#ifdef __MAC_OS_X_VERSION_MAX_ALLOWED
+ (void)userUpdatePhoto:(NSImage *)image
               callback:(Foursquare2Callback)callback;
#else
/**
    Updates the user's profile photo.
    @param image Photo under 100KB.
    @returns "user" field. The current user object.
    https://developer.foursquare.com/docs/responses/user
 */
+ (void)userUpdatePhoto:(UIImage *)image
               callback:(Foursquare2Callback)callback;
#endif

#pragma mark -




#pragma mark ---------------------------- Venues -----------------------------------------------------------------------

+ (void)getDetailForVenue:(NSString *)venueID
                 callback:(Foursquare2Callback)callback;

+ (void)addVenueWithName:(NSString *)name
                 address:(NSString *)address
             crossStreet:(NSString *)crossStreet
                    city:(NSString *)city
                   state:(NSString *)state
                     zip:(NSString *)zip
                   phone:(NSString *)phone
                latitude:(NSString *)lat
               longitude:(NSString *)lon
       primaryCategoryId:(NSString *)primaryCategoryId
                callback:(Foursquare2Callback)callback;

+ (void)getVenueCategoriesCallback:(Foursquare2Callback)callback;

+ (void)searchVenuesNearByLatitude:(NSNumber *)lat
                         longitude:(NSNumber *)lon
                        accuracyLL:(NSNumber *)accuracyLL
                          altitude:(NSNumber *)altitude
                       accuracyAlt:(NSNumber *)accuracyAlt
                             query:(NSString *)query
                             limit:(NSNumber *)limit
                            intent:(FoursquareIntentType)intent
                            radius:(NSNumber *)radius
                        categoryId:(NSString *)categoryId
                          callback:(Foursquare2Callback)callback;

+ (void)searchTrendingVenuesNearByLatitude:(NSNumber *)lat
                                 longitude:(NSNumber *)lon
                                     limit:(NSNumber *)limit
                                    radius:(NSNumber *)radius
                                  callback:(Foursquare2Callback)callback;

+ (void)searchRecommendedVenuesNearByLatitude:(NSNumber *)lat
                                    longitude:(NSNumber *)lon
                                   accuracyLL:(NSNumber *)accuracyLL
                                     altitude:(NSNumber *)altitude
                                  accuracyAlt:(NSNumber *)accuracyAlt
                                        query:(NSString *)query
                                        limit:(NSNumber *)limit
                                       radius:(NSNumber *)radius
                                      section:(NSString *)section
                                      novelty:(NSString *)novelty
                               sortByDistance:(NSNumber *)sortByDistance
                                        price:(NSString *)price
                                     callback:(Foursquare2Callback)callback;

+ (void)searchVenuesInBoundingQuadrangleS:(NSNumber *)s
                                        w:(NSNumber *)w
                                        n:(NSNumber *)n
                                        e:(NSNumber *)e
                                    query:(NSString *)query
                                    limit:(NSNumber *)limit
                                 callback:(Foursquare2Callback)callback;
#pragma mark Aspects
+ (void)getVenueHereNow:(NSString *)venueID
                  limit:(NSString *)limit
                 offset:(NSString *)offset
         afterTimestamp:(NSString *)afterTimestamp
               callback:(Foursquare2Callback)callback;

+ (void)getTipsFromVenue:(NSString *)venueID
                    sort:(FoursquareSortingType)sort
                callback:(Foursquare2Callback)callback;

#pragma mark Actions

+ (void)markVenueToDo:(NSString *)venueID
                 text:(NSString *)text
             callback:(Foursquare2Callback)callback;

+ (void)flagVenue:(NSString *)venueID
          problem:(FoursquareProblemType)problem
         callback:(Foursquare2Callback)callback;

+ (void)proposeEditVenue:(NSString *)venueID
                    name:(NSString *)name
                 address:(NSString *)address
             crossStreet:(NSString *)crossStreet
                    city:(NSString *)city
                   state:(NSString *)state
                     zip:(NSString *)zip
                   phone:(NSString *)phone
                latitude:(NSString *)lat
               longitude:(NSString *)lon
       primaryCategoryId:(NSString *)primaryCategoryId
                callback:(Foursquare2Callback)callback;
#pragma mark -

#pragma mark ---------------------------- Checkins ---------------------------------------------------------------------

+ (void)getDetailForCheckin:(NSString *)checkinID
                   callback:(Foursquare2Callback)callback;


+ (void)createCheckinAtVenue:(NSString *)venueID
                       venue:(NSString *)venue
                       shout:(NSString *)shout
                    callback:(Foursquare2Callback)callback;


+ (void)createCheckinAtVenue:(NSString *)venueID
                       venue:(NSString *)venue
                       shout:(NSString *)shout
                   broadcast:(FoursquareBroadcastType)broadcast
                    latitude:(NSString *)lat
                   longitude:(NSString *)lon
                  accuracyLL:(NSString *)accuracyLL
                    altitude:(NSString *)altitude
                 accuracyAlt:(NSString *)accuracyAlt
                    callback:(Foursquare2Callback)callback;

+ (void)getRecentCheckinsByFriendsNearByLatitude:(NSString *)lat
                                       longitude:(NSString *)lon
                                           limit:(NSString *)limit
                                          offset:(NSString *)offset
                                  afterTimestamp:(NSString *)afterTimestamp
                                        callback:(Foursquare2Callback)callback;

#pragma mark Actions

+ (void)addCommentToCheckin:(NSString *)checkinID
                       text:(NSString *)text
                   callback:(Foursquare2Callback)callback;

+ (void)deleteComment:(NSString *)commentID
           forCheckin:(NSString *)checkinID
             callback:(Foursquare2Callback)callback;

#pragma mark -
#pragma mark ---------------------------- Tips ------------------------------------------------------------------------

+ (void)getDetailForTip:(NSString *)tipID
               callback:(Foursquare2Callback)callback;

+ (void)addTip:(NSString *)tip
      forVenue:(NSString *)venueID
       withURL:(NSString *)url
      callback:(Foursquare2Callback)callback;

+ (void)searchTipNearbyLatitude:(NSString *)lat
                      longitude:(NSString *)lon
                          limit:(NSString *)limit
                         offset:(NSString *)offset
                    friendsOnly:(BOOL)friendsOnly
                          query:(NSString *)query
                       callback:(Foursquare2Callback)callback;

#pragma mark Actions
+ (void)markTipTodo:(NSString *)tipID
           callback:(Foursquare2Callback)callback;

+ (void)markTipDone:(NSString *)tipID
           callback:(Foursquare2Callback)callback;

+ (void)unmarkTipTodo:(NSString *)tipID
             callback:(Foursquare2Callback)callback;
#pragma mark -


#pragma mark ---------------------------- Photos ------------------------------------------------------------------------

+ (void)getDetailForPhoto:(NSString *)photoID
                 callback:(Foursquare2Callback)callback;


#ifdef __MAC_OS_X_VERSION_MAX_ALLOWED
+ (void)addPhoto:(NSImage *)photo
#else
+ (void)addPhoto:(UIImage *)photo
#endif
       toCheckin:(NSString *)checkinID
        callback:(Foursquare2Callback)callback;

#ifdef __MAC_OS_X_VERSION_MAX_ALLOWED
+ (void)addPhoto:(NSImage *)photo
#else
+ (void)addPhoto:(UIImage *)photo
#endif
       toCheckin:(NSString *)checkinID
             tip:(NSString *)tipID
           venue:(NSString *)venueID
       broadcast:(FoursquareBroadcastType)broadcast
        latitude:(NSString *)lat
       longitude:(NSString *)lon
      accuracyLL:(NSString *)accuracyLL
        altitude:(NSString *)altitude
     accuracyAlt:(NSString *)accuracyAlt
        callback:(Foursquare2Callback)callback;

+ (void)getPhotosForVenue:(NSString *)venueID
                    limit:(NSNumber *)limit
                   offset:(NSNumber *)offset
                 callback:(Foursquare2Callback)callback;

#pragma mark -

#pragma mark ---------------------------- Settings ------------------------------------------------------------------------

+ (void)getAllSettingsCallback:(Foursquare2Callback)callback;

+ (void)setSendToTwitter:(BOOL)value
                callback:(Foursquare2Callback)callback;

+ (void)setSendToFacebook:(BOOL)value
                 callback:(Foursquare2Callback)callback;

+ (void)setReceivePings:(BOOL)value
               callback:(Foursquare2Callback)callback;
#pragma mark -



+ (void)setAccessToken:(NSString *)token;

@end
