//
//  HRRequest+PhotoExt.m
//  Foursquare API
//
//  Created by Constantine Fry on 1/8/11.
//  Copyright 2011 Home. All rights reserved.
//

#import "HRRequest+PhotoExt.h"
#import "HRFormatJSON.h"
#import "HRFormatXML.h"
#import "PhotoFormatter.h"

@implementation HRRequestOperation(PhotoFormatter)
- (id)formatterFromFormat {
    NSNumber *format = [[self options] objectForKey:kHRClassAttributesFormatKey];
    id theFormatter = nil;
    switch([format intValue]) {
        case HRDataFormatJSON:
            theFormatter = [HRFormatJSON class];
			break;
        case HRDataFormatXML:
            theFormatter = [HRFormatXML class];
			break;
        default:
            theFormatter = [PhotoFormatter class];
			break;   
    }
    
    NSString *errorMessage = [NSString stringWithFormat:@"Invalid Formatter %@", NSStringFromClass(theFormatter)];
    NSAssert([theFormatter conformsToProtocol:@protocol(HRFormatterProtocol)], errorMessage); 
    
    return theFormatter;
}
@end
