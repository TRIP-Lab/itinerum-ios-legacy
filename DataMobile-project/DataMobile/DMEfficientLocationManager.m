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
//  DMEfficientLocationManager.m
//  DataMobile
//
//  Created by Colin Rofls on 2014-07-22.
//  Copyright (c) 2014 MML-Concordia. All rights reserved.
//

//
//  MyLocationManager.m
//  DataMobile
//
//  Created by Kim Sawchuk on 11-11-28.
//  Copyright (c) 2011 MML-Concordia. All rights reserved.
//
// Modified by MUKAI Takeshi in 2015-08


#import "DMEfficientLocationManager.h"
#import "DMAppDelegate.h"
#import <CoreMotion/CoreMotion.h>
//#import "UIDevice-Hardware.h"
#import "ScaleFontSize.h"  // new
#import "Config.h"
#import "CoreDataHelper.h"
#import "EntityManager.h"


@interface DMEfficientLocationManager ()
{
    UIBackgroundTaskIdentifier bgTask;
}

@property (strong, nonatomic) CLLocation* lastLocation;
@property (strong, nonatomic) CLLocation* bestBadLocation;
@property (strong, nonatomic) CLCircularRegion* movingRegion;
@property (strong, nonatomic) NSTimer* wifiTimer;
@property (nonatomic) BOOL isGps;

@property (strong, nonatomic) CLLocation* updatedNewLocation;
@property (strong, nonatomic) CLLocation* bestBadLocationForRegion;
@property (strong, nonatomic) NSTimer* bBadLocationTimer;
@property (strong, nonatomic) NSTimer* appTerminatedTimer;
@property (nonatomic) BOOL isAppTerminating;
@property (strong, nonatomic) CLCircularRegion* movingRegionKeeper;
@property (strong, nonatomic) NSTimer* promptCountTimer;
@property (nonatomic) NSTimeInterval promptTimeCountOnAppTerminated;
@property (strong, nonatomic) NSTimer* exitOnAppTerminatedTimer;
@property (strong, nonatomic) CMMotionActivityManager *motionActivity;
@property (strong, nonatomic) NSTimer* monitoringActivityTimer;
@property (strong, nonatomic) NSTimer* monitoringActivityAutomotiveTimer;
@property (nonatomic) BOOL isDetectedMoves;
//@property (nonatomic) BOOL isA7Device;
@property (nonatomic) BOOL isStationary;
@property (nonatomic) BOOL isWalking;
@property (nonatomic) BOOL isRunning;
@property (nonatomic) BOOL isUnknown;
@property (nonatomic) BOOL isAutomotive;
@property (nonatomic) BOOL isCycling; // iOS 8 and later
@property (strong, nonatomic) NSString* strMAConfidence;
@property (strong, nonatomic) NSString* strBestBadLocationMA;
@property (strong, nonatomic) CMMotionManager *motionManager;
@property (strong, nonatomic) CMAccelerometerData *accelData;
@property (strong, nonatomic) CMAccelerometerData *bestBadAccelData;
@property (nonatomic) int minDistanceFilter;
@property (nonatomic) BOOL isAccel;
@property (nonatomic) BOOL isRecordingRestarted;  // recording

@end


@implementation DMEfficientLocationManager

/**
 The minimum amount of time the location service will be running in GPS mode.
 */
static const NSTimeInterval GPS_SWITCH_THRESHOLD = 60 * 2;
/**
 The value to set the location manager desiredAccuracy in GPS mode.
 */
static const int MIN_HORIZONTAL_ACCURACY = 30;
/**
 The minimum required distance between new location and last location.
 */
//static const int MIN_DISTANCE_BETWEEN_POINTS = 30;

#define DM_MONITORED_REGION_RADIUS 100.0
#define DM_MONITORED_REGION_RADIUS_BBAD_MIN 150.0
#define DM_MONITORED_REGION_RADIUS_BBAD_MAX 500.0

static const NSTimeInterval BBAD_RECORD_TIMER = 60 * 1;
static const int BBAD_MIN_HORIZONTAL_ACCURACY = 100;  // location can be recorded under this accuracy
static const int BBAD_MAX_HORIZONTAL_ACCURACY = 1600;  // this is used for a geofence point when no good location point
static const NSTimeInterval APP_TERMINATED_TIMER = 160;
static const int MIN_DISTANCE_MODEPROMPT = 150;
static const NSTimeInterval MODEPROMPT_THRESHOLD_ON_APP_TERMINATED = 60 * 3;
static const NSTimeInterval SCRATCH_STANDARDLOCATION_CYCLE = 160;
static const NSTimeInterval EXIT_ON_APP_TERMINATED_TIMER = 60 * 60;
static const NSTimeInterval MONITORING_ACTIVITY_TIMER = 30;
static const NSTimeInterval MONITORING_ACTIVITY_AUTOMOTIVE_TIMER = 3;
static const NSTimeInterval DETECTED_MOVES_TIMER = 60 * 1;
#define DM_MONITORED_REGION_RADIUS_KEEPER_MIN 10.0
#define DM_MONITORED_REGION_RADIUS_KEEPER_MAX 100.0

@synthesize modepromptManager;
@synthesize debugLogView;


+ (CLCircularRegion *)regionWithCenter:(CLLocationCoordinate2D)coordinate
                       radius:(CLLocationDistance)radius
                   identifier:(NSString *)identifier
{
    if ([CLLocationManager isMonitoringAvailableForClass:[CLCircularRegion class]]) {
        return  [[CLCircularRegion alloc] initWithCenter:coordinate
                                                  radius:radius
                                              identifier:identifier];
    }
    return nil;
}

- (id)init
{
    if(self == [super init])
    {
//        if([CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorized)
//        {
//            DDLogWarn(@"LOCATION IS NOT AUTHORIZED");
//        }
//        if([[UIApplication sharedApplication] backgroundRefreshStatus] != UIBackgroundRefreshStatusAvailable)
//        {
//            DDLogWarn(@"BACKGROUND REFRESH IS NOT AVAILBLE");
//        }
    }
    return self;
}

// new
// alloc UILabel TripValidated
// UILabel for Tripvalidated in DMMainView cannot update, so alloc it here
- (void)allocUILabelTripValidated
{
    // scaleFontSizeByScreenWidth
    CGFloat scaleFontSize = [ScaleFontSize scaleFontSizeByScreenWidth];
    
    UIWindow* window = [[UIApplication sharedApplication] keyWindow];
    totalTripsLabelELM = [[UILabel alloc] init];
    
    // get current language to change display by langulage(fr)
    NSString *currentLanguage = [[NSLocale preferredLanguages] objectAtIndex:0];
    // adjust position by device
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        CGRect frame = [[UIScreen mainScreen] applicationFrame];
        // if iPhone6
        if (frame.size.width==375.0) {
            if ([currentLanguage hasPrefix:@"fr"]) {
                totalTripsLabelELM.frame = CGRectMake(25, 60, 26*scaleFontSize, 33*scaleFontSize);
            }else{
                totalTripsLabelELM.frame = CGRectMake(29, 60, 26*scaleFontSize, 33*scaleFontSize);
            }
        }
        // if iPhone6 Plus
        else if (frame.size.width==414.0) {
            if ([currentLanguage hasPrefix:@"fr"]) {
                totalTripsLabelELM.frame = CGRectMake(27, 66, 26*scaleFontSize, 33*scaleFontSize);
            }else{
                totalTripsLabelELM.frame = CGRectMake(32, 66, 26*scaleFontSize, 33*scaleFontSize);
            }
        }
        else {
            if ([currentLanguage hasPrefix:@"fr"]) {
                totalTripsLabelELM.frame = CGRectMake(21, 51, 26, 33);
            }else{
                totalTripsLabelELM.frame = CGRectMake(25, 51, 26, 33);
            }
        }
    }else{
        // if iPad
        if ([currentLanguage hasPrefix:@"fr"]) {
            totalTripsLabelELM.frame = CGRectMake(50, 108, 26*scaleFontSize, 33*scaleFontSize);
        }else{
            totalTripsLabelELM.frame = CGRectMake(61, 108, 26*scaleFontSize, 33*scaleFontSize);
        }
    }
    totalTripsLabelELM.textColor = [UIColor whiteColor];
    totalTripsLabelELM.font = [UIFont fontWithName:@"AvenirNextCondensed-Bold" size:24*scaleFontSize];
    totalTripsLabelELM.textAlignment = NSTextAlignmentRight;
    totalTripsLabelELM.text = [NSString localizedStringWithFormat:@"%d", modepromptCount];
    [window.rootViewController.view addSubview:totalTripsLabelELM];
}

