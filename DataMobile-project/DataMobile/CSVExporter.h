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
//  CSVExporter.h
//  GPSRecorder
//
//  Created by Kim Sawchuk on 11-11-23.
//  Copyright (c) 2011 MML-Concordia. All rights reserved.
//
// Modified by MUKAI Takeshi in 2015-11

#import <Foundation/Foundation.h>

@class Location;
@class Modeprompt;  // Modified by MUKAI Takeshi in 2015-11
@class CancelledPrompt;  // Modified by MUKAI Takeshi in 2017-09 // cancelledPrompt

@interface CSVExporter : NSObject

+ (NSString*)exportObjects:(NSArray*)array;
+ (NSMutableArray*)exportObjectsForCustomSurvey:(NSArray*)array;  // Modified by MUKAI Takeshi in 2016-08 // for custom survey
+ (NSString*)exportObjectsModeprompt:(NSArray*)array;  // Modified by MUKAI Takeshi in 2015-11 // for modeprompts
+ (NSMutableArray*)exportObjectsModepromptForCustomSurvey:(NSArray*)array;  // Modified by MUKAI Takeshi in 2016-08 // for custom survey
+ (NSMutableArray*)exportObjectsCancelledPrompt:(NSArray*)array;  // Modified by MUKAI Takeshi in 2017-09 // cancelledPrompt

@end
