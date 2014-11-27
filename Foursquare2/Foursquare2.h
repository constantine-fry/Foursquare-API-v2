//
//  Foursquare2.h
//  Foursquare API
//
//  Created by Constantine Fry on 1/7/11.
//  Copyright 2011 Home. All rights reserved.
//

#import <Foundation/Foundation.h>
#ifndef __MAC_OS_X_VERSION_MAX_ALLOWED
#import "FSWebLogin.h"
#endif

#import "FSOperation.h"

typedef NS_OPTIONS(NSUInteger, FoursquareSortingType) {
    sortRecent,
    sortNearby,
    sortPopular,
    sortFriends
};

typedef NS_OPTIONS(NSUInteger, FoursquareProblemType) {
    problemMislocated,
    problemClosed,
    problemDuplicate,
    problemInappropriate,
    problemDoesntExist,
    problemEventOver
};

typedef NS_OPTIONS(NSUInteger, FoursquareSettingName) {
    FoursquareSettingNameSendMayorshipsToTwitter = 1,
    FoursquareSettingNameSendBadgesToTwitter,
    FoursquareSettingNameSendMayorshipsToFacebook,
    FoursquareSettingNameSendBadgesToFacebook,
    FoursquareSettingNameReceivePings,
    FoursquareSettingNameReceiveCommentPings
};

typedef NS_OPTIONS(NSUInteger, FoursquareBroadcastType) {
    broadcastPrivate    = 1 << 0,
    broadcastFollowers  = 1 << 1,
    broadcastPublic     = 1 << 2,
    broadcastFacebook   = 1 << 3,
    broadcastTwitter    = 1 << 4
};


/**
 intentCheckin Finds results that the current user is likely to check in to at the provided ll
 at the current moment in time.
 
 intentBrowse Find venues within a given area. Unlike the checkin intent, browse searches an entire
 region instead of only finding Venues closest to a point. You must define a region to search be including
 the ll and radius parameters
 
 intentGlobal Finds the most globally relevant venues for the search, independent of location.
 Ignores all other parameters other than query and limit.
 
 intentMatch Finds venues that are are nearly-exact matches for the given query and ll.
 This is helpful when trying to correlate an existing place database with foursquare's.
 */
typedef NS_OPTIONS(NSUInteger, FoursquareIntentType) {
    intentCheckin,
    intentBrowse,
    intentGlobal,
    intentMatch
};

typedef NS_OPTIONS(NSUInteger, FoursquareCheckinsSort) {
    FoursquareCheckinsNewestFirst,
    FoursquareCheckinsOldestFirst,
};

typedef NS_OPTIONS(NSUInteger, FoursquareListGroupType) {
    FoursquareListGroupNone,
    FoursquareListGroupCreated,
    FoursquareListGroupEdited,
    FoursquareListGroupFollowed,
    FoursquareListGroupFriends,
    FoursquareListGroupSuggested
};

typedef NS_ENUM(NSInteger, Foursquare2Error) {
    Foursquare2ErrorUnknown = -1,
    Foursquare2ErrorCancelled,
    Foursquare2ErrorUnauthorized = 401
};

FOUNDATION_EXPORT NSString * const kFoursquare2ErrorDomain;
FOUNDATION_EXPORT NSString * const kFoursquare2NativeAuthErrorDomain;

/**
 This notification is posted when access token has been removed
 in case of Foursquare2ErrorUnauthorized error from server.
 The notification is not posted if you call @c removeAccessToken  manually.
 Will be posted on main thread.
 */
FOUNDATION_EXPORT NSString * const kFoursquare2DidRemoveAccessTokenNotification;

/**
 End points coverage.
 Users 19 from 19.
 Venues 11 from 26.
 Checkins 6 from 7.
 Photos 1 from 1
 Settings 2 from 2.
 Lists 5 from 15.
 
 40 covered endpoints.
 */


/**
 @class Foursqure2
 */
@interface Foursquare2 : NSObject

/**
 Sets the dispatch queue in which request callbacks are called (defaults to the main queue).
 */
+ (void)setCallbackQueue:(dispatch_queue_t)callbackQueue;

/**
 Sets timeout interval for all API requeusts, in seconds.
 The default timeout interval is 60 sec.
 */
+ (void)setTimeoutInterval:(NSTimeInterval)timeoutInterval;

/**
 Returns the dispatch queue in which request callbacks are called.
 */
+ (dispatch_queue_t)callbackQueue;

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
 Method returns error if user cancels authorization.
 */
+ (void)authorizeWithCallback:(Foursquare2Callback)callback;

/**
 Removes access token from user defaults. In other words logout.
 */
+ (void)removeAccessToken;

/**
 Returns access token.
 */
+ (NSString *)accessToken;

/**
 @abstract Handle URL. You must call this method in
 @link application:openURL:sourceApplication:annotation: @/link
 
 @returns YES if link has been handled, otherwise NO.
 */
+ (BOOL)handleURL:(NSURL *)url;


#pragma mark ---------------------------- Users ------------------------------------------------------------------------

