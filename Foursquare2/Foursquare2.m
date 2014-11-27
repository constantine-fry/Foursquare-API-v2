//
//  Foursquare2.m
//  Foursquare API
//
//  Created by Constantine Fry on 1/7/11.
//  Copyright 2011 Home. All rights reserved.
//

#import "Foursquare2.h"
#import "FSKeychain.h"
#ifndef __MAC_OS_X_VERSION_MAX_ALLOWED
#import "FSOAuthNoAppStore.h"
#endif

//update this date to use up-to-date Foursquare API
#ifndef FS2_API_VERSION
#define FS2_API_VERSION (@"20140503")
#endif

static NSString * kFOURSQUARE_BASE_URL = @"https://api.foursquare.com/v2/";

static NSString const * kFOURSQUARE_CLIET_ID = @"FOURSQUARE_CLIET_ID";
static NSString const * kFOURSQUARE_OAUTH_SECRET = @"FOURSQUARE_OAUTH_SECRET";
static NSString const * kFOURSQUARE_CALLBACK_URL = @"FOURSQUARE_CALLBACK_URL";

static NSString const * kFOURSQUARE_ACCESS_TOKEN = @"FOURSQUARE_ACCESS_TOKEN";

NSString * const kFoursquare2NativeAuthErrorDomain = @"fs.native.auth";
NSString * const kFoursquare2ErrorDomain = @"kFoursquare2ErrorDomain";
NSString * const kFoursquare2DidRemoveAccessTokenNotification = @"kFoursquare2DidRemoveAccessTokenNotification";

@interface Foursquare2 () <FSWebLoginDelegate>

@property (nonatomic, copy) Foursquare2Callback authorizationCallback;

@property (nonatomic, strong) NSOperationQueue *operationQueue;
@property (nonatomic) dispatch_queue_t callbackQueue;

/** The timeout interval for NSURLRequest. The default value is 60 sec. */
@property(nonatomic,assign) NSTimeInterval timeoutInterval;

+ (NSOperation *)sendGetRequestWithPath:(NSString *)path
                             parameters:(NSDictionary *)parameters
                               callback:(Foursquare2Callback)callback;

+ (NSOperation *)sendPostRequestWithPath:(NSString *)path
                              parameters:(NSDictionary *)parameters
                                callback:(Foursquare2Callback)callback;

+ (void)setAccessToken:(NSString *)token;
+ (NSString *)problemTypeToString:(FoursquareProblemType)problem;
+ (NSString *)broadcastTypeToString:(FoursquareBroadcastType)broadcast;
+ (NSString *)sortTypeToString:(FoursquareSortingType)type;

+ (void)setAttributeValue:(id)attr forKey:(NSString *)key;
+ (NSMutableDictionary *)classAttributes;
@end

@implementation Foursquare2

static NSMutableDictionary *attributes;

+ (void)setCallbackQueue:(dispatch_queue_t)callbackQueue {
    [self sharedInstance].callbackQueue = callbackQueue;
}

+ (void)setTimeoutInterval:(NSTimeInterval)timeoutInterval {
    [self sharedInstance].timeoutInterval = timeoutInterval;
}

+ (dispatch_queue_t)callbackQueue {
    return [self sharedInstance].callbackQueue;
}

+ (void)setupFoursquareWithClientId:(NSString *)clientId
                             secret:(NSString *)secret
                        callbackURL:(NSString *)callbackURL {
    [self classAttributes][kFOURSQUARE_CLIET_ID] = clientId;
    [self classAttributes][kFOURSQUARE_OAUTH_SECRET] = secret;
    [self classAttributes][kFOURSQUARE_CALLBACK_URL] = callbackURL;
    
    //moving access token from NSUserDefault into keychain.
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *userDefaultsAccessToken = [userDefaults objectForKey:@"FOURSQUARE_ACCESS_TOKEN"];
    if (userDefaultsAccessToken != nil) {
        [[FSKeychain sharedKeychain] saveAccessTokenInKeychain:userDefaultsAccessToken
                                                   forClientId:clientId];
        [userDefaults removeObjectForKey:@"FOURSQUARE_ACCESS_TOKEN"];
    }
    
    NSString *accessToken = [[FSKeychain sharedKeychain] readAccessTokenFromKeychainWithClientId:clientId];
    if (accessToken != nil) {
        [self classAttributes][kFOURSQUARE_ACCESS_TOKEN] = accessToken;
    }
}

+ (void)setAttributeValue:(id)attr forKey:(NSString *)key {
    [self classAttributes][key] = attr;
}

+ (NSMutableDictionary *)classAttributes {
    if(attributes) {
        return attributes;
    } else {
        attributes = [[NSMutableDictionary alloc] init];
    }
    return attributes;
}

+ (void)setAccessToken:(NSString *)accessToken {
    NSString *existingAccessToken = [self accessToken];
    if (![existingAccessToken isEqualToString:accessToken]) {
        [self classAttributes][kFOURSQUARE_ACCESS_TOKEN] = accessToken;
        NSString *clientId = [self classAttributes][kFOURSQUARE_CLIET_ID];
        [[FSKeychain sharedKeychain] saveAccessTokenInKeychain:accessToken
                                                   forClientId:clientId];
    }
}

+ (void)removeAccessToken {
    [[self classAttributes] removeObjectForKey:kFOURSQUARE_ACCESS_TOKEN];
    NSString *clientId = [self classAttributes][kFOURSQUARE_CLIET_ID];
    [[FSKeychain sharedKeychain] removeAccessTokenFromKeychainWithClientId:clientId];
}

+ (NSString *)accessToken {
    return [self classAttributes][kFOURSQUARE_ACCESS_TOKEN];
}

+ (BOOL)isAuthorized {
    return ([self classAttributes][kFOURSQUARE_ACCESS_TOKEN] != nil);
}

+ (NSString *)stringFromArray:(NSArray *)array {
    if (array.count) {
        return [array componentsJoinedByString:@","];
    }
    return @"";
    
}
#pragma mark -
#pragma mark Users

+ (NSOperation *)userGetDetail:(NSString *)userID
                      callback:(Foursquare2Callback)callback {
    NSString *path = [NSString stringWithFormat:@"users/%@",userID];
    return [self sendGetRequestWithPath:path parameters:nil callback:callback];
}

+ (NSOperation *)userSearchWithPhone:(NSArray *)phones
                               email:(NSArray *)emails
                             twitter:(NSArray *)twitters
                       twitterSource:(NSString *)twitterSource
                         facebookIDs:(NSArray *)fbid
                                name:(NSString *)name
                            callback:(Foursquare2Callback)callback {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"phone"] = [self stringFromArray:phones];
    parameters[@"email"] = [self stringFromArray:emails];
    parameters[@"twitter"] = [self stringFromArray:twitters];
    if (twitterSource) {
        parameters[@"twitterSource"] = twitterSource;
    }
    parameters[@"fbid"] = [self stringFromArray:fbid];
    if (name) {
        parameters[@"name"] = name;
    }
    return [self sendGetRequestWithPath:@"users/search" parameters:parameters callback:callback];
}

