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
#define FS2_API_VERSION (@"20131109")
#endif


static NSString * kFOURSQUARE_BASE_URL = @"https://api.foursquare.com/v2/";


static NSString const * kFOURSQUARE_CLIET_ID = @"FOURSQUARE_CLIET_ID";
static NSString const * kFOURSQUARE_OAUTH_SECRET = @"FOURSQUARE_OAUTH_SECRET";
static NSString const * kFOURSQUARE_CALLBACK_URL = @"FOURSQUARE_CALLBACK_URL";

static NSString const * kFOURSQUARE_ACCESS_TOKEN = @"FOURSQUARE_ACCESS_TOKEN";

@interface Foursquare2 () <FSWebLoginDelegate>

@property (nonatomic, copy) Foursquare2Callback authorizationCallback;

@property (nonatomic, strong) NSOperationQueue *operationQueue;

+ (NSOperation *)get:(NSString *)methodName
          withParams:(NSDictionary *)params
            callback:(Foursquare2Callback)callback;

+ (NSOperation *)post:(NSString *)methodName
           withParams:(NSDictionary *)params
             callback:(Foursquare2Callback)callback;

+ (NSOperation *)request:(NSString *)methodName
              withParams:(NSDictionary *)params
              httpMethod:(NSString *)httpMethod
                callback:(Foursquare2Callback)callback;

+ (NSOperation *)uploadPhoto:(NSString *)methodName
                  withParams:(NSDictionary *)params
#ifdef __MAC_OS_X_VERSION_MAX_ALLOWED
                   withImage:(NSImage *)image
#else
                   withImage:(UIImage *)image
#endif
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
	return [self get:path withParams:nil callback:callback];
}

+ (NSOperation *)userSearchWithPhone:(NSArray *)phones
                               email:(NSArray *)emails
                             twitter:(NSArray *)twitters
                       twitterSource:(NSString *)twitterSource
                         facebookIDs:(NSArray *)fbid
                                name:(NSString *)name
                            callback:(Foursquare2Callback)callback {
	NSMutableDictionary *dic = [NSMutableDictionary dictionary];
	dic[@"phone"] = [self stringFromArray:phones];
	dic[@"email"] = [self stringFromArray:emails];
	dic[@"twitter"] = [self stringFromArray:twitters];
	if (twitterSource) {
		dic[@"twitterSource"] = twitterSource;
	}
	dic[@"fbid"] = [self stringFromArray:fbid];
	if (name) {
		dic[@"name"] = name;
	}
	return [self get:@"users/search" withParams:dic callback:callback];
}

+ (NSOperation *)userGetFriendRequestsCallback:(Foursquare2Callback)callback {
    return [self get:@"users/requests" withParams:nil callback:callback];
}

+ (NSOperation *)userGetLeaderboardCallback:(Foursquare2Callback)callback {
    return [self get:@"users/leaderboard" withParams:nil callback:callback];
}

#pragma mark Aspects


+ (NSOperation *)userGetBadges:(NSString *)userID
                      callback:(Foursquare2Callback)callback {
	NSString *path = [NSString stringWithFormat:@"users/%@/badges",userID];
	return [self get:path withParams:nil callback:callback];
}

+ (NSOperation *)userGetCheckins:(NSString *)userID
                           limit:(NSNumber *)limit
                          offset:(NSNumber *)offset
                            sort:(FoursquareCheckinsSort)sort
                           after:(NSDate *)after
                          before:(NSDate *)before
                        callback:(Foursquare2Callback)callback {
	NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    if (sort == FoursquareCheckinsNewestFirst) {
        dic[@"sort"] = @"newestfirst";
    } else if (sort == FoursquareCheckinsOldestFirst) {
        dic[@"sort"] = @"oldestfirst";
    }
	if (offset) {
		dic[@"offset"] = [offset stringValue];
	}
    if (limit) {
		dic[@"limit"] = [limit stringValue];
	}
	if (after) {
		dic[@"afterTimestamp"] = [self timeStampStringFromDate:after];
	}
	if (before) {
		dic[@"beforeTimestamp"] = [self timeStampStringFromDate:before];
	}
	NSString *path = [NSString stringWithFormat:@"users/%@/checkins",userID];
	return [self get:path withParams:dic callback:callback];
}

+ (NSOperation *)userGetFriends:(NSString *)userID
                          limit:(NSNumber *)limit
                         offset:(NSNumber *)offset
                       callback:(Foursquare2Callback)callback {
	NSString *path = [NSString stringWithFormat:@"users/%@/friends",userID];
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    if (limit) {
        dic[@"limit"] = [limit stringValue];
    }
    if (offset) {
        dic[@"offset"] = [offset stringValue];
    }
	return [self get:path withParams:dic callback:callback];
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
    
	NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[@"sort"] = [self sortTypeToString:sort];
    if (limit) {
        dic[@"limit"] = [limit stringValue];
    }
    if (offset) {
        dic[@"offset"] = [offset stringValue];
    }
    
	if (latitude && longitude) {
		dic[@"ll"] = [NSString stringWithFormat:@"%@,%@",latitude,longitude];
	}
	NSString *path = [NSString stringWithFormat:@"users/%@/tips",userID];
	return [self get:path withParams:dic callback:callback];
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
    
	
	NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[@"sort"] = [self sortTypeToString:sort];
	if (latitude && longitude) {
		dic[@"ll"] = [NSString stringWithFormat:@"%@,%@",latitude,longitude];
	}
	NSString *path = [NSString stringWithFormat:@"users/%@/todos",userID];
	return [self get:path withParams:dic callback:callback];
}


+ (NSOperation *)userGetVenueHistory:(NSString *)userID
                               after:(NSDate *)after
                              before:(NSDate *)before
                          categoryID:(NSString *)categoryID
                            callback:(Foursquare2Callback)callback {
	NSString *path = [NSString stringWithFormat:@"users/%@/venuehistory",userID];
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    if (after) {
		dic[@"afterTimestamp"] = [self timeStampStringFromDate:after];
	}
	if (before) {
		dic[@"beforeTimestamp"] = [self timeStampStringFromDate:before];
	}
    if (categoryID) {
        dic[@"categoryId"] = categoryID;
    }
	return [self get:path withParams:dic callback:callback];
}

+ (NSOperation *)userGetLists:(NSString *)userID
                        group:(FoursquareListGroupType)groupType
                     latitude:(NSNumber *)latitude
                    longitude:(NSNumber *)longitude
                     callback:(Foursquare2Callback)callback {
    NSString *path = [NSString stringWithFormat:@"users/%@/lists",userID];
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    if (groupType) {
        dic[@"group"] = [self listGroupTypeToString:groupType];
    }
    if (latitude && longitude) {
		dic[@"ll"] = [NSString stringWithFormat:@"%@,%@",latitude,longitude];
	}
	return [self get:path withParams:dic callback:callback];
}

+ (NSOperation *)userGetMayorships:(NSString *)userID
                          callback:(Foursquare2Callback)callback {
    NSString *path = [NSString stringWithFormat:@"users/%@/mayorships",userID];
    return [self get:path withParams:nil callback:callback];
}

+ (NSOperation *)userGetPhotos:(NSString *)userID
                         limit:(NSNumber *)limit
                        offset:(NSNumber *)offset
                      callback:(Foursquare2Callback)callback {
    NSString *path = [NSString stringWithFormat:@"users/%@/photos",userID];
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    if (limit) {
        dic[@"limit"] = [limit stringValue];
    }
    if (offset) {
        dic[@"offset"] = [offset stringValue];
    }
    return [self get:path withParams:nil callback:callback];
}
#pragma mark Actions

+ (NSOperation *)userSendFriendRequest:(NSString *)userID
                              callback:(Foursquare2Callback)callback {
    if (!userID || !userID.length) {
        NSAssert(NO, @"Foursqure2 sendFriendRequestToUser: userID can't be nil or empty.");
    }
	NSString *path = [NSString stringWithFormat:@"users/%@/request",userID];
	return [self post:path withParams:nil callback:callback];
}