// from DMModeprompManager
- (void)updateTripValidated
{
    // update UILabel TripValidated
    totalTripsLabelELM.text = [NSString localizedStringWithFormat:@"%d", modepromptCount];
}

// alloc DMModeptomptManager
- (void)allocDMModepromptManager
{
    UIWindow* window = [[UIApplication sharedApplication] keyWindow];
    modepromptManager = [[DMModepromptManager alloc] initWithNibName:@"DMModepromptManager" bundle:nil];
    modepromptManager.delegate = self;
    modepromptManager.view.frame = [[UIScreen mainScreen] bounds];
    [window.rootViewController.view addSubview:modepromptManager.view];
}

// alloc DMdebugLogView
- (void)allocDMDebugLogView
{
    UIWindow* window = [[UIApplication sharedApplication] keyWindow];
    debugLogView = [[DMDebugLogViewController alloc] initWithNibName:@"DMDebugLogViewController" bundle:nil];
    debugLogView.view.frame = CGRectMake(window.frame.size.width-240, 104, 240, 40);
    [window.rootViewController.view addSubview:debugLogView.view];
}

// startDMLocatinoManager - this is called from DMMainView when its viewDidLoad
- (void)startDMLocatinoManager {
    
    // notification observer
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidEnterBackground)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    
    
    // load UserDefaults
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    isModeprompting = [userDefaults boolForKey:@"ISMODEPROMPTING_USER_DEFAULT"];
    lastPromptedLocation = (CLLocation *)[NSKeyedUnarchiver unarchiveObjectWithData:[userDefaults objectForKey:@"LASTPROMPTEDLOCATION_DEFAULT"]];
    isModepromptingOnAppTerminated = [userDefaults boolForKey:@"ISMODEPROMPTINGOAT_USER_DEFAULT"];
    lastPromptedLocationOnAppTerminated = (CLLocation *)[NSKeyedUnarchiver unarchiveObjectWithData:[userDefaults objectForKey:@"LASTPROMPTEDLOCATIONOAT_DEFAULT"]];
    promptTimeOnAppTerminated = (int)[userDefaults integerForKey:@"PROMPTTIMEOAT_USER_DEFAULT"];
    // for custom survey
    modepromptCount = (int)[userDefaults integerForKey:@"MODEPROMPTCOUNT_USER_DEFAULT"];
    isModepromptDisabled = [userDefaults boolForKey:@"ISMODEPROMPTDISABLED_USER_DEFAULT"];
    isRecordingStopped = [userDefaults boolForKey:@"ISRECORDINGSTOPPED_USER_DEFAULT"];  // recording
    lastSubmittedPromptedLocation = (CLLocation *)[NSKeyedUnarchiver unarchiveObjectWithData:[userDefaults objectForKey:@"LASTSUBMITTEDPROMPTEDLOCATION_DEFAULT"]];  // cancelledPrompt
    lastCancelledByUserPromptedLocation = (CLLocation *)[NSKeyedUnarchiver unarchiveObjectWithData:[userDefaults objectForKey:@"LASTCANCELLEDBYUSERPROMPTEDLOCATION_DEFAULT"]];  // cancelledPrompt
    
//    isDebugLogEnabled = [userDefaults boolForKey:@"ISDEBUGLOG_USER_DEFAULT"];
//    isDebugLogLiteEnabled = [userDefaults boolForKey:@"ISDEBUGLOGLITE_USER_DEFAULT"];
    
    // use Accel or not
    self.isAccel = NO;
    
    // set parameter from survey data
    self.minDistanceFilter = 25;
    
    
    // for ready to update location and create region on app terminated
    if (isAppTerminated) {
        [self readyOnAppTerminated];
    }
    
    // new
    // alloc UILabel Tripvalidated
    // UILabel for Tripvalidated in DMMainView cannot update, so alloc it here
    // check if custom propmpts exists
    // isModepromptDisable cannot be used for this, because it is also disabled after maxTripsValidated
    BOOL isNotPromptExist = NO;
    if ([[[CoreDataHelper instance] entityManager] fetchCustomSurveyData]) {
        NSDictionary* dictResults = [[[CoreDataHelper instance] entityManager] fetchCustomSurveyData];
        NSDictionary* dictSurveies = [dictResults objectForKey:@"results"];
        NSDictionary *dictPrompt = [dictSurveies objectForKey:@"prompt"];
        NSArray *arrayPrompts = [dictPrompt objectForKey:@"prompts"];
        if (arrayPrompts.count==0) {
            isNotPromptExist = YES;
        }else{
            // if custom prompts exist
            // load num_prompts
            NSString *strNumPrompts = [NSString stringWithFormat:@"%@",[dictPrompt objectForKey:@"maxPrompts"]];
            if ([strNumPrompts intValue]<=0) {
                isNotPromptExist = YES;
            }
        }
    }
    if (!isNotPromptExist) {
        [self performSelectorOnMainThread:@selector(allocUILabelTripValidated) withObject:nil waitUntilDone:NO];
    }
    
    // alloc DMModeptomptManager
    [self performSelectorOnMainThread:@selector(allocDMModepromptManager) withObject:nil waitUntilDone:NO];
    
    // for DMDebugLogView
    // alloc DMDebugLogView
//    [self performSelectorOnMainThread:@selector(allocDMDebugLogView) withObject:nil waitUntilDone:NO];
    // for DMDebugLogView
    if (isDebugLogEnabled||isDebugLogLiteEnabled) {
        [debugLogView notifyDebugLog:@"DMLaunched(init)" region:nil location:nil];
    }
    
    // if significationLocationService is available - because motionActivity is used only on models which support significantLocation
    if ([CLLocationManager significantLocationChangeMonitoringAvailable]) {
    
        // start motionActivity
        // if motionActivity is available - iPhone5s or above (M7 or above)
        if ([CMMotionActivityManager isActivityAvailable]) {
            // alloc motionActivity
            self.motionActivity = [[CMMotionActivityManager alloc] init];
            
            // to show autorization for motionActivity at the moment user opens DM (finish survery and start DM), motionActivity must be started at first
            [self.motionActivity startActivityUpdatesToQueue:[NSOperationQueue mainQueue] withHandler:^(CMMotionActivity *activity) {
            }];
            // stop motionActivity
            [self.motionActivity stopActivityUpdates];
    
            // check if A7 or not - because on A7 devices, motionActivity is not well, so it should make timing for some triggers easier
            // iPhone 5S, iPad Air, iPad Mini 2, iPad Mini 3
//            if ([[[UIDevice currentDevice] modelName] isEqualToString:@"iPhone 5s (GSM)"]||[[[UIDevice currentDevice] modelName] isEqualToString:@"iPhone 5s (Global)"]||[[[UIDevice currentDevice] modelName] isEqualToString:@"iPad Air (Wi-Fi)"]||[[[UIDevice currentDevice] modelName] isEqualToString:@"iPad Air (Cellular)"]||[[[UIDevice currentDevice] modelName] isEqualToString:@"iPad mini 2G (Wi-Fi)"]||[[[UIDevice currentDevice] modelName] isEqualToString:@"iPad mini 2G (Cellular)"]||[[[UIDevice currentDevice] modelName] isEqualToString:@"iPad mini 3G (Wi-Fi)"]||[[[UIDevice currentDevice] modelName] isEqualToString:@"iPad mini 3G (Cellular)"]) {
//                self.isA7Device = YES;
//            }
        }
    }
    
    // set locationManager property
    self.locationManager.delegate = self;
    self.locationManager.distanceFilter = self.minDistanceFilter; // a relic, we should probably be using apple supplied values - 25
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.locationManager.pausesLocationUpdatesAutomatically = NO;
    // for iOS9, to update location in background
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 9.0) {
        self.locationManager.allowsBackgroundLocationUpdates = YES;
    }
    
    // start significantLocationService, to keep running and wake up DM if it is terminated. SignificantLocation doesn't use battery a lot
    // and it also can keep app running in background(terminated) - glitch?
    [self startSignificantLocation];
    
    // start motion - accelerometer
    if (self.isAccel) {
        self.motionManager = [[CMMotionManager alloc] init];
    }
    
    // recording
    if (!isRecordingStopped) {
        [self startRecording];
    }