+ (NSOperation *)userGetFriendRequestsCallback:(Foursquare2Callback)callback {
    return [self sendGetRequestWithPath:@"users/requests" parameters:nil callback:callback];
}

+ (NSOperation *)userGetLeaderboardCallback:(Foursquare2Callback)callback {
    return [self sendGetRequestWithPath:@"users/leaderboard" parameters:nil callback:callback];
}

#pragma mark Aspects

+ (NSOperation *)userGetBadges:(NSString *)userID
                      callback:(Foursquare2Callback)callback {
    NSString *path = [NSString stringWithFormat:@"users/%@/badges",userID];
    return [self sendGetRequestWithPath:path parameters:nil callback:callback];
}

+ (NSOperation *)userGetCheckins:(NSString *)userID
                           limit:(NSNumber *)limit
                          offset:(NSNumber *)offset
                            sort:(FoursquareCheckinsSort)sort
                           after:(NSDate *)after
                          before:(NSDate *)before
                        callback:(Foursquare2Callback)callback {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    if (sort == FoursquareCheckinsNewestFirst) {
        parameters[@"sort"] = @"newestfirst";
    } else if (sort == FoursquareCheckinsOldestFirst) {
        parameters[@"sort"] = @"oldestfirst";
    }
    if (offset) {
        parameters[@"offset"] = [offset stringValue];
    }
    if (limit) {
        parameters[@"limit"] = [limit stringValue];
    }
    if (after) {
        parameters[@"afterTimestamp"] = [self timeStampStringFromDate:after];
    }
    if (before) {
        parameters[@"beforeTimestamp"] = [self timeStampStringFromDate:before];
    }
    NSString *path = [NSString stringWithFormat:@"users/%@/checkins",userID];
    return [self sendGetRequestWithPath:path parameters:parameters callback:callback];
}

+ (NSOperation *)userGetFriends:(NSString *)userID
                          limit:(NSNumber *)limit
                         offset:(NSNumber *)offset
                       callback:(Foursquare2Callback)callback {
    NSString *path = [NSString stringWithFormat:@"users/%@/friends",userID];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    if (limit) {
        parameters[@"limit"] = [limit stringValue];
    }
    if (offset) {
        parameters[@"offset"] = [offset stringValue];
    }
    return [self sendGetRequestWithPath:path parameters:parameters callback:callback];
}

+ (NSOperation *)userGetTips:(NSString *)userID
                       limit:(NSNumber *)limit
                      offset:(NSNumber *)offset
                        sort:(FoursquareSortingType)sort
                    latitude:(NSNumber *)latitude
                   longitude:(NSNumber *)longitude
                    callback:(Foursquare2Callback)callback {
    if (sort == sortNearby && (!latitude || !longitude)) {
        NSAssert(NO, @"Foursqure2 getTipsFromUser: Nearby requires geolat and geolong to be provided.");
    }
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"sort"] = [self sortTypeToString:sort];
    if (limit) {
        parameters[@"limit"] = [limit stringValue];
    }
    if (offset) {
        parameters[@"offset"] = [offset stringValue];
    }
    
    if (latitude && longitude) {
        parameters[@"ll"] = [NSString stringWithFormat:@"%@,%@",latitude,longitude];
    }
    NSString *path = [NSString stringWithFormat:@"users/%@/tips",userID];
    return [self sendGetRequestWithPath:path parameters:parameters callback:callback];
}

+ (NSOperation *)userGetTodos:(NSString *)userID
                         sort:(FoursquareSortingType)sort
                     latitude:(NSNumber *)latitude
                    longitude:(NSNumber *)longitude
                     callback:(Foursquare2Callback)callback {
    if (sort == sortNearby && (!latitude || !longitude)) {
        NSAssert(NO, @"Foursqure2 getTodosFromUser: Nearby requires geolat and geolong to be provided.");
    }
    
    if (sort == sortPopular) {
        NSAssert(NO, @"Foursqure2 getTodosFromUser: sortPopular is not supported in this method.");
    }
    
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"sort"] = [self sortTypeToString:sort];
    if (latitude && longitude) {
        parameters[@"ll"] = [NSString stringWithFormat:@"%@,%@",latitude,longitude];
    }
    NSString *path = [NSString stringWithFormat:@"users/%@/todos",userID];
    return [self sendGetRequestWithPath:path parameters:parameters callback:callback];
}

+ (NSOperation *)userGetVenueHistory:(NSString *)userID
                               after:(NSDate *)after
                              before:(NSDate *)before
                          categoryID:(NSString *)categoryID
                            callback:(Foursquare2Callback)callback {
    NSString *path = [NSString stringWithFormat:@"users/%@/venuehistory",userID];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    if (after) {
        parameters[@"afterTimestamp"] = [self timeStampStringFromDate:after];
    }
    if (before) {
        parameters[@"beforeTimestamp"] = [self timeStampStringFromDate:before];
    }
    if (categoryID) {
        parameters[@"categoryId"] = categoryID;
    }
    return [self sendGetRequestWithPath:path parameters:parameters callback:callback];
}

+ (NSOperation *)multiUserGetLists:(NSArray *)userIDs
                          callback:(Foursquare2Callback)callback {
    NSAssert([userIDs count] >= 5, @"Multi does not work with more than 5 methods at a time");
    NSString *path = @"multi?requests=/users/";
    NSString *multiParameters = [userIDs componentsJoinedByString:@"/lists,/users/"];
    path = [[path stringByAppendingString:multiParameters] stringByAppendingString:@"/lists"];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    return [self sendGetRequestWithPath:path parameters:parameters callback:callback];
}

+ (NSOperation *)userGetLists:(NSString *)userID
                        group:(FoursquareListGroupType)groupType
                     latitude:(NSNumber *)latitude
                    longitude:(NSNumber *)longitude
                     callback:(Foursquare2Callback)callback {
    NSString *path = [NSString stringWithFormat:@"users/%@/lists",userID];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    if (groupType) {
        parameters[@"group"] = [self listGroupTypeToString:groupType];
    }
    if (latitude && longitude) {
        parameters[@"ll"] = [NSString stringWithFormat:@"%@,%@",latitude,longitude];
    }
    return [self sendGetRequestWithPath:path parameters:parameters callback:callback];
}

+ (NSOperation *)userGetMayorships:(NSString *)userID
                          callback:(Foursquare2Callback)callback {
    NSString *path = [NSString stringWithFormat:@"users/%@/mayorships",userID];
    return [self sendGetRequestWithPath:path parameters:nil callback:callback];
}

+ (NSOperation *)userGetPhotos:(NSString *)userID
                         limit:(NSNumber *)limit
                        offset:(NSNumber *)offset
                      callback:(Foursquare2Callback)callback {
    NSString *path = [NSString stringWithFormat:@"users/%@/photos",userID];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    if (limit) {
        parameters[@"limit"] = [limit stringValue];
    }
    if (offset) {
        parameters[@"offset"] = [offset stringValue];
    }
    return [self sendGetRequestWithPath:path parameters:nil callback:callback];
}
#pragma mark Actions

