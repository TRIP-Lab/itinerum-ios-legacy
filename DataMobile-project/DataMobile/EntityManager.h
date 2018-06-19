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
//  EntityManager.h
//  DataMobile
//
//  Created by DataMobile on 13-07-15.
//  Copyright (c) 2013 MML-Concordia. All rights reserved.
//
// Modified by MUKAI Takeshi in 2015-10

#import <Foundation/Foundation.h>
#import "Location+Functionality.h"
#import <CoreMotion/CoreMotion.h>  // Modified by MUKAI Takeshi in 2017-02

@class Location;
@class User;
@class Data;
@class DMUserSurveyForm;


/**
 * This class manages Entities specfied in the DataMobile Core Data Model file.
 */
@interface EntityManager : NSObject

- (id)initWithManagedObjectContext:(NSManagedObjectContext*)moc;

- (void)saveContext;


/**
 Inserts the passed location in the database
 @param newLocation the new location to insert.
 */
- (void)insertLocation:(CLLocation *)newLocation;
- (void)insertLocation:(CLLocation *)newLocation options:(DMPointOptions)pointOptions str:(NSString*)strMAData accelData:(CMAccelerometerData*)accelData;  // Modified by MUKAI Takeshi in 2017-01
- (void)insertModeprompt:(CLLocation*)location prompts:(NSArray*)prompts promptsID:(NSArray *)promptsID;  // Modified by MUKAI Takeshi in 2016-11  // for custom survey
- (void)insertCancelledPrompt:(CLLocation*)location and:(BOOL)isCancelledByUser and:(NSString*)isTravelling;  // Modified by MUKAI Takeshi in 2017-09  // cancelledPrompt
- (void)insertNewUserIfNotExists;


/**
 update user survey with values from provided form object
 */

- (void)updateUserSurveyWithForm:(DMUserSurveyForm*)form;
- (void)updateUserSurveyForCustomSurvey:(NSDictionary *)dictSurveyAnswer;  // Modified by MUKAI Takeshi in 2016-08 - for custom survey
- (void)updateCustomSurveyData:(NSDictionary *)dictSurvey;  // Modified by MUKAI Takeshi in 2016-08 - for custom survey

/**
 Update the user survey attributes with the passed values
 */
- (void)updateUserSurveyAttributesWithEmail:(NSString*)userEmail;


/**
 * Fetches the passed request, ignoring the error.
 */
- (NSArray*)fetchRequest:(NSFetchRequest*)request;

/**
 @returns an array of All Locations sorted by Timestamp in Ascending order.
 */
- (NSArray*)fetchAllLocations;

/**
 @returns an array of Unsynced Locations with server.
 */
- (NSArray*)fetchUnsyncedLocations;
- (NSArray*)fetchUnsyncedModeprompts;  // Modified by MUKAI Takeshi in 2015-11
- (NSArray*)fetchUnsyncedCancelledPrompts;  // Modified by MUKAI Takeshi in 2017-09  // cancelledPrompt

/**
 * Returns the current number of locations.
 */
- (NSUInteger)numOfLocations;

/**
 @param startDate The Start Date
 @param endDate The End Date
 @returns an array of all Routes with a timestamp in between
 *startDate* and *endDate*
 */
- (NSArray*)fetchLocationsFromDate:(NSDate*)startDate
                            ToDate:(NSDate*)endDate;

/**
 @returns the location with the most recent timestamp.
 */
- (Location*)fetchLastInsertedLocation;

/**
 @returns the first User Entity, nil if there are no User in the database.
 */
- (User*)fetchUser;

/**
 @returns true if user has been created and has completed the survey,
 false otherwise.
 */
- (BOOL)userExistsAndCompletedSurvey;
- (BOOL)userExistsAndCompletedSurveyCustom;  // Modified by MUKAI Takeshi in 2017-01 - for custom survey
- (BOOL)hasUplodedUser;  // Modified by MUKAI Takeshi in 2016-08 - for custom survey
- (NSDictionary*)fetchCustomSurveyData;  // Modified by MUKAI Takeshi in 2016-08 - for custom survey
- (NSDate*)fetchSurveyStartDate;  // Modified by MUKAI Takeshi in 2017-02

/**
 @returns the first CalibrationData Entity, nil if there are no User in the database.
 */
- (Data*)fetchData;

/**
 @returns true if at least one CalibrationData entity has been created
 false otherwise.
 */
- (BOOL)calibrationCompleted;
- (void)updateCalibrationDataWithX:(double)x Y:(double)y AndZ:(double)z;


/**
 Delete all the locations objects from the database.
 */
- (void)deleteAllLocations;

/**
 Delete the oldest locations
 @param numOfObjects the number of locations to delete
 */
- (void)deleteOldestLocations:(NSInteger)numOfLocations;

/**
 Delete all the objects from the database.
 */
- (void)deleteAllObjects:(NSString*)entityName;


@end