+ (NSOperation *)userUnfriend:(NSString *)userID
                     callback:(Foursquare2Callback)callback {
	NSString *path = [NSString stringWithFormat:@"users/%@/unfriend",userID];
	return [self post:path withParams:nil callback:callback];
}

+ (NSOperation *)userApproveFriend:(NSString *)userID
                          callback:(Foursquare2Callback)callback {
	NSString *path = [NSString stringWithFormat:@"users/%@/approve",userID];
	return [self post:path withParams:nil callback:callback];
}

+ (NSOperation *)userDenyFriend:(NSString *)userID
                       callback:(Foursquare2Callback)callback {
	NSString *path = [NSString stringWithFormat:@"users/%@/deny",userID];
	return [self post:path withParams:nil callback:callback];
}

+ (NSOperation *)userSetPings:(BOOL)value
                    forFriend:(NSString *)userID
                     callback:(Foursquare2Callback)callback {
    if (!userID || !userID.length) {
        NSAssert(NO, @"Foursqure2 setPings: userID can't be nil or empty.");
    }
	NSString *path = [NSString stringWithFormat:@"users/%@/setpings",userID];
	NSDictionary *params = @{@"value":(value?@"true":@"false")};
	return [self post:path withParams:params callback:callback];
}



#ifdef __MAC_OS_X_VERSION_MAX_ALLOWED
+ (void)userUpdatePhoto:(NSImage *)image
               callback:(Foursquare2Callback)callback
#else
+ (NSOperation *)userUpdatePhoto:(UIImage *)image
                        callback:(Foursquare2Callback)callback
#endif
{
    
    return [self uploadPhoto:@"users/self/update"
                  withParams:nil
                   withImage:image
                    callback:callback];
}
#pragma mark -


#pragma mark Venues

+ (NSOperation *)venueGetDetail:(NSString *)venueID
                       callback:(Foursquare2Callback)callback {
	NSString *path = [NSString stringWithFormat:@"venues/%@",venueID];
	return [self get:path withParams:nil callback:callback];
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
    
	NSMutableDictionary *dic = [NSMutableDictionary dictionary];
	if (name) {
		dic[@"name"] = name;
	}
	if (address) {
		dic[@"address"] = address;
	}
	if (crossStreet) {
		dic[@"crossStreet"] = crossStreet;
	}
	if (city) {
		dic[@"city"] = city;
	}
	if (state) {
		dic[@"state"] = state;
	}
	if (zip) {
		dic[@"zip"] = zip;
	}
	if (phone) {
		dic[@"phone"] = phone;
	}
    if (twitter) {
        dic[@"twitter"] = twitter;
    }
    if (description) {
        dic[@"description"] = description;
    }
	if (latitude && longitude) {
		dic[@"ll"] = [NSString stringWithFormat:@"%@,%@", latitude, longitude];
	}
	if (primaryCategoryId) {
		dic[@"primaryCategoryId"] = primaryCategoryId;
	}
	return [self post:@"venues/add" withParams:dic callback:callback];
}

+ (NSOperation *)venueGetCategoriesCallback:(Foursquare2Callback)callback {
	return [self get:@"venues/categories" withParams:nil callback:callback];
}

+ (NSOperation *)venueSearchNearByLatitude:(NSNumber *)latitude
                                 longitude:(NSNumber *)longitude
                                     query:(NSString *)query
                                     limit:(NSNumber *)limit
                                    intent:(FoursquareIntentType)intent
                                    radius:(NSNumber *)radius
                                categoryId:(NSString *)categoryId
                                  callback:(Foursquare2Callback)callback {
	NSMutableDictionary *dic = [NSMutableDictionary dictionary];
	if (latitude && longitude) {
		dic[@"ll"] = [NSString stringWithFormat:@"%@,%@",latitude,longitude];
	}
	if (query) {
		dic[@"query"] = query;
	}
	if (limit) {
		dic[@"limit"] = limit.stringValue;
	}
	if (intent) {
		dic[@"intent"] = [self inentTypeToString:intent];
	}
    if (radius) {
		dic[@"radius"] = radius.stringValue;
	}
    if (categoryId) {
        dic[@"categoryId"] = categoryId;
    }
	return [self get:@"venues/search" withParams:dic callback:callback];
}

+ (NSOperation *)venueSearchNearLocation:(NSString *)location
                                   query:(NSString *)query
                                   limit:(NSNumber *)limit
                                  intent:(FoursquareIntentType)intent
                                  radius:(NSNumber *)radius
                              categoryId:(NSString *)categoryId
                                callback:(Foursquare2Callback)callback {
	NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    if (location) {
        dic[@"near"] = location;
    }
    if (query) {
        dic[@"query"] = query;
    }
    if (limit) {
        dic[@"limit"] = limit.stringValue;
    }
    if (intent) {
        dic[@"intent"] = [self inentTypeToString:intent];
    }
    if (radius) {
        dic[@"radius"] = radius.stringValue;
    }
    if (categoryId) {
        dic[@"categoryId"] = categoryId;
    }
    return [self get:@"venues/search" withParams:dic callback:callback];
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
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
	if (latitude && longitude) {
		dic[@"ll"] = [NSString stringWithFormat:@"%@,%@",latitude,longitude];
	}
    if (near) {
        dic[@"near"] = near;
    }
	if (query) {
		dic[@"query"] = query;
	}
	if (limit) {
		dic[@"limit"] = limit.stringValue;
	}
    if (radius) {
		dic[@"radius"] = radius.stringValue;
	}
    if (s && w && n && e) {
		dic[@"sw"] = [NSString stringWithFormat:@"%@,%@",s, w];
        dic[@"ne"] = [NSString stringWithFormat:@"%@,%@",n, e];
	}
	return [self get:@"venues/suggestcompletion" withParams:dic callback:callback];
    
}

+ (NSOperation *)venueSearchInBoundingQuadrangleS:(NSNumber *)s
                                                w:(NSNumber *)w
                                                n:(NSNumber *)n
                                                e:(NSNumber *)e
                                            query:(NSString *)query
                                            limit:(NSNumber *)limit
                                         callback:(Foursquare2Callback)callback {
	NSMutableDictionary *dic = [NSMutableDictionary dictionary];
	if (s && w && n && e) {
		dic[@"sw"] = [NSString stringWithFormat:@"%@,%@",s, w];
        dic[@"ne"] = [NSString stringWithFormat:@"%@,%@",n, e];
	}
	if (query) {
		dic[@"query"] = query;
	}
	if (limit) {
		dic[@"limit"] = limit.stringValue;
	}
    dic[@"intent"] = [self inentTypeToString:intentBrowse];
    
	return [self get:@"venues/search" withParams:dic callback:callback];
}

