//
//  LyphySettings.h
//  Lyphy
//
//  Created by Liang Xing on 27/1/14.
//  Copyright (c) 2014 LiangXing. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LyphySettings : NSObject
+ (LyphySettings *)sharedInstance;

@property (strong, nonatomic) NSString *userName;
@property (strong, nonatomic) NSString *userFullName;
@property (strong, nonatomic) NSString *emailAddress;
@property (strong, nonatomic) UIImage *imgPhoto;
@property (strong, nonatomic) NSString *photoUrl;
@property (strong, nonatomic) NSString *password;
@property (strong, nonatomic) NSString *phoneNumber;
@end
