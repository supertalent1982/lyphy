//
//  LyphyFindFriendsCell.h
//  Lyphy
//
//  Created by Liang Xing on 26/1/14.
//  Copyright (c) 2014 LiangXing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AsyncImageView.h"

@interface LyphyFindFriendsCell : UITableViewCell

@property (strong, nonatomic) IBOutlet AsyncImageView *imgPhoto;
@property (strong, nonatomic) IBOutlet UILabel *lblName;
@property (strong, nonatomic) IBOutlet UILabel *lblSubInfo;
@property (strong, nonatomic) IBOutlet UIButton *inviteBtn;

@end