+ (NSOperation *)venueTrendingNearByLatitude:(NSNumber *)latitude
                                   longitude:(NSNumber *)longitude
                                       limit:(NSNumber *)limit
                                      radius:(NSNumber *)radius
                                    callback:(Foursquare2Callback)callback {
    if (!latitude || !longitude) {
        NSAssert(NO, @"Foursqure2 venueTrendingNearByLatitude: latitude and longitude are required parameters.");
    }
	NSMutableDictionary *dic = [NSMutableDictionary dictionary];
	if (latitude && longitude) {
		dic[@"ll"] = [NSString stringWithFormat:@"%@,%@",latitude,longitude];
	}
	if (limit) {
		dic[@"limit"] = limit.stringValue;
	}
    if (radius) {
		dic[@"radius"] = radius.stringValue;
	}
	return [self get:@"venues/trending" withParams:dic callback:callback];
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
	NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    if (!near && !near.length && (!latitude && !longitude)) {
        NSAssert(NO, @"Foursqure2 venueExploreRecommendedNearByLatitude: near or ll are required parameters.");
    }
	if (latitude && longitude) {
		dic[@"ll"] = [NSString stringWithFormat:@"%@,%@",latitude,longitude];
	}
    if (near) {
        dic[@"near"] = near;
    }
	if (accuracyLL) {
		dic[@"llAcc"] = accuracyLL.stringValue;
	}
	if (altitude) {
		dic[@"alt"] = altitude.stringValue;
	}
	if (accuracyAlt) {
		dic[@"altAcc"] = accuracyAlt.stringValue;
	}
	if (query) {
		dic[@"query"] = query;
	}
	if (limit) {
		dic[@"limit"] = limit.stringValue;
	}
    if (offset) {
        dic[@"offset"] = offset.stringValue;
    }
    if (radius) {
		dic[@"radius"] = radius.stringValue;
	}
    if (novelty) {
        dic[@"novelty"] = novelty;
    }
    if (openNow) {
        dic[@"openNow"] = @(openNow);
    }
    if (sortByDistance) {
        dic[@"sortByDistance"] = @(sortByDistance);
    }
    if (section) {
        dic[@"section"] = section;
    }
    if (venuePhotos) {
		dic[@"venuePhotos"] = @(venuePhotos);
	}
    if (price) {
        dic[@"price"] = price;
    }
	return [self get:@"venues/explore" withParams:dic callback:callback];
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
	
	NSMutableDictionary *dic = [NSMutableDictionary dictionary];
	if (limit) {
		dic[@"limit"] = limit;
	}
	if (offset) {
		dic[@"offset"] = offset;
	}
	if (afterTimestamp) {
		dic[@"afterTimestamp"] = afterTimestamp;
	}
	NSString *path = [NSString stringWithFormat:@"venues/%@/herenow",venueID];
	return [self get:path withParams:dic callback:callback];
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
	NSMutableDictionary *dic = [NSMutableDictionary dictionary];
	dic[@"sort"] = [self sortTypeToString:sort];
    if (limit) {
        dic[@"limit"] = limit.stringValue;
    }
    if (offset) {
        dic[@"offset"] = offset.stringValue;
    }
	NSString *path = [NSString stringWithFormat:@"venues/%@/tips",venueID];
	return [self get:path withParams:dic callback:callback];
}

#pragma mark Actions

+ (NSOperation *)venueFlag:(NSString *)venueID
                   problem:(FoursquareProblemType)problem
          duplicateVenueID:(NSString *)duplicateVenueID
                  callback:(Foursquare2Callback)callback {
	if (!venueID || !venueID.length) {
        NSAssert(NO, @"Foursqure2 venueFlag: venueID is required parameter");
	}
	NSMutableDictionary *dic = [NSMutableDictionary dictionary];
	dic[@"problem"] = [self problemTypeToString:problem];
	NSString *path = [NSString stringWithFormat:@"venues/%@/flag",venueID];
	return [self post:path withParams:dic callback:callback];
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
	NSMutableDictionary *dic = [NSMutableDictionary dictionary];
	if (name) {
		dic[@"name"] = name;
	}
	if (address) {
		dic[@"address"] = address;
	}
	if (crossStreet) {
		dic[@"crossStreet"] = crossStreet;
	}
	if (city) {
		dic[@"city"] = city;
	}
	if (state) {
		dic[@"state"] = state;
	}
	if (zip) {
		dic[@"zip"] = zip;
	}
	if (phone) {
		dic[@"phone"] = phone;
	}
	if (lat && lon) {
		dic[@"ll"] = [NSString stringWithFormat:@"%@,%@",lat,lon];
	}
	if (primaryCategoryId) {
		dic[@"primaryCategoryId"] = primaryCategoryId;
	}
	NSString *path = [NSString stringWithFormat:@"venues/%@/proposeedit",venueID];
	return [self post:path withParams:dic callback:callback];
}

+ (NSOperation *)venueGetPhotos:(NSString *)venueID
                          limit:(NSNumber *)limit
                         offset:(NSNumber *)offset
                       callback:(Foursquare2Callback)callback {
    if (!venueID) {
        callback(NO,nil);
        return nil;
    }
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    if (limit) {
        dic[@"limit"] = limit.stringValue;
    }
    
    if (offset) {
        dic[@"offset"] = offset.stringValue;
    }
    
    NSString *path = [NSString stringWithFormat:@"venues/%@/photos", venueID];
    return [self get:path withParams:dic callback:callback];
}

#pragma mark -

#pragma mark Checkins

+ (NSOperation *)checkinGetDetail:(NSString *)checkinID
                         callback:(Foursquare2Callback)callback {
	NSString *path = [NSString stringWithFormat:@"checkins/%@",checkinID];
	return [self get:path withParams:nil callback:callback];
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
	NSMutableDictionary *dic = [NSMutableDictionary dictionary];
	if (venueID) {
		dic[@"venueId"] = venueID;
	} else {
        NSAssert(NO, @"Foursqure2 checkinAddAtVenue: venueID is required.");
    }
	if (eventID) {
		dic[@"eventId"] = eventID;
	}
	if (shout) {
		dic[@"shout"] = shout;
	}
	if (latitude && longitude) {
		dic[@"ll"] = [NSString stringWithFormat:@"%@,%@",latitude,longitude];
	}
	if (accuracyLL) {
		dic[@"llAcc"] = accuracyLL.stringValue;
	}
	if (altitude) {
		dic[@"alt"] = altitude.stringValue;
	}
	if (accuracyAlt) {
		dic[@"altAcc"] = accuracyAlt.stringValue;
	}
	
	dic[@"broadcast"] = [self broadcastTypeToString:broadcast];
	return [self post:@"checkins/add" withParams:dic callback:callback];
}

+ (NSOperation *)checkinGetRecentsByFriends:(NSNumber *)latitude
                                  longitude:(NSNumber *)longitude
                                      limit:(NSNumber *)limit
                             afterTimestamp:(NSString *)afterTimestamp
                                   callback:(Foursquare2Callback)callback {
	NSMutableDictionary *dic = [NSMutableDictionary dictionary];
	if (limit) {
		dic[@"limit"] = limit.stringValue;
	}
	if (afterTimestamp) {
		dic[@"afterTimestamp"] = afterTimestamp;
	}
	if (latitude && longitude) {
		dic[@"ll"] = [NSString stringWithFormat:@"%@,%@",latitude,longitude];
	}
	
	return [self get:@"checkins/recent" withParams:dic callback:callback];
}

#pragma mark Aspects

+ (NSOperation *)checkinGetLikes:(NSString *)checkinID
                        callback:(Foursquare2Callback)callback {
    if (!checkinID) {
        NSAssert(NO, @"Foursqure2 checkinGetLikes: checkinID is required.");
    }
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
	if (checkinID) {
		dic[@"checkinId"] = checkinID;
	}
	NSString *path = [NSString stringWithFormat:@"checkins/%@/likes",checkinID];
	return [self post:path withParams:dic callback:callback];
}

#pragma -

#pragma mark Actions
+ (NSOperation *)checkinAddComment:(NSString *)checkinID
                              text:(NSString *)text
                          callback:(Foursquare2Callback)callback {
	if (nil ==checkinID) {
		callback(NO,nil);
		return nil;
	}
	NSMutableDictionary *dic = [NSMutableDictionary dictionary];
	if (text) {
		dic[@"text"] = text;
	}
	NSString *path = [NSString stringWithFormat:@"checkins/%@/addcomment",checkinID];
	return [self post:path withParams:dic callback:callback];
}

