//
//  LyphyFindFriendsByLyphyViewController.m
//  Lyphy
//
//  Created by Liang Xing on 28/1/14.
//  Copyright (c) 2014 LiangXing. All rights reserved.
//

#import "LyphyFindFriendsByLyphyViewController.h"
#import "LyphyNetworkClient.h"
#import "LyphyFindFriendsCell.h"
#import "LyphyAppDelegate.h"


@interface LyphyFindFriendsByLyphyViewController ()

@end

@implementation LyphyFindFriendsByLyphyViewController
@synthesize searchBar;
@synthesize userSearchResult;

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
}

- (void)viewWillAppear:(BOOL)animated {
//    searchBar.text = @"";
//    userSearchResult = [[NSMutableArray alloc]init];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)backBtnTapped:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UISearchBar Delegate Method

-(void)searchBarSearchButtonClicked:(UISearchBar *)_searchBar {
    [_searchBar resignFirstResponder];
    
    if ([searchBar.text isEqualToString:@""])
    {
        UIAlertView* mes=[[UIAlertView alloc] initWithTitle:@"Warning"
                                                    message:@"Please enter search name." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        
        [mes show];
        return;
    }
    
    userSearchResult = [[LyphyNetworkClient sharedInstance] searchFriendsWithSearchString:searchBar.text];

    [self.tableView reloadData];
}

#pragma mark - UITableView Delegate Method

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [userSearchResult count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LyphyFindFriendsCell *cell = (LyphyFindFriendsCell *)[tableView dequeueReusableCellWithIdentifier:@"FindFriendsCell"];
    if (cell == Nil) {
        [[NSBundle mainBundle] loadNibNamed:@"LyphyFindFriendsCell" owner:self options:nil];
        cell = self.cell;
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    NSDictionary *userDict = [userSearchResult objectAtIndex:indexPath.row];
    [cell.lblName setText:[userDict objectForKey:@"name"]];
    
    [cell.imgPhoto setImage:nil];
    CGRect lblNameFrame = cell.lblName.frame;
    lblNameFrame.origin.y = 15;
    
    NSNumber *isContact = [userDict objectForKey:@"contact"];
    if (isContact != nil && [isContact boolValue] == YES)
    {
        [cell.imgPhoto setImage:[userDict objectForKey:@"image"]];
        NSString *phoneNumber = [userDict objectForKey:@"phonenumber"];
        NSString *emailAddres = [userDict objectForKey:@"email"];
        if (phoneNumber && ![phoneNumber isEqualToString:@""]) {
            [cell.lblSubInfo setText:phoneNumber];
        } else {
            [cell.lblSubInfo setText:emailAddres];
        }
    } else {
        NSString *photoName = [userDict objectForKey:@"photo"];
        NSLog(@"photoName:%@", photoName);
        if (photoName != nil && ![photoName isEqualToString:@""])
        {
            NSString *photoURL = [NSString stringWithFormat:@"http://%@/ChatService/uploads/%@", LYPHY_SERVER_NAME, photoName];
            [cell.imgPhoto loadImageFromURL:[NSURL URLWithString:photoURL]];
        }
        
        lblNameFrame.origin.y = 22;
        [cell.lblSubInfo setText:@""];
    }
    
    [cell.lblName setFrame:lblNameFrame];
    if (cell.imgPhoto.image == nil) {
        [cell.imgPhoto setImage:[UIImage imageNamed:@"avatar_unknown.png"]];
    }
    
    [cell.inviteBtn setTag:indexPath.row];
    [cell.inviteBtn addTarget:self action:@selector(onAddFriend:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}

- (void)onAddFriend:(id)sender {
    UIButton *button = (UIButton*)sender;
    NSDictionary *user = [userSearchResult objectAtIndex: button.tag];
    NSString *name = [user objectForKey:@"name"];
    NSString *phoneNumber = [user objectForKey:@"phonenumber"];
    NSNumber *isContact = [user objectForKey:@"contact"];
    
    if (isContact != nil && [isContact boolValue] == YES)
    {
        if (phoneNumber != nil && ![phoneNumber isEqualToString:@""]) {
            if ([MFMessageComposeViewController canSendText]) {
                /* __autoreleasing is used here to ensure that this object
                 * is released as soon as there are no more strong references
                 * to it (since in ARC we can no longer explicitly release
                 * an object) */
                NSArray *toRecipents = [NSArray arrayWithObject:phoneNumber];
                MFMessageComposeViewController* __autoreleasing messageController =
                [[MFMessageComposeViewController alloc] init];
                messageController.messageComposeDelegate = self;
                [messageController setBody:[NSString stringWithFormat:@"Hello %@\n Please contact me on Lyphy http://%@", name, LYPHY_SERVER_NAME]];
                [messageController setRecipients:toRecipents];
                
                if (messageController) {
                    [self presentViewController:messageController animated:YES completion:nil];
                }
            }
            return;
        }
        if ([MFMailComposeViewController canSendMail]) {
            /* __autoreleasing is used here to ensure that this object
             * is released as soon as there are no more strong references
             * to it (since in ARC we can no longer explicitly release
             * an object) */
            NSString *emailAddress = [user objectForKey:@"email"];
            NSArray *toRecipents = [NSArray arrayWithObject:(emailAddress ? emailAddress:@"")];
            MFMailComposeViewController* __autoreleasing mailController =
            [[MFMailComposeViewController alloc] init];
            mailController.mailComposeDelegate = self;
            [mailController setSubject:@"Invite a friend"];
            [mailController setMessageBody:[NSString stringWithFormat:@"Hello %@\n Please contact me on Lyphy http://%@", name, LYPHY_SERVER_NAME] isHTML:NO];
            [mailController setToRecipients:toRecipents];
            
            if (mailController) {
                [self presentViewController:mailController animated:YES completion:nil];
            }
        }
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Send a contact request to" message:name delegate:self cancelButtonTitle:@"Yes" otherButtonTitles:@"No", nil];
        alert.tag = button.tag;
        [alert show];
    }
}

#pragma mark MFMailComposer
/*
 *  This is a delegate method of MFMailComposeViewController. It is fired
 *  when the mail controller finishes with the email.
 *  Note that the simulator will not actually send the email, but will
 *  respond here with a successful result.
 */
- (void) mailComposeController:(MFMailComposeViewController *)controller
           didFinishWithResult:(MFMailComposeResult)result
                         error:(NSError *)error {
    // check that the mail was sent successfully:
    if (result == MFMailComposeResultSent) {
        NSLog(@"Mail Sent");
    } else {
        // log out the error:
        NSLog(@"%@", error.description);
    }
    // regardless, dismiss the mail controller:
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark MFMailComposer
/*
 *  This is a delegate method of MessageComposeViewController. It is fired
 *  when the mail controller finishes with the email.
 *  Note that the simulator will not actually send the sms, but will
 *  respond here with a successful result.
 */
- (void) messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
    // check that the mail was sent successfully:
    if (result == MessageComposeResultSent) {
        NSLog(@"Mail Sent");
    } else {
        // log out the error:
        NSLog(@"Failed");
    }
    // regardless, dismiss the mail controller:
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        //add
        NSDictionary *user = [userSearchResult objectAtIndex:alertView.tag];
        NSString *name = [user objectForKey:@"name"];
        
        XMPPJID *jid = [XMPPJID jidWithString:[NSString stringWithFormat:@"%@@%@",name, LYPHY_XMPP_SERVER_NAME]];
        [[LyphyAppDelegate sharedInstance].xmppRoster addUser:jid
                                                 withNickname:name];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Invite request sent" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }
}

@end