/**
 @param userID Valid user ID to get detail for. Pass "self" to get detail of the acting user.
 @returns The instance of NSOperation already inqueued in internal operation queue.
 Callback will not be called, if you send cancel message to the operation.
 @discussion returns in callback block "user" field. User detail for user with userID:
 https://developer.foursquare.com/docs/responses/user
 */
+ (NSOperation *)userGetDetail:(NSString *)userID
                      callback:(Foursquare2Callback)callback;

#pragma mark General
/**
 @returns The instance of NSOperation already inqueued in internal operation queue.
 Callback will not be called, if you send cancel message to the operation.
 @discussion returns in callback block "results" and "unmatched" fields.
 Where "results" is an array of compact user objects:
 https://developer.foursquare.com/docs/responses/user
 */
+ (NSOperation *)userSearchWithPhone:(NSArray *)phones
                               email:(NSArray *)emails
                             twitter:(NSArray *)twitters
                       twitterSource:(NSString *)twitterSource
                         facebookIDs:(NSArray *)bdids
                                name:(NSString *)name
                            callback:(Foursquare2Callback)callback;
/**
 @returns The instance of NSOperation already inqueued in internal operation queue.
 Callback will not be called, if you send cancel message to the operation.
 @discussion returns in callback block "requests" field. Array of compact user object:
 https://developer.foursquare.com/docs/responses/user
 */
+ (NSOperation *)userGetFriendRequestsCallback:(Foursquare2Callback)callback;

/**
 @returns The instance of NSOperation already inqueued in internal operation queue. In case you call cancel
 method, calback will not be called.
 @discussion returns in callback block "leaderboard" field with "count" and "items". API explorer:
 https://developer.foursquare.com/docs/explore#req=users/leaderboard
 */
+ (NSOperation *)userGetLeaderboardCallback:(Foursquare2Callback)callback;


#pragma mark Aspects

/**
 @returns The instance of NSOperation already inqueued in internal operation queue.
 Callback will not be called, if you send cancel message to the operation.
 @param userID Valid user ID to get badges for. Pass "self" to get badges of the acting user.
 @discussion returns in callback block "sets" and "badges" fields. API explorer:
 https://developer.foursquare.com/docs/explore#req=users/self/badges
 */
+ (NSOperation *)userGetBadges:(NSString *)userID
                      callback:(Foursquare2Callback)callback;

/**
 @disscuss asd
 @param userID For now, only "self" is supported.
 @param limit Number of result to return, up to 250.
 @param offset The number of results to skip. Used for paging.
 @param sort How to sort return checkins.
 @param after Retrieve the first results to follow these seconds since epoch.
 @param before Retrieve the first results prior to these seconds since epoch. Useful for paging backward in time.
 @returns The instance of NSOperation already inqueued in internal operation queue.
 Callback will not be called, if you send cancel message to the operation.
 @discussion returns in callback block "checkings" field. A "count" and "items" of check-ins:
 https://developer.foursquare.com/docs/responses/checkin
 */
+ (NSOperation *)userGetCheckins:(NSString *)userID
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
 @returns The instance of NSOperation already inqueued in internal operation queue. In case you call cancel
 method, calback will not be called.
 @returns The instance of NSOperation already inqueued in internal operation queue.
 Callback will not be called, if you send cancel message to the operation.
 @discussion returns in callback block "friends" field. A "count" and "items" of compact user objects:
 https://developer.foursquare.com/docs/responses/user
 */
+ (NSOperation *)userGetFriends:(NSString *)userID
                          limit:(NSNumber *)limit
                         offset:(NSNumber *)offset
                       callback:(Foursquare2Callback)callback;

/**
 @param userID Valid user ID to get tips from. Pass "self" to get tips of the acting user.
 @param limit Number of result to return, up to 250.
 @param offset The number of results to skip. Used for paging.
 @param sort sortNearby requires latitude and longitude to be provided.
 @returns The instance of NSOperation already inqueued in internal operation queue.
 Callback will not be called, if you send cancel message to the operation.
 @discussion returns in callback block "tips" field. A count and items of tips:
 https://developer.foursquare.com/docs/responses/tip
 */
+ (NSOperation *)userGetTips:(NSString *)userID
                       limit:(NSNumber *)limit
                      offset:(NSNumber *)offset
                        sort:(FoursquareSortingType)sort
                    latitude:(NSNumber *)latitude
                   longitude:(NSNumber *)longitude
                    callback:(Foursquare2Callback)callback;


/**
 @param userID Valid user ID to get todos from. Pass "self" to get todos of the acting user.
 @param sort Only sortNearby and sortRecent are supported. sortNearby requires latitude and longitude to be provided.
 @returns The instance of NSOperation already inqueued in internal operation queue.
 Callback block will not be called, if you send cancel message to the operation.
 @discussion returns in callback block "todos" field. A count and items of todos:
 https://developer.foursquare.com/docs/responses/todo
 */
+ (NSOperation *)userGetTodos:(NSString *)userID
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
 @returns The instance of NSOperation already inqueued in internal operation queue.
 Callback block will not be called, if you send cancel message to the operation.
 @discussion returns in callback block "venues" field.
 A count and items of objects containing a beenHere count and venue compact venues:
 https://developer.foursquare.com/docs/responses/venue
 */
