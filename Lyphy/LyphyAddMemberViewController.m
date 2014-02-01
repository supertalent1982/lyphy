//
//  LyphyAddMemberViewController.m
//  Lyphy
//
//  Created by Liang Xing on 1/2/14.
//  Copyright (c) 2014 LiangXing. All rights reserved.
//

#import "LyphyAddMemberViewController.h"
#import "LyphyAppDelegate.h"
#import "LyphyAddMemberCell.h"

@interface LyphyAddMemberViewController ()

@end

@implementation LyphyAddMemberViewController
@synthesize searchBar;
@synthesize userSearchResult;

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
//		[fetchedResultsController setDelegate:self];
		
		
		NSError *error = nil;
		if (![fetchedResultsController performFetch:&error])
		{
			NSLog(@"Error performing fetch: %@", error);
		}
        
	}
	
	return fetchedResultsController;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.arrEditingMembers = [NSMutableArray new];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UITapGestureRecognizer *singleFingerTap =
    [[UITapGestureRecognizer alloc] initWithTarget:self.searchBar
                                            action:@selector(resignFirstResponder)];
    [self.view addGestureRecognizer:singleFingerTap];

    searchBar.text = @"";
    userSearchResult = [[NSMutableArray alloc]init];
    searchBar.backgroundColor=[UIColor clearColor];
    searchBar.backgroundImage = [UIImage new];
    [searchBar setTranslucent:YES];
    
    //remove background of searchbar
    for (UIView *subview in searchBar.subviews) {
        if ([subview isKindOfClass:NSClassFromString(@"UISearchBarBackground")]) {
            [subview removeFromSuperview];
            break;
        }
    }
    [self getUserData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)getUserData {
    NSArray *sections = [[self fetchedResultsController] sections];
    self.userData = [NSMutableArray new];
    self.userSearchResult = [NSMutableArray new];
    for (NSInteger sectionNum = 0; sectionNum < [sections count]; sectionNum++) {
        id <NSFetchedResultsSectionInfo> sectionInfo = [sections objectAtIndex:sectionNum];
        for (NSInteger rowNum =  0; rowNum < sectionInfo.numberOfObjects; rowNum++) {
            XMPPUserCoreDataStorageObject *user = [[sectionInfo objects] objectAtIndex:rowNum];
            [self.userData addObject:user.jid.user];
            [self.userSearchResult addObject:user.jid.user];
        }
    }
}

- (IBAction)backBtnTapped:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)doneBtnTapped:(id)sender {
    [self.arrMembers removeAllObjects];
    for (NSString *member in self.arrEditingMembers) {
        [self.arrMembers addObject:member];
    }
    
    if ([self.delegate respondsToSelector:@selector(membersEdited)]) {
        [self.delegate membersEdited];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITableView Deleagate Methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex {
    return [userSearchResult count];
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LyphyAddMemberCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AddMemberCell"];
    
    if ( cell == nil ){
        [[NSBundle mainBundle] loadNibNamed:@"LyphyAddMemberCell" owner:self options:nil];
        cell = self.cell;
    }
    
    cell.tag = indexPath.row;
    [cell setDelegate:self];
    
    NSString *userName = [self.userSearchResult objectAtIndex:indexPath.row];
    [cell.lblName setText:userName];
    [cell.addBtn setSelected:NO];
    for (NSString *member in self.arrEditingMembers) {
        if ([member isEqualToString:userName]) {
            [cell.addBtn setSelected:YES];
        }
    }
    
    return cell;
}

#pragma mark - LyphyAddMemberCell Delegate Methods
- (void)addMember:(LyphyAddMemberCell *)cell {
    NSString *member = [self.userSearchResult objectAtIndex:cell.tag];
    [self.arrEditingMembers addObject:member];
}

- (void)deleteMember:(LyphyAddMemberCell *)cell {
    NSString *member = [self.userSearchResult objectAtIndex:cell.tag];
    [self.arrEditingMembers removeObject:member];
}

#pragma mark - UISearchBar Delegate Method

- (void)searchBar:(UISearchBar *)_searchBar textDidChange:(NSString *)searchText {
    
    [self.userSearchResult removeAllObjects];
    if ([searchText isEqualToString:@""]) {
        for (NSString *username in self.userData)
             [self.userSearchResult addObject:username];
    } else {
        for (NSString *username in self.userData) {
            NSRange rangeValue = [username rangeOfString:searchText];
            if (rangeValue.location != NSNotFound) {
                [self.userSearchResult addObject:username];
            }
        }
    }
    
    [self.tableView reloadData];
}

#pragma mark - UIScrollView Delegate Methods

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.searchBar resignFirstResponder];
}

@end
