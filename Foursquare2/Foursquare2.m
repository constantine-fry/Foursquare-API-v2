//
//  Foursquare2.m
//  Foursquare API
//
//  Created by Constantine Fry on 1/7/11.
//  Copyright 2011 Home. All rights reserved.
//

#import "Foursquare2.h"
#import "FSTargetCallback.h"



@interface Foursquare2 (PrivateAPI)
+ (void)        get:(NSString *)methodName
         withParams:(NSDictionary *)params 
		   callback:(Foursquare2Callback)callback;

+ (void)       post:(NSString *)methodName
		 withParams:(NSDictionary *)params
		   callback:(Foursquare2Callback)callback;

+ (void)    request:(NSString *)methodName 
	     withParams:(NSDictionary *)params 
	     httpMethod:(NSString *)httpMethod
		   callback:(Foursquare2Callback)callback;

+ (void)    uploadPhoto:(NSString *)methodName 
			 withParams:(NSDictionary *)params 
#ifdef __MAC_OS_X_VERSION_MAX_ALLOWED
			  withImage:(NSImage*)image
#else
			  withImage:(UIImage*)image
#endif
			   callback:(Foursquare2Callback)callback;

+(void)setAccessToken:(NSString*)token;
+(NSString*)problemTypeToString:(FoursquareProblemType)problem;
+(NSString*)broadcastTypeToString:(FoursquareBroadcastType)broadcast;
+(NSString*)sortTypeToString:(FoursquareSortingType)type;
// Declared in HRRestModel
+ (void)setAttributeValue:(id)attr forKey:(NSString *)key;
+ (NSMutableDictionary *)classAttributes;
@end

@implementation Foursquare2

static NSMutableDictionary *attributes;

+ (void)initialize
{
    [self setBaseURL:kBaseUrl];
	NSUserDefaults *usDef = [NSUserDefaults standardUserDefaults];
	if ([usDef objectForKey:@"access_token2"] != nil) {
		[self classAttributes][@"access_token"] = [usDef objectForKey:@"access_token2"];
	}
}



+ (void)setBaseURL:(NSString *)uri {
    [self setAttributeValue:uri forKey:@"kBaseUrl"];
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

+(void)setAccessToken:(NSString*)token{
	[self classAttributes][@"access_token"] = token;
	[[NSUserDefaults standardUserDefaults]setObject:token forKey:@"access_token2"];
	[[NSUserDefaults standardUserDefaults]synchronize];
}

+(void)removeAccessToken{
	[[self classAttributes]removeObjectForKey:@"access_token"];
	[[NSUserDefaults standardUserDefaults]removeObjectForKey:@"access_token2"];
	[[NSUserDefaults standardUserDefaults]synchronize];
}

+(BOOL)isNeedToAuthorize{
	return ([self classAttributes][@"access_token"] == nil);
}

+(BOOL)isAuthorized{
    return ([self classAttributes][@"access_token"] != nil);
}


+(NSString*)stringFromArray:(NSArray*)array{
	if (array.count) {
        return [array componentsJoinedByString:@","];
    }
    return @"";
	
}
#pragma mark -
#pragma mark Users

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
		dic[@"zip"] = name;
	}
	if (phone) {
		dic[@"phone"] = name;
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
	[self get:@"venues/search" withParams:dic callback:callback];
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
		dic[@"zip"] = name;
	}
	if (phone) {
		dic[@"phone"] = name;
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












#pragma mark Private methods

+(NSString*)inentTypeToString:(FoursquareIntentType)broadcast{
	switch (broadcast) {
		case intentBrowse:
			return @"browse";
			break;
		case intentCheckin:
			return @"checkin";
			break;
		case intentGlobal:
			return @"global";
			break;
		case intentMatch:
			return @"match";
			break;
		default:
			return nil;
			break;
	}
	
}


+(NSString*)broadcastTypeToString:(FoursquareBroadcastType)broadcast{
	switch (broadcast) {
		case broadcastPublic:
			return @"public";
			break;
		case broadcastPrivate:
			return @"private";
			break;
		case broadcastFacebook:
			return @"faceboook";
			break;
		case broadcastTwitter:
			return @"twitter";
			break;
		case broadcastBoth:
			return @"twitter,facebook";
			break;
		default:
			return nil;
			break;
	}
	
}

+(NSString*)problemTypeToString:(FoursquareProblemType)problem{
	switch (problem) {
		case problemClosed:
			return @"closed";
			break;
		case problemDuplicate:
			return @"duplicate";
			break;
		case problemMislocated:
			return @"mislocated";
			break;
		default:
			return nil;
			break;
	}
	
}

+(NSString*)sortTypeToString:(FoursquareSortingType)type{
	switch (type) {
		case sortNearby:
			return @"nearby";
			break;
		case sortPopular:
			return @"popular";
			break;
		case sortRecent:
			return @"recent";
			break;
		default:
			return nil;
			break;
	}
}


+ (void)        get:(NSString *)methodName
         withParams:(NSDictionary *)params 
		   callback:(Foursquare2Callback)callback
{
	[self request:methodName withParams:params httpMethod:@"GET" callback:callback];
}

+ (void)       post:(NSString *)methodName
		 withParams:(NSDictionary *)params
		   callback:(Foursquare2Callback)callback 
{
	[self request:methodName withParams:params httpMethod:@"POST" callback:callback];
}

+ (NSString *)constructRequestUrlForMethod:(NSString *)methodName 
                                    params:(NSDictionary *)paramMap {
    NSMutableString *paramStr = [NSMutableString stringWithString: [self classAttributes][@"kBaseUrl"]];
    
    [paramStr appendString:methodName];
	[paramStr appendFormat:@"?client_id=%@",OAUTH_KEY];
    [paramStr appendFormat:@"&client_secret=%@",OAUTH_SECRET];
    [paramStr appendFormat:@"&v=%@",VERSION];
    NSLocale *locale = [NSLocale currentLocale];
    NSString *countryCode = [locale objectForKey: NSLocaleLanguageCode];
    [paramStr appendFormat:@"&locale=%@",countryCode];
    
	NSString *accessToken  = [self classAttributes][@"access_token"];
	if ([accessToken length] > 0)
        [paramStr appendFormat:@"&oauth_token=%@",accessToken];
	
	if(paramMap) {
		NSEnumerator *enumerator = [paramMap keyEnumerator];
		NSString *key, *value;
		
		while ((key = (NSString *)[enumerator nextObject])) {
			value = (NSString *)paramMap[key];
			//DLog(@"value: " @"%@", value);
			
			NSString *urlEncodedValue = [value stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];//NSASCIIStringEncoding];
			
			if(!urlEncodedValue) {
				urlEncodedValue = @"";
			}
			[paramStr appendFormat:@"&%@=%@",key,urlEncodedValue];
		}
	}
	
	return paramStr;
}



#pragma -


static Foursquare2 *instance;
+(Foursquare2*)sharedInstance{
    if (!instance) {
        instance = [[Foursquare2 alloc]init];
    }
    return instance;
    
}

+ (void)    request:(NSString *)methodName 
	     withParams:(NSDictionary *)params 
	     httpMethod:(NSString *)httpMethod
		   callback:(Foursquare2Callback)callback{
    [[Foursquare2 sharedInstance]request:methodName 
                              withParams:params
                              httpMethod:httpMethod
                                callback:callback];   
}

- (void) callback: (NSDictionary *)d target:(FSTargetCallback *)target {
    if (d[@"access_token"]) {
        target.callback(YES,d);
        return;
    }
    NSNumber *code = [d valueForKeyPath:@"meta.code"];
    if (d!= nil && (code.intValue == 200 || code.intValue == 201)) {
        target.callback(YES,d);
    }else{
        target.callback(NO,[d valueForKeyPath:@"meta.errorDetail"]);
    }
}

-(void)    request:(NSString *)methodName 
        withParams:(NSDictionary *)params 
        httpMethod:(NSString *)httpMethod
          callback:(Foursquare2Callback)callback
{
    //	callback = [callback copy];
    NSString *path = [Foursquare2 constructRequestUrlForMethod:methodName
                                                        params:params];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:path ]];
    request.HTTPMethod = httpMethod;
	
    FSTargetCallback *target = [[FSTargetCallback alloc] initWithCallback:callback
                                                       resultCallback:@selector(callback:target:)
                                                           requestUrl: path
                                                             numTries: 2];
	
	[self makeAsyncRequestWithRequest:request 
                               target:target];
}


