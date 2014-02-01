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
#import "LyphySettings.h"
#import "LyphyNetworkClient.h"
#import "NSString+Utils.h"
#import "SMMessageViewTableCell.h"

@interface LyphyChatViewController ()

@end

@implementation LyphyChatViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        messages = [[NSMutableArray alloc ] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self registerForKeyboardNotifications];
    
    
    UITapGestureRecognizer *singleFingerTap =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(handleSingleTap:)];
    [self.view addGestureRecognizer:singleFingerTap];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newMessageReceived:) name:@"newmessageReceived" object:nil];
    
    [self.lblGroupName setText:self.xmppCoreData.jid.user];
    
    [[LyphyAppDelegate sharedInstance].loadingView.titleLabel setText:@"Downloading chatting history..."];
    [UIView animateWithDuration:0.3
					 animations:^{
						 [[LyphyAppDelegate sharedInstance].loadingView setAlpha:1];
					 }];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableArray *chatHistoryArray = [[LyphyNetworkClient sharedInstance] getChatHistoryWithSender:[LyphySettings sharedInstance].userName receiver:self.xmppCoreData.jid.user];
        [self performSelectorOnMainThread:@selector(addChatHistory:) withObject:chatHistoryArray waitUntilDone:NO];
    });
}

- (void)addChatHistory:(id)sender {
    NSMutableArray *chatHistoryArray = (NSMutableArray *)sender;
    
    [[LyphyAppDelegate sharedInstance].loadingView setAlpha:0];
    if (chatHistoryArray.count > 0) {
        int num_rows = [chatHistoryArray count];
        for (int i = 0; i < num_rows; i++) {
            [messages addObject:[chatHistoryArray objectAtIndex:i]];
        }
        
        [self.tableView reloadData];
        
        if (messages.count > 0) {
            NSIndexPath *topIndexPath = [NSIndexPath indexPathForRow:messages.count-1
                                                       inSection:0];
            [self.tableView scrollToRowAtIndexPath:topIndexPath
                          atScrollPosition:UITableViewScrollPositionMiddle
                                  animated:YES];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShown:)
                                                 name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    
}

- (IBAction)leftBtnTapped:(id)sender {
    [self.messageField resignFirstResponder];
    [self.revealViewController revealToggle:sender];
}

- (IBAction)rightBtnTapped:(id)sender {
    LyphyMemberManageViewController *memberManageViewController = [[LyphyMemberManageViewController alloc] initWithNibName:@"LyphyMemberManageViewController" bundle:nil];
    [self presentViewController:memberManageViewController animated:YES completion:nil];
}

- (IBAction)sendBtnTapped:(id)sender {
    NSString *userToSend = self.xmppCoreData.jidStr;
    if (userToSend && ![userToSend isEqualToString:@""]){
        NSString *messageStr = _messageField.text;
        
        if (messageStr == nil ||
            [[messageStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] == 0)
        {
            return;
        }
        
        if([messageStr length] > 0) {
            NSString *chatWithUser = userToSend;
            
            // send
            
            //for (NSString *chatWithUser in [AppDelegate sharedInstance].buddyArray)
            {
                //   if ([chatWithUser isEqualToString:login])
                //      continue;
                
                NSXMLElement *body = [NSXMLElement elementWithName:@"body"];
                [body setStringValue:messageStr];
                
                NSXMLElement *message = [NSXMLElement elementWithName:@"message"];
                [message addAttributeWithName:@"type" stringValue:@"chat"];
                [message addAttributeWithName:@"to" stringValue:chatWithUser];
                [message addChild:body];
                
                [[[LyphyAppDelegate sharedInstance] xmppStream] sendElement:message];
            }
            
            // initialize
            self.messageField.text = @"";
            
            
            // add message to list
            NSMutableDictionary *m = [[NSMutableDictionary alloc] init];
            [m setObject:messageStr forKey:@"msg"];
            [m setObject:@"you" forKey:@"sender"];
            [m setObject:[NSString getCurrentTime] forKey:@"time"];
            
            [messages addObject:m];
            
            NSString *unicodeMsg = [NSString getUnicodeStrFrom:messageStr];
            NSString *lastTime = [NSString getFormattedCurrentTime];
            NSString *toUsername = self.xmppCoreData.jid.user;
            NSString *fromUsername = [LyphySettings sharedInstance].userName;
            
            [[LyphyNetworkClient sharedInstance] addLastMessageWithFrom:fromUsername to:toUsername msg:unicodeMsg time:lastTime];
            
            [self.tableView reloadData];
        }
        
        if (messages.count > 0) {
            NSIndexPath *topIndexPath = [NSIndexPath indexPathForRow:messages.count-1
                                                       inSection:0];
            [self.tableView scrollToRowAtIndexPath:topIndexPath
                          atScrollPosition:UITableViewScrollPositionMiddle
                                  animated:YES];
        }
    }
}

#pragma mark - UITableView Deleagate Methods

static CGFloat padding = 30.0;

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
    return [messages count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	NSDictionary *dict = (NSDictionary *)[messages objectAtIndex:indexPath.row];
	NSString *msg = [dict objectForKey:@"msg"];
	
	CGSize  textSize = { 260.0, 10000.0 };
	CGSize size = [msg sizeWithFont:[UIFont fontWithName:@"Emoticons" size:20.0]
                  constrainedToSize:textSize
                      lineBreakMode:NSLineBreakByWordWrapping];
    
    NSArray *vComp = [[UIDevice currentDevice].systemVersion componentsSeparatedByString:@"."];
    if ([[vComp objectAtIndex:0] intValue] >= 7) {
        size.height = size.height + 20;
    }
    
	size.height += padding*2 +10;
	
	CGFloat height = size.height < 65 ? 65 : size.height;
	return height;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"MessageCellIdentifier";
	
	SMMessageViewTableCell *cell = (SMMessageViewTableCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
	if (cell == nil) {
		cell = [[SMMessageViewTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
	}
    
    NSDictionary *s = (NSDictionary *) [messages objectAtIndex:indexPath.row];
    
    NSString *sender = [s objectForKey:@"sender"];
    NSString *message = [s objectForKey:@"msg"];
    NSString *time = [s objectForKey:@"time"];
    
    CGSize  textSize = { 210, 10000.0 };
	CGSize size = [message sizeWithFont:[UIFont fontWithName:@"Helvetica" size:18.0]
					  constrainedToSize:textSize
						  lineBreakMode:NSLineBreakByWordWrapping];
    
    NSArray *vComp = [[UIDevice currentDevice].systemVersion componentsSeparatedByString:@"."];
    if ([[vComp objectAtIndex:0] intValue] >= 7) {
        size.height = size.height + 10;
    }
	size.width += (padding/2);
	
	cell.messageContentView.text = message;
    [cell.messageContentView setFont:[UIFont fontWithName:@"Helvetica" size:18.0]];
	cell.accessoryType = UITableViewCellAccessoryNone;
	cell.userInteractionEnabled = YES;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    UIImage *bgImage = nil;
    int padding1 = 10;
    
	if ([sender isEqualToString:@"you"]) { // right aligned
        bgImage = [[UIImage imageNamed:@"aqua.png"] stretchableImageWithLeftCapWidth:24  topCapHeight:15];
		NSArray *vComp = [[UIDevice currentDevice].systemVersion componentsSeparatedByString:@"."];
        
        if ([[vComp objectAtIndex:0] intValue] >= 7) {
            [cell.messageContentView setFrame:CGRectMake(270 - size.width - padding,
                                                         padding,
                                                         size.width,
                                                         size.height + 20)];
            
            CGRect tmpRect = cell.messageContentView.frame;
            tmpRect.origin.y += 10;
            tmpRect.size.width += 10;
            [cell.messageContentView setFrame:tmpRect];
            [cell.bgImageView setFrame:CGRectMake( cell.messageContentView.frame.origin.x - padding/2,
                                                  cell.messageContentView.frame.origin.y - padding/2,
                                                  size.width+padding,
                                                  size.height+padding)];
        }
        else{
            [cell.messageContentView setFrame:CGRectMake(270 - size.width - padding,
                                                         padding+10,
                                                         size.width,
                                                         size.height + 20)];
            CGRect tmpRect = cell.messageContentView.frame;
            tmpRect.origin.y -= 10;
            tmpRect.size.height += 10;
            tmpRect.size.width += 10;
            [cell.messageContentView setFrame:tmpRect];
            [cell.bgImageView setFrame:CGRectMake( cell.messageContentView.frame.origin.x - padding/2,
                                                  cell.messageContentView.frame.origin.y - padding/2,
                                                  size.width+padding,
                                                  size.height+padding)];
        }

        [cell.userPhoto loadImageFromURL:[NSURL URLWithString:[LyphySettings sharedInstance].photoUrl]];
        [cell.userPhoto setFrame:CGRectMake(320 - padding1 - 40, padding + size.height / 2 - 10, 40, 40)];
        [cell.ttsButton setFrame:CGRectMake(320 - padding1 - 80, padding + size.height  - 10, 30, 30)];
		
	} else {
        bgImage = [[UIImage imageNamed:@"orange.png"] stretchableImageWithLeftCapWidth:24  topCapHeight:15];
		
        
        if ([[vComp objectAtIndex:0] intValue] >= 7) {
            // iOS-7 code[current] or greater
            [cell.messageContentView setFrame:CGRectMake(padding1 + 60, padding + 5, size.width, size.height)];
            CGRect tmpRect = cell.messageContentView.frame;
            tmpRect.size.height += 10;
            tmpRect.size.width += 10;
            [cell.messageContentView setFrame:tmpRect];
            [cell.bgImageView setFrame:CGRectMake(cell.messageContentView.frame.origin.x - padding/2,
                                                  cell.messageContentView.frame.origin.y - padding/2,
                                                  size.width+padding,
                                                  size.height+padding)];
        }else
        {
            [cell.messageContentView setFrame:CGRectMake(padding1 + 60, padding+10, size.width, size.height)];
            CGRect tmpRect = cell.messageContentView.frame;
            tmpRect.origin.y -= 10;
            tmpRect.size.height += 10;
            tmpRect.size.width += 10;
            [cell.messageContentView setFrame:tmpRect];
            [cell.bgImageView setFrame:CGRectMake(cell.messageContentView.frame.origin.x - padding/2,
                                                  cell.messageContentView.frame.origin.y - padding/2,
                                                  size.width+padding,
                                                  size.height+padding)];
        }
        
        NSString *otherUsername = self.xmppCoreData.jid.user;
        NSString *otherPhotoURL = [NSString stringWithFormat:@"http://%@/ChatService/uploads/%@.jpg", LYPHY_SERVER_NAME, otherUsername];
        [cell.userPhoto loadImageFromURL:[NSURL URLWithString:otherPhotoURL]];
        [cell.userPhoto setFrame:CGRectMake(padding1 , padding + size.height / 2 - 10, 40, 40)];
        [cell.ttsButton setFrame:CGRectMake(padding1 + 40 , padding + size.height  - 10, 30, 30)];
        
	}
    [cell.ttsButton addTarget:self action:@selector(speak:) forControlEvents:UIControlEventTouchUpInside];
	cell.ttsButton.tag = indexPath.row;
    
	cell.bgImageView.image = bgImage;
	cell.senderAndTimeLabel.text = [NSString stringWithFormat:@"%@ %@", sender, time];
//	self.messageField.text = @"";
    
	return cell;
}

#pragma mark - UITapGesture Recognizer
- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer {
    [self.messageField resignFirstResponder];
}

#pragma mark - UIKeyboard events
// Called when UIKeyboardWillShowNotification is sent
- (void)keyboardWillShown:(NSNotification*)notification
{
    self.scrollViewSize = self.scrollView.frame.size;
    
    // if we have no view or are not visible in any window, we don't care
    if (!self.isViewLoaded || !self.scrollView.window) {
        return;
    }
    
    CGRect scrollViewFrame = self.scrollView.frame;
    scrollViewFrame.size = self.scrollViewSize;
    
    NSDictionary *userInfo = [notification userInfo];
    
    CGRect keyboardFrameInWindow;
    [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardFrameInWindow];
    scrollViewFrame.size.height -= keyboardFrameInWindow.size.height;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:[[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue]];
    [UIView setAnimationCurve:[[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue]];
    
    [self.scrollView setFrame:scrollViewFrame];
    
    CGRect tableViewFrame = scrollViewFrame;
    tableViewFrame.origin.x = 0;
    tableViewFrame.origin.y = 0;
    tableViewFrame.size.height -= self.messageContainer.frame.size.height;
    [self.tableView setFrame:tableViewFrame];
    
    self.tableView.contentInset = UIEdgeInsetsZero;
    self.tableView.scrollIndicatorInsets = UIEdgeInsetsZero;
    
    [UIView commitAnimations];
    
    if (messages.count > 0) {
        NSIndexPath *topIndexPath = [NSIndexPath indexPathForRow:messages.count-1
                                                       inSection:0];
        [self.tableView scrollToRowAtIndexPath:topIndexPath
                              atScrollPosition:UITableViewScrollPositionMiddle
                                      animated:YES];
    }

}


// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)notification
{
    // if we have no view or are not visible in any window, we don't care
    if (!self.isViewLoaded || !self.view.window) {
        return;
    }
    
    CGRect scrollViewFrame = self.scrollView.frame;
    scrollViewFrame.size = self.scrollViewSize;
    
    NSDictionary *userInfo = notification.userInfo;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:[[userInfo valueForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue]];
    [UIView setAnimationCurve:[[userInfo valueForKey:UIKeyboardAnimationCurveUserInfoKey] intValue]];
    
    [self.scrollView setFrame:scrollViewFrame];
    
    CGRect tableViewFrame = scrollViewFrame;
    tableViewFrame.origin.x = 0;
    tableViewFrame.origin.y = 0;
    tableViewFrame.size.height -= self.messageContainer.frame.size.height;
    [self.tableView setFrame:tableViewFrame];
    
    [UIView commitAnimations];
}

#pragma mark - Chat delegates

- (void)newMessageReceived:(NSNotification *)note {
	
    NSMutableDictionary *messageContent = [note object];
	NSString *m = [messageContent objectForKey:@"msg"];
	[messageContent setObject:m forKey:@"msg"];
	[messageContent setObject:[NSString getCurrentTime] forKey:@"time"];
	[messages addObject:messageContent];
    
    [self.tableView reloadData];
    
    if (messages.count > 0) {
        NSIndexPath *topIndexPath = [NSIndexPath indexPathForRow:messages.count-1
												   inSection:0];
        [self.tableView scrollToRowAtIndexPath:topIndexPath
					  atScrollPosition:UITableViewScrollPositionMiddle
							  animated:YES];
    }
}

#pragma mark - UIScrollView Delegate Methods

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.messageField resignFirstResponder];
}

@end
