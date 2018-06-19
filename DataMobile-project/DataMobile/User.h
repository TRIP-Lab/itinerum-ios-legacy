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
//  User.h
//  DataMobile
//
//  Created by Colin Rofls on 2014-11-09.
//  Copyright (c) 2014 MML-Concordia. All rights reserved.
//
// Modified by MUKAI Takeshi in 2015-10

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface User : NSManagedObject

@property (nonatomic, retain) NSString * device_id;
@property (nonatomic, retain) NSDate * created_at;
// from Concordia Version
@property (nonatomic, retain) NSString * member_type;
@property (nonatomic, retain) NSString * sex;
@property (nonatomic, retain) NSString * age_bracket;
@property (nonatomic, retain) NSString * user_docs;
@property (nonatomic, retain) NSString * lives_with;
@property (nonatomic, retain) NSString * num_of_people_living;
@property (nonatomic, retain) NSString * num_of_minors;
@property (nonatomic, retain) NSString * num_of_cars;
@property (nonatomic, retain) NSString * email;

// Modified by MUKAI Takeshi in 2015-10
// new values for DM general ver
@property (nonatomic, retain) NSString * location_home;
@property (nonatomic, retain) NSString * location_work;
@property (nonatomic, retain) NSString * location_study;
@property (nonatomic, retain) NSString * travel_mode_work;
@property (nonatomic, retain) NSString * travel_mode_alt_work;
@property (nonatomic, retain) NSString * travel_mode_study;
@property (nonatomic, retain) NSString * travel_mode_alt_study;
@property (nonatomic, retain) NSNumber * has_completed_survey_general;

// for custom survey
@property (nonatomic, retain) NSDictionary * custom_survey_data;
@property (nonatomic, retain) NSDictionary * custom_survey_answer;
@property (nonatomic, retain) NSNumber * has_completed_survey_custom;
@property (nonatomic) BOOL uploaded;
@property (nonatomic, retain) NSDate * survey_start_date;

@end