+ (NSOperation *)userGetVenueHistory:(NSString *)userID
                               after:(NSDate *)after
                              before:(NSDate *)before
                          categoryID:(NSString *)categoryID
                            callback:(Foursquare2Callback)callback;

/**
 An array of users's lists.
 @param userIDs Up to 5 valid user IDs to get lists for. Passing "self" as one of the userIDs should be valid
 @returns The instance of NSOperation already inqueued in internal operation queue.
 Callback block will not be called, if you send cancel message to the operation.
 @discussion returns in callback "lists" field. If group is specified, contains a count and items of lists:
 https://developer.foursquare.com/docs/responses/list https://developer.foursquare.com/docs/multi/multi
 If FoursquareListGroupNone is specified, it contains a groups array containing elements.
 */

+ (NSOperation *)multiUserGetLists:(NSArray *)userIDs
                          callback:(Foursquare2Callback)callback;

/**
 A User's Lists.
 @param userID Valid user ID to get lists for. Pass "self" to get lists of the acting user.
 @returns The instance of NSOperation already inqueued in internal operation queue.
 Callback block will not be called, if you send cancel message to the operation.
 @discussion returns in callback "lists" field. If group is specified, contains a count and items of lists:
 https://developer.foursquare.com/docs/responses/list
 If FoursquareListGroupNone is specified, it contains a groups array containing elements.
 */
+ (NSOperation *)userGetLists:(NSString *)userID
                        group:(FoursquareListGroupType)groupType
                     latitude:(NSNumber *)latitude
                    longitude:(NSNumber *)longitude
                     callback:(Foursquare2Callback)callback;

/**
 Returns a user's mayorships.
 @param userID Valid user ID to get mayorships for. Pass "self" to get mayorships of the acting user.
 @returns The instance of NSOperation already inqueued in internal operation queue.
 Callback block will not be called, if you send cancel message to the operation.
 @discussion returns in callback "mayorships" field.
 A count and items of objects which currently only contain compact venue objects:
 https://developer.foursquare.com/docs/responses/venue
 */
+ (NSOperation *)userGetMayorships:(NSString *)userID
                          callback:(Foursquare2Callback)callback;

/**
 Returns photos from a user.
 @param userID For now, only self is supported.
 @returns The instance of NSOperation already inqueued in internal operation queue.
 Callback block will not be called, if you send cancel message to the operation.
 @discussion returns in callback block "photos" field. A count and items of photos:
 https://developer.foursquare.com/docs/responses/photo
 */
+ (NSOperation *)userGetPhotos:(NSString *)userID
                         limit:(NSNumber *)limit
                        offset:(NSNumber *)offset
                      callback:(Foursquare2Callback)callback;

#pragma mark Actions
/**
 Sends a friend request to another user. If the other user is a page then the requesting user
 will automatically start following the page.
 @param userID required The user ID to which a request will be sent.
 @returns The instance of NSOperation already inqueued in internal operation queue.
 Callback block will not be called, if you send cancel message to the operation.
 @discussion returns in callback block "user" field. A "user" object for pending user:
 https://developer.foursquare.com/docs/responses/user
 */
+ (NSOperation *)userSendFriendRequest:(NSString *)userID
                              callback:(Foursquare2Callback)callback;

/**
 Unfriend user with userID.
 @param userID The user ID to unfriend.
 @returns The instance of NSOperation already inqueued in internal operation queue.
 Callback block will not be called, if you send cancel message to the operation.
 @discussion returns in callback block "user" field.
 https://developer.foursquare.com/docs/responses/user
 */
+ (NSOperation *)userUnfriend:(NSString *)userID
                     callback:(Foursquare2Callback)callback;

/**
 Approve pending friend request.
 @param userID User ID to approve friendship.
 @returns The instance of NSOperation already inqueued in internal operation queue.
 Callback block will not be called, if you send cancel message to the operation.
 @discussion returns in callback block "user" field. User object of approved user.
 https://developer.foursquare.com/docs/responses/user
 */
+ (NSOperation *)userApproveFriend:(NSString *)userID
                          callback:(Foursquare2Callback)callback;

/**
 Deny pending friend reques.
 @param userID User ID to deny friendship.
 @returns The instance of NSOperation already inqueued in internal operation queue.
 Callback block will not be called, if you send cancel message to the operation.
 @discussion returns in callback block "user" field. User object of denied user.
 https://developer.foursquare.com/docs/responses/user
 */
+ (NSOperation *)userDenyFriend:(NSString *)userID
                       callback:(Foursquare2Callback)callback;
/**
 Changes whether the acting user will receive pings (phone notifications) when the specified user checks in.
 @returns The instance of NSOperation already inqueued in internal operation queue.
 Callback block will not be called, if you send cancel message to the operation.
 @discussion returns in callback block "user" field. User object of the user.
 https://developer.foursquare.com/docs/responses/user
 */
+ (NSOperation *)userSetPings:(BOOL)value
                    forFriend:(NSString *)userID
                     callback:(Foursquare2Callback)callback;

/**
 Updates the user's profile photo.
 @param imageData Photo under 100KB.
 @returns The instance of NSOperation already inqueued in internal operation queue.
 Callback block will not be called, if you send cancel message to the operation.
 @discussion returns in callback block "user" field. The current user object.
 https://developer.foursquare.com/docs/responses/user
 */
