//
//  LyphyLoginViewController.m
//  Lyphy
//
//  Created by Liang Xing on 26/1/14.
//  Copyright (c) 2014 LiangXing. All rights reserved.
//

#import "LyphyLoginViewController.h"
#import "LyphyInboxViewController.h"
#import "LyphySettings.h"
#import "LyphyAppDelegate.h"
#import "LyphyNetworkClient.h"

@interface LyphyLoginViewController () <UITextFieldDelegate>

@end

@implementation LyphyLoginViewController

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
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)backBtnTapped:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

// login btn
- (IBAction)nextBtnTapped:(id)sender {
    [self.edtNewPassword resignFirstResponder];
    [self.edtEmailAddress resignFirstResponder];
    
    [[LyphySettings sharedInstance] setUserName:self.edtEmailAddress.text];
    [[LyphySettings sharedInstance] setPassword:self.edtNewPassword.text];

    [[LyphyAppDelegate sharedInstance].loadingView.titleLabel setText:@"Logging in..."];
    [UIView animateWithDuration:0.3
					 animations:^{
						 [[LyphyAppDelegate sharedInstance].loadingView setAlpha:1];
					 }];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        LoginStatus loginStatus = [[LyphyNetworkClient sharedInstance]
                               loginWithUsername:[LyphySettings sharedInstance].userName
                               password:[LyphySettings sharedInstance].password];
        NSNumber *numStatus = [NSNumber numberWithInt:loginStatus];
        
        [self performSelectorOnMainThread:@selector(login:) withObject:numStatus waitUntilDone:NO];
    });
}

- (void)login:(id)sender {
    LoginStatus loginStatus = [(NSNumber *)sender integerValue];
    
    [[LyphyAppDelegate sharedInstance].loadingView setAlpha:0];
    
    if (loginStatus == LOGIN_FAIL) {
        UIAlertView* mes=[[UIAlertView alloc] initWithTitle:@"Warning"
                                                    message:@"This username or password is invalid." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        
        [mes show];
        return;
    } else if (loginStatus == LOGIN_NETWORKCONNECTION_ERROR) {
        UIAlertView* mes=[[UIAlertView alloc] initWithTitle:@"Warning"
                                                    message:@"The server is not running." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        
        [mes show];
        return;
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%@@%@", [LyphySettings sharedInstance].userFullName, LYPHY_XMPP_SERVER_NAME] forKey:@"userID"];
    [[NSUserDefaults standardUserDefaults] setObject:[LyphySettings sharedInstance].password forKey:@"password"];
    
    // xmpp connect
    if (![[LyphyAppDelegate sharedInstance] connect]) {
        UIAlertView* mes=[[UIAlertView alloc] initWithTitle:@"Warning"
                                                    message:@"The server is not running." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        
        [mes show];
        return;
    }
    
    LyphyInboxViewController *inboxViewController = [[LyphyInboxViewController alloc] initWithNibName:@"LyphyInboxViewController" bundle:nil];
    [self.navigationController pushViewController:inboxViewController animated:YES];
}

- (IBAction)textFieldChanged:(id)sender {
    if ([self.edtEmailAddress.text isEqual:@""] || [self.edtNewPassword.text isEqual:@""]) {
        [self.nextBtn setEnabled:NO];
    } else {
        [self.nextBtn setEnabled:YES];
    }
}

#pragma mark - UITextField Delegate Method
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.edtEmailAddress)
        [self.edtNewPassword becomeFirstResponder];
    else if (textField == self.edtNewPassword)
        [self.edtNewPassword resignFirstResponder];
    
    return YES;
}

@end
