//
//  CheckinViewController.m
//  Foursquare2-iOS
//
//  Created by Constantine Fry on 1/21/13.
//
//

#import "CheckinViewController.h"
#import "Foursquare2.h"
#import "FSVenue.h"

@interface CheckinViewController ()

@end

@implementation CheckinViewController


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.title = @"Checkin";
    self.venueName.text = self.venue.name;
}

- (void)viewDidUnload {
    [self setVenueName:nil];
    [super viewDidUnload];
}
- (IBAction)checkin:(id)sender {
    [Foursquare2  createCheckinAtVenue:self.venue.venueId
                                 venue:nil
                                 shout:@"Testing"
                             broadcast:broadcastPublic
                              latitude:nil
                             longitude:nil
                            accuracyLL:nil
                              altitude:nil
                           accuracyAlt:nil
                              callback:^(BOOL success, id result){
                                  if (success) {
                                      UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Checkin"
                                                                                     message:@"Success"
                                                                                    delegate:self
                                                                           cancelButtonTitle:@"хорошо" otherButtonTitles:nil];
                                      [alert show];
                                  }
                              }];

    
}
@end