+ (NSOperation *)userUpdatePhoto:(NSData *)imageData
                        callback:(Foursquare2Callback)callback;

#pragma mark -

#pragma mark ---------------------------- Lists -----------------------------------------------------------------------

/**
 Update an list
 @discussion returns a callback containing the list that is edited
 https://developer.foursquare.com/docs/lists/update
 */
+ (NSOperation *)listUpdateWithId:(NSString *)listId
                             name:(NSString *)name
                      description:(NSString *)description
                    collaborative:(BOOL)isCollaborative
                          photoId:(NSString *)photoId
                         callback:(Foursquare2Callback)callback;

/**
 Delete a list
 @discussion returns a callback indicating success or failure

 Not documented on the foursquare developer site
 */
+ (NSOperation *)listDeleteWithId:(NSString *)listId
                         callback:(Foursquare2Callback)callback;

/**
 Delete an item from a given list
 @discussion returns in callback a list containing the deleted item
 https://developer.foursquare.com/docs/lists/deleteitem
 */
+ (NSOperation *)listDeleteItemWithId:(NSString *)itemId
                       fromListWithId:(NSString *)listId
                             callback:(Foursquare2Callback)callback;

/**
Add a new list given a set of params
@discussion returns in callback block the list that was created
https://developer.foursquare.com/docs/lists/add
 */
+ (NSOperation *)listAddWithName:(NSString *)listName
                     description:(NSString *)description
                   collaborative:(BOOL)isCollaborative
                         photoID:(NSString *)photoId
                        callback:(Foursquare2Callback)callback;

/**
 Get the venues on a list
 @param listID ID for the given list
 @returns array of "listitems"
 https://developer.foursquare.com/docs/responses/item.html
 */
+ (NSOperation *)listGetDetail:(NSString *)listID
                      callback:(Foursquare2Callback)callback;

/**
 Add a venue to a list
 @discussion returns in callback block a list item that was just added.
 @returns The instance of NSOperation already inqueued in internal operation queue.
 Callback block will not be called, if you send cancel message to the operation.
 List item object that was created: https://developer.foursquare.com/docs/lists/additem
 */
+ (NSOperation *)listAddVenueWithId:(NSString *)venueID
                             listId:(NSString *)listID
                               text:(NSString *)text
                           callback:(Foursquare2Callback)callback;

/**
 Suggests venues that may be appropriate for this list.
 @discussion returns in callback block, suggested venues that may be appropriate for this list.
 @returns The instance of NSOperation already inqueued in internal operation queue.
 Callback block will not be called, if you send cancel message to the operation.
 https://developer.foursquare.com/docs/lists/suggestvenues
 */
+ (NSOperation *)listSuggestVenuesForListWithId:(NSString *)listID
                                       callback:(Foursquare2Callback)callback;

/**
 Adds the current user as a follower of this list
 @discussion
 @returns The instance of NSOperation already inqueued in internal operation queue.
 Callback block will not be called, if you send cancel message to the operation.
 https://developer.foursquare.com/docs/lists/suggestvenues
 */
+ (NSOperation *)listFollowListWithId:(NSString *)listID
                               follow:(BOOL)follow
                             callback:(Foursquare2Callback)callback;

#pragma mark ---------------------------- Venues -----------------------------------------------------------------------

/**
 Returns details about a venue, including location, mayorship, tags, tips, specials, and category.
 @param venueID ID of venue to revrieve.
 @returns The instance of NSOperation already inqueued in internal operation queue.
 Callback block will not be called, if you send cancel message to the operation.
 @discussion returns in callback block "venue" field.
 A complete venue object: https://developer.foursquare.com/docs/responses/venue
 */
+ (NSOperation *)venueGetDetail:(NSString *)venueID
                       callback:(Foursquare2Callback)callback;

/**
 Add new venue.
 @discussion returns in callback block "venue" field.
 @returns The instance of NSOperation already inqueued in internal operation queue.
 Callback block will not be called, if you send cancel message to the operation.
 Venue object that was created: https://developer.foursquare.com/docs/responses/venue
 */
+ (NSOperation *)venueAddWithName:(NSString *)name
                          address:(NSString *)address
                      crossStreet:(NSString *)crossStreet
                             city:(NSString *)city
                            state:(NSString *)state
                              zip:(NSString *)zip
                            phone:(NSString *)phone
                          twitter:(NSString *)twitter
                      description:(NSString *)description
                         latitude:(NSNumber *)latitude
                        longitude:(NSNumber *)longitude
                primaryCategoryId:(NSString *)primaryCategoryId
                         callback:(Foursquare2Callback)callback;

/**
 Returns a hierarchical list of categories applied to venues.
 @returns The instance of NSOperation already inqueued in internal operation queue.
 Callback block will not be called, if you send cancel message to the operation.
 @discussion returns in callback block "categories" field.
 An array of categories containing sub- and sub-sub-categories.
 https://developer.foursquare.com/docs/responses/category
 */
+ (NSOperation *)venueGetCategoriesCallback:(Foursquare2Callback)callback;

