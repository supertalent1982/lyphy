//
//  LyphyInboxCell.h
//  Lyphy
//
//  Created by Liang Xing on 26/1/14.
//  Copyright (c) 2014 LiangXing. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LyphyInboxCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UIImageView *imvBg;
@property (strong, nonatomic) IBOutlet UIImageView *imvAvatar;
@property (strong, nonatomic) IBOutlet UILabel *lblGroupName;
@property (strong, nonatomic) IBOutlet UILabel *lblShortHistory;
@property (strong, nonatomic) IBOutlet UIView *badgeView;
@property (strong, nonatomic) IBOutlet UILabel *lblMessageCount;

@end