+ (NSOperation *)userSendFriendRequest:(NSString *)userID
                              callback:(Foursquare2Callback)callback {
    if (!userID || !userID.length) {
        NSAssert(NO, @"Foursqure2 sendFriendRequestToUser: userID can't be nil or empty.");
    }
    NSString *path = [NSString stringWithFormat:@"users/%@/request",userID];
    return [self sendPostRequestWithPath:path parameters:nil callback:callback];
}

+ (NSOperation *)userUnfriend:(NSString *)userID
                     callback:(Foursquare2Callback)callback {
    NSString *path = [NSString stringWithFormat:@"users/%@/unfriend",userID];
    return [self sendPostRequestWithPath:path parameters:nil callback:callback];
}

+ (NSOperation *)userApproveFriend:(NSString *)userID
                          callback:(Foursquare2Callback)callback {
    NSString *path = [NSString stringWithFormat:@"users/%@/approve",userID];
    return [self sendPostRequestWithPath:path parameters:nil callback:callback];
}

+ (NSOperation *)userDenyFriend:(NSString *)userID
                       callback:(Foursquare2Callback)callback {
    NSString *path = [NSString stringWithFormat:@"users/%@/deny",userID];
    return [self sendPostRequestWithPath:path parameters:nil callback:callback];
}

+ (NSOperation *)userSetPings:(BOOL)value
                    forFriend:(NSString *)userID
                     callback:(Foursquare2Callback)callback {
    if (!userID || !userID.length) {
        NSAssert(NO, @"Foursqure2 setPings: userID can't be nil or empty.");
    }
    NSString *path = [NSString stringWithFormat:@"users/%@/setpings",userID];
    NSDictionary *parameters = @{@"value":(value?@"true":@"false")};
    return [self sendPostRequestWithPath:path parameters:parameters callback:callback];
}

+ (NSOperation *)userUpdatePhoto:(NSData *)imageData
                        callback:(Foursquare2Callback)callback {
    return [[Foursquare2 sharedInstance] uploadPhoto:@"users/self/update"
                                      withParameters:nil
                                       withImageData:imageData
                                            callback:callback];
}

#pragma mark -
#pragma mark Lists

+ (NSOperation *)listDeleteWithId:(NSString *)listId
                         callback:(Foursquare2Callback)callback {
    NSString *path = [NSString stringWithFormat:@"lists/%@/delete", listId];

    return [self sendPostRequestWithPath:path parameters:nil callback:callback];
}

+ (NSOperation *)listUpdateWithId:(NSString *)listId
                             name:(NSString *)name
                      description:(NSString *)description
                    collaborative:(BOOL)isCollaborative
                          photoId:(NSString *)photoId
                         callback:(Foursquare2Callback)callback {
    NSString *path = [NSString stringWithFormat:@"lists/%@/update", listId];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];

    if (name) {
        [parameters setObject:name forKey:@"name"];
    }
    if (description) {
        [parameters setObject:description forKey:@"description"];
    }
    if (isCollaborative) {
        [parameters setObject:@(TRUE) forKey:@"collaborative"];
    }
    if (photoId) {
        [parameters setObject:photoId forKey:@"photoId"];
    }
    return [self sendPostRequestWithPath:path parameters:parameters callback:callback];
}

+ (NSOperation *)listDeleteItemWithId:(NSString *)itemId
                       fromListWithId:(NSString *)listId
                         callback:(Foursquare2Callback)callback {
    NSAssert(listId, @"ListId for deletion must not be nil");
    NSAssert(itemId, @"itemId for deletion must not be nil");
    NSString *path = [NSString stringWithFormat:@"/lists/%@/deleteitem", listId];
    NSDictionary *parameters = @{@"itemId":itemId};
    return [self sendPostRequestWithPath:path parameters:parameters callback:callback];
}

+ (NSOperation *)listAddWithName:(NSString *)listName
                     description:(NSString *)description
                   collaborative:(BOOL)isCollaborative
                         photoID:(NSString *)photoId
                        callback:(Foursquare2Callback)callback {

    NSString *path = @"lists/add";
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    NSAssert(listName, @"List must have a name");
    [parameters setObject:listName forKey:@"name"];
    
    if (description) {
        [parameters setObject:description forKey:@"description"];
    }
    if (isCollaborative) {
        [parameters setObject:@(TRUE) forKey:@"collaborative"];
    }
    if (photoId) {
        [parameters setObject:photoId forKey:@"photoId"];
    }
    return [self sendPostRequestWithPath:path parameters:parameters callback:callback];
}

+ (NSOperation *)listGetDetail:(NSString *)listID
                      callback:(Foursquare2Callback)callback {
    NSString *path = [NSString stringWithFormat:@"lists/%@", listID];
    return [self sendGetRequestWithPath:path parameters:nil callback:callback];
}

+ (NSOperation *)listAddVenueWithId:(NSString *)venueID
                             listId:(NSString *)listID
                               text:(NSString *)text
                           callback:(Foursquare2Callback)callback {
    NSAssert(venueID, @"Must pass in a non-nil venueID");
    NSString *path = [NSString stringWithFormat:@"/lists/%@/additem", listID];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithDictionary:@{@"venueId":venueID}];
    if (text) {
        parameters[@"text"] = text;
    }
    return [self sendPostRequestWithPath:path parameters:parameters callback:callback];
}

+ (NSOperation *)listSuggestVenuesForListWithId:(NSString *)listID
                           callback:(Foursquare2Callback)callback {
    NSString *path = [NSString stringWithFormat:@"/lists/%@/suggestvenues", listID];
    return [self sendGetRequestWithPath:path parameters:nil callback:callback];
}

+ (NSOperation *)listFollowListWithId:(NSString *)listID
                               follow:(BOOL)follow
                             callback:(Foursquare2Callback)callback {
    NSString *method = follow ? @"follow" : @"unfollow";
    NSString *path = [NSString stringWithFormat:@"/lists/%@/%@", listID, method];
    return [self sendPostRequestWithPath:path parameters:nil callback:callback];
}

#pragma mark -
#pragma mark Venues

+ (NSOperation *)venueGetDetail:(NSString *)venueID
                       callback:(Foursquare2Callback)callback {
    NSString *path = [NSString stringWithFormat:@"venues/%@",venueID];
    return [self sendGetRequestWithPath:path parameters:nil callback:callback];
}

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
                         callback:(Foursquare2Callback)callback {
    if (!name || !name.length || !latitude || !longitude) {
        NSAssert(NO, @"Forusquare2 venueAddWithName: name, latitude, longitude are required parameters.");
    }
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    if (name) {
        parameters[@"name"] = name;
    }
    if (address) {
        parameters[@"address"] = address;
    }
    if (crossStreet) {
        parameters[@"crossStreet"] = crossStreet;
    }
    if (city) {
        parameters[@"city"] = city;
    }
    if (state) {
        parameters[@"state"] = state;
    }
    if (zip) {
        parameters[@"zip"] = zip;
    }
    if (phone) {
        parameters[@"phone"] = phone;
    }
    if (twitter) {
        parameters[@"twitter"] = twitter;
    }
    if (description) {
        parameters[@"description"] = description;
    }
    if (latitude && longitude) {
        parameters[@"ll"] = [NSString stringWithFormat:@"%@,%@", latitude, longitude];
    }
    if (primaryCategoryId) {
        parameters[@"primaryCategoryId"] = primaryCategoryId;
    }
    return [self sendPostRequestWithPath:@"venues/add" parameters:parameters callback:callback];
}

