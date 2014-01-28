//
//  LyphyInboxViewController.h
//  Lyphy
//
//  Created by Liang Xing on 26/1/14.
//  Copyright (c) 2014 LiangXing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "LyphyInboxCell.h"

@interface LyphyInboxViewController : UIViewController {
    NSFetchedResultsController *fetchedResultsController;
}

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet LyphyInboxCell *cell;

- (IBAction)settingsBtnTapped:(id)sender;
- (IBAction)newLyphyBtnTapped:(id)sender;
@end
