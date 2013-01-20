//
//  VenueAnnotation.h
//  Foursquare2-iOS
//
//  Created by Constantine Fry on 1/21/13.
//
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@interface VenueAnnotation : NSObject<MKAnnotation>{
    CLLocationCoordinate2D _coordinate;
}
@property (nonatomic, copy) NSString *title;

@end
