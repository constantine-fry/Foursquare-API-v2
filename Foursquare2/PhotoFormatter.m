//
//  PhotoFormatter.m
//  Foursquare API
//
//  Created by Constantine Fry on 1/8/11.
//  Copyright 2011 Home. All rights reserved.
//

#import "PhotoFormatter.h"
#import "JSON.h"

@implementation PhotoFormatter
+ (NSString *)extension {
    return @"*";
}

+ (NSString *)mimeType {
    return @"multipart/form-data; boundary=0xKhTmLbOuNdArY";
}

+ (id)decode:(NSData *)data error:(NSError **)error {
    NSString *rawString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    // If we failed to decode the data using UTF8 attempt to use ASCII encoding.
    if(rawString == nil && ([data length] > 0)) {
        rawString = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    }
    
    NSError *parseError = nil;
    SBJSON *parser = [[SBJSON alloc] init];
    id results = [parser objectWithString:rawString error:&parseError];
    [parser release];
    [rawString release];
    
    if(parseError && !results) {  
        if(error != nil)      
            *error = parseError;
        return nil;
    }
    
    return results;
}

+ (NSString *)encode:(id)data error:(NSError **)error {
    return [data JSONRepresentation];
}


@end
