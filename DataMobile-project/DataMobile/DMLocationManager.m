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
//  MyLocationManager.m
//  DataMobile
//
//  Created by Kim Sawchuk on 11-11-28.
//  Copyright (c) 2011 MML-Concordia. All rights reserved.
//
// Modified by MUKAI Takeshi in 2015-11

#import "DMLocationManager.h"
#import "DMEfficientLocationManager.h"

#import "CoreDataHelper.h"
#import "EntityManager.h"


@interface DMLocationManager ()
@property (strong, nonatomic) EntityManager* entityManager;
@property (strong, nonatomic, readwrite) CLLocationManager* locationManager;
@end

@implementation DMLocationManager

- (instancetype)init
{
    self = [super init];
    if (self) {
//        we can assume on first launch that the last point was a terminated point. Right?
        Location *lastLocation = [self.entityManager fetchLastInsertedLocation];
        
        NSDate *now = [NSDate date];
        NSTimeInterval deltaTime = [now timeIntervalSinceDate:self.lastInsertedLocation.timestamp];
        
        // if DM restarted in a certain period,
        // DMPointOptions should not be DMPointApplicationTerminatePoint
        if (deltaTime<60*60*24) {
            lastLocation.pointType = lastLocation.pointType;
        }else{
            lastLocation.pointType = (lastLocation.pointType | DMPointApplicationTerminatePoint);
        }
        
        [self.entityManager saveContext];
    }
    
    return self;
}

+ (DMLocationManager*)defaultLocationManager {
    DMLocationManager *handler = nil;
    handler = [[DMEfficientLocationManager alloc]init];
    return handler;
}

- (EntityManager*)entityManager {
    if (!_entityManager) {
        _entityManager = [[CoreDataHelper instance] entityManager];
    }
    return _entityManager;
}

- (CLLocationManager*)locationManager {
    if (!_locationManager) {
        _locationManager = [[CLLocationManager alloc]init];
        _locationManager.delegate = self;
    }
    return _locationManager;
}

// this is called from DMEfficientLocationManager
- (void)insertLocation:(CLLocation*)location pointOptions:(DMPointOptions)pointOptions str:(NSString*)strMAData accelData:(CMAccelerometerData*)accelData {
    
    // save new location
    [self.entityManager insertLocation:location options:pointOptions str:strMAData accelData:accelData];
    // update viewContents - DMMainView
    [self.displayDelegate locationDataSource:self didAddLocation:location pointOptions:pointOptions];
    
    DDLogInfo(@"added: %@, %u", location, pointOptions);
}

// this is called from DMEfficientLocationManager  // for custom survey
- (void)insertModeprompt:(CLLocation*)location prompts:(NSArray*)prompts promptsID:(NSArray *)promptsID{
    // save new modeprompt
    [self.entityManager insertModeprompt:location prompts:prompts promptsID:promptsID];
}

// this is called from DMEfficientLocationManager  // cancelledPrompt
- (void)insertCancelledPrompt:(CLLocation*)location and:(BOOL)isCancelledByUser and:(NSString*)isTravelling{
    // save new cancelledPrompt
    [self.entityManager insertCancelledPrompt:location and:isCancelledByUser and:isTravelling];
}

- (CLLocation*)lastInsertedLocation {
    return [[self.entityManager fetchLastInsertedLocation] cllLocation];
}

// this is called from DMEfficientLocationManager
- (void)addOptionsToLastInsertedPoint:(DMPointOptions)options {
    Location *lastInsertedLocation = [self.entityManager fetchLastInsertedLocation];
    lastInsertedLocation.pointType = (lastInsertedLocation.pointType | options);
    [self.entityManager saveContext];
}

- (void)startDMLocatinoManager {
    NSAssert(1 == 0, @"methods of abstract superclass should not be called directly");
}

// recording
- (void)startRecording {
    NSAssert(1 == 0, @"methods of abstract superclass should not be called directly");
}

- (void)stopRecording {
    NSAssert(1 == 0, @"methods of abstract superclass should not be called directly");
}

- (CLAuthorizationStatus)authorizationStatus {
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    
    switch (status) {
        case kCLAuthorizationStatusNotDetermined: {
            if ([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
                [self.locationManager requestAlwaysAuthorization];
                status = [CLLocationManager authorizationStatus];
            }
            break;
        case kCLAuthorizationStatusDenied: {
            DDLogError(@"authorization denied. How do we handle?");
        }
        default:
            //            authorized / authorized always
            break;
        }
    }
    return status;
}


@end
