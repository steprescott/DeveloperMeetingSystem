//
//  LoginViewController.m
//  Developer meeting system
//
//  Created by Ste Prescott on 04/12/2014.
//  Copyright (c) 2014 Ste Prescott. All rights reserved.
//

#import "LoginViewController.h"
#import "WebServiceClient.h"

@interface LoginViewController ()
@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
- (IBAction)loginButtonWasTapped:(id)sender;

@end

@implementation LoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.usernameTextField.text = @"GuestUser1";
    self.passwordTextField.text = @"Password";
}

- (IBAction)loginButtonWasTapped:(id)sender
{
    [[WebServiceClient sharedInstance] loginWithUsername:self.usernameTextField.text
                                                password:self.passwordTextField.text
                                                 success:^(NSDictionary *JSON) {
                                                     NSLog(@"%s JSON %@", __PRETTY_FUNCTION__, JSON);
                                                     [self dismissViewControllerAnimated:YES completion:nil];
                                                 }
                                                 failure:^(NSError *error) {
                                                     NSLog(@"%s Error %@", __PRETTY_FUNCTION__, error.localizedDescription);
                                                 }];
}

@end
