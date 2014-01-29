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
#import "SBJsonParser.h"
#import <AddressBook/AddressBook.h>
#import "LyphyPerson.h"

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

- (NSMutableArray *)searchFriendsWithSearchString:(NSString *)searchString {
    
    NSMutableArray *userSearchResult = [NSMutableArray new];
    
    if (searchString == nil || [searchString isEqualToString:@""]) {
        return userSearchResult;
    }
    
    NSString *url_string = [[NSString alloc] initWithFormat:@"http://%@/ChatService/searchfriend.php?name=%@", LYPHY_SERVER_NAME, searchString];
    url_string = [url_string stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:url_string]];
    
    if(data) {
        NSString *response = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        
        SBJsonParser *parser = [[SBJsonParser alloc] init];
        NSMutableArray *array = [[NSMutableArray alloc] init];
        array = [parser objectWithString:response];
        int count = [array count];
        for (int i = 0; i < count; i++)
        {
            NSDictionary *dict = [array objectAtIndex:i];
            if ([[dict objectForKey:@"name"] isEqualToString:[LyphySettings sharedInstance].userName])
                continue;
            [userSearchResult addObject:dict];
        }
    }
    
    NSArray *contactSearchResult = [self getPersonOutOfAddressBookWithName:searchString];
    for (int i = 0; i < contactSearchResult.count; i++)
    {
        LyphyPerson *person = [contactSearchResult objectAtIndex:i];
        NSString *email = (person.homeEmail? person.homeEmail: person.workEmail);
        if (email == nil)
            email = @"";
        
        [userSearchResult addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                                     person.fullName, @"name",
                                     email, @"email",
                                     [NSNumber numberWithBool:YES], @"contact",
                                     person.phoneNumber, @"phonenumber",
                                     person.image, @"image",nil]];
    }
    
    return userSearchResult;
}

- (NSArray *)getPersonOutOfAddressBookWithName:(NSString*)substring
{
    //1
    CFErrorRef error = NULL;
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, &error);
    NSMutableArray *contactSearchResult = [[NSMutableArray alloc] init];
    
    if (addressBook != nil) {
        NSLog(@"Succesful.");
        
        //2
        NSArray *allContacts = (__bridge_transfer NSArray *)ABAddressBookCopyArrayOfAllPeople(addressBook);
        
        //3
        NSUInteger i = 0; for (i = 0; i < [allContacts count]; i++)
        {
            LyphyPerson *person = [[LyphyPerson alloc] init];
            ABRecordRef contactPerson = (__bridge ABRecordRef)allContacts[i];
            
            //4
            NSString *firstName = (__bridge_transfer NSString *)ABRecordCopyValue(contactPerson,
                                                                                  kABPersonFirstNameProperty);
            NSString *lastName = (__bridge_transfer NSString *)ABRecordCopyValue(contactPerson, kABPersonLastNameProperty);
            NSString *fullName = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
            
            person.firstName = firstName; person.lastName = lastName;
            person.fullName = fullName;
            
            NSLog(@"fullName = %@", person.fullName);
            if ([person.fullName rangeOfString:substring].location != NSNotFound) {
                //email
                //5
                ABMultiValueRef emails = ABRecordCopyValue(contactPerson, kABPersonEmailProperty);
                
                //6
                NSUInteger j = 0;
                for (j = 0; j < ABMultiValueGetCount(emails); j++) {
                    NSString *email = (__bridge_transfer NSString *)ABMultiValueCopyValueAtIndex(emails, j);
                    if (j == 0) {
                        person.homeEmail = email;
                        NSLog(@"person.homeEmail = %@ ", person.homeEmail);
                    }
                    else if (j==1) person.workEmail = email;
                }
                
                UIImage *img ;
                if (person != nil && ABPersonHasImageData(contactPerson)) {
                    if ( &ABPersonCopyImageDataWithFormat != nil ) {
                        // iOS >= 4.1
                        img= [UIImage imageWithData:(__bridge NSData *)ABPersonCopyImageDataWithFormat(contactPerson, kABPersonImageFormatThumbnail)];
                    } else {
                        // iOS < 4.1
                        img= [UIImage imageWithData:(__bridge NSData *)ABPersonCopyImageData(contactPerson)];
                    }
                } else {
                    img= nil;
                }
                person.image = img;
                
                ABMultiValueRef multiPhones = ABRecordCopyValue(contactPerson,
                                  kABPersonPhoneProperty);
                if (ABMultiValueGetCount(multiPhones) >  0) {
                    CFStringRef phoneNumberRef = ABMultiValueCopyValueAtIndex(multiPhones, 0);
                    person.phoneNumber = (__bridge NSString *) phoneNumberRef;
                     NSLog(@"phonenumber:%@", person.phoneNumber);
                }
               
                
                //7
                [contactSearchResult addObject:person];
            }
        }
        //8
        CFRelease(addressBook);
    } else {
        //9
        NSLog(@"Error reading Address Book");
    }
    
    return contactSearchResult;
}