//    // start GPS mode
//    [self switchToGps];
    
    // start motionActivity - call this after switchToGps because there is isGPS flag
    // if motionActivity is available - iPhone5s or above (M7 or above)
    if ([CMMotionActivityManager isActivityAvailable]) {
        // alloc motionActivity
        self.motionActivity = [[CMMotionActivityManager alloc] init];
        [self startMotionActivity];
    }
}

// start standard location service
- (void)startStandardLocation {
    [self.locationManager startUpdatingLocation];
}

// stop standard location service
- (void)stopStandardLocation {
    [self.locationManager stopUpdatingLocation];
}

// start significant location service
- (void)startSignificantLocation {
    if ([CLLocationManager significantLocationChangeMonitoringAvailable]) {
        [self.locationManager startMonitoringSignificantLocationChanges];
    }
}

// stop significant location service
- (void)stopSignificantLocation {
    if ([CLLocationManager significantLocationChangeMonitoringAvailable]) {
        [self.locationManager stopMonitoringSignificantLocationChanges];
    }
}

// recording
// startRecording - this is called from startDMLocatinoManager, and DMMainView when recordingBtn is tapped
- (void)startRecording
{
    // this method is called when app starts or recocording restarts, so check if it is restarting
    if (isRecordingStopped) {
        self.isRecordingRestarted = YES;
        isRecordingStopped = NO;
    }
    
    // start significantLocationService, to keep running and wake up DM if it is terminated. SignificantLocation doesn't use battery a lot
    // and it also can keep app running in background(terminated) - glitch?
    [self startSignificantLocation];
    
    self.isGps = NO;
    // start GPS mode
    [self switchToGps];
}

// stopRecording - this is called from DMMainView when recordingBtn is tapped
- (void)stopRecording
{
    isRecordingStopped = YES;
    
    // stop monitoringRegionKeeper
    [self.locationManager stopMonitoringForRegion:self.movingRegionKeeper];
    self.movingRegionKeeper = nil;
    
    [self resetBBadLocation];
    [self switchToGps];
    isMonitoringForRegionExit = NO;
    self.lastLocation = nil;
    
    // mark previous location as Terminated Point
    [self addOptionsToLastInsertedPoint:DMPointApplicationTerminatePoint];
    
    [self stopSignificantLocation];
    [self stopStandardLocation];
}


- (void)switchToGps
{
    // for DMDebugLogView
    if (isDebugLogEnabled) {
        [debugLogView notifyDebugLog:@"switchToGPS" region:nil location:nil];
    }
    
    // delete modeprompt - left from geofence
    [modepromptManager deleteModeprompt];
    
    // stop monitoringRegion
    [self.locationManager stopMonitoringForRegion:self.movingRegion];
    self.movingRegion = nil;
    // update viewContents - DMMainView - remove RegionOverlay
    [self.displayDelegate locationDataSourceStoppedMonitoringRegion];
    
    // stop exitOnAppTerminatedTimer
    if (self.exitOnAppTerminatedTimer) {
        [self.exitOnAppTerminatedTimer invalidate];
        self.exitOnAppTerminatedTimer = nil;
    }
    
    // if significationLocationService is available - because motionActivity is helpful to detect a new location only on models which support significantLocation
    if ([CLLocationManager significantLocationChangeMonitoringAvailable]) {
        // if motionActivity is available - iPhone5s or above (M7 or above)
        if ([CMMotionActivityManager isActivityAvailable]) {
            // stop detectMove timer
            if (self.monitoringActivityTimer) {
                [self.monitoringActivityTimer invalidate];
                self.monitoringActivityTimer = nil;
            }
            if (self.monitoringActivityAutomotiveTimer) {
                [self.monitoringActivityAutomotiveTimer invalidate];
                self.monitoringActivityAutomotiveTimer = nil;
            }
            // stop motionActivity
            [self.motionActivity stopActivityUpdates];
        }
    }
    
    // start GPS mode
    DDLogInfo(@"Location manager switched to Gps");
    if (!self.isGps) {
        // start accel to get data only when isGps
        if (self.isAccel) {
            [self startAccelerometer];
        }
        
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;  // set AccuracyBest in GPS mode
        // start standardLocationService
        [self startStandardLocation];
        self.isGps = YES;
    }
    [self resetWifiSwitchTimer];  // start timer for Wifi(region) mode
}

- (void)switchToWifiForRegion:(CLCircularRegion*)region
{
    if (!self.isGps) {
        DDLogError(@"switch to wifi called while !isGPS");
        NSAssert(self.isGps, @"switch to wifi should not be called if we aren't currently running on GPS");
    }
    
    // if we aren't given a region, switch to gps
    if (!region) {
        DDLogInfo(@"failed to acquire point");
        // This is called when app cannot get any locations after launched.
        // Turn on Gps mode, and then it will start from beginning
        [self switchToGps];
        return;
    }
    
    // if region is created by wifiTimer - start wifi mode
    if ([region.identifier isEqualToString:@"movingRegion"]) {
        
        // for DMDebugLogView
        if (isDebugLogEnabled) {
            [debugLogView notifyDebugLog:@"switchToWifiForRegion" region:nil location:nil];
        }

        // to make Modeprompt alertView when stopped
        if (!isModepromptDisabled) {
            if (self.isGps && region) {
                // does not allow to make Modeprompt alertView when geofence created without moving(150m) from last prompted
                CLLocation *location = [[CLLocation alloc]initWithLatitude:region.center.latitude longitude:region.center.longitude];
                CLLocationDistance deltaDistance = [lastPromptedLocation distanceFromLocation:location];
                if (deltaDistance>=MIN_DISTANCE_MODEPROMPT) {
                    // show alertview and set notification
                    [modepromptManager readyModeprompt:location];
                }
            }
        }
        
        // start Wifi mode
        DDLogInfo(@"Location manager switched to wifi");
        [self.wifiTimer invalidate];  // stop timer for Wifi(region) mode
        
        if (self.isGps) {
            // stop accel
            if (self.motionManager.accelerometerActive) {
                [self.motionManager stopAccelerometerUpdates];
            }
            
            self.locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers;  // set AccuracyThreeKilo in Wifi mode
            // if significationLocationService is available - because motionActivity can be helpful to detect a new location only on models which support significantLocation
            if ([CLLocationManager significantLocationChangeMonitoringAvailable]) {
                // if motionActivity is available - iPhone5s or above (M7 or above)
                if ([CMMotionActivityManager isActivityAvailable]) {
//                    // start motion activity to help detecting moves
//                    // because while standardLocation is stopping, sometimes it takes time to recognize exiting from geofence.
//                    [self startMotionActivity];
                    
                    // stop standradLocationService
                    [self stopStandardLocation];
                    // turn on and off standardLocationService at every 3min in Wifi mode, to keep DM running in background.
                    // Bacause app cannot keep working over 3min in background without standardLocation
                    [self performSelector:@selector(scratchStandardLocation) withObject:nil afterDelay:SCRATCH_STANDARDLOCATION_CYCLE];
                }
            }  // if significantLocation or motionActivity isn't available, don't stopStandardLocation
            self.isGps = NO;
        }
        
        // kill DM if it is in Wifi mode(no new locations) for 60 min, onAppTerminated
        if (isAppTerminated) {
            [self.exitOnAppTerminatedTimer invalidate];
            self.exitOnAppTerminatedTimer = nil;
            self.exitOnAppTerminatedTimer = [NSTimer scheduledTimerWithTimeInterval:EXIT_ON_APP_TERMINATED_TIMER target:self selector:@selector(readyToExitOnAppTerminated:) userInfo:nil repeats:NO];
        }
        
        // draw region overlay
        // for DMPointOptions
        isMonitoringForRegionExit = YES;
        //            mark previous location as involving a region change
        [self addOptionsToLastInsertedPoint:DMPointMonitorRegionStartPoint];
        // if regionMonitoring succeeded
        // update viewContents - DMMainView - set RegionOverlay
        [self.displayDelegate locationDataSource:self
              didStartMonitoringRegionWithCenter:region.center
                                          radius:region.radius];
        
        DDLogInfo(@"started monitoring for region %@ (%f, %f), radius %f",
                  region.identifier,
                  region.center.latitude,
                  region.center.longitude,
                  region.radius);
        
    }
    // if region is created by onAppTerminated - movingRegionKeeper
    else if ([region.identifier isEqualToString:@"movingRegionKeeper"]) {
        if (isAppTerminated) {
            // for modeprompt onAppTerminated, the notification will appear in 2min, if no new location updates
            if (!isModepromptDisabled) {
                if (self.isGps && region) {
                    // does not allow to make Modeprompt alertView when geofence created without moving(150m) from last prompted
                    CLLocation *location = [[CLLocation alloc]initWithLatitude:region.center.latitude longitude:region.center.longitude];
                    CLLocationDistance deltaDistance = [lastPromptedLocation distanceFromLocation:location];
                    if (deltaDistance>=MIN_DISTANCE_MODEPROMPT) {
                        // for DMDebugLogView
                        if (isDebugLogEnabled) {
                            [debugLogView notifyDebugLog:@"Ready_ModePromptOnAppTerminated" region:nil location:nil];
                        }
                        // show alertview and set notification - it will notifiy if DM doesn't update location in certain time
                        [modepromptManager setLocalNotificationModeprompt:[self calcPromptTimeInterval]];
                        lastPromptedLocationOnAppTerminated = location;  // put location into prePromptedLocation
                        isModepromptingOnAppTerminated = YES;
                    }
                }
            }
        }
    }
}

