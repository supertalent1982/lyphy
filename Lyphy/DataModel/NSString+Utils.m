//
//  NSString+Date.m
//  JabberClient
//
//  Created by cesarerocchi on 9/12/11.
//  Copyright 2011 studiomagnolia.com. All rights reserved.
//

#import "NSString+Utils.h"


@implementation NSString (Utils)

+ (NSString *) getCurrentTime {

	NSDate *nowUTC = [NSDate date];
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
	[dateFormatter setDateStyle:NSDateFormatterMediumStyle];
	[dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
	return [dateFormatter stringFromDate:nowUTC];
	
}

+ (NSString *) getUnicodeStrFrom:(NSString *) str {
    NSData *data = [str dataUsingEncoding:NSNonLossyASCIIStringEncoding];
    NSString *unicodeStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return unicodeStr;
}

+ (NSString *) getFormattedCurrentTime {
    NSDate *date = [[NSDate alloc]init];
    NSDateFormatter *df = [[NSDateFormatter alloc]init];
    [df setDateFormat:@"yyyy-MM-dd hh:mm:ss a"];
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    [df setLocale:locale];
    NSTimeZone *tz = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
    [df setTimeZone:tz];
    
    NSString *timeStr = [df stringFromDate:date];
    return timeStr;
}


@end