+ (NSOperation *)venueGetCategoriesCallback:(Foursquare2Callback)callback {
    return [self sendGetRequestWithPath:@"venues/categories" parameters:nil callback:callback];
}

+ (NSOperation *)venueSearchNearByLatitude:(NSNumber *)latitude
                                 longitude:(NSNumber *)longitude
                                     query:(NSString *)query
                                     limit:(NSNumber *)limit
                                    intent:(FoursquareIntentType)intent
                                    radius:(NSNumber *)radius
                                categoryId:(NSString *)categoryId
                                  callback:(Foursquare2Callback)callback {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    if (latitude && longitude) {
        parameters[@"ll"] = [NSString stringWithFormat:@"%@,%@",latitude,longitude];
    }
    if (query) {
        parameters[@"query"] = query;
    }
    if (limit) {
        parameters[@"limit"] = limit.stringValue;
    }
    if (intent) {
        parameters[@"intent"] = [self inentTypeToString:intent];
    }
    if (radius) {
        parameters[@"radius"] = radius.stringValue;
    }
    if (categoryId) {
        parameters[@"categoryId"] = categoryId;
    }
    return [self sendGetRequestWithPath:@"venues/search" parameters:parameters callback:callback];
}

+ (NSOperation *)venueSearchNearLocation:(NSString *)location
                                   query:(NSString *)query
                                   limit:(NSNumber *)limit
                                  intent:(FoursquareIntentType)intent
                                  radius:(NSNumber *)radius
                              categoryId:(NSString *)categoryId
                                callback:(Foursquare2Callback)callback {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    if (location) {
        parameters[@"near"] = location;
    }
    if (query) {
        parameters[@"query"] = query;
    }
    if (limit) {
        parameters[@"limit"] = limit.stringValue;
    }
    if (intent) {
        parameters[@"intent"] = [self inentTypeToString:intent];
    }
    if (radius) {
        parameters[@"radius"] = radius.stringValue;
    }
    if (categoryId) {
        parameters[@"categoryId"] = categoryId;
    }
    return [self sendGetRequestWithPath:@"venues/search" parameters:parameters callback:callback];
}

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
                                         callback:(Foursquare2Callback)callback {
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    if (latitude && longitude) {
        parameters[@"ll"] = [NSString stringWithFormat:@"%@,%@",latitude,longitude];
    }
    if (near) {
        parameters[@"near"] = near;
    }
    if (query) {
        parameters[@"query"] = query;
    }
    if (limit) {
        parameters[@"limit"] = limit.stringValue;
    }
    if (radius) {
        parameters[@"radius"] = radius.stringValue;
    }
    if (s && w && n && e) {
        parameters[@"sw"] = [NSString stringWithFormat:@"%@,%@",s, w];
        parameters[@"ne"] = [NSString stringWithFormat:@"%@,%@",n, e];
    }
    return [self sendGetRequestWithPath:@"venues/suggestcompletion" parameters:parameters callback:callback];
}

+ (NSOperation *)venueSearchInBoundingQuadrangleS:(NSNumber *)s
                                                w:(NSNumber *)w
                                                n:(NSNumber *)n
                                                e:(NSNumber *)e
                                            query:(NSString *)query
                                            limit:(NSNumber *)limit
                                         callback:(Foursquare2Callback)callback {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    if (s && w && n && e) {
        parameters[@"sw"] = [NSString stringWithFormat:@"%@,%@",s, w];
        parameters[@"ne"] = [NSString stringWithFormat:@"%@,%@",n, e];
    }
    if (query) {
        parameters[@"query"] = query;
    }
    if (limit) {
        parameters[@"limit"] = limit.stringValue;
    }
    parameters[@"intent"] = [self inentTypeToString:intentBrowse];
    return [self sendGetRequestWithPath:@"venues/search" parameters:parameters callback:callback];
}

+ (NSOperation *)venueTrendingNearByLatitude:(NSNumber *)latitude
                                   longitude:(NSNumber *)longitude
                                       limit:(NSNumber *)limit
                                      radius:(NSNumber *)radius
                                    callback:(Foursquare2Callback)callback {
    if (!latitude || !longitude) {
        NSAssert(NO, @"Foursqure2 venueTrendingNearByLatitude: latitude and longitude are required parameters.");
    }
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    if (latitude && longitude) {
        parameters[@"ll"] = [NSString stringWithFormat:@"%@,%@",latitude,longitude];
    }
    if (limit) {
        parameters[@"limit"] = limit.stringValue;
    }
    if (radius) {
        parameters[@"radius"] = radius.stringValue;
    }
    return [self sendGetRequestWithPath:@"venues/trending" parameters:parameters callback:callback];
}

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
                                              callback:(Foursquare2Callback)callback {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    if (!near && !near.length && (!latitude && !longitude)) {
        NSAssert(NO, @"Foursqure2 venueExploreRecommendedNearByLatitude: near or ll are required parameters.");
    }
    if (latitude && longitude) {
        parameters[@"ll"] = [NSString stringWithFormat:@"%@,%@",latitude,longitude];
    }
    if (near) {
        parameters[@"near"] = near;
    }
    if (accuracyLL) {
        parameters[@"llAcc"] = accuracyLL.stringValue;
    }
    if (altitude) {
        parameters[@"alt"] = altitude.stringValue;
    }
    if (accuracyAlt) {
        parameters[@"altAcc"] = accuracyAlt.stringValue;
    }
    if (query) {
        parameters[@"query"] = query;
    }
    if (limit) {
        parameters[@"limit"] = limit.stringValue;
    }
    if (offset) {
        parameters[@"offset"] = offset.stringValue;
    }
    if (radius) {
        parameters[@"radius"] = radius.stringValue;
    }
    if (novelty) {
        parameters[@"novelty"] = novelty;
    }
    if (openNow) {
        parameters[@"openNow"] = @(openNow);
    }
    if (sortByDistance) {
        parameters[@"sortByDistance"] = @(sortByDistance);
    }
    if (section) {
        parameters[@"section"] = section;
    }
    if (venuePhotos) {
        parameters[@"venuePhotos"] = @(venuePhotos);
    }
    if (price) {
        parameters[@"price"] = price;
    }
    return [self sendGetRequestWithPath:@"venues/explore" parameters:parameters callback:callback];
}

#pragma mark Aspects
+ (NSOperation *)venueGetHereNow:(NSString *)venueID
                           limit:(NSString *)limit
                          offset:(NSString *)offset
                  afterTimestamp:(NSString *)afterTimestamp
                        callback:(Foursquare2Callback)callback {
    if(!venueID || !venueID.length){
        NSAssert(NO, @"Foursquare2 venueGetHereNow: venueID is required parameter.");
        return nil;
    }
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    if (limit) {
        parameters[@"limit"] = limit;
    }
    if (offset) {
        parameters[@"offset"] = offset;
    }
    if (afterTimestamp) {
        parameters[@"afterTimestamp"] = afterTimestamp;
    }
    NSString *path = [NSString stringWithFormat:@"venues/%@/herenow",venueID];
    return [self sendGetRequestWithPath:path parameters:parameters callback:callback];
}