// turn on and off standardLocationService at every 3min in Wifi mode, to keep DM running in background.
- (void)scratchStandardLocation
{
    if (!self.isGps) {
        // for DMDebugLogView
        if (isDebugLogEnabled) {
            [debugLogView notifyDebugLog:@"scratchStandardLocation" region:nil location:nil];
        }
        
        // if DM is detectedMovesMode, don't toggle standardLocationService
        if (!self.isDetectedMoves) {
            [self startStandardLocation];
            [self stopStandardLocation];
        }
        // repeat this method if DM is in Wifi mode
        [self performSelector:@selector(scratchStandardLocation) withObject:nil afterDelay:SCRATCH_STANDARDLOCATION_CYCLE];
    }
}

// start accelerometer - motionManager
- (void)startAccelerometer
{
    if (self.motionManager.accelerometerAvailable){
        if (!self.motionManager.accelerometerActive) {
            // set updateInterval
            self.motionManager.accelerometerUpdateInterval = 1/10;  // 10Hz
            
            CMAccelerometerHandler handler = ^(CMAccelerometerData *data, NSError *error) {
                // this is called when activity is updated
                self.accelData = data;
            };
            
            // start Accelerometer
            [self.motionManager startAccelerometerUpdatesToQueue:[NSOperationQueue currentQueue] withHandler:handler];
        }
    }
}

// start motion activity to help detecting moves
- (void)startMotionActivity
{
    self.strMAConfidence = @"";
    
    [self.motionActivity startActivityUpdatesToQueue:[NSOperationQueue mainQueue] withHandler:^(CMMotionActivity *activity) {
        // this is called when activity is updated
        
        // get confidence
        switch (activity.confidence) {
            case CMMotionActivityConfidenceLow:
                self.strMAConfidence = @"Low";
                break;
            case CMMotionActivityConfidenceMedium:
                self.strMAConfidence = @"Medium";
                break;
            case CMMotionActivityConfidenceHigh:
                self.strMAConfidence = @"High";
                break;
            default:
                self.strMAConfidence = @"Error";
                break;
        }
        
        // get activity status
        self.isStationary = activity.stationary;
        self.isWalking = activity.walking;
        self.isRunning = activity.running;
        self.isUnknown = activity.unknown;
        self.isAutomotive = activity.automotive;
        self.isCycling = activity.cycling; // iOS 8 and later
        
        // to help detecting moves when in Wifi mode, stopStandardLocation
        if (!self.isGps) {
            // if significationLocationService is available - because motionActivity can be helpful to detect a new location only on models which support significantLocation
            if ([CLLocationManager significantLocationChangeMonitoringAvailable]) {
                // if starts moving
               if ((self.isWalking||self.isRunning)&&(activity.confidence==CMMotionActivityConfidenceLow||activity.confidence==CMMotionActivityConfidenceMedium||activity.confidence==CMMotionActivityConfidenceHigh)) {
                    // for DMDebugLogView
                    if (isDebugLogEnabled) {
                        [debugLogView notifyDebugLog:@"startMonitoringActivityTimer" region:nil location:nil];
                    }
                    // start timer to monitor if we're moving for severl periods
                    if (!self.monitoringActivityTimer) {
                        self.monitoringActivityTimer = [NSTimer scheduledTimerWithTimeInterval:MONITORING_ACTIVITY_TIMER target:self selector:@selector(detectedMoves:) userInfo:nil repeats:NO];
                    }
                }else{
                    if (self.monitoringActivityTimer) {
                        [self.monitoringActivityTimer invalidate];
                        self.monitoringActivityTimer = nil;
                    }
                }
                // if starts moving by automotive - monitoring time should be shorter
                if ((self.isAutomotive||self.isCycling)&&(activity.confidence==CMMotionActivityConfidenceLow||activity.confidence==CMMotionActivityConfidenceMedium||activity.confidence==CMMotionActivityConfidenceHigh))  {
                    // for DMDebugLogView
                    if (isDebugLogEnabled) {
                        [debugLogView notifyDebugLog:@"startMonitoringActivityAutomotiveTimer" region:nil location:nil];
                    }
                    // start timer to monitor if we're moving for severl periods
                    if (!self.monitoringActivityAutomotiveTimer) {
                        self.monitoringActivityAutomotiveTimer = [NSTimer scheduledTimerWithTimeInterval:MONITORING_ACTIVITY_AUTOMOTIVE_TIMER target:self selector:@selector(detectedMoves:) userInfo:nil repeats:NO];
                    }
                }else{
                    if (self.monitoringActivityAutomotiveTimer) {
                        [self.monitoringActivityAutomotiveTimer invalidate];
                        self.monitoringActivityAutomotiveTimer = nil;
                    }
                }
            }
        }
    }];
}

// if we keep moving for serveral periods, detectedMovesMode starts - startStandardLocation in Wifi mode to recognize exitingFromRegion faster
- (void)detectedMoves:(NSTimer*)timer
{
    // for DMDebugLogView
    if (isDebugLogEnabled) {
        [debugLogView notifyDebugLog:@"detectedMoves" region:nil location:nil];
    }
    
    // stop detectMove timer
    if (self.monitoringActivityTimer) {
        [self.monitoringActivityTimer invalidate];
        self.monitoringActivityTimer = nil;
    }
    if (self.monitoringActivityAutomotiveTimer) {
        [self.monitoringActivityAutomotiveTimer invalidate];
        self.monitoringActivityAutomotiveTimer = nil;
    }
    // stop motionActivity
    [self.motionActivity stopActivityUpdates];
    
//    // if wifi is not turned on and accuracyThreeKiloMeteres, sometimes it takes time to recognize exiting from geofence
//    // (there is no method to check if wifi is turned on or not)
//    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;  // set AccuracyBest in GPS mode
    // start standardLocationService
    [self startStandardLocation];
    self.isDetectedMoves = YES;
    
    [self performSelector:@selector(cancelDetectedMoves) withObject:nil afterDelay:DETECTED_MOVES_TIMER];
}

- (void)cancelDetectedMoves
{
    // if DM is still in Wifi mode, stopStandardLocation and startMotionActivity again
    if (!self.isGps) {
        // for DMDebugLogView
        if (isDebugLogEnabled) {
            [debugLogView notifyDebugLog:@"cancelDetectedMoves" region:nil location:nil];
        }
        
//        self.locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers;  // set AccuracyThreeKilo in Wifi mode
        [self startMotionActivity];
        [self stopStandardLocation];
    }
    self.isDetectedMoves = NO;
}

