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
//  EntityManager.m
//  DataMobile
//
//  Created by DataMobile on 13-07-15.
//  Copyright (c) 2013 MML-Concordia. All rights reserved.
//
// Modified by MUKAI Takeshi in 2015-10


#import "EntityManager.h"
#import "Location+Functionality.h"
#import "User.h"
#import "Data.h"
#import "FetchRequestFactory.h"
#import "DMUserSurveyForm.h"

// Modified by MUKAI Takeshi in 2015-10
#import "DMUSDataManager.h"
#import "Modeprompt+Functionality.h"
#import "CancelledPrompt+Functionality.h"  // cancelledPrompt


#define MAX_NUMBER_OF_LOCATIONS 10000
#define LOCATION_BUFFER 100

@interface EntityManager()

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) FetchRequestFactory *fetchRequestFactory;
@property (strong, nonatomic) DMUSDataManager *usDataManager;  // Modified by MUKAI Takeshi in 2015-10

@end

@implementation EntityManager

@synthesize managedObjectContext;

- (id)initWithManagedObjectContext:(NSManagedObjectContext*)moc
{
    if(self = [super init])
    {
        self.managedObjectContext = moc;
        self.fetchRequestFactory = [[FetchRequestFactory alloc] initWithManagedObjectContext:moc];
        self.usDataManager = [DMUSDataManager instance];  // Modified by MUKAI Takeshi in 2015-10
    }
    return self;
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *moc = self.managedObjectContext;
    if (moc != nil)
    {
        if ([moc hasChanges] && ![moc save:&error])
        {
            /*
             Replace this implementation with code to handle the error appropriately.
             
             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
             */
            
            NSLog(@"%@", [[NSThread callStackSymbols] description]);
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

- (void)insertLocation:(CLLocation*)newLocation
{
    // Modified by MUKAI Takeshi in 2017-01
    [self insertLocation:newLocation options:0 str:nil accelData:nil];
}

// Modified by MUKAI Takeshi in 2017-01
// Save new Location
- (void)insertLocation:(CLLocation *)newLocation options:(DMPointOptions)pointOptions str:(NSString*)strMAData accelData:(CMAccelerometerData*)accelData {
    
    NSUInteger locationCount = [self numOfLocations];
    
    if(locationCount > MAX_NUMBER_OF_LOCATIONS)
    {
        DDLogWarn(@"too many locations, deleting old locations (!?)");
        [self deleteOldestLocations:LOCATION_BUFFER];
    }
    
    // Save new Location :
    Location* location = (Location*)[NSEntityDescription insertNewObjectForEntityForName:@"Location"
                                                                  inManagedObjectContext:self.managedObjectContext];
    
    location.altitude = newLocation.altitude;
    location.latitude = newLocation.coordinate.latitude;
    location.longitude = newLocation.coordinate.longitude;
    location.speed = newLocation.speed;
    location.direction = newLocation.course;
    location.h_accuracy = newLocation.horizontalAccuracy;
    location.v_accuracy = newLocation.verticalAccuracy;
    location.timestamp = [newLocation.timestamp timeIntervalSinceReferenceDate];
    location.pointType = pointOptions;
    location.modeDetected = strMAData;  // Modified by MUKAI Takeshi in 2017-01
    location.acceleration_x = accelData.acceleration.x;  // Modified by MUKAI Takeshi in 2017-01
    location.acceleration_y = accelData.acceleration.y;  // Modified by MUKAI Takeshi in 2017-02
    location.acceleration_z = accelData.acceleration.z;  // Modified by MUKAI Takeshi in 2017-02
    
    [self saveContext];
}

// Modified by MUKAI Takeshi in 2016-11
// Save new Modeprompt  // for custom survey
- (void)insertModeprompt:(CLLocation*)newLocation prompts:(NSArray*)prompts promptsID:(NSArray*)promptsID{

    //MARK: MODIFIED BY SAGAR TO FIX THIS : https://gitlab.com/itinerum/itinerum-ios/issues/66
    
    NSString * uuid = [[NSUUID UUID] UUIDString];
    
    if ([self fetchCustomSurveyData]) {
        for (int i=0; i<prompts.count; i++) {
            Modeprompt* modeprompt = (Modeprompt*)[NSEntityDescription insertNewObjectForEntityForName:@"Modeprompt"
                                                                                inManagedObjectContext:self.managedObjectContext];
            
            // if custom survey
            modeprompt.latitude = newLocation.coordinate.latitude;
            modeprompt.longitude = newLocation.coordinate.longitude;
            modeprompt.timestamp = [newLocation.timestamp timeIntervalSinceReferenceDate];
            modeprompt.recorded_at = [[NSDate date] timeIntervalSinceReferenceDate];
            // prompt answers
            modeprompt.prompt_answer = [NSDictionary dictionaryWithObject:prompts[i] forKey:@"prompt_answer"];
            modeprompt.prompt_id = [NSString stringWithFormat:@"%@",promptsID[i]];
            modeprompt.prompt_num = i ;
            modeprompt.uuid = uuid ;
            
            [self saveContext];
        }
    }else{
        Modeprompt* modeprompt = (Modeprompt*)[NSEntityDescription insertNewObjectForEntityForName:@"Modeprompt"
                                                                            inManagedObjectContext:self.managedObjectContext];
        
        modeprompt.latitude = newLocation.coordinate.latitude;
        modeprompt.longitude = newLocation.coordinate.longitude;
        modeprompt.timestamp = [newLocation.timestamp timeIntervalSinceReferenceDate];
        modeprompt.mode = [NSString stringWithFormat:@"%@",prompts[0]];
        modeprompt.purpose = [NSString stringWithFormat:@"%@",prompts[1]];
        //MARK: CHANGED BY SAGAR
        modeprompt.prompt_num = 0 ;
        modeprompt.uuid = uuid;
        
        [self saveContext];
    }
}

// Modified by MUKAI Takeshi in 2017-09
// Save new cancelledPrompt  // cancelledPrompt
- (void)insertCancelledPrompt:(CLLocation*)newLocation and:(BOOL)isCancelledByUser and:(NSString*)isTravelling{
    CancelledPrompt* cancelledPrompt = (CancelledPrompt*)[NSEntityDescription insertNewObjectForEntityForName:@"CancelledPrompt"
                                                                                       inManagedObjectContext:self.managedObjectContext];
    
    cancelledPrompt.latitude = newLocation.coordinate.latitude;
    cancelledPrompt.longitude = newLocation.coordinate.longitude;
    cancelledPrompt.timestamp = [newLocation.timestamp timeIntervalSinceReferenceDate];
    if (isCancelledByUser) {
        cancelledPrompt.cancelled_at = [[NSDate date] timeIntervalSinceReferenceDate];
    }else{
        cancelledPrompt.cancelled_at = 0;
    }
    cancelledPrompt.is_travelling = isTravelling;
    
    [self saveContext];
}

// Create new user with device_id and created_at
- (void)insertNewUserIfNotExists
{
    if([self fetchUser] == nil)
    {
        User* newUser = [NSEntityDescription insertNewObjectForEntityForName:@"User"
                                                      inManagedObjectContext:self.managedObjectContext];
        
        // Modified by MUKAI Takeshi in 2017-03
        // for joining any survies, I've changed to create different uuid when here is called - before, ID never changes even when app is reinstalled.
//        newUser.device_id = [[[UIDevice currentDevice] identifierForVendor]UUIDString];
        newUser.device_id = [[NSUUID UUID] UUIDString];
        newUser.created_at = [NSDate date];
        [self saveContext];
    }
}

// Modified by MUKAI Takeshi in 2015-10
// this is called when the submit button is touched in DMUserSurveyView
// add user
- (void)updateUserSurveyWithForm:(DMUserSurveyForm *)form {
    
    [self insertNewUserIfNotExists];
    User* user = [self fetchUser];
    
    
    if (self.usDataManager.locationHome.count) {
        user.location_home = [self stringFromLocations:self.usDataManager.locationHome];
    }else {
        user.location_home = @"None";
    }
    if (self.usDataManager.locationWork.count) {
        user.location_work = [self stringFromLocations:self.usDataManager.locationWork];
    }else {
        user.location_work = @"None";
    }
    if (self.usDataManager.locationStudy.count) {
        user.location_study = [self stringFromLocations:self.usDataManager.locationStudy];
    }else {
        user.location_study = @"None";
    }
    
    user.member_type = DM_MEMBER_TYPE_OPTIONS[self.usDataManager.memberType];
    user.travel_mode_work = self.usDataManager.travelModeWork >= 0 ? DM_TRAVEL_OPTIONS[self.usDataManager.travelModeWork] : @"None";
    user.travel_mode_alt_work = self.usDataManager.travelModeAltWork >= 0 ? DM_TRAVEL_ALT_OPTIONS[self.usDataManager.travelModeAltWork] : @"None";
    user.travel_mode_study = self.usDataManager.travelModeStudy >= 0 ? DM_TRAVEL_OPTIONS[self.usDataManager.travelModeStudy] : @"None";
    user.travel_mode_alt_study = self.usDataManager.travelModeAltStudy >= 0 ? DM_TRAVEL_ALT_OPTIONS[self.usDataManager.travelModeAltStudy] : @"None";
    
    // if not worker
    if (self.usDataManager.memberType<0||self.usDataManager.memberType==2||self.usDataManager.memberType>=4) {
        user.location_work = @"None";
        user.travel_mode_work = @"None";
        user.travel_mode_alt_work = @"None";
    }
    // if not student
    if (self.usDataManager.memberType<=1||self.usDataManager.memberType>=4) {
        user.location_study = @"None";
        user.travel_mode_study = @"None";
        user.travel_mode_alt_study = @"None";
    }
    
    user.sex = DM_SEX_OPTIONS[form.sex];
    user.age_bracket = DM_AGE_OPTIONS[form.ageBracket];
    user.user_docs = [form userDocumentsString];
    user.lives_with = DM_LIVING_ARRANGEMENT_OPTIONS[form.livingArrangement];
    
    user.num_of_people_living = [NSString stringWithFormat:@"%lu", (unsigned long)form.totalPeopleInHome];
    user.num_of_minors = [NSString stringWithFormat:@"%lu", (unsigned long)form.peopleUnder16InHome];
    user.num_of_cars = [NSString stringWithFormat:@"%lu", (unsigned long)form.totalCarsInHome];
    if (form.email) {
        user.email = [form.email copy];
    }else{
        user.email = @"None";
    }
    user.has_completed_survey_general = @YES;
    user.custom_survey_data = nil;  // for custom survey
    
    [self saveContext];
    DDLogInfo(@"added new user");
}

// Modified by MUKAI Takeshi in 2016-08
// for custom survey
- (void)updateUserSurveyForCustomSurvey:(NSDictionary *)dictSurveyAnswer {
    
    User* user = [self fetchUser];
    
    user.custom_survey_answer = dictSurveyAnswer;
    user.has_completed_survey_custom = @YES;
    user.survey_start_date = [NSDate date];  // set survey start date
    
    [self saveContext];
    DDLogInfo(@"added new user");
    DDLogInfo(@"set survey start date: %@", [NSDate date]);
}

// Modified by MUKAI Takeshi in 2016-08
// for custom survey
- (void)updateCustomSurveyData:(NSDictionary *)dictSurvey {
    
    User* user = [self fetchUser];
    
    user.custom_survey_data = dictSurvey;
    
    [self saveContext];
}

- (NSString*)stringFromLocations:(NSDictionary*)locationDict {
    NSString *result = @"";
    CLLocation *location = locationDict[@"location"];
    result = [result stringByAppendingString:[NSString stringWithFormat:@"(%0.6f, %0.6f)",
                                              location.coordinate.latitude,
                                              location.coordinate.longitude]];
    return result;
}

- (void)updateUserSurveyAttributesWithEmail:(NSString*)userEmail
{
    [self insertNewUserIfNotExists];
    User* user = [self fetchUser];
    
    user.email = userEmail;
    
    [self saveContext];
}


- (NSArray*)fetchRequest:(NSFetchRequest*)request
{
    NSError *error;
    return  [self.managedObjectContext executeFetchRequest:request
                                                     error:&error];
}

- (NSArray*)fetchAllLocations
{
    NSFetchRequest *request = [self.fetchRequestFactory getAllLocationsFetchRequestAscending:NO
                                                                      includesPropertyValues:YES];
    return [self fetchRequest:request];
}

- (NSArray*)fetchUnsyncedLocations {
    NSFetchRequest *request = [self.fetchRequestFactory unSyncedLocationsFetchRequest];
    return [self fetchRequest:request];
}

// Modified by MUKAI Takeshi in 2015-11
- (NSArray*)fetchUnsyncedModeprompts {
    NSFetchRequest *request = [self.fetchRequestFactory unSyncedModepromptsFetchRequest];
    return [self fetchRequest:request];
}

// Modified by MUKAI Takeshi in 2017-09  // cancelledPrompt
- (NSArray*)fetchUnsyncedCancelledPrompts {
    NSFetchRequest *request = [self.fetchRequestFactory unSyncedCancelledPromptsFetchRequest];
    return [self fetchRequest:request];
}

- (NSUInteger)numOfLocations
{
    NSFetchRequest *request = [self.fetchRequestFactory getLocationCountFetchRequest];
    NSError *error;
    NSUInteger count = [self.managedObjectContext countForFetchRequest:request error:&error];
    if (error) {
        DDLogError(@"number of locations fetch failed with error %@", error.localizedDescription);
    }
    return count;
}

- (NSArray*)fetchLocationsFromDate:(NSDate*)startDate
                            ToDate:(NSDate*)endDate
{
    if(startDate == nil || endDate == nil)
    {
        return [[NSArray alloc] init];
    }
    else
    {
        NSFetchRequest *fetchRequest = [self.fetchRequestFactory getLocationsFetchRequestFromDate:startDate
                                                                                           ToDate:endDate];
        return [self fetchRequest:fetchRequest];
    }
}

- (Location *)fetchLastInsertedLocation
{
    NSFetchRequest* request = [self.fetchRequestFactory getLastInsertedLocationFetchRequest];
    NSArray* result = [self fetchRequest:request];
    return [result count] > 0 ? (Location*)[result objectAtIndex:0] : nil;
}

- (User *)fetchUser
{
    NSFetchRequest* request = [self.fetchRequestFactory getFirstUserFetchRequest];
    NSArray* users = [self fetchRequest:request];
    return ([users count] > 0) ? (User*)[users objectAtIndex:0] : nil;
}

// this is called when app is launched from DMAppDelegate
- (BOOL)userExistsAndCompletedSurvey
{
    User* user = [self fetchUser];
    return user != nil && [user.has_completed_survey_general boolValue] == YES;
}

// Modified by MUKAI Takeshi in 2017-01
// for custom survey
// this is called when app is launched from DMAppDelegate
- (BOOL)userExistsAndCompletedSurveyCustom
{
    User* user = [self fetchUser];
    return user != nil && [user.has_completed_survey_custom boolValue] == YES;
}

- (Data*)fetchData
{
    NSFetchRequest* request = [self.fetchRequestFactory getFirstCalibrationDataFetchRequest];
    NSArray* datas = [self fetchRequest:request];
    return ([datas count] > 0) ? (Data*)[datas objectAtIndex:0] : nil;
}

// Modified by MUKAI Takeshi in 2016-08
// for custom survey
- (NSDictionary*)fetchCustomSurveyData
{
    User* user = [self fetchUser];
    return user.custom_survey_data;
}

// Modified by MUKAI Takeshi in 2016-08
// for custom survey
- (BOOL)hasUplodedUser
{
    User* user = [self fetchUser];
    return user.uploaded;
}

// Modified by MUKAI Takeshi in 2017-02
- (NSDate*)fetchSurveyStartDate
{
    User* user = [self fetchUser];
    return user.survey_start_date;
}

- (BOOL)calibrationCompleted
{
    return [self fetchData] != nil;
}

- (void)updateCalibrationDataWithX:(double)x Y:(double)y AndZ:(double)z
{
    Data* data = [self fetchData];
    if(data == nil)
    {
        data = (Data*)[NSEntityDescription insertNewObjectForEntityForName:@"Data"
                                                               inManagedObjectContext:self.managedObjectContext];
    }
    
    data.x = [NSNumber numberWithDouble:x];
    data.y = [NSNumber numberWithDouble:y];
    data.z = [NSNumber numberWithDouble:z];
    
    [self saveContext];
}


- (void)deleteAllLocations
{
    [self deleteAllObjects:@"Location"];
}

- (void)deleteOldestLocations:(NSInteger)numOfLocations
{
    NSFetchRequest *fetchRequest = [self.fetchRequestFactory getOldestLocationsFetchRequest:numOfLocations];
    
    NSError *error;
    NSArray *items = [self fetchRequest:fetchRequest];
    
    for (NSManagedObject *managedObject in items)
    {
        [self.managedObjectContext deleteObject:managedObject];
        // object deleted
    }
    if (![self.managedObjectContext save:&error])
    {
        // error deleting object
    }
    
    [self saveContext];
}

- (void)deleteAllObjects:(NSString*)entityName
{
    NSFetchRequest *fetchRequest = [self.fetchRequestFactory getAllObjectsFetchRequest:entityName];
    
    NSArray *items = [self fetchRequest:fetchRequest];
    
    for (NSManagedObject *managedObject in items)
    {
        [self.managedObjectContext deleteObject:managedObject];
        // object deleted
    }
    
    [self saveContext];
}


@end
