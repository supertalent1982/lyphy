//
//  LyphySyncPhoneViewController.h
//  Lyphy
//
//  Created by Liang Xing on 25/1/14.
//  Copyright (c) 2014 LiangXing. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LyphySyncPhoneViewController : UIViewController

@property (strong, nonatomic) IBOutlet UITextField *edtMobileNumber;
@property (strong, nonatomic) IBOutlet UIButton *syncPhoneBtn;

- (IBAction)textFieldChanged:(id)sender;
- (IBAction)nextBtnTapped:(id)sender;
- (IBAction)syncPhoneBtnTapped:(id)sender;

@end
