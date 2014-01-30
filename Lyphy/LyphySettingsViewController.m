//
//  LyphySettingsViewController.m
//  Lyphy
//
//  Created by Liang Xing on 26/1/14.
//  Copyright (c) 2014 LiangXing. All rights reserved.
//

#import "LyphySettingsViewController.h"
#import "LyphyFindFriendsByLyphyViewController.h"
#import "LyphySettings.h"

@interface LyphySettingsViewController () <UITextFieldDelegate>

@property (strong, nonatomic) UITextField *focusedTextField;

@end

@implementation LyphySettingsViewController

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
    
    [self.scrollView addSubview:self.contentView];
    [self.scrollView setContentSize:self.contentView.frame.size];
    
    [self.txtUsername setText:[LyphySettings sharedInstance].userName];
    [self.txtEmail setText:[LyphySettings sharedInstance].emailAddress];
    [self.txtPassword setText:[LyphySettings sharedInstance].password];
    [self.txtPhoneNumber setText:[LyphySettings sharedInstance].phoneNumber];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onKeyboardHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onKeyboardShow:) name:UIKeyboardWillShowNotification object:nil];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)backBtnTapped:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)logoutBtnTapped:(id)sender {
    if ([self.delegate respondsToSelector:@selector(logout)]) {
        [self.delegate logout];
    }
    
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (IBAction)editProfileBtnTapped:(id)sender {
}

- (IBAction)findFriendsBtnTapped:(id)sender {
    LyphyFindFriendsByLyphyViewController *findFriendsViewController = [[LyphyFindFriendsByLyphyViewController alloc] initWithNibName:@"LyphyFindFriendsByLyphyViewController" bundle:nil];
    [self.navigationController pushViewController:findFriendsViewController animated:YES];
}

#pragma mark - UIKeyboard events
// Called when UIKeyboardWillShowNotification is sent
- (void)onKeyboardShow:(NSNotification*)notification
{
    // if we have no view or are not visible in any window, we don't care
    if (!self.isViewLoaded || !self.scrollView.window) {
        return;
    }
    
    NSDictionary *userInfo = [notification userInfo];
    
    CGRect keyboardFrameInWindow;
    [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardFrameInWindow];
    
    // the keyboard frame is specified in window-level coordinates. this calculates the frame as if it were a subview of our view, making it a sibling of the scroll view
    CGRect keyboardFrameInView = [self.scrollView convertRect:keyboardFrameInWindow fromView:nil];
    
    CGRect scrollViewKeyboardIntersection = CGRectIntersection(_scrollView.frame, keyboardFrameInView);
    UIEdgeInsets newContentInsets = UIEdgeInsetsMake(0, 0, scrollViewKeyboardIntersection.size.height, 0);
    
    // this is an old animation method, but the only one that retains compaitiblity between parameters (duration, curve) and the values contained in the userInfo-Dictionary.
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:[[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue]];
    [UIView setAnimationCurve:[[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue]];
    
    _scrollView.contentInset = newContentInsets;
    _scrollView.scrollIndicatorInsets = newContentInsets;
    
    /*
     * Depending on visual layout, _focusedControl should either be the input field (UITextField,..) or another element
     * that should be visible, e.g. a purchase button below an amount text field
     * it makes sense to set _focusedControl in delegates like -textFieldShouldBeginEditing: if you have multiple input fields
     */
    if (self.focusedTextField) {
        CGRect controlFrameInScrollView = [_scrollView convertRect:self.focusedTextField.bounds fromView:self.focusedTextField]; // if the control is a deep in the hierarchy below the scroll view, this will calculate the frame as if it were a direct subview
        controlFrameInScrollView = CGRectInset(controlFrameInScrollView, 0, -10); // replace 10 with any nice visual offset between control and keyboard or control and top of the scroll view.
        
        CGFloat controlVisualOffsetToTopOfScrollview = controlFrameInScrollView.origin.y - _scrollView.contentOffset.y;
        CGFloat controlVisualBottom = controlVisualOffsetToTopOfScrollview + controlFrameInScrollView.size.height;
        
        // this is the visible part of the scroll view that is not hidden by the keyboard
        CGFloat scrollViewVisibleHeight = _scrollView.frame.size.height - scrollViewKeyboardIntersection.size.height;
        
        if (controlVisualBottom > scrollViewVisibleHeight) { // check if the keyboard will hide the control in question
            // scroll up until the control is in place
            CGPoint newContentOffset = _scrollView.contentOffset;
            newContentOffset.y += (controlVisualBottom - scrollViewVisibleHeight);
            
            // make sure we don't set an impossible offset caused by the "nice visual offset"
            // if a control is at the bottom of the scroll view, it will end up just above the keyboard to eliminate scrolling inconsistencies
            newContentOffset.y = MIN(newContentOffset.y, _scrollView.contentSize.height - scrollViewVisibleHeight);
            
            [_scrollView setContentOffset:newContentOffset animated:NO]; // animated:NO because we have created our own animation context around this code
        } else if (controlFrameInScrollView.origin.y < _scrollView.contentOffset.y) {
            // if the control is not fully visible, make it so (useful if the user taps on a partially visible input field
            CGPoint newContentOffset = _scrollView.contentOffset;
            newContentOffset.y = controlFrameInScrollView.origin.y;
            
            [_scrollView setContentOffset:newContentOffset animated:NO]; // animated:NO because we have created our own animation context around this code
        }
    }
    
    [UIView commitAnimations];
}


// Called when the UIKeyboardWillHideNotification is sent
- (void)onKeyboardHide:(NSNotification*)notification
{
    // if we have no view or are not visible in any window, we don't care
    if (!self.isViewLoaded || !self.view.window) {
        return;
    }
    
    NSDictionary *userInfo = notification.userInfo;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:[[userInfo valueForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue]];
    [UIView setAnimationCurve:[[userInfo valueForKey:UIKeyboardAnimationCurveUserInfoKey] intValue]];
    
    // undo all that keyboardWillShow-magic
    // the scroll view will adjust its contentOffset apropriately
    _scrollView.contentInset = UIEdgeInsetsZero;
    _scrollView.scrollIndicatorInsets = UIEdgeInsetsZero;
    
    [UIView commitAnimations];
}


#pragma mark - UITextField Delegate methods
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    self.focusedTextField = textField;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

@end
