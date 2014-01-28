//
//  LyphyNetworkClient.m
//  Lyphy
//
//  Created by Liang Xing on 27/1/14.
//  Copyright (c) 2014 LiangXing. All rights reserved.
//

#import "LyphyNetworkClient.h"
#import "LyphySettings.h"
#import "SecureUDID.h"

static LyphyNetworkClient *instance = nil;

@implementation LyphyNetworkClient

+ (LyphyNetworkClient *)sharedInstance
{
    if (instance == nil)
        instance = [[LyphyNetworkClient alloc] init];
    
    return instance;
}

- (LoginStatus)loginWithUsername:(NSString *)username password:(NSString *)password {
    NSString *url_string = [[NSString alloc] initWithFormat:@"http://%@/ChatService/login.php?name=%@&password=%@", LYPHY_SERVER_NAME, username, password];
    url_string = [url_string stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:url_string]];
    
    if(data) {
        NSDictionary *myJson = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    
        NSString *status = [myJson valueForKey:@"status"];
        if ([status isEqualToString:@"1"])
        {
            return LOGIN_SUCCESS;
        } else if ([status isEqualToString:@"2"]) {
            return LOGIN_FAIL;
        }
        
        return LOGIN_NETWORKCONNECTION_ERROR;
    }
    return YES;
}

- (SignupStatus)signup {
    NSString *udid = [SecureUDID UDIDForDomain:@"com.app.chatape" usingKey:@"superSecretCodeHere!@##%#$#%$^"];
    NSString *url_string = nil;
    if ([LyphySettings sharedInstance].imgPhoto == nil) {
        url_string = [[NSString alloc] initWithFormat:@"http://%@/ChatService/register.php?name=%@&password=%@&birthday=%@&email=%@&location=%@&lang=%@&token=%@",
                      LYPHY_SERVER_NAME,
                      [LyphySettings sharedInstance].userName,
                      [LyphySettings sharedInstance].password,
                      @"",
                      [LyphySettings sharedInstance].emailAddress,
                      @"",
                      @"",
                      udid];

    } else {
        NSString *photofile = [NSString stringWithFormat:@"%@.jpg", [LyphySettings sharedInstance].userName];
        url_string = [[NSString alloc] initWithFormat:@"http://%@/ChatService/register.php?name=%@&password=%@&birthday=%@&email=%@&location=%@&lang=%@&photo=%@&token=%@",
                      LYPHY_SERVER_NAME,
                      [LyphySettings sharedInstance].userName,
                      [LyphySettings sharedInstance].password,
                      @"",
                      [LyphySettings sharedInstance].emailAddress,
                      @"",
                      @"",
                      photofile,
                      udid];
    }
    
    NSLog(@"url:%@", url_string);
    
    url_string = [url_string stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:url_string]];
    
    if(data) {
        NSDictionary *myJson = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
        
        NSString *status = [myJson valueForKey:@"status"];
        if ([status isEqualToString:@"3"])
        {
            return SIGNUP_PHONENUMBEREXISTS;
        } else if ([status isEqualToString:@"2"]) {
            return SIGNUP_USEREXISTS;
        } else if ([status isEqualToString:@"1"] || [status isEqualToString:@"0"]) {
            [self uploadImage:[LyphySettings sharedInstance].userName withImage:[LyphySettings sharedInstance].imgPhoto];
            return SIGNUP_SUCCESS;
        }
        
        return SIGNUP_NETWORKCONNECTION_ERROR;
    }
    return YES;
}

- (void)uploadImage:(NSString *)filename withImage:(UIImage *)image
{
    if (image == nil) {
        return;
    }
    
	NSData *imageData = UIImageJPEGRepresentation(image, 0.6);
    
    // setting up the URL to post to
	NSString *urlString = [NSString stringWithFormat:@"http://%@/ChatService/uploader.php?username=%@", LYPHY_SERVER_NAME, [LyphySettings sharedInstance].userName];
	
	// setting up the request object now
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
	[request setURL:[NSURL URLWithString:urlString]];
	[request setHTTPMethod:@"POST"];
	
	/*
	 add some header info now
	 we always need a boundary when we post a file
	 also we need to set the content type
	 
	 You might want to generate a random boundary.. this is just the same
	 as my output from wireshark on a valid html post
	 */
	NSString *boundary = @"---------------------------14737809831466499882746641449";
	NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
	[request addValue:contentType forHTTPHeaderField: @"Content-Type"];
	
	/*
	 now lets create the body of the post
	 */
	NSMutableData *body = [NSMutableData data];
	[body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[@"Content-Disposition: form-data; name=\"uploadedfile\"; filename=" dataUsingEncoding:NSUTF8StringEncoding]];
	
	[body appendData:[[NSString stringWithString:filename] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[NSData dataWithData:imageData]];
	[body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	// setting the body of the post to the reqeust
	[request setHTTPBody:body];
	
	// now lets make the connection to the web
	NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
	NSString *returnString = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
	NSLog(@"image upload returnData = %@", returnString);
    
    NSError *error = nil;
    NSDictionary *myJson = [NSJSONSerialization JSONObjectWithData:returnData options:kNilOptions error:&error];
    if([[myJson valueForKey:@"status"] isEqualToString:@"2"])
    {
        NSLog(@"It failed to upload the avatar");
    }
    if([[myJson valueForKey:@"status"] isEqualToString:@"1"])
    {
        NSLog(@"OK uploading photo");
    }
}


@end
