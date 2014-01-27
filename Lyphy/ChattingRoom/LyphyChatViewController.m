//
//  LyphyChatViewController.m
//  Lyphy
//
//  Created by Liang Xing on 26/1/14.
//  Copyright (c) 2014 LiangXing. All rights reserved.
//

#import "LyphyChatViewController.h"
#import "SWRevealViewController.h"
#import "LyphyMemberManageViewController.h"

@interface LyphyChatViewController ()

@end

@implementation LyphyChatViewController

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

- (IBAction)leftBtnTapped:(id)sender {
    [self.revealViewController revealToggle:sender];
}

- (IBAction)rightBtnTapped:(id)sender {
    LyphyMemberManageViewController *memberManageViewController = [[LyphyMemberManageViewController alloc] initWithNibName:@"LyphyMemberManageViewController" bundle:nil];
    [self presentViewController:memberManageViewController animated:YES completion:nil];
}
@end
