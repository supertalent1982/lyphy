//
//  LyphyAddMemberViewController.h
//  Lyphy
//
//  Created by Liang Xing on 1/2/14.
//  Copyright (c) 2014 LiangXing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "LyphyAddMemberCell.h"

@protocol LyphyAddMemberViewControllerDelegate <NSObject>

- (void) membersEdited;

@end

@interface LyphyAddMemberViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, NSFetchedResultsControllerDelegate, LyphyAddMemberCellDelegate, UIScrollViewDelegate> {
    NSFetchedResultsController *fetchedResultsController;
}

@property (strong, nonatomic) id<LyphyAddMemberViewControllerDelegate> delegate;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;
@property (nonatomic,strong) NSMutableArray *userSearchResult;
@property (nonatomic,strong) NSMutableArray *userData;
@property (nonatomic, strong) NSMutableArray *arrMembers;
@property (nonatomic, strong) NSMutableArray *arrEditingMembers;
@property (strong, nonatomic) IBOutlet LyphyAddMemberCell *cell;

- (IBAction)backBtnTapped:(id)sender;
- (IBAction)doneBtnTapped:(id)sender;

@end
