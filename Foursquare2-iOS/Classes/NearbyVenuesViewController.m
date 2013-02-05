//
//  NearbyVenuesViewController.m
//  Foursquare2-iOS
//
//  Created by Constantine Fry on 1/20/13.
//
//

#import "NearbyVenuesViewController.h"
#import "Foursquare2.h"
#import "VenueAnnotation.h"
#import "CheckinViewController.h"
#import "SettingsViewController.h"


@interface NearbyVenuesViewController ()

@end

@implementation NearbyVenuesViewController



- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Nearby";
    self.tableView.tableHeaderView = self.mapView;
    self.tableView.tableFooterView = self.footer;
    _locationManager = [[CLLocationManager alloc]init];
    _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    _locationManager.delegate = self;
    [_locationManager startUpdatingLocation];
}

-(void)addRightButton{
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"Settings" style:UIBarButtonItemStyleBordered target:self action:@selector(settings)];
}

-(void)settings{
    SettingsViewController *settings = [[SettingsViewController alloc]init];
    [self.navigationController pushViewController:settings animated:YES];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if ([Foursquare2 isAuthorized] == YES) {
        [self addRightButton];
    }else{
        self.navigationItem.rightBarButtonItem = nil;
    }
}

-(void)proccessAnnotations{
    NSMutableArray *annotations = [NSMutableArray arrayWithCapacity:self.nearbyVenues.count];
    for (NSDictionary *v  in self.nearbyVenues) {
        VenueAnnotation *ann = [[VenueAnnotation alloc]init];
        ann.title = v[@"name"];
        [ann setCoordinate:CLLocationCoordinate2DMake([v[@"location"][@"lat"] doubleValue],
                                                      [v[@"location"][@"lng"] doubleValue])];
        [annotations addObject:ann];
    }
    [self.mapView addAnnotations:annotations];
    
}

-(void)getVenuesForLocation:(CLLocation*)location{
    [Foursquare2 searchVenuesNearByLatitude:@(location.coordinate.latitude)
								  longitude:@(location.coordinate.longitude)
								 accuracyLL:nil
								   altitude:nil
								accuracyAlt:nil
									  query:nil
									  limit:@(10)
									 intent:intentCheckin
                                     radius:@(500)
								   callback:^(BOOL success, id result){
									   if (success) {
										   NSDictionary *dic = result;
										   NSArray* venues = [dic valueForKeyPath:@"response.venues"];
                                           self.nearbyVenues = venues;
                                           [self.tableView insertSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationTop];
                                           [self proccessAnnotations];

									   }
								   }];
}

-(void)setupMapForLocatoion:(CLLocation*)newLocation{
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
           fromLocation:(CLLocation *)oldLocation{
    [_locationManager stopUpdatingLocation];
    [self getVenuesForLocation:newLocation];
    [self setupMapForLocatoion:newLocation];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.nearbyVenues.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (self.nearbyVenues.count) {
        return 1;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.textLabel.font = [UIFont boldSystemFontOfSize:12];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:12];
        cell.detailTextLabel.textColor = [UIColor lightGrayColor];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    cell.textLabel.text = self.nearbyVenues[indexPath.row][@"name"];
    cell.detailTextLabel.text = self.nearbyVenues[indexPath.row][@"location"][@"address"];
    return cell;
}



#pragma mark - Table view delegate

-(void)checkin{
    CheckinViewController *checkin = [[CheckinViewController alloc]init];
    checkin.venue = self.selected;
    [self.navigationController pushViewController:checkin animated:YES];
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    self.selected = self.nearbyVenues[indexPath.row];
    if ([Foursquare2 isAuthorized]) {
        [self checkin];
	}else{
        [Foursquare2 authorizeWithCallback:^(BOOL success, id result) {
            if (success) {
				[Foursquare2  getDetailForUser:@"self"
									  callback:^(BOOL success, id result){
										  if (success) {
                                              [self addRightButton];
											  [self checkin];
										  }
									  }];
			}
        }];
    }
}

- (void)viewDidUnload {
    [self setUsernameLabel:nil];
    [self setLogoutButton:nil];
    [self setFooter:nil];
    [super viewDidUnload];
}


@end
