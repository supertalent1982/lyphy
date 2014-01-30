//
//  LyphyLandingViewController.m
//  Lyphy
//
//  Created by Liang Xing on 25/1/14.
//  Copyright (c) 2014 LiangXing. All rights reserved.
//

#import "LyphyLandingViewController.h"
#import "LyphySignupViewController.h"
#import "LyphyLoginViewController.h"
#import "LyphyInboxViewController.h"
#import "LyphySettings.h"
#import "LyphyNetworkClient.h"
#import "LyphyAppDelegate.h"

@interface LyphyLandingViewController ()

@end

@implementation LyphyLandingViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    NSString *userID = [[NSUserDefaults standardUserDefaults] objectForKey:@"userID"];
	if (userID && ![userID isEqualToString:@""]) {
        userID = [userID stringByReplacingOccurrencesOfString:@"@ps262296.dreamhostps.com" withString:@""];
        NSString *password = [[NSUserDefaults standardUserDefaults] objectForKey:@"password"];
        [[LyphySettings sharedInstance] setUserName:userID];
        [[LyphySettings sharedInstance] setPassword:password];
        [[LyphySettings sharedInstance] setPhotoUrl:[NSString stringWithFormat:@"http://%@/ChatService/uploads/%@.jpg", LYPHY_SERVER_NAME, [userID lowercaseString]]];
    
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
    
    NSLog(@"userID:%@:%@", [NSString stringWithFormat:@"%@@%@", [LyphySettings sharedInstance].userName, LYPHY_XMPP_SERVER_NAME], [LyphySettings sharedInstance].password);
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%@@%@", [LyphySettings sharedInstance].userName, LYPHY_XMPP_SERVER_NAME] forKey:@"userID"];
    [[NSUserDefaults standardUserDefaults] setObject:[LyphySettings sharedInstance].password forKey:@"password"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)signupBtnTapped:(id)sender {
    LyphySignupViewController *signupViewController = [[LyphySignupViewController alloc] initWithNibName:@"LyphySignupViewController" bundle:nil];
    [self.navigationController pushViewController:signupViewController animated:YES];
}

- (IBAction)loginBtnTapped:(id)sender {
    LyphyLoginViewController *loginViewController = [[LyphyLoginViewController alloc] initWithNibName:@"LyphyLoginViewController" bundle:nil];
    [self.navigationController pushViewController:loginViewController animated:YES];
}

@end
