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
//  Config.h
//  DataMobile
//
//  Created by Kim Sawchuk on 11-12-16.
//  Copyright (c) 2011 MML-Concordia. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Config : NSObject

@property (strong, nonatomic) NSDictionary* configs;
@property (strong, nonatomic) NSString* fileLoaded;

+(Config*)loadForFileName:(NSString*)name;
+(Config*)instance;

-(id)valueForKey:(NSString*)key;
-(NSString*)stringValueForKey:(NSString*)key;
-(int)integerValueForKey:(NSString*)key;
-(NSDictionary*)dictionaryValueForKey:(NSString*)key;  // Modified by MUKAI Takeshi in 2016-08 // for custom survey
-(NSArray*)arrayValueForKey:(NSString*)key;  // Modified by MUKAI Takeshi in 2016-11 // for custom survey

@end
