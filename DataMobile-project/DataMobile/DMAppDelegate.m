

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
//  DMAppDelegate.m
//  DataMobile
//
//  Created by Kim Sawchuk on 11-11-25.
//  Copyright (c) 2011 MML-Concordia. All rights reserved.
//
// Modified by MUKAI Takeshi in 2015-11

#import "DMAppDelegate.h"
#import "CoreDataHelper.h"
#import "Config.h"
#import "EntityManager.h"
#import "DataSender.h"

#import "DDFileLogger.h"
#import "DDTTYLogger.h"
#import "DDMultipeerLogger.h"
#import <mach/mach.h>

#import "DMEfficientLocationManager.h"

BOOL isModeprompting;  // external
CLLocation* lastPromptedLocation;  // external
BOOL isAppTerminated;  // external
BOOL isModepromptingOnAppTerminated;  // external
CLLocation* lastPromptedLocationOnAppTerminated;  // external
BOOL isMonitoringForRegionExit;  // external
int promptTimeOnAppTerminated;  // external
int modepromptCount;  // external
BOOL isModepromptDisabled;  // external

BOOL isDebugLogEnabled;  // external
BOOL isDebugLogLiteEnabled;  // external

// new
UILabel *totalTripsLabelELM;  // external
BOOL isMaxDaysCompleted;  // external

// cancelledPrompt
CLLocation* lastSubmittedPromptedLocation;  // external
CLLocation* lastCancelledByUserPromptedLocation;  // external

// recording
BOOL isRecordingStopped;  // external


BOOL isNotModepromptManagerAlloced;


typedef enum {
    CONNECTION_SUCCESS = 0,
    CONNECTION_FAIL = 1,
    CONNECTION_ATTEMPTING = 2,
} ConnnectionState;

@interface DMAppDelegate ()
{
    ConnnectionState state;
    DMEfficientLocationManager *efficientLocationManager;
}

- (void)report_memory;

@end

//declared in DMGlobalLogger.h
int ddLogLevel;


#define DM_DEBUG_SHOW_SURVEY 0

@implementation DMAppDelegate

@synthesize window = _window;

- (void)report_memory
{
    struct task_basic_info info;
    mach_msg_type_number_t size = sizeof(info);
    kern_return_t kerr = task_info(mach_task_self(),
                                   TASK_BASIC_INFO,
                                   (task_info_t)&info,
                                   &size);
    if( kerr == KERN_SUCCESS ) {
        NSString *byteCount = [NSByteCountFormatter stringFromByteCount:info.resident_size
                                                             countStyle:NSByteCountFormatterCountStyleMemory];
        DDLogInfo(@"Memory in use: %@", byteCount);
    } else {
        DDLogInfo(@"Memory in use: ERROR");
    }
}

- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings {
    DDLogInfo(@"didRegisterUserNotificationSettings: %@", notificationSettings);
}

#pragma mark - Application Lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [Config loadForFileName:@"config"];