+ (NSOperation *)venueGetTips:(NSString *)venueID
                         sort:(FoursquareSortingType)sort
                        limit:(NSNumber *)limit
                       offset:(NSNumber *)offset
                     callback:(Foursquare2Callback)callback {
    if (!venueID || !venueID.length) {
        NSAssert(NO, @"Foursqare2 venueGetTips: venueID is required parameter");
    }
    if (sort == sortNearby) {
        NSAssert(NO, @"Foursqare2 venueGetTips: sort can only be sortFriends, sortRecent, or sortPopular.");
    }
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"sort"] = [self sortTypeToString:sort];
    if (limit) {
        parameters[@"limit"] = limit.stringValue;
    }
    if (offset) {
        parameters[@"offset"] = offset.stringValue;
    }
    NSString *path = [NSString stringWithFormat:@"venues/%@/tips",venueID];
    return [self sendGetRequestWithPath:path parameters:parameters callback:callback];
}

+ (NSOperation *)venueGetMenu:(NSString *)venueID
                     callback:(Foursquare2Callback)callback {
    NSString *path = [NSString stringWithFormat:@"venues/%@/menu",venueID];
    return [self sendGetRequestWithPath:path parameters:nil callback:callback];
}

#pragma mark Actions

+ (NSOperation *)venueFlag:(NSString *)venueID
                   problem:(FoursquareProblemType)problem
          duplicateVenueID:(NSString *)duplicateVenueID
                  callback:(Foursquare2Callback)callback {
    if (!venueID || !venueID.length) {
        NSAssert(NO, @"Foursqure2 venueFlag: venueID is required parameter");
    }
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"problem"] = [self problemTypeToString:problem];
    NSString *path = [NSString stringWithFormat:@"venues/%@/flag",venueID];
    return [self sendPostRequestWithPath:path parameters:parameters callback:callback];
}

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
                         callback:(Foursquare2Callback)callback {
    if (!venueID || !venueID.length) {
        NSAssert(NO, @"Foursqure2 proposeEditVenue: venueID is required parameter");
    }
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    if (name) {
        parameters[@"name"] = name;
    }
    if (address) {
        parameters[@"address"] = address;
    }
    if (crossStreet) {
        parameters[@"crossStreet"] = crossStreet;
    }
    if (city) {
        parameters[@"city"] = city;
    }
    if (state) {
        parameters[@"state"] = state;
    }
    if (zip) {
        parameters[@"zip"] = zip;
    }
    if (phone) {
        parameters[@"phone"] = phone;
    }
    if (lat && lon) {
        parameters[@"ll"] = [NSString stringWithFormat:@"%@,%@",lat,lon];
    }
    if (primaryCategoryId) {
        parameters[@"primaryCategoryId"] = primaryCategoryId;
    }
    NSString *path = [NSString stringWithFormat:@"venues/%@/proposeedit",venueID];
    return [self sendPostRequestWithPath:path parameters:parameters callback:callback];
}

+ (NSOperation *)venueGetPhotos:(NSString *)venueID
                          limit:(NSNumber *)limit
                         offset:(NSNumber *)offset
                       callback:(Foursquare2Callback)callback {
    if (!venueID) {
        callback(NO,nil);
        return nil;
    }
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    if (limit) {
        parameters[@"limit"] = limit.stringValue;
    }
    
    if (offset) {
        parameters[@"offset"] = offset.stringValue;
    }
    
    NSString *path = [NSString stringWithFormat:@"venues/%@/photos", venueID];
    return [self sendGetRequestWithPath:path parameters:parameters callback:callback];
}

#pragma mark -

#pragma mark Checkins

+ (NSOperation *)checkinGetDetail:(NSString *)checkinID
                         callback:(Foursquare2Callback)callback {
    NSString *path = [NSString stringWithFormat:@"checkins/%@",checkinID];
    return [self sendGetRequestWithPath:path parameters:nil callback:callback];
}

+ (NSOperation *)checkinAddAtVenue:(NSString *)venueID
                             shout:(NSString *)shout
                          callback:(Foursquare2Callback)callback {
    
    return [Foursquare2 checkinAddAtVenue:venueID
                                    event:nil
                                    shout:shout
                                broadcast:broadcastPublic
                                 latitude:nil
                                longitude:nil
                               accuracyLL:nil
                                 altitude:nil
                              accuracyAlt:nil
                                 callback:callback];
}

+ (NSOperation *)checkinAddAtVenue:(NSString *)venueID
                             event:(NSString *)eventID
                             shout:(NSString *)shout
                         broadcast:(FoursquareBroadcastType)broadcast
                          latitude:(NSNumber *)latitude
                         longitude:(NSNumber *)longitude
                        accuracyLL:(NSNumber *)accuracyLL
                          altitude:(NSNumber *)altitude
                       accuracyAlt:(NSNumber *)accuracyAlt
                          callback:(Foursquare2Callback)callback {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    if (venueID) {
        parameters[@"venueId"] = venueID;
    } else {
        NSAssert(NO, @"Foursqure2 checkinAddAtVenue: venueID is required.");
    }
    if (eventID) {
        parameters[@"eventId"] = eventID;
    }
    if (shout) {
        parameters[@"shout"] = shout;
    }
    if (latitude && longitude) {
        parameters[@"ll"] = [NSString stringWithFormat:@"%@,%@",latitude,longitude];
    }
    if (accuracyLL) {
        parameters[@"llAcc"] = accuracyLL.stringValue;
    }
    if (altitude) {
        parameters[@"alt"] = altitude.stringValue;
    }
    if (accuracyAlt) {
        parameters[@"altAcc"] = accuracyAlt.stringValue;
    }
    
    parameters[@"broadcast"] = [self broadcastTypeToString:broadcast];
    return [self sendPostRequestWithPath:@"checkins/add" parameters:parameters callback:callback];
}

+ (NSOperation *)checkinGetRecentsByFriends:(NSNumber *)latitude
                                  longitude:(NSNumber *)longitude
                                      limit:(NSNumber *)limit
                             afterTimestamp:(NSString *)afterTimestamp
                                   callback:(Foursquare2Callback)callback {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    if (limit) {
        parameters[@"limit"] = limit.stringValue;
    }
    if (afterTimestamp) {
        parameters[@"afterTimestamp"] = afterTimestamp;
    }
    if (latitude && longitude) {
        parameters[@"ll"] = [NSString stringWithFormat:@"%@,%@",latitude,longitude];
    }
    
    return [self sendGetRequestWithPath:@"checkins/recent" parameters:parameters callback:callback];
}

#pragma mark Aspects

+ (NSOperation *)checkinGetLikes:(NSString *)checkinID
                        callback:(Foursquare2Callback)callback {
    if (!checkinID) {
        NSAssert(NO, @"Foursqure2 checkinGetLikes: checkinID is required.");
    }
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    if (checkinID) {
        parameters[@"checkinId"] = checkinID;
    }
    NSString *path = [NSString stringWithFormat:@"checkins/%@/likes",checkinID];
    return [self sendPostRequestWithPath:path parameters:parameters callback:callback];
}