// this timer is used for switching between Gps and Wifi mode.
// keep reseting timer unless location keeps updating in Gps mode.
// so, if location doesn't update for a given time, it will swicth to Wifi mode
- (void)resetWifiSwitchTimer {
    [self.wifiTimer invalidate];
    
    if (!isRecordingStopped) {  // recording
        self.wifiTimer = [NSTimer timerWithTimeInterval:GPS_SWITCH_THRESHOLD
                                                 target:self
                                               selector:@selector(wifiTimerDidFire:)
                                               userInfo:nil
                                                repeats:NO];
        [[NSRunLoop currentRunLoop] addTimer:self.wifiTimer forMode:NSRunLoopCommonModes];
    }
    
    // for modePrompt - to check if stopping for a certain time on AppTerminated
    if (isAppTerminated) {
        if (!self.isAppTerminating) {
            [self resetPromptTimeCounter];
        }
    }
}

- (void)wifiTimerDidFire:(NSTimer*)timer {
    // for DMDebugLogView
    if (isDebugLogEnabled) {
        [debugLogView notifyDebugLog:@"wifiTimerDidFire " region:nil location:nil];
    }
    
    // if region doesn't exist, create
    if (!self.movingRegion) {
        
        if (self.lastLocation) {
            //        create a region to monitor based on last good location
            self.movingRegion = [DMEfficientLocationManager regionWithCenter:self.lastLocation.coordinate
                                                                      radius:DM_MONITORED_REGION_RADIUS
                                                                  identifier:@"movingRegion"];
            
            // for DMDebugLogView
            if (isDebugLogEnabled) {
                [debugLogView notifyDebugLog:@"creatingRegion:wifiTimerDidFire " region:nil location:self.lastLocation];
            }
        }
        else if (self.bestBadLocationForRegion.horizontalAccuracy<=BBAD_MAX_HORIZONTAL_ACCURACY && self.bestBadLocationForRegion) {
            // adjust region radius
            CLLocationDistance radius = [self adjustRegionRadiusBBad:self.bestBadLocationForRegion];
            //        if we don't have a good location, use our best _acceptable_ location.
            self.movingRegion = [DMEfficientLocationManager regionWithCenter:self.bestBadLocationForRegion.coordinate
                                                                      radius:radius
                                                                  identifier:@"movingRegion"];
            DDLogInfo(@"no good points received, using larger geofence");
            
            // for DMDebugLogView
            if (isDebugLogEnabled) {
                [debugLogView notifyDebugLog:@"creatingRegionWithBBLocation:wifiTimerDidFire " region:nil location:self.bestBadLocationForRegion];
            }
        }
        // bestBadLocationForRegion
        self.bestBadLocationForRegion = nil;
        
        
        if (self.movingRegion) {
            // if movionRegion is created, start monitoring region
            [self.locationManager startMonitoringForRegion:self.movingRegion];
            
            DDLogInfo(@"requesting state for region: %@", self.movingRegion);
            // "switchToWifiForRegion" will be called from state request
            //        if we have a region, find out if we're actually in it. Only monitor regions we're actually in.
            //        there's a bug in location manager where state requests will fail when executed immediately after a region is added:
            //        http://www.cocoanetics.com/2014/05/radar-monitoring-clregion-immediately-after-removing-one-fails/
            [self.locationManager performSelector:@selector(requestStateForRegion:) withObject:self.movingRegion afterDelay:1];
        }
        else{
            // for DMDebugLogView
            if (isDebugLogEnabled) {
                [debugLogView notifyDebugLog:@"NoLocation,RegionNotCreated,Restart" region:nil location:nil];
            }
            
            // if movingRegion isn't created
            [self switchToWifiForRegion:nil];
        }
    }
}


#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    NSLog(@"location manager did change status: %d", status);
}