+ (NSOperation *)checkinDeleteComment:(NSString *)commentID
                           forCheckin:(NSString *)checkinID
                             callback:(Foursquare2Callback)callback {
	if (nil == checkinID) {
		callback(NO,nil);
		return nil;
	}
	NSMutableDictionary *dic = [NSMutableDictionary dictionary];
	if (commentID) {
		dic[@"commentId"] = commentID;
	}
	NSString *path = [NSString stringWithFormat:@"checkins/%@/deletecomment",checkinID];
	return [self post:path withParams:dic callback:callback];
}

+ (NSOperation *)checkinLike:(NSString *)checkinID
                        like:(BOOL)like
                    callback:(Foursquare2Callback)callback {
    if (!checkinID) {
        NSAssert(NO, @"Foursqure2 checkinLike: checkinID is required.");
    }
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
	if (checkinID) {
		dic[@"checkinId"] = checkinID;
	}
    dic[@"set"] = like?@"1":@"0";
	NSString *path = [NSString stringWithFormat:@"checkins/%@/like",checkinID];
	return [self post:path withParams:dic callback:callback];
}

#pragma mark -

#pragma mark Tips


+ (NSOperation *)tipGetDetail:(NSString *)tipID
                     callback:(Foursquare2Callback)callback {
	NSString *path = [NSString stringWithFormat:@"tips/%@/",tipID];
	return [self get:path withParams:nil callback:callback];
}


+ (NSOperation *)tipAdd:(NSString *)tip
               forVenue:(NSString *)venueID
                withURL:(NSString *)url
               callback:(Foursquare2Callback)callback {
	if (!venueID || !tip) {
		NSAssert(NO, @"Foursqure2 tipAdd: tip and venueID are required parameters.");
	}
	NSMutableDictionary *dic = [NSMutableDictionary dictionary];
	dic[@"venueId"] = venueID;
	dic[@"text"] = tip;
	if(url) {
		dic[@"url"] = url;
    }
	return [self post:@"tips/add" withParams:dic callback:callback];
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
	NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[@"ll"] = [NSString stringWithFormat:@"%@,%@",latitude,longitude];
	if (limit) {
		dic[@"limit"] = limit.stringValue;
	}
	if (offset) {
		dic[@"offset"] = offset.stringValue;
	}
    if (near) {
        dic[@"near"] = near;
    }
	if (friendsOnly) {
		dic[@"filter"] = @"friends";
	}
	if (query) {
		dic[@"query"] = query;
	}
	
	return [self get:@"tips/search" withParams:dic callback:callback];
}

#pragma mark -


#pragma mark Photos

+ (NSOperation *)photoGetDetail:(NSString *)photoID
                       callback:(Foursquare2Callback)callback {
	NSString *path = [NSString stringWithFormat:@"photos/%@",photoID];
	return [self get:path withParams:nil callback:callback];
}

#ifdef __MAC_OS_X_VERSION_MAX_ALLOWED
+ (NSOperation *)photoAdd:(NSImage *)photo
#else
+ (NSOperation *)photoAdd:(UIImage *)photo
#endif
                toCheckin:(NSString *)checkinID
                 callback:(Foursquare2Callback)callback {
    
    return [Foursquare2 photoAddTo:photo
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

#ifdef __MAC_OS_X_VERSION_MAX_ALLOWED
+ (NSOperation *)photoAddTo:(NSImage *)photo
#else
+ (NSOperation *)photoAddTo:(UIImage *)photo
#endif
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
	
	NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[@"broadcast"] = [self broadcastTypeToString:broadcast];
	if (latitude && longitude) {
		dic[@"ll"] = [NSString stringWithFormat:@"%@,%@",latitude,longitude];
	}
	if (accuracyLL) {
		dic[@"llAcc"] = accuracyLL.stringValue;
	}
	if (altitude) {
		dic[@"alt"] = altitude.stringValue;
	}
	if (accuracyAlt) {
		dic[@"altAcc"] = accuracyAlt.stringValue;
	}
	if (checkinID) {
		dic[@"checkinId"] = checkinID;
	}
	if (tipID) {
		dic[@"tipId"] = tipID;
	}
	if (venueID) {
		dic[@"venueId"] = venueID;
	}
	return [self uploadPhoto:@"photos/add"
                  withParams:dic
                   withImage:photo
                    callback:callback];
}

#pragma mark -

#pragma mark Settings

+ (NSOperation *)settingsGetAllCallback:(Foursquare2Callback)callback {
	return [self get:@"settings/all" withParams:nil callback:callback];
}

+ (NSOperation *)settingsSet:(FoursquareSettingName)settingName
                     toValue:(BOOL)value
                    callback:(Foursquare2Callback)callback {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[@"value"] = value?@"1":@"0";
    NSString *path = [NSString stringWithFormat:@"settings/%@/set",
                      [self foursquareSettingNameToString:settingName]];
    return [self post:path withParams:dic callback:callback];
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


+ (NSOperation *)get:(NSString *)methodName
          withParams:(NSDictionary *)params
            callback:(Foursquare2Callback)callback {
    
	return [self request:methodName
              withParams:params
              httpMethod:@"GET"
                callback:callback];
}

+ (NSOperation *)post:(NSString *)methodName
           withParams:(NSDictionary *)params
             callback:(Foursquare2Callback)callback {
    
	return [self request:methodName
              withParams:params
              httpMethod:@"POST"
                callback:callback];
}

+ (NSString *)constructRequestUrlForMethod:(NSString *)methodName
                                    params:(NSDictionary *)paramMap {
    NSMutableString *paramStr = [NSMutableString stringWithString: kFOURSQUARE_BASE_URL];
    
    [paramStr appendString:methodName];
    NSDictionary *dic = [self classAttributes];
    NSString *key = dic[kFOURSQUARE_CLIET_ID];
    NSString *secret = dic[kFOURSQUARE_OAUTH_SECRET];
	[paramStr appendFormat:@"?client_id=%@",key];
    [paramStr appendFormat:@"&client_secret=%@",secret];
    [paramStr appendFormat:@"&v=%@",FS2_API_VERSION];
    NSLocale *locale = [NSLocale currentLocale];
    NSString *countryCode = [locale objectForKey: NSLocaleLanguageCode];
    [paramStr appendFormat:@"&locale=%@",countryCode];
    
	NSString *accessToken  = [self classAttributes][kFOURSQUARE_ACCESS_TOKEN];
	if ([accessToken length] > 0)
        [paramStr appendFormat:@"&oauth_token=%@",accessToken];
	
	if(paramMap) {
		NSEnumerator *enumerator = [paramMap keyEnumerator];
		NSString *key;
        id value;
		
		while ((key = (NSString *)[enumerator nextObject])) {
			value = paramMap[key];
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
			[paramStr appendFormat:@"&%@=%@",key,urlEncodedValue];
		}
	}
	
	return paramStr;
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
        self.operationQueue = [[NSOperationQueue alloc] init];
        self.operationQueue.maxConcurrentOperationCount = 7;
    }
    return self;
}

+ (NSOperation *)request:(NSString *)methodName
              withParams:(NSDictionary *)params
              httpMethod:(NSString *)httpMethod
                callback:(Foursquare2Callback)callback {
    
    return [[Foursquare2 sharedInstance] request:methodName
                                      withParams:params
                                      httpMethod:httpMethod
                                        callback:callback];
}

- (NSOperation *)request:(NSString *)methodName
              withParams:(NSDictionary *)params
              httpMethod:(NSString *)httpMethod
                callback:(Foursquare2Callback)callback {
    NSString *path = [Foursquare2 constructRequestUrlForMethod:methodName
                                                        params:params];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:path]];
    request.HTTPMethod = httpMethod;
	
    FSOperation *operation = [[FSOperation alloc] initWithRequest:request
                                                         callback:callback];
    [self.operationQueue addOperation:operation];
    return operation;
}


+ (NSOperation *)    uploadPhoto:(NSString *)methodName
                      withParams:(NSDictionary *)params
