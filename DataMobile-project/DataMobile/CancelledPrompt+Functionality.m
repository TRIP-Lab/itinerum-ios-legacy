//
//  CancelledPrompt+Functionality.m
//  Itinerum
//
//  Created by Takeshi MUKAI on 9/25/17.
//  Copyright (c) 2017 MML-Concordia. All rights reserved.
//

#import "CancelledPrompt+Functionality.h"

@implementation CancelledPrompt (Functionality)

- (NSDictionary*)jsonDictWithFormattedTimeStamp
{
    NSDateFormatter *ISO8601Formatter = [[NSDateFormatter alloc]init];
    NSLocale *enUSPOSIXLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    [ISO8601Formatter setLocale:enUSPOSIXLocale];
    [ISO8601Formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
    
    // create json dict object
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:[NSString stringWithFormat:@"%lf", self.latitude] forKey:@"latitude"];
    [dict setObject:[NSString stringWithFormat:@"%lf", self.longitude] forKey:@"longitude"];
    [dict setObject:[ISO8601Formatter stringFromDate:[self dateFromTimeStamp]] forKey:@"displayed_at"];
    if (self.cancelled_at!=0) {
        [dict setObject:[ISO8601Formatter stringFromDate:[self dateFromTimeStampRecordedAt]] forKey:@"cancelled_at"];
    }
    if (![self.is_travelling isEqualToString:@"NULL"]) {
        [dict setObject:[NSString stringWithFormat:@"%@", self.is_travelling] forKey:@"is_travelling"];
    }
    //MARK: CHANGED BY SAGAR
    [dict setObject:[[NSUUID UUID] UUIDString] forKey:@"uuid"];
    
    return dict;
}

- (NSDate *)dateFromTimeStamp
{
    return [NSDate dateWithTimeIntervalSinceReferenceDate:self.timestamp];
}

- (NSDate *)dateFromTimeStampRecordedAt
{
    return [NSDate dateWithTimeIntervalSinceReferenceDate:self.cancelled_at];
}

@end
