//
//  LyphyNewGroupViewController.m
//  Lyphy
//
//  Created by Liang Xing on 30/1/14.
//  Copyright (c) 2014 LiangXing. All rights reserved.
//

#import "LyphyNewGroupViewController.h"
#import "LyphyAddMemberViewController.h"

#define memberCountInFirstRow 2
#define memberCountInRow 3

@interface LyphyNewGroupViewController () <LyphyAddMemberViewControllerDelegate>

@end

@implementation LyphyNewGroupViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.arrMembers = [NSMutableArray new];
        self.arrMemberButtons = [NSMutableArray new];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)backBtnTapped:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)saveBtnTapped:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)addMemberBtnTapped:(id)sender {
    LyphyAddMemberViewController *addMemberViewController = [[LyphyAddMemberViewController alloc] initWithNibName:@"LyphyAddMemberViewController" bundle:nil];
    addMemberViewController.delegate = self;
    addMemberViewController.arrMembers = self.arrMembers;
    for (NSString *member in self.arrMembers) {
        [addMemberViewController.arrEditingMembers addObject:member];
    }
    [self.navigationController pushViewController:addMemberViewController animated:YES];
}

- (NSInteger)rowIndexInMembersView:(NSInteger)index {
    if (index < memberCountInFirstRow) {
        return 0;
    }
    
    return (index - memberCountInFirstRow) / memberCountInRow + 1;
}

- (NSInteger)cellIndexInMembersView:(NSInteger)index {
    if (index < memberCountInFirstRow) {
        return index;
    }
    
    return (index - memberCountInFirstRow) % memberCountInRow;
}

- (void)reloadMembersView {
    
    NSInteger memberBtnWidth = 85, memberBtnHeight = 30;
    NSInteger firstMemberBtnStartXPos = 100, firstMemberBtnStartYPos = 8;
    NSInteger memberBtnStartXPos = 15;
    NSInteger memberBtnPadding = 10;
    
    NSInteger lines = 1;
    if (self.arrMembers.count > memberCountInFirstRow) {
        lines += (self.arrMembers.count - memberCountInFirstRow) / memberCountInRow;
        if ((self.arrMembers.count - memberCountInFirstRow) % memberCountInRow > 0) {
            lines++;
        }
    }
    
    [self.separatorView setFrame:CGRectMake(0,
                                            225 + (lines - 1) * (memberBtnHeight + memberBtnPadding),
                                            self.separatorView.frame.size.width,
                                            self.separatorView.frame.size.height)];
    [self.addMemberBtn setFrame:CGRectMake(286,
                                           11 + (lines - 1) * (memberBtnHeight + memberBtnPadding),
                                           self.addMemberBtn.frame.size.width,
                                           self.addMemberBtn.frame.size.height)];
    [self.memberView setFrame:CGRectMake(self.memberView.frame.origin.x,
                                         self.memberView.frame.origin.y,
                                         320,
                                         self.separatorView.frame.origin.y + 1)];
    
    for (UIButton *button in self.arrMemberButtons) {
        [button removeFromSuperview];
    }
    [self.arrMemberButtons removeAllObjects];
    
    for (NSInteger i = 0; i < self.arrMembers.count; i++) {
        NSInteger rowIndex = [self rowIndexInMembersView:i];
        NSInteger cellIndex = [self cellIndexInMembersView:i];
        UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        
        if (rowIndex == 0) {
            NSInteger xPos = firstMemberBtnStartXPos + (memberBtnWidth + memberBtnPadding) * cellIndex;
            NSInteger yPos = firstMemberBtnStartYPos;
            [button setFrame:CGRectMake(xPos, yPos, memberBtnWidth, memberBtnHeight)];
            
            [self.memberView addSubview:button];
            [self.arrMemberButtons addObject:button];
            
        } else {
            NSInteger xPos = memberBtnStartXPos + (memberBtnWidth + memberBtnPadding) * cellIndex;
            NSInteger yPos = firstMemberBtnStartYPos + (memberBtnHeight + memberBtnPadding) * rowIndex;
            [button setFrame:CGRectMake(xPos, yPos, memberBtnWidth, memberBtnHeight)];
            
            [self.memberView addSubview:button];
            [self.arrMemberButtons addObject:button];
        }
        
        [button setTitle:[self.arrMembers objectAtIndex:i] forState:UIControlStateNormal];
    }
}

#pragma mark - UITableView Deleagate Methods
- (void) membersEdited {
    [self reloadMembersView];
}
@end