- (void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region {
//    we only want to monitor for exit of regions that we are actually in.
//    is this problematic? i.e., based on the fact that we only *set* region boundaries when our info has been bad for 2 mins?
//    probably not: our solution is problematic anyway. This *should* be a decent failsafe. But it requires some testing?
    NSString *stateDescription;
    switch (state) {
        case CLRegionStateInside:
            stateDescription = @"inside";
            break;
        case CLRegionStateOutside:
            stateDescription = @"outside";
            break;
        case CLRegionStateUnknown:
            stateDescription = @"unknown";
        default:
            break;
    }
    
    DDLogInfo(@"determined state: %@ for region %@", stateDescription, region);
    
    // movingRegion
    if ([region.identifier isEqualToString:@"movingRegion"]) {
        if (state == CLRegionStateInside) {
            // for DMDebugLogView
            if (isDebugLogEnabled||isDebugLogLiteEnabled) {
                [debugLogView notifyDebugLog:@"RegionStateInside" region:nil location:nil];
            }
            [self switchToWifiForRegion:(CLCircularRegion*)region];
        }
        else if (state == CLRegionStateOutside) {
            // for DMDebugLogView
            if (isDebugLogEnabled||isDebugLogLiteEnabled) {
                [debugLogView notifyDebugLog:@"RegionStateOutside" region:nil location:nil];
            }
            [self switchToGps];
        }
        // sometimes, the state will show as unknow. (in situations as no gps, no wifi, etc)
        else{  // state Unknown
            // for DMDebugLogView
            if (isDebugLogEnabled||isDebugLogLiteEnabled) {
                [debugLogView notifyDebugLog:@"RegionStateUnknown" region:nil location:nil];
            }
            [self switchToWifiForRegion:(CLCircularRegion*)region];
        }
    }
    // movingRegionKeeper
    else if ([region.identifier isEqualToString:@"movingRegionKeeper"]) {
        if (state == CLRegionStateInside) {
            // for DMDebugLogView
            if (isDebugLogEnabled) {
                [debugLogView notifyDebugLog:@"RegionStateInside:movingRegionKeeper" region:nil location:nil];
            }
        }
        else if (state == CLRegionStateOutside) {
            // for DMDebugLogView
            if (isDebugLogEnabled) {
                [debugLogView notifyDebugLog:@"RegionStateOutside:movingRegionKeeper" region:nil location:nil];
            }
            // stop monitoringRegion
            [self.locationManager stopMonitoringForRegion:self.movingRegionKeeper];
            self.movingRegionKeeper = nil;
        }
        else{  // state Unknown
            // for DMDebugLogView
            if (isDebugLogEnabled) {
                [debugLogView notifyDebugLog:@"RegionStateUnknown:movingRegionKeeper" region:nil location:nil];
            }
            // stop monitoringRegion
            [self.locationManager stopMonitoringForRegion:self.movingRegionKeeper];
            self.movingRegionKeeper = nil;
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLCircularRegion *)region
{
    DDLogInfo(@"user entered %@", region.identifier);
    
    // for ready to update location and create region on app terminated
    if (isAppTerminated) {
        [self readyOnAppTerminated];
    }
    
    // for DMDebugLogView
    if (isDebugLogEnabled||isDebugLogLiteEnabled) {
        [debugLogView notifyDebugLog:@"didEnterRegion: " region:region location:self.updatedNewLocation];
    }
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLCircularRegion *)region
{
    DDLogInfo(@"user exited %@", region.identifier);
    
    // for ready to update location and create region on app terminated
    if (isAppTerminated) {
        [self readyOnAppTerminated];
    }
    
    // for DMDebugLogView
    if (isDebugLogEnabled||isDebugLogLiteEnabled) {
        [debugLogView notifyDebugLog:@"didExitRegion: " region:region location:self.updatedNewLocation];
    }
    
    // if exit from movingRegionKeeper, remove it
    if ([region.identifier isEqualToString:@"movingRegionKeeper"]) {
        // stop monitoringRegion
        [self.locationManager stopMonitoringForRegion:self.movingRegionKeeper];
        self.movingRegionKeeper = nil;
    }
    
    if (![region.identifier isEqualToString:@"movingRegionKeeper"]||!self.isGps) {
        // switch to Gps mode and stop monitoringRegion
        [self switchToGps];
        
        // to fix glitch, app should call a method in "(isGPS)didUpdateLocations", at this time.
        // so, I moved its method into "updateLocatinos", to call it from here.
        [self updateLocation];
    }
}

// failed to create a region
- (void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error
{
    DDLogError(@"monitoring Did Fail For Region %@ with error %@", region.identifier ,error.localizedDescription);
    
    // for ready to update location and create region on app terminated
    if (isAppTerminated) {
        [self readyOnAppTerminated];
    }
    
    // for DMDebugLogView
    if (isDebugLogEnabled||isDebugLogLiteEnabled) {
        [debugLogView notifyDebugLog:@"FailedForRegion: " region:region location:self.updatedNewLocation];
    }
    
    // if failed to create a region "movinRegion", switch to GPS again
    if ([region.identifier isEqualToString:@"movingRegion"]) {
        [self switchToGps];
    }
    // if failed to create a region "movinRegionKeeper", remove it
    else if ([region.identifier isEqualToString:@"movingRegionKeeper"]) {
        // stop monitoringRegion
        [self.locationManager stopMonitoringForRegion:self.movingRegionKeeper];
        self.movingRegionKeeper = nil;
    }
}


#pragma mark - Standard and Significant Location Service - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    
    // for ready to update location and create region on app terminated
    if (isAppTerminated) {
        [self readyOnAppTerminated];
    }
    
    self.updatedNewLocation = [locations lastObject];
    
    // for DMDebugLogView
    if (isDebugLogEnabled||isDebugLogLiteEnabled) {
        // show accuracy / updated
        [debugLogView showUpdated:self.updatedNewLocation];
    }
    
    // keep creating region to have geofence all the time, to wake up DM just in case if DM is killed
    [self keepCreatingRegion];
    
    if (self.isGps) {
        // if Gps mode, updateLocation
        [self updateLocation];
        
    } else if (self.movingRegion) {
        // for DMDebugLogView
        if (isDebugLogEnabled) {
            [debugLogView notifyDebugLog:@"LocationUpdatedInWifiMode " region:self.movingRegion location:self.updatedNewLocation];
        }
        
        //        if not GPS: this is our fallback. sometimes we don't seem to exit regions, so we're going
        //        to manually check and see if we seem to be far away from the region we're in, ostensibly.
        CLLocation *movingRegionLocation = [[CLLocation alloc]initWithLatitude:self.movingRegion.center.latitude
                                                                     longitude:self.movingRegion.center.longitude];
        CLLocationDistance deltaDistance = [movingRegionLocation distanceFromLocation:self.updatedNewLocation];
        if (((deltaDistance-self.updatedNewLocation.horizontalAccuracy)>150) || !self.lastLocation) {
            DDLogInfo(@"received point likely outside of monitored region, switching to gps");
            [self switchToGps];
        }
    }
}

// this is called from "(isGPS)didUpdateLocations" or "didExitRegion"
- (void)updateLocation
{
    // for DMDebugLogView
    if (isDebugLogEnabled) {
        [debugLogView notifyDebugLog:@"LocationUpdated " region:nil location:self.updatedNewLocation];
    }
    
    if (self.updatedNewLocation.horizontalAccuracy <= MIN_HORIZONTAL_ACCURACY) {
        // record updatedNewlocation
        [self recordLocation:self.updatedNewLocation and:[self wrapMotionActivityData] and:self.accelData];
    }
    else if (!self.bestBadLocation) {
        // for DMDebugLogView
        if (isDebugLogEnabled) {
            [debugLogView notifyDebugLog:@"LocationUpdatedWithBBadLocation " region:nil location:self.updatedNewLocation];
        }
        //            if our accuracy isn't any good
        self.bestBadLocation = self.updatedNewLocation;  // we may lose the chances to record bestBadLocation, however we shouldn't lose for the senstive area??? - we should fix - for example, even in bestBadLocation, if app will not be able to record the location around there at all, app should record bestBadLocation
        // keep MAData for bestBadLocation
        self.strBestBadLocationMA = [self wrapMotionActivityData];
        self.bestBadAccelData = self.accelData;
        
        // to record bestLocation in bestBadLocation
        if (!self.bBadLocationTimer) {
            self.bBadLocationTimer = [NSTimer scheduledTimerWithTimeInterval:BBAD_RECORD_TIMER target:self selector:@selector(setBBadLocation:) userInfo:nil repeats:NO];
        }
    }
    else if (self.updatedNewLocation.horizontalAccuracy < self.bestBadLocation.horizontalAccuracy) {
        self.bestBadLocation = self.updatedNewLocation;
        // keep MAData for bestBadLocation
        self.strBestBadLocationMA = [self wrapMotionActivityData];
        self.bestBadAccelData = self.accelData;
    }
    
    [self resetWifiSwitchTimer];
}

// to record bestLocation in bestBadLocation
- (void)setBBadLocation:(NSTimer *)timer
{
    // record bestBadlocation, if accrucacy is less than BBAD_MIN_HORIZONTAL_ACCURACY and not nil
    if (self.bestBadLocation.horizontalAccuracy<=BBAD_MIN_HORIZONTAL_ACCURACY && self.bestBadLocation) {
        [self recordLocation:self.bestBadLocation and:self.strBestBadLocationMA and:self.bestBadAccelData];
    }else{
        [self resetBBadLocation];
        // after resetting, put bestBadLocation into bestBadLocationForRegion
        self.bestBadLocationForRegion = self.bestBadLocation;
    }
}

// reset bBadLocationTimer and bBadLocation
- (void)resetBBadLocation
{
    if (self.bBadLocationTimer) {
        [self.bBadLocationTimer invalidate];
        self.bBadLocationTimer = nil;
        self.bestBadLocation = nil;
        self.bestBadLocationForRegion = nil;
    }
}

// to record location
- (void)recordLocation:(CLLocation*)newLocation and:(NSString*)strMAData and:(CMAccelerometerData*)accelData
{
    // calculate distance between newLocation and lastLocation
    CLLocationDistance deltaDistance = [newLocation distanceFromLocation:self.lastLocation];
    
    //            if we're moving quickly, we will save points less frequently.
    CLLocationDistance minDistance = fmax(self.minDistanceFilter, newLocation.speed * 4); // (30m distance OR 27km/h or higher - default) new.10m or 9km/h
    if ((deltaDistance >= minDistance) || !self.lastLocation) {
        
        // make lastPromptedLocation to be used for Modeprompt, if empty
        if (!lastPromptedLocation) {
            lastPromptedLocation = newLocation;
        }
        
        // for modePrompt - to check if stopping for a certain time on AppTerminated
        // sometimes DM updates locations in very short time of DM is terminating, so this method should not be called when DM is terminating
        if (!self.isAppTerminating) {
            // to check if stopping for a certain time
            [self checkModePromptOnAppTerminated:@"recordLocation"];
        }
        
        // for updating viewContents
        // if self.lastLocation exists, put 0 into options, else put DMPointLaunchPoint into options
//        DMPointOptions options = self.lastLocation ? 0 : DMPointLaunchPoint;
        DMPointOptions options;
        
        // if DM restarted in a certain period,
        // DMPointOptions should not be DMPointLaunchPoint
        if (!self.lastLocation) {
            NSDate *now = [NSDate date];
            NSTimeInterval deltaTime = [now timeIntervalSinceDate:self.lastInsertedLocation.timestamp];
            // also, if DM recording is just restareted, mark the new location as LaunchPoint
            if (deltaTime>=60*60*24||self.isRecordingRestarted) {  // recording
                options = DMPointLaunchPoint;
                self.isRecordingRestarted = NO;
            }else{
                options = 0;
            }
        }else{
            options = 0;
        }
        
        if (isMonitoringForRegionExit) {
            options = (options | DMPointMonitorRegionExitPoint);
            isMonitoringForRegionExit = NO;
        }
        
        // save new location - EntityManager
        // and, update viewContents - DMMainView
        [self insertLocation:newLocation pointOptions:options str:strMAData accelData:accelData];
        self.lastLocation = newLocation;
        
        // for DMDebugLogView
        if (isDebugLogEnabled||isDebugLogLiteEnabled) {
            // show  accuracy / recorded
            [debugLogView showRecorded:newLocation];
            if (isDebugLogEnabled) {
                [debugLogView notifyDebugLog:@"LocationRecorded " region:nil location:newLocation];
            }
        }
    }
    
    [self resetBBadLocation];
}


#pragma mark - Application Lifecycle

- (void)applicationDidEnterBackground
{
    // keep creating region to have geofence all the time, to wake up DM just in case if DM is killed
    [self keepCreatingRegion];
    
    // save UserDefaults
    [self saveUserDefaults];
    
    // set bgTask (for 3min)
    UIApplication* app = [UIApplication sharedApplication];
    bgTask = [app beginBackgroundTaskWithExpirationHandler:^{
        
        [app endBackgroundTask:bgTask];
        bgTask = UIBackgroundTaskInvalid;
    }];
}

// keep creating region to have geofence all the time, to wake up DM just in case if DM is killed
- (void)keepCreatingRegion
{
    // if region doesn't exist, create
    if (!self.movingRegionKeeper&&!isRecordingStopped) {  // recording
        // create region
        // adjust region radius
        CLLocationDistance radius = [self adjustRegionRadiusKeeper:self.updatedNewLocation];
        // create a region to monitor
        self.movingRegionKeeper = [DMEfficientLocationManager regionWithCenter:self.updatedNewLocation.coordinate
                                                                        radius:radius
                                                                    identifier:@"movingRegionKeeper"];
        
        // for DMDebugLogView
        if (isDebugLogEnabled) {
            [debugLogView notifyDebugLog:@"creatingRegionKeeper " region:nil location:self.updatedNewLocation];
        }
        
        // if region is created
        if (self.movingRegionKeeper) {
            // start monitoring region
            [self.locationManager startMonitoringForRegion:self.movingRegionKeeper];
            
            // request state
            // to know that didDetermineState: is called by requestStateForRegion
            // because, didDetermineState: is called by requestStateForRegion or when DM exits or enters the region.
            [self.locationManager performSelector:@selector(requestStateForRegion:) withObject:self.movingRegionKeeper afterDelay:1];
        }
        // if region isn't created
        else{
            // for DMDebugLogView
            if (isDebugLogEnabled) {
                [debugLogView notifyDebugLog:@"NoRegionKeeper " region:nil location:self.updatedNewLocation];
            }
        }
    }
}


#pragma mark - onAppTerminated

// for ready to update location and create region on app terminated, DM can work for only 3min in background(terminated)
- (void)readyOnAppTerminated
{
    if (!self.appTerminatedTimer) {
        // it must run timer to create region and quit processing, because bgTask will finish in 3 min
        self.appTerminatedTimer = [NSTimer scheduledTimerWithTimeInterval:APP_TERMINATED_TIMER target:self selector:@selector(readyToCreateRegionOnAppTerminated:) userInfo:nil repeats:NO];
    }
    
    if (bgTask==UIBackgroundTaskInvalid) {
        // set bgTask (for 3min)
        UIApplication* app = [UIApplication sharedApplication];
        bgTask = [app beginBackgroundTaskWithExpirationHandler:^{
            
            [app endBackgroundTask:bgTask];
            bgTask = UIBackgroundTaskInvalid;
        }];
    }
}

- (void)readyToCreateRegionOnAppTerminated:(NSTimer *)timer
{
    if (isAppTerminated) {
        // prepare for appTerminated, create region and ready modeprompt
        [self prepareForAppTerminated];
    }
    
    // delay, for requestStateForRegion:
    [self performSelector:@selector(quitTaskOnAppTerminated) withObject:nil afterDelay:5];
}

- (void)quitTaskOnAppTerminated
{
    // for DMDebugLogView
    if (isDebugLogEnabled||isDebugLogLiteEnabled) {
        [debugLogView notifyDebugLog:@"quitTaskOnAppTerminated" region:nil location:nil];
    }
    
    // save UserDefaults
    [self saveUserDefaults];
    
    self.isAppTerminating = NO;
    
    // quit timer
    [self.appTerminatedTimer invalidate];
    self.appTerminatedTimer = nil;
    
    // quit bgTask
    [[UIApplication sharedApplication] endBackgroundTask:bgTask];
    bgTask = UIBackgroundTaskInvalid;
}

// kill DM by itself if it is in Wifi mode(no new locations) for 60 min, onAppTerminated
- (void)readyToExitOnAppTerminated:(NSTimer *)timer
{
    if (isAppTerminated) {
        // prepare for appTerminated, create region and ready modeprompt
        // just in case
        [self prepareForAppTerminated];
    }
    
    // delay, for requestStateForRegion:
    [self performSelector:@selector(appExitOnAppTerminated) withObject:nil afterDelay:5];
}

- (void)appExitOnAppTerminated
{
    // save UserDefaults
    [self saveUserDefaults];
    
    self.isAppTerminating = NO;
    
    // if app is active(foreground), don't allow to quit - just in case
    UIApplicationState applicationState = [[UIApplication sharedApplication] applicationState];
    if (applicationState == UIApplicationStateBackground) {
        // for DMDebugLogView
        if (isDebugLogEnabled||isDebugLogLiteEnabled) {
            [debugLogView notifyDebugLog:@"DMTerminatedOnAppTerminated" region:nil location:nil];
        }
        
        // DM quits by itself
        exit(0);
    }
//    else{
//        // kill DM if it is in Wifi mode(no new locations) for 60 min, onAppTerminated
//        [self.exitOnAppTerminatedTimer invalidate];
//        self.exitOnAppTerminatedTimer = nil;
//        self.exitOnAppTerminatedTimer = [NSTimer scheduledTimerWithTimeInterval:EXIT_ON_APP_TERMINATED_TIMER target:self selector:@selector(readyToExitOnAppTerminated:) userInfo:nil repeats:NO];
//    }
}

- (void)prepareForAppTerminated
{
    self.isAppTerminating = YES;
    
    // keep creating region to have geofence all the time, to wake up DM just in case if DM is killed
    [self keepCreatingRegion];
    
    // swithToWifiForRegionl with @"movingRegionKeeper" - to ready modePromptOnAppTerminated
    [self switchToWifiForRegion:self.movingRegionKeeper];
}

// this is called from self recordLocation and DMAppDelegate applicationDidBecomeActive, didReceiveLocalNotification
// for modePrompt - to check if stopping for a certain time on AppTerminated
- (void)checkModePromptOnAppTerminated:(NSString*)status
{
    if (isModepromptingOnAppTerminated) {
        // for DMDebugLogView
        if (isDebugLogEnabled) {
            [debugLogView notifyDebugLog:@"isModeOnAppT_checkingModeP" region:nil location:nil];
        }
        
        NSDate *now = [NSDate date];
        NSTimeInterval deltaTime = [now timeIntervalSinceDate:lastPromptedLocationOnAppTerminated.timestamp];
        if (deltaTime>=promptTimeOnAppTerminated) {
            // for DMDebugLogView
            if (isDebugLogEnabled) {
                [debugLogView notifyDebugLog:@"isModeOnAppT_createdModeP" region:nil location:nil];
            }
            
            // if no new location for more than certain time, make modeprompt
            lastPromptedLocation = lastPromptedLocationOnAppTerminated;
            isModeprompting = YES;
            
            // draw region overlay
            // for DMPointOptions
            isMonitoringForRegionExit = YES;
            //            mark previous location as involving a region change
            [self addOptionsToLastInsertedPoint:DMPointMonitorRegionStartPoint];
            
            // cancel all notifications
            if (!isDebugLogEnabled&&!isDebugLogLiteEnabled) {
//                [[UIApplication sharedApplication] cancelAllLocalNotifications];
                // to remove notification in iOS10
                UIApplication *application = [UIApplication sharedApplication];
                [application cancelAllLocalNotifications];
                application.applicationIconBadgeNumber = 1;
                application.applicationIconBadgeNumber = 0;
            }
            
            isModepromptingOnAppTerminated = NO;
        }
        // if DM updates location within a certain time
        else {
            // if this is called from self recordLocation
            if ([status isEqualToString:@"recordLocation"]) {
                // for DMDebugLogView
                if (isDebugLogEnabled) {
                    [debugLogView notifyDebugLog:@"isModeOnAppT_canceledModeP" region:nil location:nil];
                }
                //                // cancel the notification for modeprompt on AppTerminated
                //                NSMutableArray *array = [[NSMutableArray alloc] initWithArray:[[UIApplication sharedApplication]scheduledLocalNotifications]];
                //                for (int i = 0; i < [array count]; i++) {
                //                    UILocalNotification *notification = [array objectAtIndex:i];
                //                    NSString *DateString = [notification.userInfo valueForKey:@"NOTIFICATION_ID"];
                //                    if([DateString isEqualToString:@"modePromptOnAppTerminated"]) {
                //                        [[UIApplication sharedApplication] cancelLocalNotification:notification];
                //                    }
                //                }
                // cancel all notifications
                if (!isDebugLogEnabled&&!isDebugLogLiteEnabled) {
//                    [[UIApplication sharedApplication] cancelAllLocalNotifications];
                    // to remove notification in iOS10
                    UIApplication *application = [UIApplication sharedApplication];
                    [application cancelAllLocalNotifications];
                    application.applicationIconBadgeNumber = 1;
                    application.applicationIconBadgeNumber = 0;
                }
                
                isModepromptingOnAppTerminated = NO;
            }
        }
    }
}


#pragma mark - misc.

- (CLLocationDistance)adjustRegionRadiusBBad:(CLLocation*)location
{
    CLLocationDistance radius = location.horizontalAccuracy*1.1;
    if (radius<=DM_MONITORED_REGION_RADIUS_BBAD_MIN) {
        radius = DM_MONITORED_REGION_RADIUS_BBAD_MIN;
    }else if (radius>=DM_MONITORED_REGION_RADIUS_BBAD_MAX) {
        radius = DM_MONITORED_REGION_RADIUS_BBAD_MAX;
    }
    return radius;
}

- (CLLocationDistance)adjustRegionRadiusKeeper:(CLLocation*)location
{
    CLLocationDistance radius = location.horizontalAccuracy*0.1;
    if (radius<=DM_MONITORED_REGION_RADIUS_KEEPER_MIN) {
        radius = DM_MONITORED_REGION_RADIUS_KEEPER_MIN;
    }else if (radius>=DM_MONITORED_REGION_RADIUS_KEEPER_MAX) {
        radius = DM_MONITORED_REGION_RADIUS_KEEPER_MAX;
    }
    return radius;
}

// for modePrompt - to check if stopping for a certain time on AppTerminated
- (void)resetPromptTimeCounter
{
    self.promptTimeCountOnAppTerminated = 0;
    if (!self.promptCountTimer) {
        self.promptCountTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(promptTimeCounter:) userInfo:nil repeats:YES];
    }
}

- (void)promptTimeCounter:(NSTimer*)timer
{
    self.promptTimeCountOnAppTerminated++;
    if (self.promptTimeCountOnAppTerminated>=MODEPROMPT_THRESHOLD_ON_APP_TERMINATED) {
        self.promptTimeCountOnAppTerminated = MODEPROMPT_THRESHOLD_ON_APP_TERMINATED;
        [self.promptCountTimer invalidate];
        self.promptCountTimer = nil;
    }
}

- (int)calcPromptTimeInterval
{
    // promptTimeOnAppTerminated is used for promptTimeInterval for modeprompt onAppTerminated
    // it is also used in checkModePromptOnAppTerminated
    promptTimeOnAppTerminated = MODEPROMPT_THRESHOLD_ON_APP_TERMINATED - self.promptTimeCountOnAppTerminated;
    if (promptTimeOnAppTerminated<=10) {
        promptTimeOnAppTerminated = 10;
    }
    return promptTimeOnAppTerminated;
}

- (NSString*)wrapMotionActivityData
{
    // check if self.strMAConfidence is empty for non M7 device
//    if(self.strMAConfidence == nil || [self.strMAConfidence isEqualToString:@""]){
//        self.strMAConfidence = @"";
//    }
//
//    NSString *strMAData;
//    strMAData = @"";
//
//    // confidence
//    strMAData = [strMAData stringByAppendingString:self.strMAConfidence];
//    // activity
//    if (self.isStationary) {
//        strMAData = [strMAData stringByAppendingString:@""];
//    }
//    if (self.isWalking) {
//        strMAData = [strMAData stringByAppendingString:@", Walking"];
//    }
//    if (self.isRunning) {
//        strMAData = [strMAData stringByAppendingString:@", Running"];
//    }
//    if (self.isCycling) {  // iOS 8 and later
//        strMAData = [strMAData stringByAppendingString:@", Cycling"];
//    }
//    if (self.isAutomotive) {
//        strMAData = [strMAData stringByAppendingString:@", Automotive"];
//    }
//    if (self.isUnknown) {
//        strMAData = [strMAData stringByAppendingString:@", Unknown"];
//    }
//
//    return strMAData;
    
//    0   IN_VEHICLE  The device is in a vehicle, such as a car.
//    1   ON_BICYCLE  The device is on a bicycle.
//    2   ON_FOOT The device is on a user who is walking or running.
//    8   RUNNING The device is on a user who is running.
//    3   STILL   The device is still (not moving).
//    5   TILTING The device angle relative to gravity changed significantly.
//    4   UNKNOWN Unable to detect the current activity.
//    7   WALKING The device is on a user who is walking.

        if(self.strMAConfidence == nil || [self.strMAConfidence isEqualToString:@""]){
            return @"4";
        }
    

        if (self.isStationary) {
            return @"3";
        }
        if (self.isWalking) {
            return @"2";
        }
        if (self.isRunning) {
            return @"8";
        }
        if (self.isCycling) {  // iOS 8 and later
            return @"1";
        }
        if (self.isAutomotive) {
            return @"0";
        }
        if (self.isUnknown) {
            return @"4";
        }
    
        return @"4";
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error
{
    if ([error domain] == kCLErrorDomain && [error code] == 0)
    {
        [manager startUpdatingLocation];
    }
    DDLogWarn(@"location manager failed: %@", error.localizedDescription);
}

// saveUserDefaults
- (void)saveUserDefaults
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    [userDefaults setBool:isModeprompting forKey:@"ISMODEPROMPTING_USER_DEFAULT"];
    [userDefaults setObject:[NSKeyedArchiver archivedDataWithRootObject:lastPromptedLocation] forKey:@"LASTPROMPTEDLOCATION_DEFAULT"];
    [userDefaults setBool:isModepromptingOnAppTerminated forKey:@"ISMODEPROMPTINGOAT_USER_DEFAULT"];
    [userDefaults setObject:[NSKeyedArchiver archivedDataWithRootObject:lastPromptedLocationOnAppTerminated] forKey:@"LASTPROMPTEDLOCATIONOAT_DEFAULT"];
    [userDefaults setInteger:promptTimeOnAppTerminated forKey:@"PROMPTTIMEOAT_USER_DEFAULT"];
    // for custom survey
    [userDefaults setInteger:modepromptCount forKey:@"MODEPROMPTCOUNT_USER_DEFAULT"];
    [userDefaults setBool:isModepromptDisabled forKey:@"ISMODEPROMPTDISABLED_USER_DEFAULT"];
    [userDefaults setBool:isRecordingStopped forKey:@"ISRECORDINGSTOPPED_USER_DEFAULT"];  // recording
    [userDefaults setObject:[NSKeyedArchiver archivedDataWithRootObject:lastSubmittedPromptedLocation] forKey:@"LASTSUBMITTEDPROMPTEDLOCATION_DEFAULT"];  // cancelledPrompt
    [userDefaults setObject:[NSKeyedArchiver archivedDataWithRootObject:lastCancelledByUserPromptedLocation] forKey:@"LASTCANCELLEDBYUSERPROMPTEDLOCATION_DEFAULT"];  // cancelledPrompt
    
//    [userDefaults setBool:isDebugLogEnabled forKey:@"ISDEBUGLOG_USER_DEFAULT"];
//    [userDefaults setBool:isDebugLogLiteEnabled forKey:@"ISDEBUGLOGLITE_USER_DEFAULT"];
    
    // save userDefaults
    [userDefaults synchronize];
}


@end
