//
//  LyphyProfileViewController.m
//  Lyphy
//
//  Created by Liang Xing on 25/1/14.
//  Copyright (c) 2014 LiangXing. All rights reserved.
//

#import "LyphyProfileViewController.h"
#import "LyphySyncPhoneViewController.h"
#import "DTActionSheet.h"
#import "ImagePickerViewController.h"
#import "LyphySettings.h"
#import "LyphyAppDelegate.h"
#import "LyphyNetworkClient.h"

#import <MobileCoreServices/MobileCoreServices.h>
#import <QuartzCore/QuartzCore.h>

@interface LyphyProfileViewController () <UITextFieldDelegate, ImagePickerDelegate>

@property (strong, nonatomic) UITextField *focusedTextField;

@end

@implementation LyphyProfileViewController

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
    
    [self.scrollView setContentSize:CGSizeMake(320, 272)];
    self.imvPhoto.layer.cornerRadius = 36;
    self.imvPhoto.layer.masksToBounds = YES;

    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onKeyboardHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onKeyboardShow:) name:UIKeyboardWillShowNotification object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)backBtnTapped:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)photoBtnTapped:(id)sender {
    
    [self.edtFullName resignFirstResponder];
    [self.edtLyphyID resignFirstResponder];
    
    void (^block)(UIImagePickerControllerSourceType) = ^(UIImagePickerControllerSourceType type) {
        ImagePickerViewController *controller;
        controller = [[ImagePickerViewController alloc] init];
        if(controller != nil) {
            controller.sourceType = type;
            
            // Displays a control that allows the user to choose picture or
            // movie capture, if both are available:
            controller.mediaTypes = [NSArray arrayWithObject:(NSString *)kUTTypeImage];
            
            // Hides the controls for moving & scaling pictures, or for
            // trimming movies. To instead show the controls, use YES.
            controller.allowsEditing = YES;
            controller.imagePickerDelegate = self;
            
            [self presentViewController:controller animated:YES completion:nil];
        }
    };
    DTActionSheet *sheet = [[DTActionSheet alloc] initWithTitle:NSLocalizedString(@"",nil)];
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [sheet addButtonWithTitle:NSLocalizedString(@"Camera",nil) block:^(){
            block(UIImagePickerControllerSourceTypeCamera);
        }];
    }
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        [sheet addButtonWithTitle:NSLocalizedString(@"Photo library",nil) block:^(){
            block(UIImagePickerControllerSourceTypePhotoLibrary);
        }];
    }
    if (self.imvPhoto.image != nil) {
        [sheet addDestructiveButtonWithTitle:NSLocalizedString(@"Remove", nil) block:^(){
            self.imvPhoto.image = nil;
        }];
    }
    [sheet addCancelButtonWithTitle:NSLocalizedString(@"Cancel",nil) block:nil];
    
    [sheet showInView:self.view];
}

- (IBAction)saveBtnTapped:(id)sender {
    [self.edtFullName resignFirstResponder];
    [self.edtLyphyID resignFirstResponder];
    
    if ([self.edtFullName.text isEqualToString:@""]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Warning" message:@"Please enter your full name." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alertView show];
        return;
    }
    if ([self.edtLyphyID.text isEqualToString:@""]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Warning" message:@"Please enter your Lyphy ID." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alertView show];
        return;
    }
    
    [[LyphySettings sharedInstance] setUserFullName:self.edtFullName.text];
    [[LyphySettings sharedInstance] setUserName:self.edtLyphyID.text];
    [[LyphySettings sharedInstance] setImgPhoto:self.imvPhoto.image];
    
    [[LyphyAppDelegate sharedInstance].loadingView.titleLabel setText:@"Signing up..."];
    [UIView animateWithDuration:0.3
					 animations:^{
						 [[LyphyAppDelegate sharedInstance].loadingView setAlpha:1];
					 }];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        SignupStatus signupStatus = [[LyphyNetworkClient sharedInstance] signup];
        NSNumber *numStatus = [NSNumber numberWithInt:signupStatus];
        
        [self performSelectorOnMainThread:@selector(signup:) withObject:numStatus waitUntilDone:NO];
    });
    
    
}

- (void)signup:(id)sender {
    SignupStatus signupStatus = [(NSNumber *)sender integerValue];
    
    [[LyphyAppDelegate sharedInstance].loadingView setAlpha:0];
    
    if (signupStatus == SIGNUP_USEREXISTS) {
        UIAlertView* mes=[[UIAlertView alloc] initWithTitle:@"Warning"
                                                    message:[NSString stringWithFormat:@"%@ is already used. Please use another Lyphy ID.", [LyphySettings sharedInstance].userName]
                                                   delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        
        [mes show];
        return;
    } else if (signupStatus == SIGNUP_PHONENUMBEREXISTS) {
        UIAlertView* mes=[[UIAlertView alloc] initWithTitle:@"Warning"
                                                    message:@"This phone was already registered. Please use another phone."
                                                   delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        
        [mes show];
        return;
    } else if (signupStatus == SIGNUP_NETWORKCONNECTION_ERROR) {
        UIAlertView* mes=[[UIAlertView alloc] initWithTitle:@"Warning"
                                                    message:@"The server is not running." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        
        [mes show];
        return;
    }
    
    [[LyphyAppDelegate sharedInstance].loadingView.titleLabel setText:@"Logging in..."];
    [UIView animateWithDuration:0.3
					 animations:^{
						 [[LyphyAppDelegate sharedInstance].loadingView setAlpha:1];
					 }];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        LoginStatus loginStatus = [[LyphyNetworkClient sharedInstance]
                                   loginWithUsername:[LyphySettings sharedInstance].userName
                                   password:[LyphySettings sharedInstance].password];
        NSNumber *numStatus = [NSNumber numberWithInt:loginStatus];
        
        [self performSelectorOnMainThread:@selector(login:) withObject:numStatus waitUntilDone:NO];
    });
}

- (void)login:(id)sender {
    LoginStatus loginStatus = [(NSNumber *)sender integerValue];
    
    [[LyphyAppDelegate sharedInstance].loadingView setAlpha:0];
    
    if (loginStatus == LOGIN_FAIL) {
        UIAlertView* mes=[[UIAlertView alloc] initWithTitle:@"Warning"
                                                    message:@"This username or password is invalid." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        
        [mes show];
        return;
    } else if (loginStatus == LOGIN_NETWORKCONNECTION_ERROR) {
        UIAlertView* mes=[[UIAlertView alloc] initWithTitle:@"Warning"
                                                    message:@"The server is not running." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        
        [mes show];
        return;
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%@@%@", [LyphySettings sharedInstance].userName, LYPHY_XMPP_SERVER_NAME] forKey:@"userID"];
    [[NSUserDefaults standardUserDefaults] setObject:[LyphySettings sharedInstance].password forKey:@"password"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    // xmpp connect
    if (![[LyphyAppDelegate sharedInstance] connect]) {
        UIAlertView* mes=[[UIAlertView alloc] initWithTitle:@"Warning"
                                                    message:@"The server is not running." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        
        [mes show];
        return;
    }
    
    LyphySyncPhoneViewController *syncPhoneViewController = [[LyphySyncPhoneViewController alloc] initWithNibName:@"LyphySyncPhoneViewController" bundle:nil];
    [self.navigationController pushViewController:syncPhoneViewController animated:YES];
}

#pragma mark - ImagePickerDelegate Functions

- (void)imagePickerDelegateImage:(UIImage*)image info:(NSDictionary *)info{
    [self.imvPhoto setImage:image];
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
