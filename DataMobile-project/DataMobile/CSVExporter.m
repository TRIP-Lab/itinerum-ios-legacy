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
//  CSVExporter.m
//  GPSRecorder
//
//  Created by Kim Sawchuk on 11-11-23.
//  Copyright (c) 2011 MML-Concordia. All rights reserved.
//
// Modified by MUKAI Takeshi in 2015-11

#import "CSVExporter.h"
#import "Location+Functionality.h"
#import "Modeprompt+Functionality.h"  // Modified by MUKAI Takeshi in 2015-11
#import "CancelledPrompt+Functionality.h"  // Modified by MUKAI Takeshi in 2017-09 // cancelledPrompt

@implementation CSVExporter 

+ (NSString*)exportObjects:(NSArray*)array
{
    NSMutableString* locations = [[NSMutableString alloc] initWithFormat:@""];
    for (Location *location in array)
    {
        [locations appendString:[location csvStringWithFormattedTimeStamp:YES]];
    }
    return locations;
}

// Modified by MUKAI Takeshi in 2016-08 // for custom survey
+ (NSMutableArray*)exportObjectsForCustomSurvey:(NSArray*)array
{
    NSMutableArray *arrayCoordinates = [NSMutableArray array];
    for (Location *location in array)
    {
        // add coordinate json dicts into array
        [arrayCoordinates addObject:[location jsonDictWithFormattedTimeStampForCustomSurvey]];
    }
    return arrayCoordinates;
}

// Modified by MUKAI Takeshi in 2015-11 // for modeprompts
+ (NSString*)exportObjectsModeprompt:(NSArray*)array
{
    NSMutableString* modeprompts = [[NSMutableString alloc] initWithFormat:@""];
    for (Modeprompt *modeprompt in array)
    {
        [modeprompts appendString:[modeprompt csvStringWithFormattedTimeStamp:YES]];
    }
    return modeprompts;
}

// Modified by MUKAI Takeshi in 2016-08 // for custom survey
+ (NSMutableArray*)exportObjectsModepromptForCustomSurvey:(NSArray*)array
{
    NSMutableArray *arrayModeprompts = [NSMutableArray array];
    for (Modeprompt *modeprompt in array)
    {
        // add coordinate json dicts into array
        [arrayModeprompts addObject:[modeprompt jsonDictWithFormattedTimeStampForCustomSurvey]];
    }
    return arrayModeprompts;
}

// Modified by MUKAI Takeshi in 2017-09 // cancelledPrompt
+ (NSMutableArray*)exportObjectsCancelledPrompt:(NSArray*)array
{
    NSMutableArray *arrayCancelledPrompts = [NSMutableArray array];
    for (CancelledPrompt *cancelledPrompt in array)
    {
        // add coordinate json dicts into array
        [arrayCancelledPrompts addObject:[cancelledPrompt jsonDictWithFormattedTimeStamp]];
    }
    return arrayCancelledPrompts;
}

@end
