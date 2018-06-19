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
//  CoreDataHelper.m
//  DataMobile
//
//  Created by Zachary Patterson on 3/19/12.
//  Copyright (c) 2012 MML-Concordia. All rights reserved.
//

#import "CoreDataHelper.h"
#import "Location.h"
#import "User.h"
#import "EntityManager.h"
#import "DMDocumentDirectoryHelper.h"

@interface CoreDataHelper ()

@end

@implementation CoreDataHelper

static CoreDataHelper* instance;

@synthesize entityManager = __entityManager;
@synthesize storeURL;

@synthesize managedObjectContext = __managedObjectContext;
@synthesize managedObjectModel = __managedObjectModel;
@synthesize persistentStoreCoordinator = __persistentStoreCoordinator;

/**
 * Singleton implementation
 */
+ (void)initialize
{
    if (instance == nil)
    {
        NSString *cdataPath = [[[DMDocumentDirectoryHelper applicationDocumentsDirectory] path] stringByAppendingPathComponent:@"DataMobile.sqlite"];
        NSURL *cdataUrl = [NSURL fileURLWithPath:cdataPath];
        
        instance = [[CoreDataHelper alloc] init];
        instance.storeURL = cdataUrl;
    }
}

+ (CoreDataHelper *)instance
{
    return instance;
}

- (void)resetContext
{
    [self.entityManager saveContext];
    [self.managedObjectContext reset];
}

- (EntityManager *)entityManager
{
    if(__entityManager == nil)
    {
        __entityManager = [[EntityManager alloc] initWithManagedObjectContext:self.managedObjectContext];
    }
    return __entityManager;
}

#pragma mark - Core Data stack

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *)managedObjectContext
{
    if (__managedObjectContext != nil)
    {
        return __managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil)
    {
        __managedObjectContext = [[NSManagedObjectContext alloc] init];
        [__managedObjectContext setPersistentStoreCoordinator:coordinator];
        [__managedObjectContext setUndoManager:nil];
    }

    return __managedObjectContext;
}

/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created from the application's model.
 */
- (NSManagedObjectModel *)managedObjectModel
{
    if (__managedObjectModel != nil)
    {
        return __managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"DataMobile" withExtension:@"momd"];
    __managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return __managedObjectModel;
}

/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (__persistentStoreCoordinator != nil)
    {
        return __persistentStoreCoordinator;
    }
    
    NSError *error = nil;
    __persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![__persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:self.storeURL options:nil error:&error])
    {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         *///[[NSFileManager defaultManager] removeItemAtURL:self.storeURL error:nil];
        
         // Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         NSDictionary* options = [NSDictionary dictionaryWithObjectsAndKeys:
                                      [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                                      [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption,
                                      nil];
        
        if(![__persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                   configuration:nil
                                                             URL:self.storeURL
                                                         options:options
                                                        error:&error])
        {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
         
         /*Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.*/
    }    
    
    return __persistentStoreCoordinator;
}

@end
