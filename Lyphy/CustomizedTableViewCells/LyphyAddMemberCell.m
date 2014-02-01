//
//  LyphyFindFriendsCell.m
//  Lyphy
//
//  Created by Liang Xing on 26/1/14.
//  Copyright (c) 2014 LiangXing. All rights reserved.
//

#import "LyphyAddMemberCell.h"

@implementation LyphyAddMemberCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)addBtnTapped:(id)sender {
    if ([self.addBtn isSelected]) {
        [self.addBtn setSelected:NO];
        if ([self.delegate respondsToSelector:@selector(deleteMember:)]) {
            [self.delegate deleteMember:self];
        }
    } else {
        [self.addBtn setSelected:YES];
        if ([self.delegate respondsToSelector:@selector(addMember:)]) {
            [self.delegate addMember:self];
        }
    }
}
@end
