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
//  DMUSDataManager.h
//  DataMobile
//
//  Created by Takeshi MUKAI on 10/30/15.
//  Copyright (c) 2015 MML-Concordia. All rights reserved.
//

#import <Foundation/Foundation.h>

#define DM_MEMBER_TYPE_OPTIONS @[@"A full time worker", @"A part-time worker", @"A student", @"A student and worker", @"Retired", @"At home"]
#define DM_TRAVEL_OPTIONS @[@"Car", @"On foot", @"Public Transportation (PT)", @"Bicycle", @"Car and PT", @"Other Modes", @"Other Combinations"]
#define DM_TRAVEL_ALT_OPTIONS @[@"No", @"Yes, Car", @"Yes, On foot", @"Yes, Public Transportation (PT)", @"Yes, Bicycle", @"Yes, Car and PT", @"Yes, Other Modes", @"Yes, Other Combinations"]


@interface DMUSDataManager : NSObject

+ (id)instance;
+(void)clearSharedInstance;

@property (nonatomic, retain) NSDictionary* locationHome;
@property (nonatomic) NSInteger memberType;
@property (nonatomic, retain) NSDictionary* locationWork;
@property (nonatomic) NSInteger travelModeWork;
@property (nonatomic) NSInteger travelModeAltWork;
@property (nonatomic, retain) NSDictionary* locationStudy;
@property (nonatomic) NSInteger travelModeStudy;
@property (nonatomic) NSInteger travelModeAltStudy;
@property (nonatomic) BOOL isWorkInfoEnded;

// for DMUserSurveyForm - just for use and save DMUserSurveyForm vaules temporary in DMUserSurveyForm
@property (nonatomic) NSInteger sex;
@property (nonatomic) NSInteger ageBracket;
@property (nonatomic) NSInteger licenseXorTransitPass;
@property (nonatomic) NSInteger livingArrangement;
@property (nonatomic) NSInteger totalPeopleInHome;
@property (nonatomic) NSInteger totalCarsInHome;
@property (nonatomic) NSInteger peopleUnder16InHome;
@property (strong, retain) NSString* email;
@property (nonatomic) BOOL useReminders;

// for custom survey
@property (nonatomic) NSInteger customSurveyIndex;
@property (nonatomic, retain) NSMutableArray* arrayAnswers;
@property (nonatomic) BOOL isWorker;
@property (nonatomic) BOOL isStudent;

@end