#ifdef __MAC_OS_X_VERSION_MAX_ALLOWED
                       withImage:(NSImage *)image
#else
                       withImage:(UIImage *)image
#endif
                        callback:(Foursquare2Callback)callback {
    
    return [[Foursquare2 sharedInstance] uploadPhoto:methodName
                                          withParams:params
                                           withImage:image
                                            callback:callback];
}


- (NSOperation *)    uploadPhoto:(NSString *)methodName
                      withParams:(NSDictionary *)params
#ifdef __MAC_OS_X_VERSION_MAX_ALLOWED
                       withImage:(NSImage *)image
#else
                       withImage:(UIImage *)image
#endif
                        callback:(Foursquare2Callback)callback {
    
	
    NSString *finalURL = [Foursquare2 constructRequestUrlForMethod:methodName
                                                            params:params];
    
#ifdef __MAC_OS_X_VERSION_MAX_ALLOWED
	NSArray *reps = [image representations];
	NSData *data = [NSBitmapImageRep representationOfImageRepsInArray:reps
                                                            usingType:NSJPEGFileType
                                                           properties:nil];
#else
	NSData *data = UIImageJPEGRepresentation(image,1.0);
#endif
    
    
    
    NSURL *url = [NSURL URLWithString:finalURL];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:url] ;
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
	[body appendData:data];
	[body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	[request setHTTPBody:body];
    
    FSOperation *operation = [[FSOperation alloc] initWithRequest:request
                                                         callback:callback];
    [self.operationQueue addOperation:operation];
    return operation;
}


#ifndef __MAC_OS_X_VERSION_MAX_ALLOWED

- (BOOL)nativeAuthorization {
    NSDictionary *dic = [Foursquare2 classAttributes];
    NSString *key = dic[kFOURSQUARE_CLIET_ID];
    NSString *callbackURL = dic[kFOURSQUARE_CALLBACK_URL];
    FSOAuthStatusCode statusCode = [FSOAuthNoAppStore authorizeUserUsingClientId:key callbackURIString:callbackURL];
    if (statusCode == FSOAuthStatusSuccess) {
        return YES;
    }
    return NO;
}

- (void)webAuthorization {
    NSDictionary *dic = [Foursquare2 classAttributes];
    NSString *key = dic[kFOURSQUARE_CLIET_ID];
    NSString *callbackURL = dic[kFOURSQUARE_CALLBACK_URL];
	NSString *url = [NSString stringWithFormat:
                     @"https://foursquare.com/oauth2/authenticate?client_id=%@&response_type=token&redirect_uri=%@",
                     key,callbackURL];
	FSWebLogin *loginViewControler = [[FSWebLogin alloc] initWithUrl:url
                                               andDelegate:self];
	UINavigationController *navigationController = [[UINavigationController alloc]
                                                    initWithRootViewController:loginViewControler];
	UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
    UIViewController *controller = [self topViewController:keyWindow.rootViewController];
	[controller presentViewController:navigationController animated:YES completion:nil];
}


+ (void)authorizeWithCallback:(Foursquare2Callback)callback {
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
    if ([Foursquare2 isAuthorized]) {
        [Foursquare2 sharedInstance].authorizationCallback(YES, error);
    } else {
        [Foursquare2 sharedInstance].authorizationCallback(NO, error);
    }
    [Foursquare2 sharedInstance].authorizationCallback = nil;
}

+ (BOOL)handleURL:(NSURL *)url {
    NSDictionary *dic = [self classAttributes];
    NSString *callbackURL = dic[kFOURSQUARE_CALLBACK_URL];
    
    if ([callbackURL hasPrefix:[url scheme]]) {
        
        BOOL isWebLoginURL = [url.absoluteString rangeOfString:@"#access_token"].length;
        if (isWebLoginURL) {
            NSArray *array = [url.absoluteString componentsSeparatedByString:@"="];
            NSString *accessToken = array.lastObject;
            [Foursquare2 setAccessToken:accessToken];
            [self callAuthorizationCallbackWithError:nil];
            return YES;
        }
        
        //then  it's native oauth.
        FSOAuthErrorCode errorCode;
        NSString *code = [FSOAuthNoAppStore accessCodeForFSOAuthURL:url
                                                    error:&errorCode];
        if (errorCode == FSOAuthErrorNone) {
            NSString *key = dic[kFOURSQUARE_CLIET_ID];
            NSString *secret = dic[kFOURSQUARE_OAUTH_SECRET];
            [FSOAuthNoAppStore requestAccessTokenForCode:code
                                      clientId:key
                             callbackURIString:callbackURL
                                  clientSecret:secret
                               completionBlock:^(NSString *authToken, BOOL requestCompleted,
                                                 FSOAuthErrorCode errorCode) {
                                   if (errorCode  == FSOAuthErrorNone) {
                                       [Foursquare2 setAccessToken:authToken];
                                       [self callAuthorizationCallbackWithError:nil];
                                   } else {
                                       [self callAuthorizationCallbackWithError:[self errorForCode:errorCode]];
                                   }
                               }];
            
        } else {
            [self callAuthorizationCallbackWithError:[self errorForCode:errorCode]];
        }
        return YES;
    }
    return NO;
}

+ (NSError *)errorForCode:(FSOAuthErrorCode)errorCode {
    NSString *msg = [self errorMessageForCode:errorCode];
    NSError *error = [NSError errorWithDomain:@"fs.native.auth"
                                         code:-1
                                     userInfo:@{@"error":msg}];
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
            resultText =  @"Invalid request error";
            break;
        }
        case FSOAuthErrorUnauthorizedClient: {
            resultText =  @"Invalid unauthorized client error";
            break;
        }
        case FSOAuthErrorUnsupportedGrantType: {
            resultText =  @"Invalid unsupported grant error";
            break;
        }
        case FSOAuthErrorUnknown:
        default: {
            resultText =  @"Unknown error";
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
        UINavigationController *navigationController = (UINavigationController *)rootViewController.presentedViewController;
        UIViewController *lastViewController = [[navigationController viewControllers] lastObject];
        return [self topViewController:lastViewController];
    }
    
    UIViewController *presentedViewController = (UIViewController *)rootViewController.presentedViewController;
    return [self topViewController:presentedViewController];
}


#endif













#pragma mark DEPRECETED ----------------------------------------------------------------------
+(void)getDetailForUser:(NSString*)userID
			   callback:(Foursquare2Callback)callback
{
	NSString *path = [NSString stringWithFormat:@"users/%@",userID];
	[self get:path withParams:nil callback:callback];
}

+(void)searchUserPhone:(NSArray*)phones
				 email:(NSArray*)emails
			   twitter:(NSArray*)twitters
		 twitterSource:(NSString*)twitterSource
		   facebookIDs:(NSArray*)fbid
				  name:(NSString*)name
			  callback:(Foursquare2Callback)callback
{
	NSMutableDictionary *dic = [NSMutableDictionary dictionary];
	dic[@"phone"] = [self stringFromArray:phones];
	dic[@"email"] = [self stringFromArray:emails];
	dic[@"twitter"] = [self stringFromArray:twitters];
	if (twitterSource) {
		dic[@"twitterSource"] = twitterSource;
	}
	dic[@"fbid"] = [self stringFromArray:fbid];
	if (name) {
		dic[@"name"] = name;
	}
	[self get:@"users/search" withParams:dic callback:callback];
}

+(void)getFriendRequestsCallback:(Foursquare2Callback)callback
{
	[self get:@"users/requests" withParams:nil callback:callback];
}

#pragma mark Aspects


+(void)getBadgesForUser:(NSString*)userID
			   callback:(Foursquare2Callback)callback
{
	NSString *path = [NSString stringWithFormat:@"users/%@/badges",userID];
	[self get:path withParams:nil callback:callback];
}

