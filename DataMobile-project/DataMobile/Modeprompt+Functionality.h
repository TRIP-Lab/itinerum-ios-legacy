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
//  Modeprompt+Functionality.h
//  DataMobile
//
//  Created by Takeshi MUKAI on 11/13/15.
//  Copyright (c) 2015 MML-Concordia. All rights reserved.
//

#import "Modeprompt.h"

@interface Modeprompt (Functionality)

/**
 Returns a csv string equivalent of the location object.
 @param formatTimeStamp YES if the timestamp should be formatted, NO otherwise.
 @returns a csv string equivalent of the location object
 */
- (NSString*)csvStringWithFormattedTimeStamp:(BOOL)formatTimeStamp;
- (NSDictionary*)jsonDictWithFormattedTimeStampForCustomSurvey;  // for custom survey

@end
