//
//  LyphyFindFriendsByLyphyViewController.h
//  Lyphy
//
//  Created by Liang Xing on 28/1/14.
//  Copyright (c) 2014 LiangXing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LyphyFindFriendsCell.h"
#import <MessageUI/MessageUI.h>

@interface LyphyFindFriendsByLyphyViewController : UIViewController <UISearchBarDelegate, MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate>
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;
@property (nonatomic,strong) NSMutableArray *userSearchResult;
@property (nonatomic,strong) NSMutableArray *contactSearchResult;
@property (strong, nonatomic) IBOutlet LyphyFindFriendsCell *cell;

- (IBAction)backBtnTapped:(id)sender;
@end
