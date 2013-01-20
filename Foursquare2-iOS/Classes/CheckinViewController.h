//
//  CheckinViewController.h
//  Foursquare2-iOS
//
//  Created by Constantine Fry on 1/21/13.
//
//

#import <UIKit/UIKit.h>

@interface CheckinViewController : UIViewController

@property(strong,nonatomic)NSDictionary* venue;
@property (strong, nonatomic) IBOutlet UILabel *venueName;
- (IBAction)checkin:(id)sender;



@end
