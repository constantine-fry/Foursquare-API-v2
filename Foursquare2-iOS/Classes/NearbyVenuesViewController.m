//
//  NearbyVenuesViewController.m
//  Foursquare2-iOS
//
//  Created by Constantine Fry on 1/20/13.
//
//

#import "NearbyVenuesViewController.h"
#import "Foursquare2.h"
#import "FSVenue.h"
#import "CheckinViewController.h"
#import "FSConverter.h"
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@interface NearbyVenuesViewController () <CLLocationManagerDelegate>
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) IBOutlet UIView *footer;

@property (strong, nonatomic) FSVenue *selected;
@property (strong, nonatomic) NSArray *nearbyVenues;
@end

@implementation NearbyVenuesViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Nearby";
    self.tableView.tableHeaderView = self.mapView;
    self.tableView.tableFooterView = self.footer;
    self.locationManager = [[CLLocationManager alloc]init];
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.locationManager.delegate = self;
    [self.locationManager startUpdatingLocation];
}

- (void)updateRightBarButtonStatus {
    self.navigationItem.rightBarButtonItem.enabled = [Foursquare2 isAuthorized];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self updateRightBarButtonStatus];
}

- (void)removeAllAnnotationExceptOfCurrentUser {
    NSMutableArray *annForRemove = [[NSMutableArray alloc] initWithArray:self.mapView.annotations];
    if ([self.mapView.annotations.lastObject isKindOfClass:[MKUserLocation class]]) {
        [annForRemove removeObject:self.mapView.annotations.lastObject];
    } else {
        for (id <MKAnnotation> annot_ in self.mapView.annotations) {
            if ([annot_ isKindOfClass:[MKUserLocation class]] ) {
                [annForRemove removeObject:annot_];
                break;
            }
        }
    }
    
    [self.mapView removeAnnotations:annForRemove];
}

- (void)proccessAnnotations {
    [self removeAllAnnotationExceptOfCurrentUser];
    [self.mapView addAnnotations:self.nearbyVenues];
}



- (void)getVenuesForLocation:(CLLocation *)location {
    
    [Foursquare2 venueSearchNearByLatitude:@(location.coordinate.latitude)
                                 longitude:@(location.coordinate.longitude)
                                     query:nil
                                     limit:nil
                                    intent:intentCheckin
                                    radius:@(500)
                                categoryId:nil
                                  callback:^(BOOL success, id result){
                                      if (success) {
                                          NSDictionary *dic = result;
                                          NSArray *venues = [dic valueForKeyPath:@"response.venues"];
                                          FSConverter *converter = [[FSConverter alloc]init];
                                          self.nearbyVenues = [converter convertToObjects:venues];
                                          [self.tableView reloadData];
                                          [self proccessAnnotations];
                                          
                                      }
                                  }];
}

- (void)setupMapForLocatoion:(CLLocation *)newLocation {
    MKCoordinateRegion region;
    MKCoordinateSpan span;
    span.latitudeDelta = 0.003;
    span.longitudeDelta = 0.003;
    CLLocationCoordinate2D location;
    location.latitude = newLocation.coordinate.latitude;
    location.longitude = newLocation.coordinate.longitude;
    region.span = span;
    region.center = location;
    [self.mapView setRegion:region animated:YES];
}

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation {
    [self.locationManager stopUpdatingLocation];
    [self getVenuesForLocation:newLocation];
    [self setupMapForLocatoion:newLocation];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.nearbyVenues.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.nearbyVenues.count) {
        return 1;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.textLabel.font = [UIFont boldSystemFontOfSize:12];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:12];
        cell.detailTextLabel.textColor = [UIColor lightGrayColor];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    cell.textLabel.text = [self.nearbyVenues[indexPath.row] name];
    FSVenue *venue = self.nearbyVenues[indexPath.row];
    if (venue.location.address) {
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@m, %@",
                                     venue.location.distance,
                                     venue.location.address];
    } else {
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@m",
                                     venue.location.distance];
    }

    return cell;
}



#pragma mark - Table view delegate

- (void)checkin {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    CheckinViewController *checkin = [storyboard instantiateViewControllerWithIdentifier:@"CheckinVC"];
    checkin.venue = self.selected;
    [self.navigationController pushViewController:checkin animated:YES];
}

- (void)userDidSelectVenue {
    if ([Foursquare2 isAuthorized]) {
        [self checkin];
	} else {
        [Foursquare2 authorizeWithCallback:^(BOOL success, id result) {
            if (success) {
				[Foursquare2  userGetDetail:@"self"
                                   callback:^(BOOL success, id result){
                                       if (success) {
                                           [self updateRightBarButtonStatus];
                                           [self checkin];
                                       }
                                   }];
			}
        }];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    self.selected = self.nearbyVenues[indexPath.row];
    [self userDidSelectVenue];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    if (annotation == mapView.userLocation)
        return nil;
    
    static NSString *s = @"ann";
    MKAnnotationView *pin = [mapView dequeueReusableAnnotationViewWithIdentifier:s];
    if (!pin) {
        pin = [[MKPinAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:s];
        pin.canShowCallout = YES;
        pin.image = [UIImage imageNamed:@"pin.png"];
        pin.calloutOffset = CGPointMake(0, 0);
        UIButton *button = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        [button addTarget:self
                   action:@selector(checkinButton) forControlEvents:UIControlEventTouchUpInside];
        pin.rightCalloutAccessoryView = button;
        
    }
    return pin;
}

- (void)checkinButton {
    self.selected = self.mapView.selectedAnnotations.lastObject;
    [self userDidSelectVenue];
}

@end
