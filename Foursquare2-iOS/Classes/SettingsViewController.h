//
//  SettingsViewController.h
//  Foursquare2-iOS
//
//  Created by Constantine Fry on 1/21/13.
//
//

#import <UIKit/UIKit.h>

@interface SettingsViewController : UIViewController
@property (strong, nonatomic) IBOutlet UILabel *name;


- (IBAction)logout:(id)sender;
@end