/**
 Returns a list of venues near the current location, optionally matching a search term. llAcc, alt, altAcc are not
 included because they do not currently affect search results.
 @param query A search term to be applied against venue names.
 @param limit Number of results to return, up to 50.
 @discussion returns in callback block "venues" field.
 @returns The instance of NSOperation already inqueued in internal operation queue.
 Callback block will not be called, if you send cancel message to the operation.
 An array of compact venues:https://developer.foursquare.com/docs/responses/venue
 */
+ (NSOperation *)venueSearchNearByLatitude:(NSNumber *)latitude
                                 longitude:(NSNumber *)longitude
                                     query:(NSString *)query
                                     limit:(NSNumber *)limit
                                    intent:(FoursquareIntentType)intent
                                    radius:(NSNumber *)radius
                                categoryId:(NSString *)categoryId
                                  callback:(Foursquare2Callback)callback;

/**
 Returns a list of venues near the specified location, optionally matching a search term.
 
 @param location   A string naming a place in the world.
 If the near string is not geocodable, returns a failed_geocode error.
 @param query      A search term to be applied against venue names.
 @param limit      Number of results to return, up to 50.
 @param intent     A value defined by FoursquareIntentType.
 @param radius     Limit results to venues within this many meters of the specified location.
 Defaults to a city-wide area.
 @discussion returns in callback block "venues" field.
 @returns The instance of NSOperation already inqueued in internal operation queue.
 Callback block will not be called, if you send cancel message to the operation.
 An array of compact venues:https://developer.foursquare.com/docs/responses/venue
 */
+ (NSOperation *)venueSearchNearLocation:(NSString *)location
                                   query:(NSString *)query
                                   limit:(NSNumber *)limit
                                  intent:(FoursquareIntentType)intent
                                  radius:(NSNumber *)radius
                              categoryId:(NSString *)categoryId
                                callback:(Foursquare2Callback)callback;
/**
 Returns a list of minivenues near the current location, matching a required partial search term.
 llAcc, alt, altAcc are not included because they do not currently affect search results.
 @param query A required search term of at least 3 characters to be applied against venue names.
 @param limit Number of results to return, up to 100.
 @param radius Limit results to venues within this many meters of the specified location
 @param s , w , n , e limits results to the bounding quadrangle defined by the latitude and longitude.
 see https://github.com/Constantine-Fry/Foursquare-API-v2 Useful tips section for help.
 @returns The instance of NSOperation already inqueued in internal operation queue.
 Callback block will not be called, if you send cancel message to the operation.
 @discussion returns in callback block "minivenues" field.
 An array of compact venues:https://developer.foursquare.com/docs/responses/venue
 */
+ (NSOperation *)venueSuggestCompletionByLatitude:(NSNumber *)latitude
                                        longitude:(NSNumber *)longitude
                                             near:(NSString *)near
                                       accuracyLL:(NSNumber *)accuracyLL
                                         altitude:(NSNumber *)altitude
                                      accuracyAlt:(NSNumber *)accuracyAlt
                                            query:(NSString *)query
                                            limit:(NSNumber *)limit
                                           radius:(NSNumber *)radius
                                                s:(NSNumber *)s
                                                w:(NSNumber *)w
                                                n:(NSNumber *)n
                                                e:(NSNumber *)e
                                         callback:(Foursquare2Callback)callback;

/**
 Returns a list of venues near the current location, optionally matching a search term
 @param s , w , n , e limits results to the bounding quadrangle defined by the latitude and longitude.
 see https://github.com/Constantine-Fry/Foursquare-API-v2 Useful tips section for help.
 given by sw as its south-west corner, and ne as its north-east corner.
 @param query A search term to be applied against venue names.
 @param limit Number of results to return, up to 50.
 @returns The instance of NSOperation already inqueued in internal operation queue.
 Callback block will not be called, if you send cancel message to the operation.
 @discussion returns in callback block "venues" field.
 An array of compact venues:https://developer.foursquare.com/docs/responses/venue
 */
+ (NSOperation *)venueSearchInBoundingQuadrangleS:(NSNumber *)s
                                                w:(NSNumber *)w
                                                n:(NSNumber *)n
                                                e:(NSNumber *)e
                                            query:(NSString *)query
                                            limit:(NSNumber *)limit
                                         callback:(Foursquare2Callback)callback;

/**
 Returns a list of venues near the current location with the most people currently checked in.
 @returns The instance of NSOperation already inqueued in internal operation queue.
 Callback block will not be called, if you send cancel message to the operation.
 @discussion returns in callback block "venues" field. https://developer.foursquare.com/docs/responses/venue
 */
+ (NSOperation *)venueTrendingNearByLatitude:(NSNumber *)latitude
                                   longitude:(NSNumber *)longitude
                                       limit:(NSNumber *)limit
                                      radius:(NSNumber *)radius
                                    callback:(Foursquare2Callback)callback;

