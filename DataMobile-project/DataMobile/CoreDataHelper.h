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
//  CoreDataHelper.h
//  DataMobile
//
//  Created by Zachary Patterson on 3/19/12.
//  Copyright (c) 2012 MML-Concordia. All rights reserved.
//


#import <Foundation/Foundation.h>

@class Location;
@class User;
@class EntityManager;

/**
 * Wrapper around the CoreData-related classes.
 */
@interface CoreDataHelper : NSObject

@property (strong, nonatomic) NSURL* storeURL;
@property (strong, nonatomic) EntityManager* entityManager;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

+ (CoreDataHelper*)instance;

/**
 *  Resets the Context
 */
- (void)resetContext;

@end
