//
//  LyphyFindFriendsViewController.h
//  Lyphy
//
//  Created by Liang Xing on 28/1/14.
//  Copyright (c) 2014 LiangXing. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LyphyFindFriendsViewController : UIViewController
@property (strong, nonatomic) IBOutlet UIButton *findByLyphyBtn;
@property (strong, nonatomic) IBOutlet UIButton *findByPhoneBtn;

- (IBAction)findByLyphyTapped:(id)sender;
- (IBAction)findByPhoneTapped:(id)sender;
- (IBAction)backBtnTapped:(id)sender;
@end
