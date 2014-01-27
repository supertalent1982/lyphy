//
//  LyphyPhotoUploadViewController.m
//  Lyphy
//
//  Created by Liang Xing on 26/1/14.
//  Copyright (c) 2014 LiangXing. All rights reserved.
//

#import "LyphyPhotoUploadViewController.h"
#import "DTActionSheet.h"
#import "ImagePickerViewController.h"

#import <MobileCoreServices/MobileCoreServices.h>

@interface LyphyPhotoUploadViewController () <UIGestureRecognizerDelegate, ImagePickerDelegate>

@property (nonatomic, strong) UIView *topView;

@end

@implementation LyphyPhotoUploadViewController

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
    
    [self addTopBar];
    
    UISwipeGestureRecognizer *leftRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(SwipeRecognizer:)];
    leftRecognizer.direction=UISwipeGestureRecognizerDirectionLeft;
    leftRecognizer.numberOfTouchesRequired = 1;
    leftRecognizer.delegate = self;
    [self.view addGestureRecognizer:leftRecognizer];
}

- (void)addTopBar {
    self.topView = [[UIView alloc] initWithFrame:CGRectMake(0, -44, 320, 44)];
    [self.revealViewController.view addSubview:self.topView];
    
    UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    [backgroundView setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.3]];
    [self.topView addSubview:backgroundView];
    
    UIButton *cameraBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [cameraBtn setFrame:CGRectMake(145, 9, 30, 26)];
    [cameraBtn setBackgroundImage:[UIImage imageNamed:@"camera.png"] forState:UIControlStateNormal];
    [cameraBtn addTarget:self action:@selector(cameraBtnTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.topView addSubview:cameraBtn];
    
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [backBtn setFrame:CGRectMake(0, 0, 32, 44)];
    [backBtn setBackgroundImage:[UIImage imageNamed:@"white-back-btn.png"] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(backBtnTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.topView addSubview:backBtn];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)cameraBtnTapped:(id)sender {
    
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
    DTActionSheet *sheet = [[DTActionSheet alloc] initWithTitle:NSLocalizedString(@"Image Upload",nil)];
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
    
    [sheet addCancelButtonWithTitle:NSLocalizedString(@"Cancel",nil) block:nil];
    
    [sheet showInView:self.view];
}

- (void)backBtnTapped:(id)sender {
    [self.revealViewController.navigationController popViewControllerAnimated:YES];
}

#pragma mark - ImagePickerDelegate Functions

- (void)imagePickerDelegateImage:(UIImage*)image info:(NSDictionary *)info{
//    [self.imvPhoto setImage:image];
}

#pragma mark  UIGestureRecognizer Delegate Methods

- (void) SwipeRecognizer:(UISwipeGestureRecognizer *)sender {
    if ( sender.direction == UISwipeGestureRecognizerDirectionLeft ){
        
        [UIView animateWithDuration:.2 animations:^{
            [self.topView setFrame:CGRectMake(0, -44, 320, 44)];
        }];
        
        [self.revealViewController revealToggle:sender];
    }
}

#pragma mark - SWRevealViewController Delegate
- (void)revealController:(SWRevealViewController *)revealController didMoveToPosition:(FrontViewPosition)position {
    if (position == FrontViewPositionLeft) {
        
    } else if (position == FrontViewPositionRight) {
        
        
        [UIView animateWithDuration:.2 animations:^{
            [self.topView setFrame:CGRectMake(0, 0, 320, 44)];
        }];
    }
}

@end
