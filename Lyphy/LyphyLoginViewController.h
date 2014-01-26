//
//  LyphyLoginViewController.h
//  Lyphy
//
//  Created by Liang Xing on 26/1/14.
//  Copyright (c) 2014 LiangXing. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LyphyLoginViewController : UIViewController

@property (strong, nonatomic) IBOutlet UITextField *edtEmailAddress;
@property (strong, nonatomic) IBOutlet UITextField *edtNewPassword;
@property (strong, nonatomic) IBOutlet UIButton *nextBtn;

- (IBAction)nextBtnTapped:(id)sender;
- (IBAction)textFieldChanged:(id)sender;
- (IBAction)backBtnTapped:(id)sender;

@end
