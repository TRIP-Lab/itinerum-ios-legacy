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
//  Config.m
//  DataMobile
//
//  Created by Kim Sawchuk on 11-12-16.
//  Copyright (c) 2011 MML-Concordia. All rights reserved.
//

#import "Config.h"

@implementation Config

@synthesize configs;
@synthesize fileLoaded;

static Config* instance;

/**
 * Singleton implementation
 */
+ (void)initialize
{
    if (instance == nil) 
    {
        instance = [[Config alloc] init];
    }
}

+(Config*)loadForFileName:(NSString*)name
{
    if (![instance.fileLoaded isEqualToString:name]) 
    {
        [Config initialize];
        
        NSString *path = [[NSBundle mainBundle] pathForResource:name
                                                         ofType:@"plist"];
        instance.configs = [NSDictionary dictionaryWithContentsOfFile:path];
        instance.fileLoaded = name;
    }
    return instance;
}

+(Config*)instance
{
    return instance;
}

-(id)valueForKey:(NSString*)key
{
    return [self.configs valueForKey:key];
}

-(NSString*)stringValueForKey:(NSString*)key
{
    return (NSString*)[self valueForKey:key];
}

-(int)integerValueForKey:(NSString*)key
{
    NSString *value = (NSString*)[self stringValueForKey:key];
    return [value intValue];
}

// Modified by MUKAI Takeshi - for custom survey
-(NSDictionary*)dictionaryValueForKey:(NSString*)key
{
    return (NSDictionary*)[self valueForKey:key];
}

-(NSArray*)arrayValueForKey:(NSString*)key
{
    return (NSArray*)[self valueForKey:key];
}

@end