+(void)getCheckinsByUser:(NSString*)userID
				   limit:(NSString*)limit
				  offset:(NSString*)offset
		  afterTimestamp:(NSString*)afterTimestamp
		 beforeTimestamp:(NSString*)beforeTimestamp
				callback:(Foursquare2Callback)callback
{
	NSMutableDictionary *dic = [NSMutableDictionary dictionary];
	if (limit) {
		dic[@"limit"] = limit;
	}
	if (offset) {
		dic[@"offset"] = offset;
	}
	if (afterTimestamp) {
		dic[@"afterTimestamp"] = afterTimestamp;
	}
	if (beforeTimestamp) {
		dic[@"beforeTimestamp"] = beforeTimestamp;
	}
	NSString *path = [NSString stringWithFormat:@"users/%@/checkins",userID];
	[self get:path withParams:dic callback:callback];
	
}

+(void)getFriendsOfUser:(NSString*)userID
			   callback:(Foursquare2Callback)callback
{
	NSString *path = [NSString stringWithFormat:@"users/%@/friends",userID];
	[self get:path withParams:nil callback:callback];
}



+(void)getTipsFromUser:(NSString*)userID
				  sort:(FoursquareSortingType)sort
			  latitude:(NSString*)lat
			 longitude:(NSString*)lon
			  callback:(Foursquare2Callback)callback
{
	NSMutableDictionary *dic = [NSMutableDictionary dictionary];
	if (sort) {
		dic[@"sort"] = [self sortTypeToString:sort];
	}
	if (lat && lon) {
		dic[@"ll"] = [NSString stringWithFormat:@"%@,%@",lat,lon];
	}
	NSString *path = [NSString stringWithFormat:@"users/%@/tips",userID];
	[self get:path withParams:dic callback:callback];
}

+(void)getTodosFromUser:(NSString*)userID
				   sort:(FoursquareSortingType)sort
			   latitude:(NSString*)lat
			  longitude:(NSString*)lon
			   callback:(Foursquare2Callback)callback
{
	if (sort == sortNearby) {
		callback(NO, @"sort is one of recent or popular. Nearby requires geolat and geolong to be provided.");
		return;
	}
	
	NSMutableDictionary *dic = [NSMutableDictionary dictionary];
	if (sort) {
		dic[@"sort"] = [self sortTypeToString:sort];
	}
	if (lat && lon) {
		dic[@"ll"] = [NSString stringWithFormat:@"%@,%@",lat,lon];
	}
	NSString *path = [NSString stringWithFormat:@"users/%@/todos",userID];
	[self get:path withParams:dic callback:callback];
}


+(void)getVenuesVisitedByUser:(NSString*)userID
					 callback:(Foursquare2Callback)callback
{
	NSString *path = [NSString stringWithFormat:@"users/%@/venuehistory",userID];
	[self get:path withParams:nil callback:callback];
}

#pragma mark Actions

+(void)sendFriendRequestToUser:(NSString*)userID
					  callback:(Foursquare2Callback)callback
{
	NSString *path = [NSString stringWithFormat:@"users/%@/request",userID];
	[self post:path withParams:nil callback:callback];
}

+(void)removeFriend:(NSString*)userID
		   callback:(Foursquare2Callback)callback
{
	NSString *path = [NSString stringWithFormat:@"users/%@/unfriend",userID];
	[self post:path withParams:nil callback:callback];
}

+(void)approveFriend:(NSString*)userID
			callback:(Foursquare2Callback)callback
{
	NSString *path = [NSString stringWithFormat:@"users/%@/approve",userID];
	[self post:path withParams:nil callback:callback];
}

+(void)denyFriend:(NSString*)userID
		 callback:(Foursquare2Callback)callback
{
	NSString *path = [NSString stringWithFormat:@"users/%@/deny",userID];
	[self post:path withParams:nil callback:callback];
}

+(void)setPings:(BOOL)value
	  forFriend:(NSString*)userID
	   callback:(Foursquare2Callback)callback
{
	NSString *path = [NSString stringWithFormat:@"users/%@/setpings",userID];
	NSDictionary *params = @{@"value":(value?@"true":@"false")};
	[self post:path withParams:params callback:callback];
}

#pragma mark -


#pragma mark Venues

+(void)getDetailForVenue:(NSString*)venueID
				callback:(Foursquare2Callback)callback
{
	NSString *path = [NSString stringWithFormat:@"venues/%@",venueID];
	[self get:path withParams:nil callback:callback];
}

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
			   callback:(Foursquare2Callback)callback
{
	NSMutableDictionary *dic = [NSMutableDictionary dictionary];
	if (name) {
		dic[@"name"] = name;
	}
	if (address) {
		dic[@"address"] = address;
	}
	if (crossStreet) {
		dic[@"crossStreet"] = crossStreet;
	}
	if (city) {
		dic[@"city"] = city;
	}
	if (state) {
		dic[@"state"] = state;
	}
	if (zip) {
		dic[@"zip"] = zip;
	}
	if (phone) {
		dic[@"phone"] = phone;
	}
	if (lat && lon) {
		dic[@"ll"] = [NSString stringWithFormat:@"%@,%@",lat,lon];
	}
	if (primaryCategoryId) {
		dic[@"primaryCategoryId"] = primaryCategoryId;
	}
	[self post:@"venues/add" withParams:dic callback:callback];
}

+(void)getVenueCategoriesCallback:(Foursquare2Callback)callback
{
	[self get:@"venues/categories" withParams:nil callback:callback];
}

+(void)searchVenuesNearByLatitude:(NSNumber*)lat
						longitude:(NSNumber*)lon
					   accuracyLL:(NSNumber*)accuracyLL
						 altitude:(NSNumber*)altitude
					  accuracyAlt:(NSNumber*)accuracyAlt
							query:(NSString*)query
							limit:(NSNumber*)limit
						   intent:(FoursquareIntentType)intent
                           radius:(NSNumber*)radius
                       categoryId:(NSString*)categoryId
						 callback:(Foursquare2Callback)callback
{
	NSMutableDictionary *dic = [NSMutableDictionary dictionary];
	if (lat && lon) {
		dic[@"ll"] = [NSString stringWithFormat:@"%@,%@",lat,lon];
	}
	if (accuracyLL) {
		dic[@"llAcc"] = accuracyLL.stringValue;
	}
	if (altitude) {
		dic[@"alt"] = altitude.stringValue;
	}
	if (accuracyAlt) {
		dic[@"altAcc"] = accuracyAlt.stringValue;
	}
	if (query) {
		dic[@"query"] = query;
	}
	if (limit) {
		dic[@"limit"] = limit.stringValue;
	}
	if (intent) {
		dic[@"intent"] = [self inentTypeToString:intent];
	}
    if (radius) {
		dic[@"radius"] = radius.stringValue;
	}
    if (categoryId) {
        dic[@"categoryId"] = categoryId;
    }
	[self get:@"venues/search" withParams:dic callback:callback];
}

+(void)searchTrendingVenuesNearByLatitude:(NSNumber*)lat
                                longitude:(NSNumber*)lon
                                    limit:(NSNumber*)limit
                                   radius:(NSNumber*)radius
                                 callback:(Foursquare2Callback)callback
{
	NSMutableDictionary *dic = [NSMutableDictionary dictionary];
	if (lat && lon) {
		dic[@"ll"] = [NSString stringWithFormat:@"%@,%@",lat,lon];
	}
	if (limit) {
		dic[@"limit"] = limit.stringValue;
	}
    if (radius) {
		dic[@"radius"] = radius.stringValue;
	}
	[self get:@"venues/trending" withParams:dic callback:callback];
}

