//
//  LyphySettings.m
//  Lyphy
//
//  Created by Liang Xing on 27/1/14.
//  Copyright (c) 2014 LiangXing. All rights reserved.
//

#import "LyphySettings.h"

static LyphySettings *instance = nil;

@implementation LyphySettings

+ (LyphySettings *)sharedInstance
{
    if (instance == nil)
        instance = [[LyphySettings alloc] init];
    
    return instance;
}

@end
