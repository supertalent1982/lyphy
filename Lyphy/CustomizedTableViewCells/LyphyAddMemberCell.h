//
//  LyphyFindFriendsCell.h
//  Lyphy
//
//  Created by Liang Xing on 26/1/14.
//  Copyright (c) 2014 LiangXing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AsyncImageView.h"

@class LyphyAddMemberCell;

@protocol LyphyAddMemberCellDelegate <NSObject>

- (void)addMember:(LyphyAddMemberCell *)cell;
- (void)deleteMember:(LyphyAddMemberCell *)cell;

@end

@interface LyphyAddMemberCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *lblName;
@property (strong, nonatomic) IBOutlet UIButton *addBtn;
@property (strong, nonatomic) id<LyphyAddMemberCellDelegate> delegate;

- (IBAction)addBtnTapped:(id)sender;
@end
