//
//  LyphyNewGroupViewController.h
//  Lyphy
//
//  Created by Liang Xing on 30/1/14.
//  Copyright (c) 2014 LiangXing. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LyphyNewGroupViewController : UIViewController
@property (nonatomic, strong) NSMutableArray *arrMembers;
@property (nonatomic, strong) NSMutableArray *arrMemberButtons;
@property (strong, nonatomic) IBOutlet UIView *memberView;
@property (strong, nonatomic) IBOutlet UIButton *addMemberBtn;
@property (strong, nonatomic) IBOutlet UIView *separatorView;

- (IBAction)backBtnTapped:(id)sender;
- (IBAction)saveBtnTapped:(id)sender;
- (IBAction)addMemberBtnTapped:(id)sender;
@end
