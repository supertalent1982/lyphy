//
//  LyphyLoginViewController.m
//  Lyphy
//
//  Created by Liang Xing on 26/1/14.
//  Copyright (c) 2014 LiangXing. All rights reserved.
//

#import "LyphyLoginViewController.h"
#import "LyphyInboxViewController.h"

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

- (IBAction)nextBtnTapped:(id)sender {
    [self.edtNewPassword resignFirstResponder];
    [self.edtEmailAddress resignFirstResponder];
    
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