#pragma -

#pragma mark Actions
+ (NSOperation *)checkinAddComment:(NSString *)checkinID
                              text:(NSString *)text
                          callback:(Foursquare2Callback)callback {
    if (nil == checkinID) {
        callback(NO, nil);
        return nil;
    }
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    if (text) {
        parameters[@"text"] = text;
    }
    NSString *path = [NSString stringWithFormat:@"checkins/%@/addcomment",checkinID];
    return [self sendPostRequestWithPath:path parameters:parameters callback:callback];
}

+ (NSOperation *)checkinDeleteComment:(NSString *)commentID
                           forCheckin:(NSString *)checkinID
                             callback:(Foursquare2Callback)callback {
    if (nil == checkinID) {
        callback(NO, nil);
        return nil;
    }
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    if (commentID) {
        parameters[@"commentId"] = commentID;
    }
    NSString *path = [NSString stringWithFormat:@"checkins/%@/deletecomment",checkinID];
    return [self sendPostRequestWithPath:path parameters:parameters callback:callback];
}

+ (NSOperation *)checkinLike:(NSString *)checkinID
                        like:(BOOL)like
                    callback:(Foursquare2Callback)callback {
    if (!checkinID) {
        NSAssert(NO, @"Foursqure2 checkinLike: checkinID is required.");
    }
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    if (checkinID) {
        parameters[@"checkinId"] = checkinID;
    }
    parameters[@"set"] = like?@"1":@"0";
    NSString *path = [NSString stringWithFormat:@"checkins/%@/like",checkinID];
    return [self sendPostRequestWithPath:path parameters:parameters callback:callback];
}

#pragma mark -

#pragma mark Tips

+ (NSOperation *)tipGetDetail:(NSString *)tipID
                     callback:(Foursquare2Callback)callback {
    NSString *path = [NSString stringWithFormat:@"tips/%@/",tipID];
    return [self sendGetRequestWithPath:path parameters:nil callback:callback];
}

+ (NSOperation *)tipAdd:(NSString *)tip
               forVenue:(NSString *)venueID
                withURL:(NSString *)url
               callback:(Foursquare2Callback)callback {
    if (!venueID || !tip) {
        NSAssert(NO, @"Foursqure2 tipAdd: tip and venueID are required parameters.");
    }
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"venueId"] = venueID;
    parameters[@"text"] = tip;
    if(url) {
        parameters[@"url"] = url;
    }
    return [self sendPostRequestWithPath:@"tips/add" parameters:parameters callback:callback];
}

+ (NSOperation *)tipSearchNearbyLatitude:(NSNumber *)latitude
                               longitude:(NSNumber *)longitude
                                    near:(NSString *)near
                                   limit:(NSNumber *)limit
                                  offset:(NSNumber *)offset
                             friendsOnly:(BOOL)friendsOnly
                                   query:(NSString *)query
                                callback:(Foursquare2Callback)callback {
    if ((!latitude || !longitude)) {
        NSAssert(NO, @"Foursquare2 lat and lon are required parameters");
    }
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"ll"] = [NSString stringWithFormat:@"%@,%@",latitude,longitude];
    if (limit) {
        parameters[@"limit"] = limit.stringValue;
    }
    if (offset) {
        parameters[@"offset"] = offset.stringValue;
    }
    if (near) {
        parameters[@"near"] = near;
    }
    if (friendsOnly) {
        parameters[@"filter"] = @"friends";
    }
    if (query) {
        parameters[@"query"] = query;
    }
    
    return [self sendGetRequestWithPath:@"tips/search" parameters:parameters callback:callback];
}

#pragma mark -

#pragma mark Photos

+ (NSOperation *)photoGetDetail:(NSString *)photoID
                       callback:(Foursquare2Callback)callback {
    NSString *path = [NSString stringWithFormat:@"photos/%@",photoID];
    return [self sendGetRequestWithPath:path parameters:nil callback:callback];
}

+ (NSOperation *)photoAdd:(NSData *)photoData
                toCheckin:(NSString *)checkinID
                 callback:(Foursquare2Callback)callback {
    
    return [Foursquare2 photoAddTo:photoData
                           checkin:checkinID
                               tip:nil
                             venue:nil
                         broadcast:broadcastPublic
                          latitude:nil
                         longitude:nil
                        accuracyLL:nil
                          altitude:nil
                       accuracyAlt:nil
                          callback:callback];
}

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
                   callback:(Foursquare2Callback)callback {
    if (!checkinID && !tipID && !venueID) {
        callback(NO,nil);
        return nil;
    }
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"broadcast"] = [self broadcastTypeToString:broadcast];
    if (latitude && longitude) {
        parameters[@"ll"] = [NSString stringWithFormat:@"%@,%@",latitude,longitude];
    }
    if (accuracyLL) {
        parameters[@"llAcc"] = accuracyLL.stringValue;
    }
    if (altitude) {
        parameters[@"alt"] = altitude.stringValue;
    }
    if (accuracyAlt) {
        parameters[@"altAcc"] = accuracyAlt.stringValue;
    }
    if (checkinID) {
        parameters[@"checkinId"] = checkinID;
    }
    if (tipID) {
        parameters[@"tipId"] = tipID;
    }
    if (venueID) {
        parameters[@"venueId"] = venueID;
    }
    return [[Foursquare2 sharedInstance] uploadPhoto:@"photos/add"
                                      withParameters:parameters
                                       withImageData:photoData
                                            callback:callback];
}

#pragma mark -

#pragma mark Settings

+ (NSOperation *)settingsGetAllCallback:(Foursquare2Callback)callback {
    return [self sendGetRequestWithPath:@"settings/all" parameters:nil callback:callback];
}

+ (NSOperation *)settingsSet:(FoursquareSettingName)settingName
                     toValue:(BOOL)value
                    callback:(Foursquare2Callback)callback {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"value"] = value?@"1":@"0";
    NSString *path = [NSString stringWithFormat:@"settings/%@/set",
                      [self foursquareSettingNameToString:settingName]];
    return [self sendPostRequestWithPath:path parameters:parameters callback:callback];
}

#pragma mark -

#pragma mark Private methods

+ (NSString *)inentTypeToString:(FoursquareIntentType)broadcast {
    switch (broadcast) {
        case intentBrowse:
            return @"browse";
        case intentCheckin:
            return @"checkin";
        case intentGlobal:
            return @"global";
        case intentMatch:
            return @"match";
        default:
            return @"";
    }
    
}

+ (NSString *)foursquareSettingNameToString:(FoursquareSettingName)settingName {
    switch (settingName) {
        case FoursquareSettingNameSendMayorshipsToTwitter:
            return @"sendMayorshipsToTwitter";
        case FoursquareSettingNameSendBadgesToTwitter:
            return @"sendBadgesToTwitter";
        case FoursquareSettingNameSendMayorshipsToFacebook:
            return @"sendMayorshipsToFacebook";
        case FoursquareSettingNameSendBadgesToFacebook:
            return @"sendBadgesToFacebook";
        case FoursquareSettingNameReceivePings:
            return @"receivePings";
        case FoursquareSettingNameReceiveCommentPings:
            return @"receiveCommentPings";
        default:
            return @"";
    }
}