//    set up logging
    ddLogLevel = LOG_LEVEL_VERBOSE;
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    DDFileLogger *fileLogger = [[DDFileLogger alloc] init];
    fileLogger.rollingFrequency = 60 * 60 * 24; // 24 hour rolling
    fileLogger.logFileManager.maximumNumberOfLogFiles = 7;
    [DDLog addLogger:fileLogger];
    [DDLog addLogger:[[DDMultipeerLogger alloc]init]];
    
    
    // this is called when app is launched on app terminated status by some services
    if([launchOptions objectForKey:UIApplicationLaunchOptionsLocationKey] != nil)
    {
        // it is called by Location services (region, significant)
        if([[launchOptions allKeys] containsObject:UIApplicationLaunchOptionsLocationKey]) {
            isAppTerminated = YES;
        }
    }
    
    //register for background data transfer: set fetch interval
    [application setMinimumBackgroundFetchInterval:(60 * 60 * 8)];

    // set up our main view
    UIStoryboard *storyboard;
    if ([[[CoreDataHelper instance] entityManager]userExistsAndCompletedSurveyCustom] && !DM_DEBUG_SHOW_SURVEY) {
        storyboard = [UIStoryboard storyboardWithName:@"NewLook" bundle:nil];
    }else {
        storyboard = [UIStoryboard storyboardWithName:@"NewSurvey" bundle:nil];
    }
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = [storyboard instantiateInitialViewController];
    [self.window makeKeyAndVisible];
    
    
    // ready local notification - it needs for iOS8 or above
    if ([application respondsToSelector:@selector(registerUserNotificationSettings:)])
    {
        // ready action notification - ios8 or above
        UIMutableUserNotificationAction *acceptAction = [[UIMutableUserNotificationAction alloc] init];
        acceptAction.identifier = @"ACCEPT_IDENTIFIER";
        acceptAction.title = NSLocalizedString(@"Yes", @"");
        acceptAction.activationMode = UIUserNotificationActivationModeForeground;
        acceptAction.destructive = NO;
        acceptAction.authenticationRequired = NO;
        
        UIMutableUserNotificationAction *declineAction = [[UIMutableUserNotificationAction alloc] init];
        declineAction.identifier = @"DECLINE_IDENTIFIER";
        declineAction.title = NSLocalizedString(@"No", @"");
        declineAction.activationMode = UIUserNotificationActivationModeBackground;
        declineAction.destructive = NO;
        declineAction.authenticationRequired = NO;
        
        // set category - action notification
        UIMutableUserNotificationCategory *inviteCategory = [[UIMutableUserNotificationCategory alloc] init];
        inviteCategory.identifier = @"INVITE_CATEGORY";
        [inviteCategory setActions:@[acceptAction, declineAction] forContext:UIUserNotificationActionContextDefault];
        [inviteCategory setActions:@[acceptAction, declineAction] forContext:UIUserNotificationActionContextMinimal];
        
        // register
        NSSet *categories = [NSSet setWithObjects:inviteCategory, nil];
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound categories:categories];
        [application registerUserNotificationSettings:settings];
    }
    
    // if completedSurvey - to avoid from loading modeprompt questions when survey has not finished (first time app launch)
    if ([[[CoreDataHelper instance] entityManager]userExistsAndCompletedSurveyCustom]){
        // alloc DMEfficientLocationManager
        efficientLocationManager = [[DMEfficientLocationManager alloc] init];
        // modepromtManager - allocModepromptAlerView to access from DMAppDelegate - notification
        [efficientLocationManager allocDMModepromptManager]; 
    }else{
        // if not completedSurvey, alloc DMModeprmptManager(from DMAppDelegate) from DidBecomeActive (after completedSurvey)
        isNotModepromptManagerAlloced = YES;
    }
    
    DDLogInfo(@"Did Finish Launching");
    return YES;
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    DDLogInfo(@"received local notification: %@", notification);
    
    // local notification - callback
    
    // notification when app is active
    if(application.applicationState == UIApplicationStateActive) {
    }
    // notification when app is background
    if(application.applicationState == UIApplicationStateInactive || application.applicationState == UIApplicationStateBackground) {
        // if the notification is modePrompt
        if([[notification.userInfo objectForKey:@"NOTIFICATION_ID"] isEqualToString:@"modePrompt"] || [[notification.userInfo objectForKey:@"NOTIFICATION_ID"] isEqualToString:@"modePromptOnAppTerminated"]) {
            [efficientLocationManager checkModePromptOnAppTerminated:@"didReceiveLocalNotification"];
            [efficientLocationManager.modepromptManager dealModepromptFromNotif:YES];
        }
    }
    
    // delete from notificationCenter
    [[UIApplication sharedApplication] cancelLocalNotification:notification];
}


