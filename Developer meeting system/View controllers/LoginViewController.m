//
//  LoginViewController.m
//  Developer meeting system
//
//  Created by Ste Prescott on 04/12/2014.
//  Copyright (c) 2014 Ste Prescott. All rights reserved.
//

#import "LoginViewController.h"
#import "WebServiceClient.h"
#import "ContextManager.h"

@interface LoginViewController ()
@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
- (IBAction)loginButtonWasTapped:(id)sender;

@end

@implementation LoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.usernameTextField.text = @"HostUser";
    self.passwordTextField.text = @"Password";
}

- (IBAction)loginButtonWasTapped:(id)sender
{
    [SVProgressHUD showWithStatus:@"Logging in" maskType:SVProgressHUDMaskTypeBlack];
    
    [[WebServiceClient sharedInstance] asyncLoginUsername:self.usernameTextField.text
                                                 password:self.passwordTextField.text
                                                  success:^(NSDictionary *JSON) {
                                                      [SVProgressHUD showWithStatus:@"Synchronizing data" maskType:SVProgressHUDMaskTypeBlack];
                                                      
                                                      NSError *synchronizeError;
                                                      [WebServiceClient synchronizeWithError:&synchronizeError];
                                                      
                                                      if(synchronizeError)
                                                      {
                                                          [SVProgressHUD showErrorWithStatus:synchronizeError.userInfo[webServiceClientErrorMessage] maskType:SVProgressHUDMaskTypeBlack];
                                                      }
                                                      else
                                                      {
                                                          [SVProgressHUD showSuccessWithStatus:@"Synchronized" maskType:SVProgressHUDMaskTypeBlack];
                                                          [self dismissViewControllerAnimated:YES completion:nil];
                                                      }
                                                  }
                                                  failure:^(NSError *error) {
                                                      [SVProgressHUD showErrorWithStatus:error.userInfo[webServiceClientErrorMessage] maskType:SVProgressHUDMaskTypeBlack];
                                                  }];
}

@end
