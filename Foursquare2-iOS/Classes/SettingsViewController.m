//
//  SettingsViewController.m
//  Foursquare2-iOS
//
//  Created by Constantine Fry on 1/21/13.
//
//

#import "SettingsViewController.h"
#import "Foursquare2.h"

@interface SettingsViewController ()
@property (strong, nonatomic) IBOutlet UILabel *name;
@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self prepareViewForUser];
    self.title = @"Settings";
}

- (void)prepareViewForUser {
    [Foursquare2  userGetDetail:@"self"
                       callback:^(BOOL success, id result){
                           if (success) {
                               self.name.text =
                               [NSString stringWithFormat:@"%@ %@",
                                [result valueForKeyPath:@"response.user.firstName"],
                                [result valueForKeyPath:@"response.user.lastName"]];
                           }
                       }];
}

- (void)viewDidUnload {
    [self setName:nil];
    [super viewDidUnload];
}

- (IBAction)logout:(id)sender {
    [Foursquare2 removeAccessToken];
    [self.navigationController popViewControllerAnimated:YES];
}

@end