/**
 Returns a list of recommended venues near the current location.
 @param latitude ,longitude required unless near is provided. Latitude and longitude of the user's location.
 @param near required unless lat and lon are provided. A string naming a place in the world.
 If the near string is not geocodable, returns a failed_geocode error.
 @param limit Number of results to return, up to 50.
 @param offset Used to page through results.
 @param sortByDistance flag to sort the results by distance instead of relevance.
 @param openNow flag to only include venues that are open now. This prefers official provider
 hours but falls back to popular check-in hours.
 @returns The instance of NSOperation already inqueued in internal operation queue.
 Callback block will not be called, if you send cancel message to the operation.
 @discussion returns in callback block see documentation https://developer.foursquare.com/docs/venues/explore
 */
+ (NSOperation *)venueExploreRecommendedNearByLatitude:(NSNumber *)latitude
                                             longitude:(NSNumber *)longitude
                                                  near:(NSString *)near
                                            accuracyLL:(NSNumber *)accuracyLL
                                              altitude:(NSNumber *)altitude
                                           accuracyAlt:(NSNumber *)accuracyAlt
                                                 query:(NSString *)query
                                                 limit:(NSNumber *)limit
                                                offset:(NSNumber *)offset
                                                radius:(NSNumber *)radius
                                               section:(NSString *)section
                                               novelty:(NSString *)novelty
                                        sortByDistance:(BOOL)sortByDistance
                                               openNow:(BOOL)openNow
                                           venuePhotos:(BOOL)venuePhotos
                                                 price:(NSString *)price
                                              callback:(Foursquare2Callback)callback;


#pragma mark Aspects
/**
 Provides a count of how many people are at a given venue.
 @param venueID required ID of venue to retrieve
 @returns The instance of NSOperation already inqueued in internal operation queue.
 Callback block will not be called, if you send cancel message to the operation.
 @discussion returns in callback block "hereNow" field. A count and items where items are checkins:
 https://developer.foursquare.com/docs/responses/checkin
 */
+ (NSOperation *)venueGetHereNow:(NSString *)venueID
                           limit:(NSString *)limit
                          offset:(NSString *)offset
                  afterTimestamp:(NSString *)afterTimestamp
                        callback:(Foursquare2Callback)callback;

/**
 Returns tips for a venue.
 @param venueID required The venue you want tips for.
 @param limit Number of results to return, up to 500.
 @param offset Used to page through results.
 @returns The instance of NSOperation already inqueued in internal operation queue.
 Callback block will not be called, if you send cancel message to the operation.
 @discussion returns in callback block "tips" field.
 A count and items of tips: https://developer.foursquare.com/docs/responses/tip
 */
+ (NSOperation *)venueGetTips:(NSString *)venueID
                         sort:(FoursquareSortingType)sort
                        limit:(NSNumber *)limit
                       offset:(NSNumber *)offset
                     callback:(Foursquare2Callback)callback;

/**
 Returns menu for a venue.
 @param venueID ID of venue to revrieve.
 @returns The instance of NSOperation already inqueued in internal operation queue.
 Callback block will not be called, if you send cancel message to the operation.
 @discussion returns in callback block "menu" field.
 A complete menu object: https://developer.foursquare.com/docs/responses/menu
 */
+ (NSOperation *)venueGetMenu:(NSString *)venueID
                     callback:(Foursquare2Callback)callback;

#pragma mark Actions


/**
 Allows users to indicate a venue is incorrect in some way.
 @param venueID required The venue id for which an edit is being proposed.
 @param problem required
 @param duplicateVenueID ID of the duplicated venue (for problem problemDuplicate)
 @returns The instance of NSOperation already inqueued in internal operation queue.
 Callback block will not be called, if you send cancel message to the operation.
 @discussion returns in callback block no fields.
 */
+ (NSOperation *)venueFlag:(NSString *)venueID
                   problem:(FoursquareProblemType)problem
          duplicateVenueID:(NSString *)duplicateVenueID
                  callback:(Foursquare2Callback)callback;

/**
 Allows you to propose a change to a venue.
 @param venueID required The venue id for which an edit is being proposed.
 @returns The instance of NSOperation already inqueued in internal operation queue.
 Callback block will not be called, if you send cancel message to the operation.
 @discussion returns in callback block no fields.
 */
+ (NSOperation *)venueProposeEdit:(NSString *)venueID
                             name:(NSString *)name
                          address:(NSString *)address
                      crossStreet:(NSString *)crossStreet
                             city:(NSString *)city
                            state:(NSString *)state
                              zip:(NSString *)zip
                            phone:(NSString *)phone
                         latitude:(NSNumber *)lat
                        longitude:(NSNumber *)lon
                primaryCategoryId:(NSString *)primaryCategoryId
                         callback:(Foursquare2Callback)callback;

/**
 Returns photos for a venue.
 @param venueID required The venue you want photos for.
 @param limit Number of result to return, up to 500.
 @param offset The number of results to skip. Used for paging.
 @returns The instance of NSOperation already inqueued in internal operation queue.
 Callback block will not be called, if you send cancel message to the operation.
 @discussion returns in callback block "photos" field.
 A count and items of photo. https://developer.foursquare.com/docs/responses/photo
 */
+ (NSOperation *)venueGetPhotos:(NSString *)venueID
                          limit:(NSNumber *)limit
                         offset:(NSNumber *)offset
                       callback:(Foursquare2Callback)callback;
#pragma mark -

