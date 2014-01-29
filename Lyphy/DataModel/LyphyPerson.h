//
//  LyphyPerson.h
//  Lyphy
//
//  Created by Liang Xing on 28/1/14.
//  Copyright (c) 2014 LiangXing. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LyphyPerson : NSObject

@property (strong, nonatomic) NSString *fullName;
@property (strong, nonatomic) NSString *firstName;
@property (strong, nonatomic) NSString *lastName;
@property (strong, nonatomic) NSString *homeEmail;
@property (strong, nonatomic) NSString *workEmail;
@property (strong, nonatomic) NSString *phoneNumber;
@property (strong, nonatomic) UIImage *image;

@end
