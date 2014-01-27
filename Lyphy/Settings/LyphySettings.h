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

@property (strong, nonatomic) NSString *username;
@property (strong, nonatomic) NSString *password;
@end
