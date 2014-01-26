//
//  LyphySettingsViewController.h
//  Lyphy
//
//  Created by Liang Xing on 26/1/14.
//  Copyright (c) 2014 LiangXing. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LyphySettingsViewControllerDelegate <NSObject>

- (void)logout;

@end

@interface LyphySettingsViewController : UIViewController
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIView *contentView;
@property (strong, nonatomic) IBOutlet UIButton *findFriendsBtn;
@property (strong, nonatomic) id<LyphySettingsViewControllerDelegate> delegate;

- (IBAction)backBtnTapped:(id)sender;
- (IBAction)logoutBtnTapped:(id)sender;
- (IBAction)editProfileBtnTapped:(id)sender;
- (IBAction)findFriendsBtnTapped:(id)sender;
@end
