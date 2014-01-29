//
//  LyphyChatViewController.h
//  Lyphy
//
//  Created by Liang Xing on 26/1/14.
//  Copyright (c) 2014 LiangXing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LyphyAppDelegate.h"

@interface LyphyChatViewController : UIViewController <UITextViewDelegate, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate> {
    NSMutableArray	*messages;
}

@property (strong, nonatomic) IBOutlet UITextView *messageField;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIView *messageContainer;
@property (strong, nonatomic) IBOutlet UILabel *lblGroupName;
@property (nonatomic, assign) CGSize scrollViewSize;
@property (strong, nonatomic) XMPPUserCoreDataStorageObject *xmppCoreData;

- (IBAction)leftBtnTapped:(id)sender;
- (IBAction)rightBtnTapped:(id)sender;
- (IBAction)sendBtnTapped:(id)sender;

@end