+(void)searchRecommendedVenuesNearByLatitude:(NSNumber*)lat
                                   longitude:(NSNumber*)lon
                                  accuracyLL:(NSNumber*)accuracyLL
                                    altitude:(NSNumber*)altitude
                                 accuracyAlt:(NSNumber*)accuracyAlt
                                       query:(NSString*)query
                                       limit:(NSNumber*)limit
                                      radius:(NSNumber*)radius
                                     section:(NSString*)section
                                     novelty:(NSString*)novelty
                              sortByDistance:(NSNumber*)sortByDistance
                                       price:(NSString*)price
                                    callback:(Foursquare2Callback)callback
{
	NSMutableDictionary *dic = [NSMutableDictionary dictionary];
	if (lat && lon) {
		dic[@"ll"] = [NSString stringWithFormat:@"%@,%@",lat,lon];
	}
	if (accuracyLL) {
		dic[@"llAcc"] = accuracyLL.stringValue;
	}
	if (altitude) {
		dic[@"alt"] = altitude.stringValue;
	}
	if (accuracyAlt) {
		dic[@"altAcc"] = accuracyAlt.stringValue;
	}
	if (query) {
		dic[@"query"] = query;
	}
	if (limit) {
		dic[@"limit"] = limit.stringValue;
	}
    if (radius) {
		dic[@"radius"] = radius.stringValue;
	}
    if (novelty) {
        dic[@"novelty"] = novelty;
    }
    if (sortByDistance) {
        dic[@"sortByDistance"] = sortByDistance.stringValue;
    }
    if (price) {
        dic[@"price"] = price;
    }
    if (section) {
        dic[@"section"] = section;
    }
	[self get:@"venues/explore" withParams:dic callback:callback];
}

+(void)searchVenuesInBoundingQuadrangleS:(NSNumber*)s
                                       w:(NSNumber*)w
                                       n:(NSNumber*)n
                                       e:(NSNumber*)e
                                   query:(NSString*)query
                                   limit:(NSNumber*)limit
                                callback:(Foursquare2Callback)callback
{
	NSMutableDictionary *dic = [NSMutableDictionary dictionary];
	if (s && w && n && e) {
		dic[@"sw"] = [NSString stringWithFormat:@"%@,%@",s,w];
        dic[@"ne"] = [NSString stringWithFormat:@"%@,%@",n,e];
	}
	if (query) {
		dic[@"query"] = query;
	}
	if (limit) {
		dic[@"limit"] = limit.stringValue;
	}
    dic[@"intent"] = [self inentTypeToString:intentBrowse];
    
	[self get:@"venues/search" withParams:dic callback:callback];
}

#pragma mark Aspects
+(void)getVenueHereNow:(NSString*)venueID
				 limit:(NSString*)limit
				offset:(NSString*)offset
		afterTimestamp:(NSString*)afterTimestamp
			  callback:(Foursquare2Callback)callback
{
	if(nil == venueID){
		callback(NO,nil);
		return;
	}
	
	NSMutableDictionary *dic = [NSMutableDictionary dictionary];
	if (limit) {
		dic[@"limit"] = limit;
	}
	if (offset) {
		dic[@"offset"] = offset;
	}
	if (afterTimestamp) {
		dic[@"afterTimestamp"] = afterTimestamp;
	}
	NSString *path = [NSString stringWithFormat:@"venues/%@/herenow",venueID];
	[self get:path withParams:dic callback:callback];
}

+(void)getTipsFromVenue:(NSString*)venueID
				   sort:(FoursquareSortingType)sort
			   callback:(Foursquare2Callback)callback
{
	if (nil == venueID || sort == sortNearby) {
		callback(NO,nil);
		return;
	}
	NSMutableDictionary *dic = [NSMutableDictionary dictionary];
	dic[@"sort"] = [self sortTypeToString:sort];
	NSString *path = [NSString stringWithFormat:@"venues/%@/tips",venueID];
	[self get:path withParams:dic callback:callback];
}

#pragma mark Actions
+(void)markVenueToDo:(NSString*)venueID
				text:(NSString*)text
			callback:(Foursquare2Callback)callback
{
	if (nil == venueID) {
		callback(NO,nil);
		return;
	}
	NSMutableDictionary *dic = [NSMutableDictionary dictionary];
	if (text) {
		dic[@"text"] = text;
	}
	NSString *path = [NSString stringWithFormat:@"venues/%@/marktodo",venueID];
	[self post:path withParams:dic callback:callback];
}

+(void)flagVenue:(NSString*)venueID
		 problem:(FoursquareProblemType)problem
		callback:(Foursquare2Callback)callback
{
	if (nil == venueID) {
		callback(NO,nil);
		return;
	}
	NSMutableDictionary *dic = [NSMutableDictionary dictionary];
	dic[@"problem"] = [self problemTypeToString:problem];
	NSString *path = [NSString stringWithFormat:@"venues/%@/flag",venueID];
	[self post:path withParams:dic callback:callback];
}


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
			   callback:(Foursquare2Callback)callback
{
	if (nil ==venueID) {
		callback(NO,nil);
		return;
	}
	NSMutableDictionary *dic = [NSMutableDictionary dictionary];
	if (name) {
		dic[@"name"] = name;
	}
	if (address) {
		dic[@"address"] = address;
	}
	if (crossStreet) {
		dic[@"crossStreet"] = crossStreet;
	}
	if (city) {
		dic[@"city"] = city;
	}
	if (state) {
		dic[@"state"] = state;
	}
	if (zip) {
		dic[@"zip"] = zip;
	}
	if (phone) {
		dic[@"phone"] = phone;
	}
	if (lat && lon) {
		dic[@"ll"] = [NSString stringWithFormat:@"%@,%@",lat,lon];
	}
	if (primaryCategoryId) {
		dic[@"primaryCategoryId"] = primaryCategoryId;
	}
	NSString *path = [NSString stringWithFormat:@"venues/%@/proposeedit",venueID];
	[self post:path withParams:dic callback:callback];
}

#pragma mark -

#pragma mark Checkins

+(void)getDetailForCheckin:(NSString*)checkinID
				  callback:(Foursquare2Callback)callback
{
	NSString *path = [NSString stringWithFormat:@"checkins/%@",checkinID];
	[self get:path withParams:nil callback:callback];
}

+(void)createCheckinAtVenue:(NSString*)venueID
					  venue:(NSString*)venue
					  shout:(NSString*)shout
				   callback:(Foursquare2Callback)callback{
    [Foursquare2 createCheckinAtVenue:venueID
								venue:venue
								shout:shout
							broadcast:broadcastPublic
							 latitude:nil
							longitude:nil
						   accuracyLL:nil
							 altitude:nil
						  accuracyAlt:nil
							 callback:callback];
}



+(void)createCheckinAtVenue:(NSString*)venueID
					  venue:(NSString*)venue
					  shout:(NSString*)shout
				  broadcast:(FoursquareBroadcastType)broadcast
				   latitude:(NSString*)lat
				  longitude:(NSString*)lon
				 accuracyLL:(NSString*)accuracyLL
				   altitude:(NSString*)altitude
				accuracyAlt:(NSString*)accuracyAlt
				   callback:(Foursquare2Callback)callback
{
	NSMutableDictionary *dic = [NSMutableDictionary dictionary];
	if (venueID) {
		dic[@"venueId"] = venueID;
	}
	if (venue) {
		dic[@"venue"] = venue;
	}
	if (shout) {
		dic[@"shout"] = shout;
	}
	if (lat && lon) {
		dic[@"ll"] = [NSString stringWithFormat:@"%@,%@",lat,lon];
	}
	if (accuracyLL) {
		dic[@"llAcc"] = accuracyLL;
	}
	if (altitude) {
		dic[@"alt"] = altitude;
	}
	if (accuracyAlt) {
		dic[@"altAcc"] = accuracyAlt;
	}
	
	dic[@"broadcast"] = [self broadcastTypeToString:broadcast];
	
    //	if ([broadcast length] == 0) {
    //		[dic setObject:@"public" forKey:@"broadcast"];
    //	}else{
    //		[dic setObject:broadcast forKey:@"broadcast"];
    //	}
	NSLog(@"Checking in with details: %@",dic);
    
	[self post:@"checkins/add" withParams:dic callback:callback];
}