+ (void)    uploadPhoto:(NSString *)methodName 
			 withParams:(NSDictionary *)params 
#ifdef __MAC_OS_X_VERSION_MAX_ALLOWED
			  withImage:(NSImage*)image
#else
			  withImage:(UIImage*)image
#endif
			   callback:(Foursquare2Callback)callback{
    [[Foursquare2 sharedInstance]uploadPhoto:methodName
                                  withParams:params 
                                   withImage:image
                                    callback:callback];
}


- (void)    uploadPhoto:(NSString *)methodName 
			 withParams:(NSDictionary *)params 
#ifdef __MAC_OS_X_VERSION_MAX_ALLOWED
			  withImage:(NSImage*)image
#else
			  withImage:(UIImage*)image
#endif
			   callback:(Foursquare2Callback)callback
{
    
	
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
	[body appendData:[@"Content-Disposition: form-data; name=\"userfile\"; filename=\"soundtracker_radio_artwork.jpg\"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:data];
	[body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	[request setHTTPBody:body];
    
    
    
    
    FSTargetCallback *target = [[FSTargetCallback alloc] initWithCallback:callback
                                                       resultCallback:@selector(callback:target:)
                                                           requestUrl: finalURL
                                                             numTries: 2];
    
    [self makeAsyncRequestWithRequest:request
                               target:target];
}


#ifndef __MAC_OS_X_VERSION_MAX_ALLOWED

Foursquare2Callback authorizeCallbackDelegate;
+(void)authorizeWithCallback:(Foursquare2Callback)callback{
	authorizeCallbackDelegate = [callback copy];
	NSString *url = [NSString stringWithFormat:@"https://foursquare.com/oauth2/authenticate?client_id=%@&response_type=token&redirect_uri=%@",OAUTH_KEY,REDIRECT_URL];
	FSWebLogin *loginCon = [[FSWebLogin alloc] initWithUrl:url];
	loginCon.delegate = self;
	loginCon.selector = @selector(done:);
	UINavigationController *navCon = [[UINavigationController alloc]initWithRootViewController:loginCon];
    navCon.navigationBar.tintColor = [UIColor lightGrayColor];
	UIWindow *mainWindow = [[UIApplication sharedApplication]keyWindow];
    UIViewController *controller = [self topViewController:mainWindow.rootViewController];
	[controller presentViewController:navCon animated:YES completion:nil];
}

+ (UIViewController *)topViewController:(UIViewController *)rootViewController
{
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

+(void)done:(NSError*)error{
    if ([Foursquare2 isAuthorized]) {
        [Foursquare2 setBaseURL:kBaseUrl];
        authorizeCallbackDelegate(YES,error);
    }else{
        authorizeCallbackDelegate(NO,error);
    }
    
}
#endif
@end
