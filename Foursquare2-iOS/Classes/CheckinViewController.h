//
//  CheckinViewController.h
//  Foursquare2-iOS
//
//  Created by Constantine Fry on 1/21/13.
//
//

#import <UIKit/UIKit.h>
@class FSVenue;
@interface CheckinViewController : UIViewController

@property(strong,nonatomic)FSVenue* venue;
@property (strong, nonatomic) IBOutlet UILabel *venueName;
- (IBAction)checkin:(id)sender;



@end
