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
#import "LyphyAppDelegate.h"
#import "NSString+Utils.h"

#import <QuartzCore/QuartzCore.h>

@interface LyphyInboxViewController () <UITableViewDataSource, UITableViewDataSource, LyphySettingsViewControllerDelegate, NSFetchedResultsControllerDelegate>

@end

@implementation LyphyInboxViewController

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark NSFetchedResultsController
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (NSFetchedResultsController *)fetchedResultsController
{
	if (fetchedResultsController == nil)
	{
		NSManagedObjectContext *moc = [[LyphyAppDelegate sharedInstance] managedObjectContext_roster];
		
		NSEntityDescription *entity = [NSEntityDescription entityForName:@"XMPPUserCoreDataStorageObject"
		                                          inManagedObjectContext:moc];
		
		NSSortDescriptor *sd1 = [[NSSortDescriptor alloc] initWithKey:@"sectionNum" ascending:YES];
		NSSortDescriptor *sd2 = [[NSSortDescriptor alloc] initWithKey:@"displayName" ascending:YES];
		
		NSArray *sortDescriptors = [NSArray arrayWithObjects:sd1, sd2, nil];
		
		NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
		[fetchRequest setEntity:entity];
		[fetchRequest setSortDescriptors:sortDescriptors];
		[fetchRequest setFetchBatchSize:10];
		
		fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
		                                                               managedObjectContext:moc
		                                                                 sectionNameKeyPath:@"sectionNum"
		                                                                          cacheName:nil];
		[fetchedResultsController setDelegate:self];
		
		
		NSError *error = nil;
		if (![fetchedResultsController performFetch:&error])
		{
			NSLog(@"Error performing fetch: %@", error);
		}
        
	}
	
	return fetchedResultsController;
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
	[[self tableView] reloadData];
}

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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newMessageReceived:) name:@"newmessageReceived" object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - LyphySettingsViewController Delegate Methods
- (void)logout
{
    [[LyphyAppDelegate sharedInstance] disconnect];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark - UITableView Deleagate Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return [[[self fetchedResultsController] sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
	NSArray *sections = [[self fetchedResultsController] sections];
	
	if (sectionIndex < [sections count])
	{
		id <NSFetchedResultsSectionInfo> sectionInfo = [sections objectAtIndex:sectionIndex];
		return sectionInfo.numberOfObjects;
	}
	
	return 0;
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
    
    XMPPUserCoreDataStorageObject *user = [[self fetchedResultsController] objectAtIndexPath:indexPath];
    NSString *username = user.jid.user;
    [cell.lblGroupName setText:username];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    XMPPUserCoreDataStorageObject *user = [[self fetchedResultsController] objectAtIndexPath:indexPath];
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    LyphyPhotoUploadViewController *photoUploadViewController = [[LyphyPhotoUploadViewController alloc] initWithNibName:@"LyphyPhotoUploadViewController" bundle:nil];
    LyphyChatViewController *chatViewController = [[LyphyChatViewController alloc] initWithNibName:@"LyphyChatViewController" bundle:nil];
    chatViewController.xmppCoreData = user;
    
    SWRevealViewController *chattingRoomViewController = [[SWRevealViewController alloc] initWithRearViewController:photoUploadViewController frontViewController:chatViewController];
    chattingRoomViewController.delegate = photoUploadViewController;
    [self.navigationController pushViewController:chattingRoomViewController animated:YES];
}

- (IBAction)settingsBtnTapped:(id)sender {
    LyphySettingsViewController *settingsViewController = [[LyphySettingsViewController alloc] initWithNibName:@"LyphySettingsViewController" bundle:nil];
    [settingsViewController setDelegate:self];
    UINavigationController *settingsNavController = [[UINavigationController alloc] initWithRootViewController:settingsViewController];
    [settingsNavController setNavigationBarHidden:YES];
    [self presentViewController:settingsNavController animated:YES completion:nil];
}

- (IBAction)newLyphyBtnTapped:(id)sender {
}

#pragma mark - Chat delegates

- (void)newMessageReceived:(NSNotification *)note {
    NSMutableDictionary *messageContent = [note object];
	NSString *m = [messageContent objectForKey:@"msg"];
	[messageContent setObject:m forKey:@"msg"];
	[messageContent setObject:[NSString getCurrentTime] forKey:@"time"];
}
@end