- (void)addLastMessageWithFrom:(NSString *)fromUser to:(NSString *)toUser msg:(NSString *)msg time:(NSString *)time {
    
    NSString *url_string = [[NSString alloc] initWithFormat:@"http://%@/ChatService/addlastmessage.php?sender=%@&receiver=%@&message=%@&time=%@",
                             LYPHY_SERVER_NAME,
                             fromUser,
                             toUser,
                             msg,
                             time];
    url_string = [url_string stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSURL *url = [NSURL URLWithString:url_string];
    [NSURLConnection connectionWithRequest:[NSURLRequest requestWithURL:url] delegate:nil];
}

- (NSMutableArray *)getChatHistoryWithSender:(NSString *)sendUser receiver:(NSString *)receiveUser {
    
    NSMutableArray *chatHistoryArray = [NSMutableArray new];
    
    NSString *url_string = [[NSString alloc] initWithFormat:@"http://%@/ChatService/getchathistory.php?sender=%@&receiver=%@",
                            LYPHY_SERVER_NAME,
                            sendUser,
                            receiveUser];
    url_string = [url_string stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSURL *url = [NSURL URLWithString:url_string];
    NSData *data1 = [NSData dataWithContentsOfURL:url];
    NSString *response1 = [[NSString alloc] initWithData:data1 encoding:NSUTF8StringEncoding];
    SBJsonParser *parser1 = [[SBJsonParser alloc] init];
    NSMutableArray *array = [[NSMutableArray alloc]init];
    array = [parser1 objectWithString:response1];
    
    if (array.count > 0)
    {
        int num_rows = [array count];
        for (int i = 0; i < num_rows; i++) {
            NSMutableDictionary *userInfo = [array objectAtIndex:i];
            
            NSString *messageStr = [userInfo objectForKey:@"message"];
            NSLog(@"message = %@", messageStr);
            
            NSData *data = [messageStr dataUsingEncoding:NSUTF8StringEncoding];
            NSString *emoStr = [[NSString alloc]initWithData:data encoding:NSNonLossyASCIIStringEncoding];
            messageStr = emoStr ? emoStr: messageStr;
            
            NSString *sender = [userInfo objectForKey:@"sender"];
            //NSString *receiver = [userInfo objectForKey:@"receiver"];
            
            if ([sender isEqualToString:sendUser])
                sender = @"you";
            
            NSString *timeStr = [userInfo objectForKey:@"time"];
            
            NSMutableDictionary *m = [[NSMutableDictionary alloc] init];
            [m setObject:messageStr forKey:@"msg"];
            [m setObject:sender forKey:@"sender"];
            [m setObject:timeStr forKey:@"time"];
            
            [chatHistoryArray addObject:m];
        }
    }
    
    return chatHistoryArray;
}

@end
