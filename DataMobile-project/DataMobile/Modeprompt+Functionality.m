/*///////////////////////////////////////////////////////////////////
 GNU PUBLIC LICENSE - The copying permission statement
 --------------------------------------------------------------------
 This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.
 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 You should have received a copy of the GNU General Public License
 along with this program.  If not, see <http://www.gnu.org/licenses/>.
 ///////////////////////////////////////////////////////////////////*/

//
//  Modeprompt+Functionality.m
//  DataMobile
//
//  Created by Takeshi MUKAI on 11/13/15.
//  Copyright (c) 2015 MML-Concordia. All rights reserved.
//

#import "Modeprompt+Functionality.h"

@implementation Modeprompt (Functionality)


- (NSString*)csvStringWithFormattedTimeStamp:(BOOL)formatTimeStamp
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
    
    if(formatTimeStamp)
    {
        NSDateFormatter *ISO8601Formatter = [[NSDateFormatter alloc]init];
        NSLocale *enUSPOSIXLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
        [ISO8601Formatter setLocale:enUSPOSIXLocale];
        [ISO8601Formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
        
        return [NSString stringWithFormat:@"%f, %f, %@, %@, %@\n",
                self.latitude,
                self.longitude,
                [ISO8601Formatter stringFromDate:[self dateFromTimeStamp]],
                self.mode,
                self.purpose];
    }
    else
    {
        return [NSString stringWithFormat:@"%f, %f, %f, %@, %@\n",
                self.latitude,
                self.longitude,
                self.timestamp,
                self.mode,
                self.purpose];
    }
}

// for custom survey
- (NSDictionary*)jsonDictWithFormattedTimeStampForCustomSurvey
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
    [dict setObject:[ISO8601Formatter stringFromDate:[self dateFromTimeStampRecordedAt]] forKey:@"recorded_at"];
    [dict setObject:[self.prompt_answer objectForKey:@"prompt_answer"] forKey:@"answer"];
    [dict setObject:[NSString stringWithFormat:@"%@", self.prompt_id] forKey:@"propmt"];
    //MARK: CHANGED BY SAGAR
    [dict setObject:self.uuid forKey:@"uuid"];
    [dict setObject:[NSString stringWithFormat:@"%d", self.prompt_num] forKey:@"prompt_num"];
    return dict;
}

- (NSDate *)dateFromTimeStamp
{
    return [NSDate dateWithTimeIntervalSinceReferenceDate:self.timestamp];
}

// for custom survey
- (NSDate *)dateFromTimeStampRecordedAt
{
    return [NSDate dateWithTimeIntervalSinceReferenceDate:self.recorded_at];
}

@end
