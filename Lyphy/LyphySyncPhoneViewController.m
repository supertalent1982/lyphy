//
//  LyphySyncPhoneViewController.m
//  Lyphy
//
//  Created by Liang Xing on 25/1/14.
//  Copyright (c) 2014 LiangXing. All rights reserved.
//

#import "LyphySyncPhoneViewController.h"

@interface LyphySyncPhoneViewController () <UITextFieldDelegate>

@end

@implementation LyphySyncPhoneViewController

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
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)textFieldChanged:(id)sender {
    if ([self.edtMobileNumber.text isEqual:@""]) {
        [self.syncPhoneBtn setEnabled:NO];
    } else {
        [self.syncPhoneBtn setEnabled:YES];
    }
}

- (IBAction)nextBtnTapped:(id)sender {
}

- (IBAction)syncPhoneBtnTapped:(id)sender {
}

#pragma mark - UITextField Delegate Method
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    
    return YES;
}

@end
