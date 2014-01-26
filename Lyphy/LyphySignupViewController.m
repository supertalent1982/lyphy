//
//  LyphySignupViewController.m
//  Lyphy
//
//  Created by Liang Xing on 25/1/14.
//  Copyright (c) 2014 LiangXing. All rights reserved.
//

#import "LyphySignupViewController.h"
#import "LyphyProfileViewController.h"

@interface LyphySignupViewController () <UITextFieldDelegate>

@end

@implementation LyphySignupViewController

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

- (IBAction)nextBtnTapped:(id)sender {
    [self.edtNewPassword resignFirstResponder];
    [self.edtEmailAddress resignFirstResponder];
    
    LyphyProfileViewController *profileViewController = [[LyphyProfileViewController alloc] initWithNibName:@"LyphyProfileViewController" bundle:nil];
    [self.navigationController pushViewController:profileViewController animated:YES];
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