// action notification - ios8 or above
- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forLocalNotification:(UILocalNotification *)notification completionHandler:(void (^)(void))completionHandler {
    
    if ([identifier isEqualToString:@"ACCEPT_IDENTIFIER"]) {
        // if the notification is modePrompt
        if([[notification.userInfo objectForKey:@"NOTIFICATION_ID"] isEqualToString:@"modePrompt"] || [[notification.userInfo objectForKey:@"NOTIFICATION_ID"] isEqualToString:@"modePromptOnAppTerminated"]) {
            [efficientLocationManager checkModePromptOnAppTerminated:@"didReceiveLocalNotification"];
            [efficientLocationManager.modepromptManager dealModepromptFromNotif:YES];
        }
    }else if([identifier isEqualToString:@"DECLINE_IDENTIFIER"]) {
        // if the notification is modePrompt
        if([[notification.userInfo objectForKey:@"NOTIFICATION_ID"] isEqualToString:@"modePrompt"] || [[notification.userInfo objectForKey:@"NOTIFICATION_ID"] isEqualToString:@"modePromptOnAppTerminated"]) {
            [efficientLocationManager checkModePromptOnAppTerminated:@"didReceiveLocalNotification"];
            [efficientLocationManager.modepromptManager dealModepromptFromNotif:NO];
        }
        
        //MARK:ADDED BY SAGAR TO FIX THIS : https://gitlab.com/itinerum/itinerum-ios/issues/67
        
    }else if ([identifier isEqualToString:@"INVITE_CATEGORY"]){
        if([[notification.userInfo objectForKey:@"NOTIFICATION_ID"] isEqualToString:@"modePrompt"] || [[notification.userInfo objectForKey:@"NOTIFICATION_ID"] isEqualToString:@"modePromptOnAppTerminated"]) {
            [efficientLocationManager checkModePromptOnAppTerminated:@"didReceiveLocalNotification"];
            [efficientLocationManager.modepromptManager dealModepromptFromNotif:YES];
        }
       
    }
    
    
    
    // delete from notificationCenter
    [[UIApplication sharedApplication] cancelLocalNotification:notification];
    
    if (completionHandler) {
        completionHandler();
    }
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
    
    [[CoreDataHelper instance] resetContext];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    DDLogInfo(@"Did Enter Background");
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
    
    [[CoreDataHelper instance] resetContext];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */    
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
    
    // if DMModepromptMager(from DMAppDelegate) has not been alloced yet and completedSurvey (first time app launch)
    if (isNotModepromptManagerAlloced && [[[CoreDataHelper instance] entityManager]userExistsAndCompletedSurveyCustom]){
        // alloc DMEfficientLocationManager
        efficientLocationManager = [[DMEfficientLocationManager alloc] init];
        // modepromtManager - allocModepromptAlerView to access from DMAppDelegate - notification
        [efficientLocationManager allocDMModepromptManager];
        
        isNotModepromptManagerAlloced = NO;
    }
    
    // for modePrompt - to check if stopping for a certain time on AppTerminated
    [efficientLocationManager checkModePromptOnAppTerminated:@"applicationDidBecomeActive"];
    
    // to show alertview if app becomes foreground without touching notification
    [efficientLocationManager.modepromptManager showAlertViewConfirm];
    
    isAppTerminated = NO;
    
    // Handle launching from a notification
    application.applicationIconBadgeNumber = 0;

    [[DataSender instance] syncWithServer];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    DDLogInfo(@"application will terminate");
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
    
    // Saves changes in the application's managed object context before the application terminates.
    [[[CoreDataHelper instance] entityManager] saveContext];
    
    [self report_memory];
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
    DDLogInfo(@"application received memory warning");
    [[CoreDataHelper instance] resetContext];
    [self report_memory];
}


- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    // Sync the data
    DDLogInfo(@"background fetch called");
    __block BOOL isWaiting = YES;
    [[DataSender instance]syncWithServerSynchronously:^(BOOL success) {
        if (success == YES) {
            completionHandler(UIBackgroundFetchResultNewData);
            isWaiting = NO;
        }else {
            completionHandler(UIBackgroundFetchResultFailed);
            isWaiting = NO;
        }
    }];

    while (isWaiting) {
        [NSThread sleepForTimeInterval:0.001];
    }
}


#pragma mark - NSURLConnectionDataDelegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    state = CONNECTION_SUCCESS;
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    state = CONNECTION_FAIL;
}


@end
