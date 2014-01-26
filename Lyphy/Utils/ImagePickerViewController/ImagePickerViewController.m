/* ImagePickerViewController.m
 *
 * Copyright (C) 2012  Belledonne Comunications, Grenoble, France
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program; if not, write to the Free Software
 *  Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
 */

#import "ImagePickerViewController.h"
#import "DTActionSheet.h"


@implementation ImagePickerViewController

@synthesize imagePickerDelegate;
@synthesize sourceType;
@synthesize mediaTypes;
@synthesize allowsEditing;


#pragma mark - Lifecycle Functions

- (id)init {
    self = [super init];
    if (self != nil) {
        pickerController = [[UIImagePickerController alloc] init];
    }
    return self;
}

#pragma mark - ViewController Functions

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view setAutoresizingMask: UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    [pickerController.view setFrame:[self.view bounds]];
    [self.view addSubview:[pickerController view]];
    [pickerController setDelegate:self];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if ([[UIDevice currentDevice].systemVersion doubleValue] < 5.0) {
        [pickerController viewWillAppear:animated];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if ([[UIDevice currentDevice].systemVersion doubleValue] < 5.0) {
        [pickerController viewDidAppear:animated];
    }
    [[UIApplication sharedApplication] setStatusBarHidden:NO]; //Fix UIImagePickerController status bar hide
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque]; //Fix UIImagePickerController status bar style change
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    if ([[UIDevice currentDevice].systemVersion doubleValue] < 5.0) {
        [pickerController viewDidDisappear:animated];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if ([[UIDevice currentDevice].systemVersion doubleValue] < 5.0) {
        [pickerController viewWillDisappear:animated];
    }
}

#pragma mark - Property Functions

- (BOOL)allowsEditing {
    return pickerController.allowsEditing;
}

- (void)setAllowsEditing:(BOOL)aallowsEditing {
    pickerController.allowsEditing = aallowsEditing;
}

- (UIImagePickerControllerSourceType)sourceType {
    return pickerController.sourceType;
}

- (void)setSourceType:(UIImagePickerControllerSourceType)asourceType {
    pickerController.sourceType = asourceType;
}

- (NSArray *)mediaTypes {
    return pickerController.mediaTypes;
}

- (void)setMediaTypes:(NSArray *)amediaTypes {
    pickerController.mediaTypes = amediaTypes;
}


#pragma mark -

- (void)dismiss {
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - UIImagePickerControllerDelegate Functions

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [self dismiss];
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    if(image == nil) {
        image = [info objectForKey:UIImagePickerControllerOriginalImage];
    }
    if(image != nil && imagePickerDelegate != nil) {
        [imagePickerDelegate imagePickerDelegateImage:image info:info];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismiss];
}

@end
