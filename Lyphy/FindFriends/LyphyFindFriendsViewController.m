//
//  LyphyFindFriendsViewController.m
//  Lyphy
//
//  Created by Liang Xing on 28/1/14.
//  Copyright (c) 2014 LiangXing. All rights reserved.
//

#import "LyphyFindFriendsViewController.h"
#import "LyphyFindFriendsByLyphyViewController.h"

@interface LyphyFindFriendsViewController ()

@end

@implementation LyphyFindFriendsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
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

- (IBAction)findByLyphyTapped:(id)sender {
    LyphyFindFriendsByLyphyViewController *findFriendsByLyphyController = [[LyphyFindFriendsByLyphyViewController alloc] initWithNibName:@"LyphyFindFriendsByLyphyViewController" bundle:nil];
    [self.navigationController pushViewController:findFriendsByLyphyController animated:YES];
}

- (IBAction)findByPhoneTapped:(id)sender {
}

- (IBAction)backBtnTapped:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
@end