+ (NSString *)broadcastTypeToString:(FoursquareBroadcastType)broadcast {
    NSMutableArray *result = [NSMutableArray array];
    if (broadcast & broadcastPublic) {
        [result addObject:@"public"];
    }
    if (broadcast & broadcastPrivate) {
        [result addObject:@"private"];
    }
    if (broadcast & broadcastFollowers) {
        [result addObject:@"followers"];
    }
    if (broadcast & broadcastFacebook) {
        [result addObject:@"facebook"];
    }
    if (broadcast & broadcastTwitter) {
        [result addObject:@"twitter"];
    }
    return [result componentsJoinedByString:@","];
}

+ (NSString *)problemTypeToString:(FoursquareProblemType)problem {
    switch (problem) {
        case problemClosed:
            return @"closed";
        case problemDuplicate:
            return @"duplicate";
        case problemMislocated:
            return @"mislocated";
        case problemDoesntExist:
            return @"doesnt_exist";
        case problemEventOver:
            return @"event_over";
        case problemInappropriate:
            return @"inappropriate";
        default:
            return @"";
    }
    
}

+ (NSString *)timeStampStringFromDate:(NSDate *)date {
    return [NSString stringWithFormat:@"%@",@(floor([date timeIntervalSince1970]))];
}

+ (NSString *)sortTypeToString:(FoursquareSortingType)type {
    switch (type) {
        case sortNearby:
            return @"nearby";
        case sortPopular:
            return @"popular";
        case sortRecent:
            return @"recent";
        case sortFriends:
            return @"friends";
        default:
            return @"";
    }
}

+ (NSString *)listGroupTypeToString:(FoursquareListGroupType)type {
    switch (type) {
        case FoursquareListGroupNone:
            return @"";
        case FoursquareListGroupCreated:
            return @"created";
        case FoursquareListGroupEdited:
            return @"edited";
        case FoursquareListGroupFollowed:
            return @"followed";
        case FoursquareListGroupFriends:
            return @"friends";
        case FoursquareListGroupSuggested:
            return @"suggested";
        default:
            return @"";
    }
}

+ (NSOperation *)sendGetRequestWithPath:(NSString *)path
                             parameters:(NSDictionary *)parameters
                               callback:(Foursquare2Callback)callback {
    return  [[Foursquare2 sharedInstance] sendRequestWithPath:path
                                                   parameters:parameters
                                                   HTTPMethod:@"GET"
                                                     callback:callback];
}

+ (NSOperation *)sendPostRequestWithPath:(NSString *)path
                              parameters:(NSDictionary *)parameters
                                callback:(Foursquare2Callback)callback {
    return  [[Foursquare2 sharedInstance] sendRequestWithPath:path
                                                   parameters:parameters
                                                   HTTPMethod:@"POST"
                                                     callback:callback];
}

+ (NSURL *)constructURLWithPath:(NSString *)path
                     parameters:(NSDictionary *)parameters {
    NSMutableString *parametersString = [NSMutableString stringWithString: kFOURSQUARE_BASE_URL];
    
    [parametersString appendString:path];
    NSDictionary *classAttributes = [self classAttributes];
    NSString *key = classAttributes[kFOURSQUARE_CLIET_ID];
    NSString *secret = classAttributes[kFOURSQUARE_OAUTH_SECRET];
    [parametersString appendFormat:@"?client_id=%@",key];
    [parametersString appendFormat:@"&client_secret=%@",secret];
    [parametersString appendFormat:@"&v=%@",FS2_API_VERSION];
    NSLocale *locale = [NSLocale currentLocale];
    NSString *countryCode = [locale objectForKey: NSLocaleLanguageCode];
    [parametersString appendFormat:@"&locale=%@",countryCode];
    
    NSString *accessToken  = [self classAttributes][kFOURSQUARE_ACCESS_TOKEN];
    if ([accessToken length] > 0)
        [parametersString appendFormat:@"&oauth_token=%@",accessToken];
    
    if(parameters) {
        NSEnumerator *enumerator = [parameters keyEnumerator];
        NSString *enumerationKey;
        id value;
        
        while ((enumerationKey = (NSString *)[enumerator nextObject])) {
            value = parameters[enumerationKey];
            //DLog(@"value: " @"%@", value);
            
            NSString *urlEncodedValue;
            if ([value isKindOfClass:[NSNumber class]]) {
                urlEncodedValue = [value stringValue];
            } else  {
                urlEncodedValue = [value stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            }
            
            if(!urlEncodedValue) {
                urlEncodedValue = @"";
            }
            [parametersString appendFormat:@"&%@=%@",enumerationKey,urlEncodedValue];
        }
    }
    
    return [NSURL URLWithString:parametersString];
}

#pragma -

+ (Foursquare2 *)sharedInstance {
    static Foursquare2 *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[Foursquare2 alloc] init];
    });
    return instance;
    
}

- (id)init {
    self = [super init];
    if (self) {
        _operationQueue = [[NSOperationQueue alloc] init];
        _operationQueue.maxConcurrentOperationCount = 7;
        _callbackQueue = dispatch_get_main_queue();
        _timeoutInterval = 60.0;
    }
    return self;
}

- (NSOperation *)sendRequestWithPath:(NSString *)path
                          parameters:(NSDictionary *)parameters
                          HTTPMethod:(NSString *)HTTPMethod
                            callback:(Foursquare2Callback)callback {
    NSURL *URL = [Foursquare2 constructURLWithPath:path parameters:parameters];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    request.timeoutInterval = self.timeoutInterval;
    request.HTTPMethod = HTTPMethod;
    Foursquare2Callback block = ^(BOOL success, id result) {
        if ([result isKindOfClass:[NSError class]]) {
            NSError *error = (NSError *)result;
            BOOL notAuthorizedError = ([error.domain isEqualToString:kFoursquare2ErrorDomain]
                                       && error.code == Foursquare2ErrorUnauthorized);
            if (notAuthorizedError && [self.class isAuthorized]) {
                [Foursquare2.class removeAccessToken];
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
                    [center postNotificationName:kFoursquare2DidRemoveAccessTokenNotification object:self];
                });
            }
        }
        if (callback) {
            callback(success, result);
        }
    };
    FSOperation *operation = [[FSOperation alloc] initWithRequest:request
                                                         callback:block
                                                    callbackQueue:self.callbackQueue];
    [self.operationQueue addOperation:operation];
    return operation;
}

