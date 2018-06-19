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
//  DMUSDataManager.m
//  DataMobile
//
//  Created by Takeshi MUKAI on 10/30/15.
//  Copyright (c) 2015 MML-Concordia. All rights reserved.
//

#import "DMUSDataManager.h"

@implementation DMUSDataManager
@synthesize locationHome, memberType, locationWork, travelModeWork, travelModeAltWork, locationStudy, travelModeStudy, travelModeAltStudy, isWorkInfoEnded;
@synthesize sex, ageBracket, licenseXorTransitPass, livingArrangement, totalPeopleInHome, totalCarsInHome, peopleUnder16InHome, email, useReminders;
// for custom survey
@synthesize customSurveyIndex, arrayAnswers, isWorker, isStudent;

- (id)init
{
    self =  [super init];
    if(self) {
        memberType = -1;
        travelModeWork = -1;
        travelModeAltWork = -1;
        travelModeStudy = -1;
        travelModeAltStudy = -1;
        
        sex = -1;
        ageBracket = -1;
        livingArrangement = -1;
        
        // for custom survey
        arrayAnswers = [NSMutableArray array];
    }
    return self;
}

static DMUSDataManager *_instance = nil ;
static dispatch_once_t pred ;

+ (id)instance
{
    dispatch_once(&pred, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}

+(void)clearSharedInstance {
    _instance = nil;
    pred = 0 ;
}

@end
