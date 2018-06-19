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
//  MyLocationManager.h
//  DataMobile
//
//  Created by Kim Sawchuk on 11-11-28.
//  Copyright (c) 2011 MML-Concordia. All rights reserved.
//
// Modified by MUKAI Takeshi in 2015-11

#import <Foundation/Foundation.h>
#import "DMLocationDisplayDelegate.h"
#import <CoreMotion/CoreMotion.h>

@interface DMLocationManager : NSObject <CLLocationManagerDelegate>

@property (nonatomic) id<DMLocationDisplayDelegate> displayDelegate;
/*
 the location manager should always be fetched via the +locationManger method,
 which returns the appropriate subclass for a given use-case
 */

+ (DMLocationManager*)defaultLocationManager;
- (void)startDMLocatinoManager;
- (CLAuthorizationStatus)authorizationStatus;

// recording
- (void)startRecording;
- (void)stopRecording;

// exposed for subclasses:
@property (strong, nonatomic, readonly) CLLocationManager* locationManager;
- (void)insertLocation:(CLLocation*)location pointOptions:(DMPointOptions)pointOptions str:(NSString*)strMAData accelData:(CMAccelerometerData*)accelData;
- (void)insertModeprompt:(CLLocation*)location prompts:(NSArray*)prompts promptsID:(NSArray*)promptsID;  // for customr survey
- (void)insertCancelledPrompt:(CLLocation*)location and:(BOOL)isCancelledByUser and:(NSString*)isTravelling;  // cancelledPrompt

- (CLLocation*)lastInsertedLocation;
- (void)addOptionsToLastInsertedPoint:(DMPointOptions)options;
@end