- (NSOperation *)uploadPhoto:(NSString *)methodName
              withParameters:(NSDictionary *)parameters
               withImageData:(NSData *)imageData
                    callback:(Foursquare2Callback)callback {
    NSURL *URL = [Foursquare2 constructURLWithPath:methodName parameters:parameters];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:URL];
    request.timeoutInterval = self.timeoutInterval;
    request.HTTPMethod = @"POST";
    
    NSString *boundary = @"0xKhTmLbOuNdArY";
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary, nil];
    [request addValue:contentType forHTTPHeaderField:@"Content-Type"];
    
    
    NSMutableData *body = [NSMutableData data];
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    NSData *stringData = [@"Content-Disposition: form-data;\
                          name=\"userfile\";\
                          filename=\"photo.jpg\"\r\n"
                          dataUsingEncoding:NSUTF8StringEncoding];
    [body appendData:stringData];
    [body appendData:[@"Content-Type: image/jpeg\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:imageData];
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [request setHTTPBody:body];
    
    FSOperation *operation = [[FSOperation alloc] initWithRequest:request
                                                         callback:callback
                                                    callbackQueue:_callbackQueue];
    [self.operationQueue addOperation:operation];
    return operation;
}

#ifndef __MAC_OS_X_VERSION_MAX_ALLOWED

- (BOOL)nativeAuthorization {
    NSDictionary *classAttributes = [Foursquare2 classAttributes];
    NSString *key = classAttributes[kFOURSQUARE_CLIET_ID];
    NSString *callbackURL = classAttributes[kFOURSQUARE_CALLBACK_URL];
    FSOAuthStatusCode statusCode = [FSOAuthNoAppStore authorizeUserUsingClientId:key callbackURIString:callbackURL];
    if (statusCode == FSOAuthStatusSuccess) {
        return YES;
    }
    return NO;
}

- (void)webAuthorization {
    NSDictionary *classAttributes = [Foursquare2 classAttributes];
    NSString *key = classAttributes[kFOURSQUARE_CLIET_ID];
    NSString *callbackURL = classAttributes[kFOURSQUARE_CALLBACK_URL];
    NSString *url = [NSString stringWithFormat:
                     @"https://foursquare.com/oauth2/authenticate?client_id=%@&response_type=token&redirect_uri=%@",
                     key,callbackURL];
    FSWebLogin *loginViewControler = [[FSWebLogin alloc] initWithUrl:url andDelegate:self];
    UINavigationController *navigationController = [[UINavigationController alloc]
                                                    initWithRootViewController:loginViewControler];
    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
    UIViewController *controller = [self topViewController:keyWindow.rootViewController];
    [controller presentViewController:navigationController animated:YES completion:nil];
}

+ (void)authorizeWithCallback:(Foursquare2Callback)callback {
    NSAssert([Foursquare2 sharedInstance].authorizationCallback == nil, @"Resetting callback that has not been called");
    [Foursquare2 sharedInstance].authorizationCallback = [callback copy];
    if ([[Foursquare2 sharedInstance] nativeAuthorization]) {
        return;
    }
    [[Foursquare2 sharedInstance] webAuthorization];
}

- (void)webLogin:(FSWebLogin *)loginViewController didFinishWithError:(NSError *)error {
    [loginViewController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    if (error) {
        [Foursquare2 callAuthorizationCallbackWithError:error];
    }
}

+ (void)callAuthorizationCallbackWithError:(NSError *)error {
    Foursquare2Callback callback = [Foursquare2 sharedInstance].authorizationCallback;
    NSAssert(callback != nil, @"Authorization callback should not be possible without setting a callback");
    if (!callback) {
        return;
    }
    dispatch_async([Foursquare2 sharedInstance].callbackQueue, ^{
        BOOL result = [Foursquare2 isAuthorized];
        callback(result, error);
    });
    [Foursquare2 sharedInstance].authorizationCallback = nil;
}

+ (BOOL)handleURL:(NSURL *)url {
    NSDictionary *classAttributes = [self classAttributes];
    NSString *callbackURL = classAttributes[kFOURSQUARE_CALLBACK_URL];
    
    if (![callbackURL hasPrefix:[url scheme]]) {
        return NO;
    }
    
    BOOL isWebLoginURL = [url.absoluteString rangeOfString:@"#access_token"].length;
    if (isWebLoginURL) {
        NSArray *array = [url.absoluteString componentsSeparatedByString:@"="];
        NSString *accessToken = array.lastObject;
        [Foursquare2 setAccessToken:accessToken];
        [self callAuthorizationCallbackWithError:nil];
        return YES;
    }
    
    //then it's native oauth.
    FSOAuthErrorCode errorCode;
    NSString *code = [FSOAuthNoAppStore accessCodeForFSOAuthURL:url error:&errorCode];
    if (errorCode == FSOAuthErrorNone) {
        NSString *key = classAttributes[kFOURSQUARE_CLIET_ID];
        NSString *secret = classAttributes[kFOURSQUARE_OAUTH_SECRET];
        [FSOAuthNoAppStore requestAccessTokenForCode:code
                                            clientId:key
                                   callbackURIString:callbackURL
                                        clientSecret:secret
                                     completionBlock:^(NSString *authToken,
                                                       BOOL requestCompleted,
                                                       FSOAuthErrorCode blockErrorCode) {
                                         if (blockErrorCode == FSOAuthErrorNone) {
                                             [Foursquare2 setAccessToken:authToken];
                                             [self callAuthorizationCallbackWithError:nil];
                                         } else {
                                             NSError *error = [self errorForCode:blockErrorCode];
                                             [self callAuthorizationCallbackWithError:error];
                                         }
                                     }];
        
    } else {
        NSError *error = [self errorForCode:errorCode];
        [self callAuthorizationCallbackWithError:error];
    }
    return YES;
}

+ (NSError *)errorForCode:(FSOAuthErrorCode)errorCode {
    NSString *message = [self errorMessageForCode:errorCode];
    NSError *error = [NSError errorWithDomain:kFoursquare2NativeAuthErrorDomain
                                         code:errorCode
                                     userInfo:@{NSLocalizedFailureReasonErrorKey:message}];
    return error;
}

+ (NSString *)errorMessageForCode:(FSOAuthErrorCode)errorCode {
    NSString *resultText = nil;
    
    switch (errorCode) {
        case FSOAuthErrorNone: {
            break;
        }
        case FSOAuthErrorInvalidClient: {
            resultText = @"Invalid client error";
            break;
        }
        case FSOAuthErrorInvalidGrant: {
            resultText = @"Invalid grant error";
            break;
        }
        case FSOAuthErrorInvalidRequest: {
            resultText = @"Invalid request error";
            break;
        }
        case FSOAuthErrorUnauthorizedClient: {
            resultText = @"Invalid unauthorized client error";
            break;
        }
        case FSOAuthErrorUnsupportedGrantType: {
            resultText = @"Invalid unsupported grant error";
            break;
        }
        case FSOAuthErrorUnknown:
        default: {
            resultText = @"Unknown error";
            break;
        }
    }
    
    return resultText;
}

- (UIViewController *)topViewController:(UIViewController *)rootViewController {
    if (rootViewController.presentedViewController == nil) {
        return rootViewController;
    }
    
    if ([rootViewController.presentedViewController isMemberOfClass:[UINavigationController class]]) {
        UINavigationController *navigationController =
        (UINavigationController *)rootViewController.presentedViewController;
        UIViewController *lastViewController = [[navigationController viewControllers] lastObject];
        return [self topViewController:lastViewController];
    }
    
    UIViewController *presentedViewController = (UIViewController *)rootViewController.presentedViewController;
    return [self topViewController:presentedViewController];
}

#endif

@end
