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
//  FetchRequestFactory.m
//  DataMobile
//
//  Created by DataMobile on 13-07-15.
//  Copyright (c) 2013 MML-Concordia. All rights reserved.
//
// Modified by MUKAI Takeshi in 2015-11

#import "FetchRequestFactory.h"

@interface FetchRequestFactory()

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end

@implementation FetchRequestFactory

- (id)initWithManagedObjectContext:(NSManagedObjectContext*)moc
{
    if(self = [super init])
    {
        self.managedObjectContext = moc;
    }
    return self;
}


- (NSFetchRequest*)unSyncedLocationsFetchRequest {
    NSFetchRequest* locationsFetchRequest = [self getAllLocationsFetchRequestAscending:NO
                                                                includesPropertyValues:YES];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"uploaded == NO || uploaded == nil"];
    [locationsFetchRequest setPredicate:predicate];
    
    return locationsFetchRequest;
}

- (NSFetchRequest*)getAllLocationsFetchRequestAscending:(BOOL)ascending
                                 includesPropertyValues:(BOOL)includesPropertyValues
{
    NSFetchRequest *request = [self getAllObjectsFetchRequest:@"Location"];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timestamp"
                                                                   ascending:ascending];
    
    request.sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    request.includesPropertyValues = includesPropertyValues;
    return request;
}

// Modified by MUKAI Takeshi in 2015-11
- (NSFetchRequest*)unSyncedModepromptsFetchRequest {
    NSFetchRequest* modepromptsFetchRequest = [self getAllModepromptsFetchRequestAscending:NO
                                                                  includesPropertyValues:YES];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"uploaded == NO || uploaded == nil"];
    [modepromptsFetchRequest setPredicate:predicate];
    
    return modepromptsFetchRequest;
}

- (NSFetchRequest*)getAllModepromptsFetchRequestAscending:(BOOL)ascending
                                 includesPropertyValues:(BOOL)includesPropertyValues
{
    NSFetchRequest *request = [self getAllObjectsFetchRequest:@"Modeprompt"];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timestamp"
                                                                   ascending:ascending];
    
    request.sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    request.includesPropertyValues = includesPropertyValues;
    return request;
}

// Modified by MUKAI Takeshi in 2017-09  // cancelledPrompt
- (NSFetchRequest*)unSyncedCancelledPromptsFetchRequest {
    NSFetchRequest* cancelledPromptsFetchRequest = [self getAllCancelledPromptsFetchRequestAscending:NO
                                                                              includesPropertyValues:YES];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"uploaded == NO || uploaded == nil"];
    [cancelledPromptsFetchRequest setPredicate:predicate];
    
    return cancelledPromptsFetchRequest;
}

- (NSFetchRequest*)getAllCancelledPromptsFetchRequestAscending:(BOOL)ascending
                                        includesPropertyValues:(BOOL)includesPropertyValues
{
    NSFetchRequest *request = [self getAllObjectsFetchRequest:@"CancelledPrompt"];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timestamp"
                                                                   ascending:ascending];
    
    request.sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    request.includesPropertyValues = includesPropertyValues;
    return request;
}


- (NSFetchRequest*)getAllObjectsFetchRequest:(NSString *)entityName
{
    NSEntityDescription *eDescription = [NSEntityDescription entityForName:entityName
                                                    inManagedObjectContext:self.managedObjectContext];
    
    NSFetchRequest* request = [[NSFetchRequest alloc] init];
    request.entity = eDescription;    
    return request;
}

- (NSFetchRequest*)getLocationsFetchRequestFromDate:(NSDate*)startDate
                                             ToDate:(NSDate*)endDate
{
    NSFetchRequest *fetchRequest = [self getAllLocationsFetchRequestAscending:YES
                                                       includesPropertyValues:YES];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%@ < timestamp && timestamp < %@",
                              startDate,
                              endDate];
    [fetchRequest setPredicate:predicate];
    
    return fetchRequest;
}

- (NSFetchRequest*)getLastInsertedLocationFetchRequest
{
    NSFetchRequest *request = [self getAllLocationsFetchRequestAscending:NO
                                                  includesPropertyValues:YES];
    request.fetchOffset = 0;
    request.fetchLimit = 1;
    
    return request;
}

- (NSFetchRequest*)getLocationCountFetchRequest
{
    NSFetchRequest *request = [self getAllLocationsFetchRequestAscending:YES
                                                  includesPropertyValues:YES];
//    request.resultType = NSCountResultType;
    [request setIncludesSubentities:NO];
    
    return request;
}

- (NSFetchRequest *)getOldestLocationsFetchRequest:(NSInteger)numOfLocations
{
    NSFetchRequest *fetchRequest = [self getAllLocationsFetchRequestAscending:YES
                                                       includesPropertyValues:NO];
    fetchRequest.fetchOffset = 0;
    fetchRequest.fetchLimit = numOfLocations;
    return fetchRequest;
}

- (NSFetchRequest*)getFirstUserFetchRequest
{
    NSFetchRequest *request = [self getAllObjectsFetchRequest:@"User"];
    request.fetchOffset = 0;
    request.fetchLimit = 1;
    request.includesPropertyValues = YES;
    
    return request;
}

- (NSFetchRequest*)getFirstCalibrationDataFetchRequest
{
    NSFetchRequest *request = [self getAllObjectsFetchRequest:@"Data"];
    request.fetchOffset = 0;
    request.fetchLimit = 1;
    request.includesPropertyValues = YES;
    
    return request;
}

@end
