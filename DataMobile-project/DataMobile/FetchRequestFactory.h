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
//  FetchRequestFactory.h
//  DataMobile
//
//  Created by DataMobile on 13-07-15.
//  Copyright (c) 2013 MML-Concordia. All rights reserved.
//
// Modified by MUKAI Takeshi in 2015-11

#import <Foundation/Foundation.h>

/**
 * The role of this class is to create custom NSFetchRequest objects
 * to be used to manage the entities specifed in the DataMobile Core Data Model
 */
@interface FetchRequestFactory : NSObject

- (id)initWithManagedObjectContext:(NSManagedObjectContext*)moc;

// THE ONE WE ACTUALLY USE -_-
- (NSFetchRequest*)unSyncedLocationsFetchRequest;
- (NSFetchRequest*)unSyncedModepromptsFetchRequest;  // Modified by MUKAI Takeshi in 2015-11
- (NSFetchRequest*)unSyncedCancelledPromptsFetchRequest;  // Modified by MUKAI Takeshi in 2017-09  // cancelledPrompt

/**
 Returns the fetch request to use to get of All Locations sorted by Timestamp,
 with includesPropertyValues set to the passed corresponding parameter.
 
 @param ascending YES if the sorting is ascending, false if descending
 @param includesPropertyValues sets the value of the includesPropertyValues
 @returns the fetch request object
 */
- (NSFetchRequest*)getAllLocationsFetchRequestAscending:(BOOL)ascending
                                 includesPropertyValues:(BOOL)includesPropertyValues;

- (NSFetchRequest*)getAllModepromptsFetchRequestAscending:(BOOL)ascending
                                 includesPropertyValues:(BOOL)includesPropertyValues;  // Modified by MUKAI Takeshi in 2015-11
- (NSFetchRequest*)getAllCancelledPromptsFetchRequestAscending:(BOOL)ascending
                                        includesPropertyValues:(BOOL)includesPropertyValues;  // Modified by MUKAI Takeshi in 2017-09  // cancelledPrompt

/**
 Returns the fetch request to use to get all Objects instances of type *entityName*.
 
 @param entityName the Entity Name
 @returns the fetch request object
 */
- (NSFetchRequest*)getAllObjectsFetchRequest:(NSString *)entityName;

/**
 Returns the fetch request to use to get all Routes with a timestamp in between
 *startDate* and *endDate*
 
 @param startDate The Start Date
 @param endDate The End Date
 @returns the fetch request object
 */
- (NSFetchRequest*)getLocationsFetchRequestFromDate:(NSDate*)startDate
                                             ToDate:(NSDate*)endDate;

/**
 Returns the fetch request to use to get the location with the most recent timestamp.
 
 @returns the fetch request object
 */
- (NSFetchRequest*)getLastInsertedLocationFetchRequest;

/**
 Returns the fetch request to use to get the total current number of locations.
 
 @returns the fetch request object
 */
- (NSFetchRequest*)getLocationCountFetchRequest;

/**
 Returns the fetch request to use to get delete the *numOfLocation* oldest locations
 
 @param numOfLocations the Number of locations to delete
 @returns the fetch request object
 */
- (NSFetchRequest *)getOldestLocationsFetchRequest:(NSInteger)numOfLocations;

/**
 Returns the fetch request to use to get one User object from the database.
 
 @returns the fetch request object
 */
- (NSFetchRequest*)getFirstUserFetchRequest;

/**
 Returns the fetch request to use to get one CalibrationData object from the database.
 
 @returns the fetch request object
 */
- (NSFetchRequest*)getFirstCalibrationDataFetchRequest;


@end
