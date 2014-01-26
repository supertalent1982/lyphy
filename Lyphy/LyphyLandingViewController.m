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

@interface LyphyLandingViewController ()

@end

@implementation LyphyLandingViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
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
