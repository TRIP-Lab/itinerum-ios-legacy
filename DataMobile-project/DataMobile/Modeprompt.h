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
//  Modeprompt.h
//  DataMobile
//
//  Created by Takeshi MUKAI on 11/13/15.
//  Copyright (c) 2015 MML-Concordia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface Modeprompt : NSManagedObject

@property (nonatomic) double latitude;
@property (nonatomic) double longitude;
@property (nonatomic) NSTimeInterval timestamp;
@property (nonatomic, retain) NSString * mode;
@property (nonatomic, retain) NSString * purpose;
@property (nonatomic) BOOL uploaded;
// for custom survey
@property (nonatomic) NSTimeInterval recorded_at;
@property (nonatomic, retain) NSDictionary * prompt_answer;
@property (nonatomic, retain) NSString * prompt_id;
@property (nonatomic) int32_t prompt_num;
@property (nonatomic, retain) NSString * uuid;

@end