#pragma mark ---------------------------- Checkins ---------------------------------------------------------------------

/**
 Get details of checkin.
 @param checkinID The ID of the checkin to retrieve additional information for.
 @returns The instance of NSOperation already inqueued in internal operation queue.
 Callback block will not be called, if you send cancel message to the operation.
 @discussion returns in callback block a complete checkin object.
 https://developer.foursquare.com/docs/responses/checkin
 */
+ (NSOperation *)checkinGetDetail:(NSString *)checkinID
                         callback:(Foursquare2Callback)callback;

/**
 Create checkin at venue with venueID with broadcastPublic.
 @param venueID required the venue where the user is checking in.
 @param shout a message about your check-in.
 @returns The instance of NSOperation already inqueued in internal operation queue.
 Callback block will not be called, if you send cancel message to the operation.
 @discussion returns in callback block "checkin" and "notifications" field.
 a checkin object https://developer.foursquare.com/docs/responses/checkin
 a notification object https://developer.foursquare.com/docs/responses/notifications
 */
+ (NSOperation *)checkinAddAtVenue:(NSString *)venueID
                             shout:(NSString *)shout
                          callback:(Foursquare2Callback)callback;
/**
 Create checkin at venue with venueID.
 @param venueID required the venue where the user is checking in.
 @param eventID the event the user is checking in to.
 @param shout a message about your check-in.
 @param broadcast who to broadcast this check-in to. Accepts several values.
 @returns The instance of NSOperation already inqueued in internal operation queue.
 Callback block will not be called, if you send cancel message to the operation.
 @discussion returns in callback block "checkin" and "notifications" field.
 a checkin object https://developer.foursquare.com/docs/responses/checkin
 a notification object https://developer.foursquare.com/docs/responses/notifications
 */
+ (NSOperation *)checkinAddAtVenue:(NSString *)venueID
                             event:(NSString *)eventID
                             shout:(NSString *)shout
                         broadcast:(FoursquareBroadcastType)broadcast
                          latitude:(NSNumber *)latitude
                         longitude:(NSNumber *)longitude
                        accuracyLL:(NSNumber *)accuracyLL
                          altitude:(NSNumber *)altitude
                       accuracyAlt:(NSNumber *)accuracyAlt
                          callback:(Foursquare2Callback)callback;

/**
 Returns a list of recent checkins from friends.
 @param limit number of results to return, up to 100.
 @returns The instance of NSOperation already inqueued in internal operation queue.
 Callback block will not be called, if you send cancel message to the operation.
 @discussion returns in callback block "checkins" field. an array of checkin objects with user details present.
 https://developer.foursquare.com/docs/responses/checkin
 */
+ (NSOperation *)checkinGetRecentsByFriends:(NSNumber *)latitude
                                  longitude:(NSNumber *)longitude
                                      limit:(NSNumber *)limit
                             afterTimestamp:(NSString *)afterTimestamp
                                   callback:(Foursquare2Callback)callback;
#pragma mark Aspects

/**
 Returns friends and a total count of users who have liked this checkin.
 @param checkinID The ID of the checkin to get likes for.
 @returns The instance of NSOperation already inqueued in internal operation queue.
 Callback block will not be called, if you send cancel message to the operation.
 @discussion returns in callback block "likes" field. A "count" and "groups" of users who like this checkin.
 */
+ (NSOperation *)checkinGetLikes:(NSString *)checkinID
                        callback:(Foursquare2Callback)callback;

#pragma -
#pragma mark Actions

/**
 Comment on a checkin-in.
 @param checkinID the ID of the checkin to add a comment to.
 @param text the text of the comment.
 @returns The instance of NSOperation already inqueued in internal operation queue.
 Callback block will not be called, if you send cancel message to the operation.
 @discussion returns in callback block "comment" field. The newly-created comment.
 */
+ (NSOperation *)checkinAddComment:(NSString *)checkinID
                              text:(NSString *)text
                          callback:(Foursquare2Callback)callback;

/**
 Remove a comment from a checkin, if the acting user is the author or the owner of the checkin.
 @param commentID the ID of the comment to remove.
 @param checkinID the ID of the checkin to remove a comment from.
 @returns The instance of NSOperation already inqueued in internal operation queue.
 Callback block will not be called, if you send cancel message to the operation.
 @discussion returns in callback block "checkin" field. the checkin, minus this comment.
 */
+ (NSOperation *)checkinDeleteComment:(NSString *)commentID
                           forCheckin:(NSString *)checkinID
                             callback:(Foursquare2Callback)callback;

/**
 Allows the acting user to like or unlike a checkin.
 @param checkinID required The checkin to like or unlike.
 @param like If YES, like this checkin. If NO, unlike.
 @returns The instance of NSOperation already inqueued in internal operation queue.
 Callback block will not be called, if you send cancel message to the operation.
 @discussion returns in callback block "likes" field. updated count and groups of users who like this checkin.
 */
+ (NSOperation *)checkinLike:(NSString *)checkinID
                        like:(BOOL)like
                    callback:(Foursquare2Callback)callback;


#pragma mark -
#pragma mark ---------------------------- Tips -------------------------------------------------------------------------

