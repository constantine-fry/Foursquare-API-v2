//
//  VenueAnnotation.m
//  Foursquare2-iOS
//
//  Created by Constantine Fry on 1/21/13.
//
//

#import "VenueAnnotation.h"

@implementation VenueAnnotation
-(void)setCoordinate:(CLLocationCoordinate2D)newCoordinate{
    _coordinate = newCoordinate;
}

-(CLLocationCoordinate2D)coordinate{
    return _coordinate;
}
@end
