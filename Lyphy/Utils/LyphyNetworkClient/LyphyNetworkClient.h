//
//  LyphyNetworkClient.h
//  Lyphy
//
//  Created by Liang Xing on 27/1/14.
//  Copyright (c) 2014 LiangXing. All rights reserved.
//

#import <Foundation/Foundation.h>

#define LYPHY_XMPP_SERVER_NAME @"ps262296.dreamhostps.com"
#define LYPHY_SERVER_NAME @"lyphy.com"

typedef enum {
    LOGIN_SUCCESS,
    LOGIN_FAIL,
    LOGIN_NETWORKCONNECTION_ERROR
} LoginStatus;

typedef enum {
    SIGNUP_SUCCESS,
    SIGNUP_USEREXISTS,
    SIGNUP_PHONENUMBEREXISTS,
    SIGNUP_NETWORKCONNECTION_ERROR
} SignupStatus;


@interface LyphyNetworkClient : NSObject

+ (LyphyNetworkClient *)sharedInstance;

- (LoginStatus)loginWithUsername:(NSString *)username password:(NSString *)password;
- (SignupStatus)signup;
- (void)uploadImage:(NSString *)filename withImage:(UIImage *)image;

@end