/**
 Gives details about a tip, including which users (especially friends) have marked the tip to-do.
 @param tipID required ID of tip to retrieve.
 @returns The instance of NSOperation already inqueued in internal operation queue.
 Callback block will not be called, if you send cancel message to the operation.
 @discussion returns in callback block "tip" field. A complete tip https://developer.foursquare.com/docs/responses/tip
 */
+ (NSOperation *)tipGetDetail:(NSString *)tipID
                     callback:(Foursquare2Callback)callback;

/**
 Allows you to add a new tip at a venue.
 @param tip required the text for this tip.
 @param venueID required The venue where you want to add this tip.
 @param url A URL related to this tip.
 @returns The instance of NSOperation already inqueued in internal operation queue.
 Callback block will not be called, if you send cancel message to the operation.
 @discussion returns in callback block "tip" field. https://developer.foursquare.com/docs/responses/tip
 */
+ (NSOperation *)tipAdd:(NSString *)tip
               forVenue:(NSString *)venueID
                withURL:(NSString *)url
               callback:(Foursquare2Callback)callback;

/**
 Returns a list of tips near the area specified.
 @param latitude and longitude required unless near is provided. Latitude and longitude of the user's location.
 @param near required unless lat and lon are provided. A string naming a place in the world.
 @param limit Number of result to return, up to 500.
 @param offset The number of results to skip. Used for paging.
 @param friendsOnly If YES only show nearby tips from friends.
 @returns The instance of NSOperation already inqueued in internal operation queue.
 Callback block will not be called, if you send cancel message to the operation.
 @discussion returns in callback block "tips" field. An array of tips, each of which contain a user and venue.
 */
+ (NSOperation *)tipSearchNearbyLatitude:(NSNumber *)latitude
                               longitude:(NSNumber *)longitude
                                    near:(NSString *)near
                                   limit:(NSNumber *)limit
                                  offset:(NSNumber *)offset
                             friendsOnly:(BOOL)friendsOnly
                                   query:(NSString *)query
                                callback:(Foursquare2Callback)callback;

#pragma mark -


#pragma mark ---------------------------- Photos -----------------------------------------------------------------------

/**
 Get details of a photo.
 @param photoID required The ID of the photo to retrieve additional information for.
 @returns The instance of NSOperation already inqueued in internal operation queue.
 Callback block will not be called, if you send cancel message to the operation.
 @discussion returns in callback block "photo" field.
 A complete photo object. https://developer.foursquare.com/docs/responses/photo
 */
+ (NSOperation *)photoGetDetail:(NSString *)photoID
                       callback:(Foursquare2Callback)callback;



/**
 Allows users to add a new photo to a checkin.
 @param photoData photo to upload.
 @param checkinID the ID of a checkin owned by the user.
 @returns The instance of NSOperation already inqueued in internal operation queue.
 Callback block will not be called, if you send cancel message to the operation.
 @discussion returns in callback block "photo" field.
 The photo that was just created. https://developer.foursquare.com/docs/responses/photo
 */
+ (NSOperation *)photoAdd:(NSData *)photoData
                toCheckin:(NSString *)checkinID
                 callback:(Foursquare2Callback)callback;



/**
 Allows users to add a new photo to a checkin, tip or venue.
 @param photoData photo to upload.
 @param checkinID the ID of a checkin owned by the user.
 @param tipID the ID of a tip owned by the user.
 @param broadcast whether to broadcast this photo.
 @returns The instance of NSOperation already inqueued in internal operation queue.
 Callback block will not be called, if you send cancel message to the operation.
 @discussion returns in callback block "photo" field.
 The photo that was just created. https://developer.foursquare.com/docs/responses/photo
 */
+ (NSOperation *)photoAddTo:(NSData *)photoData
                    checkin:(NSString *)checkinID
                        tip:(NSString *)tipID
                      venue:(NSString *)venueID
                  broadcast:(FoursquareBroadcastType)broadcast
                   latitude:(NSNumber *)latitude
                  longitude:(NSNumber *)longitude
                 accuracyLL:(NSNumber *)accuracyLL
                   altitude:(NSNumber *)altitude
                accuracyAlt:(NSNumber *)accuracyAlt
                   callback:(Foursquare2Callback)callback;

#pragma mark -

#pragma mark ---------------------------- Settings ---------------------------------------------------------------------

/**
 Returns the settings of the acting user.
 @returns The instance of NSOperation already inqueued in internal operation queue.
 Callback block will not be called, if you send cancel message to the operation.
 @discussion returns in callback block "settings" field. A setting object for the acting user.
 https://developer.foursquare.com/docs/responses/settings
 */
+ (NSOperation *)settingsGetAllCallback:(Foursquare2Callback)callback;

/*
 Change a setting for the given user.
 @param settingName setting to set value.
 @param value YES or NO.
 @returns The instance of NSOperation already inqueued in internal operation queue.
 Callback block will not be called, if you send cancel message to the operation.
 @discussion returns in callback block "message" field. a confirmation message.
 */
+ (NSOperation *)settingsSet:(FoursquareSettingName)settingName
                     toValue:(BOOL)value
                    callback:(Foursquare2Callback)callback;

#pragma mark -

@end
