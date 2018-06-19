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
//  DMUserSurveyForm.h
//  DataMobile
//
//  Created by Colin Rofls on 2014-07-27.
//  Copyright (c) 2014 MML-Concordia. All rights reserved.
//
// Modified by MUKAI Takeshi in 2015-10
// based on Concordia version

#import "FXForms.h"
#import "DMUSDataManager.h"


typedef NS_ENUM(NSInteger, DMSurveySex)
{
    DMSurveySexMale = 0,
    DMSurveySexFemale = 1,
    DMSurveySexOther = 2
};

typedef NS_ENUM(NSInteger, DMSurveyAgeBracket)
{
    DMSurveyAgeBracket16to24 = 0,
    DMSurveyAgeBracket25To34 = 1,
    DMSurveyAgeBracket35To44 = 2,
    DMSurveyAgeBracket45To54 = 3,
    DMSurveyAgeBracket55To64 = 4,
    DMSurveyAgeBracketOver65 = 5
};

typedef NS_OPTIONS(NSUInteger, DMSurveyQualification)
{
    DMSurveyQualificationNone = 0,
    DMSurveyQualificationDriversLicense = 1 << 0,
    DMSurveyQualificationBusPass = 1 << 1
};

typedef NS_ENUM(NSInteger, DMSurveyLivingArrangement)
{
    DMSurveyLivingArrangementWithParents = 1,
    DMSurveyLivingArrangementAlone,
    DMSurveyLivingArrangementRoommates,
    DMSurveyLivingArrangementFamily
};

#define DM_SURVEY_START_DATE_KEY @"DMSurveyStartDate"
//#define DM_DAY_DURATION_OF_SURVEY 14

#define DM_SEX_FIELD_KEY @"sex"
#define DM_AGE_FIELD_KEY @"ageBracket"
#define DM_LICENCE_XOR_TRANSIT_FIELD_KEY @"licenseXorTransitPass"
#define DM_TOTAL_PEOPLE_FIELD_KEY @"totalPeopleInHome"
#define DM_TOTAL_CARS_FIELD_KEY @"totalCarsInHome"
#define DM_YOUNG_PEOPLE_FIELD_KEY @"peopleUnder16InHome"
//#define DM_OPT_IN_FIELD_KEY @"contestOptIn"
#define DM_EMAIL_FIELD_KEY @"email"
#define DM_REMINDERS_FIELD_KEY @"useReminders"
#define DM_LIVING_ARRANGEMENT_KEY @"livingArrangement"

#define DM_SEX_OPTIONS @[@"Male", @"Female", @"Other/Neither"]
#define DM_AGE_OPTIONS @[@"16 to 24", @"25 to 34", @"35 to 44", @"45 to 54", @"55 to 64", @"65 or older"]
#define DM_LIVING_ARRANGEMENT_OPTIONS @[@"With my parents", @"By myself", @"With roommates", @"With my family"]

@interface DMUserSurveyForm : NSObject <FXForm>
@property (nonatomic) DMSurveySex sex;
@property (nonatomic) DMSurveyAgeBracket ageBracket;
@property (nonatomic) DMSurveyQualification licenseXorTransitPass;
@property (nonatomic) DMSurveyLivingArrangement livingArrangement;
@property (nonatomic) NSUInteger totalPeopleInHome;
@property (nonatomic) NSUInteger totalCarsInHome;
@property (nonatomic) NSUInteger peopleUnder16InHome;
@property (strong, nonatomic) NSString* email;
@property (nonatomic) BOOL useReminders;

@property (nonatomic, retain) DMUSDataManager *usDataManager;
- (void)reloadValue;
- (void)saveValue;

- (NSString*)userDocumentsString;

@end