+(void)getRecentCheckinsByFriendsNearByLatitude:(NSString*)lat
									  longitude:(NSString*)lon
										  limit:(NSString*)limit
										 offset:(NSString*)offset
								 afterTimestamp:(NSString*)afterTimestamp
									   callback:(Foursquare2Callback)callback
{
	NSMutableDictionary *dic = [NSMutableDictionary dictionary];
	if (limit) {
		dic[@"limit"] = limit;
	}
	if (offset) {
		dic[@"offset"] = offset;
	}
	if (afterTimestamp) {
		dic[@"afterTimestamp"] = afterTimestamp;
	}
	if (lat && lon) {
		dic[@"ll"] = [NSString stringWithFormat:@"%@,%@",lat,lon];
	}
	
	[self get:@"checkins/recent" withParams:dic callback:callback];
}

#pragma mark Actions
+(void)addCommentToCheckin:(NSString*)checkinID
					  text:(NSString*)text
				  callback:(Foursquare2Callback)callback
{
	if (nil ==checkinID) {
		callback(NO,nil);
		return;
	}
	NSMutableDictionary *dic = [NSMutableDictionary dictionary];
	if (text) {
		dic[@"text"] = text;
	}
	NSString *path = [NSString stringWithFormat:@"checkins/%@/addcomment",checkinID];
	[self post:path withParams:dic callback:callback];
}

+(void)deleteComment:(NSString*)commentID
		  forCheckin:(NSString*)checkinID
			callback:(Foursquare2Callback)callback
{
	if (nil ==checkinID) {
		callback(NO,nil);
		return;
	}
	NSMutableDictionary *dic = [NSMutableDictionary dictionary];
	if (commentID) {
		dic[@"commentId"] = commentID;
	}
	NSString *path = [NSString stringWithFormat:@"checkins/%@/deletecomment",checkinID];
	[self post:path withParams:dic callback:callback];
}
#pragma mark -

#pragma mark Tips


+(void)getDetailForTip:(NSString*)tipID
			  callback:(Foursquare2Callback)callback
{
	NSString *path = [NSString stringWithFormat:@"tips/%@/",tipID];
	[self get:path withParams:nil callback:callback];
}


+(void)addTip:(NSString*)tip
	 forVenue:(NSString*)venueID
	  withURL:(NSString*)url
	 callback:(Foursquare2Callback)callback
{
	if (nil ==venueID || nil == tip) {
		callback(NO,nil);
		return;
	}
	NSMutableDictionary *dic = [NSMutableDictionary dictionary];
	dic[@"venueId"] = venueID;
	dic[@"text"] = tip;
	if(url)
		dic[@"url"] = url;
	
	[self post:@"tips/add" withParams:dic callback:callback];
}

+(void)searchTipNearbyLatitude:(NSString*)lat
					 longitude:(NSString*)lon
						 limit:(NSString*)limit
						offset:(NSString*)offset
				   friendsOnly:(BOOL)friendsOnly
						 query:(NSString*)query
					  callback:(Foursquare2Callback)callback
{
	NSMutableDictionary *dic = [NSMutableDictionary dictionary];
	if (limit) {
		dic[@"limit"] = limit;
	}
	if (offset) {
		dic[@"offset"] = offset;
	}
	
	if (lat && lon) {
		dic[@"ll"] = [NSString stringWithFormat:@"%@,%@",lat,lon];
	}
	if (friendsOnly) {
		dic[@"filter"] = @"friends";
	}
	if (query) {
		dic[@"query"] = query;
	}
	
	[self get:@"tips/search" withParams:dic callback:callback];
}
#pragma mark Actions
+(void)markTipTodo:(NSString*)tipID
		  callback:(Foursquare2Callback)callback
{
	NSString *path = [NSString stringWithFormat:@"tips/%@/marktodo",tipID];
	[self post:path withParams:nil callback:callback];
}

+(void)markTipDone:(NSString*)tipID
		  callback:(Foursquare2Callback)callback
{
	NSString *path = [NSString stringWithFormat:@"tips/%@/markdone",tipID];
	[self post:path withParams:nil callback:callback];
}

+(void)unmarkTipTodo:(NSString*)tipID
			callback:(Foursquare2Callback)callback
{
	NSString *path = [NSString stringWithFormat:@"tips/%@/unmark",tipID];
	[self post:path withParams:nil callback:callback];
}

#pragma mark -


#pragma mark Photos

+(void)getDetailForPhoto:(NSString*)photoID
				callback:(Foursquare2Callback)callback
{
	NSString *path = [NSString stringWithFormat:@"photos/%@",photoID];
	[self get:path withParams:nil callback:callback];
}

#ifdef __MAC_OS_X_VERSION_MAX_ALLOWED
+(void)addPhoto:(NSImage*)photo
#else
+(void)addPhoto:(UIImage*)photo
#endif
      toCheckin:(NSString*)checkinID
       callback:(Foursquare2Callback)callback{
    [Foursquare2 addPhoto:photo
                toCheckin:checkinID
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
{
	if (!checkinID && !tipID && !venueID) {
		callback(NO,nil);
		return;
	}
	
	NSMutableDictionary *dic = [NSMutableDictionary dictionary];
	if (lat && lon) {
		dic[@"ll"] = [NSString stringWithFormat:@"%@,%@",lat,lon];
	}
	if (accuracyLL) {
		dic[@"llAcc"] = accuracyLL;
	}
	if (altitude) {
		dic[@"alt"] = altitude;
	}
	if (accuracyAlt) {
		dic[@"altAcc"] = accuracyAlt;
	}
	
	dic[@"broadcast"] = [self broadcastTypeToString:broadcast];
	if (checkinID) {
		dic[@"checkinId"] = checkinID;
	}
	if (tipID) {
		dic[@"tipId"] = tipID;
	}
	if (venueID) {
		dic[@"venueId"] = venueID;
	}
	[self uploadPhoto:@"photos/add"
		   withParams:dic
			withImage:photo
			 callback:callback];
}

+(void)getPhotosForVenue:(NSString *)venueID
                   limit:(NSNumber *)limit
                  offset:(NSNumber *)offset
                callback:(Foursquare2Callback)callback
{
    if (!venueID) {
		callback(NO,nil);
		return;
	}
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    if (limit) {
        dic[@"limit"] = limit.stringValue;
    }
    if (offset) {
        dic[@"offset"] = offset.stringValue;
    }
    NSString *path = [NSString stringWithFormat:@"venues/%@/photos", venueID];
	[self get:path withParams:dic callback:callback];
}

#pragma mark -

#pragma mark Settings
+(void)getAllSettingsCallback:(Foursquare2Callback)callback
{
	[self get:@"settings/all" withParams:nil callback:callback];
}
+(void)setSendToTwitter:(BOOL)value
			   callback:(Foursquare2Callback)callback;
{
	NSMutableDictionary *dic = [NSMutableDictionary dictionary];
	dic[@"value"] = value?@"1":@"0";
	[self post:@"settings/sendToTwitter/set" withParams:dic callback:callback];
}

+(void)setSendToFacebook:(BOOL)value
				callback:(Foursquare2Callback)callback;
{
	NSMutableDictionary *dic = [NSMutableDictionary dictionary];
	dic[@"value"] = value?@"1":@"0";
	[self post:@"settings/sendToFacebook/set" withParams:dic callback:callback];
}

+(void)setReceivePings:(BOOL)value
			  callback:(Foursquare2Callback)callback;
{
	NSMutableDictionary *dic = [NSMutableDictionary dictionary];
	dic[@"value"] = value?@"1":@"0";
	[self post:@"settings/receivePings/set" withParams:dic callback:callback];
}
#pragma mark -

@end
