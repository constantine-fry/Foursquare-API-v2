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

@end

@implementation SettingsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self prepareViewForUser];
    self.title = @"Settings";
    // Do any additional setup after loading the view from its nib.
}

-(void)prepareViewForUser{
    [Foursquare2  getDetailForUser:@"self"
                          callback:^(BOOL success, id result){
                              if (success) {
                                  self.name.text =
                                  [NSString stringWithFormat:@"%@ %@",
                                  [result valueForKeyPath:@"response.user.firstName"],
                                   [result valueForKeyPath:@"response.user.lastName"]];
                              }
                          }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
