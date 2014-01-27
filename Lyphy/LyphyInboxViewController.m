//
//  LyphyInboxViewController.m
//  Lyphy
//
//  Created by Liang Xing on 26/1/14.
//  Copyright (c) 2014 LiangXing. All rights reserved.
//

#import "LyphyInboxViewController.h"
#import "LyphySettingsViewController.h"
#import "SWRevealViewController.h"
#import "LyphyPhotoUploadViewController.h"
#import "LyphyChatViewController.h"

#import <QuartzCore/QuartzCore.h>

@interface LyphyInboxViewController () <UITableViewDataSource, UITableViewDataSource, LyphySettingsViewControllerDelegate>

@end

@implementation LyphyInboxViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

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

#pragma mark - LyphySettingsViewController Delegate Methods
- (void)logout
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark - UITableView Deleagate Methods
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 140;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LyphyInboxCell *cell = [tableView dequeueReusableCellWithIdentifier:@"InboxCell"];
    
    if ( cell == nil ){
        [[NSBundle mainBundle] loadNibNamed:@"LyphyInboxCell" owner:self options:nil];
        cell = self.cell;
    }
    
    cell.imvAvatar.layer.cornerRadius = 30;
    cell.imvAvatar.layer.masksToBounds = YES;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    LyphyPhotoUploadViewController *photoUploadViewController = [[LyphyPhotoUploadViewController alloc] initWithNibName:@"LyphyPhotoUploadViewController" bundle:nil];
    LyphyChatViewController *chatViewController = [[LyphyChatViewController alloc] initWithNibName:@"LyphyChatViewController" bundle:nil];
    
    SWRevealViewController *chattingRoomViewController = [[SWRevealViewController alloc] initWithRearViewController:photoUploadViewController frontViewController:chatViewController];
    chattingRoomViewController.delegate = photoUploadViewController;
    [self.navigationController pushViewController:chattingRoomViewController animated:YES];
}

- (IBAction)settingsBtnTapped:(id)sender {
    LyphySettingsViewController *settingsViewController = [[LyphySettingsViewController alloc] initWithNibName:@"LyphySettingsViewController" bundle:nil];
    [settingsViewController setDelegate:self];
    [self presentViewController:settingsViewController animated:YES completion:nil];
}

- (IBAction)newLyphyBtnTapped:(id)sender {
}
@end
