//
//  LyphyProfileViewController.h
//  Lyphy
//
//  Created by Liang Xing on 25/1/14.
//  Copyright (c) 2014 LiangXing. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LyphyProfileViewController : UIViewController

@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIImageView *imvPhoto;
@property (strong, nonatomic) IBOutlet UITextField *edtFullName;
@property (strong, nonatomic) IBOutlet UITextField *edtLyphyID;

- (IBAction)backBtnTapped:(id)sender;
- (IBAction)photoBtnTapped:(id)sender;
- (IBAction)saveBtnTapped:(id)sender;

@end
