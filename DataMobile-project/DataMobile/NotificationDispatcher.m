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
//  NotificationDispatcher.m
//  DataMobile
//
//  Created by Zachary Patterson on 12-11-06.
//  Copyright (c) 2012 MML-Concordia. All rights reserved.
//

#import "NotificationDispatcher.h"
#import "CoreDataHelper.h"
#import "EntityManager.h"
#import "User.h"
#import "DMUserSurveyForm.h"


@interface NotificationDispatcher ()

-(id)init;

@end

@implementation NotificationDispatcher

static NotificationDispatcher* _instance = nil;

-(id)init
{
    if(self = [super init])
    {
    }
    return self;
}

+(instancetype)sharedInstance {
    static NotificationDispatcher *singleton = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        singleton = [[self alloc]init];
    });
    return singleton;
}

+(void)requestNotificationAuthorization {

    if ([[UIApplication sharedApplication]respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        UIUserNotificationSettings * settings = [[UIApplication sharedApplication]currentUserNotificationSettings];
        
        if (!(settings.types & UIUserNotificationTypeAlert) ||
            !(settings.types & UIUserNotificationTypeBadge) ||
            !(settings.types & UIUserNotificationTypeSound))
        {
            DDLogInfo(@"not currently authorized to show full alerts");
            DDLogInfo(@" current settings: %@", settings);
        
        settings = [UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound) categories:nil];
        
        [[UIApplication sharedApplication]registerUserNotificationSettings:settings];
        }
    }
}
//FIXME: this is not one hour right now (debug)
#define THIRTY_MINUTES 60*30
#define SIX_HOURS 60*60*6


+(void)startNotificationDispatcher {
    if ([[NSUserDefaults standardUserDefaults]boolForKey:DM_REMINDERS_FIELD_KEY]) {
        [[UIApplication sharedApplication]cancelAllLocalNotifications];
        UILocalNotification *note = [[UILocalNotification alloc]init];
        note.alertAction = NSLocalizedString(@"Launch", nil);
        note.alertBody = NSLocalizedString(@"DataMobile is not running. Please remember to run DataMobile!", nil);
        note.soundName = UILocalNotificationDefaultSoundName;
        note.applicationIconBadgeNumber = 1;

        
        UILocalNotification *note2 = [note copy];
        UILocalNotification *note3 = [note copy];
        
        note.fireDate = [NSDate dateWithTimeIntervalSinceNow:THIRTY_MINUTES];
        note2.fireDate = [NSDate dateWithTimeIntervalSinceNow:SIX_HOURS];
        note3.fireDate = [self tomorrowMorningDate];
        
        DDLogInfo(@"scheduled notification for %@, next morning = %@", note.fireDate, note3.fireDate);
        [[UIApplication sharedApplication]scheduleLocalNotification:note];
        [[UIApplication sharedApplication]scheduleLocalNotification:note2];
        [[UIApplication sharedApplication]scheduleLocalNotification:note3];
        
        [self performSelector:@selector(startNotificationDispatcher)
                   withObject:self
                   afterDelay:THIRTY_MINUTES-5];
            }
}


+(NSDate*)tomorrowMorningDate
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:(NSCalendarUnitYear | NSCalendarUnitDay | NSCalendarUnitMonth)
                                               fromDate:[NSDate date]];
    components.day++;
    components.hour = 8;
    components.minute = 0;
    components.second = 0;
    
    return [calendar dateFromComponents:components];
    
}


//-(void)scheduleDailyNotifications
//{
//    UIApplication* app = [UIApplication sharedApplication];
//    [app cancelAllLocalNotifications];
//
//    NSDate* today = [[NSDate alloc] initWithTimeIntervalSinceNow:0];
//    for(int i = MAX_RECORDING_DAYS ; i > 0  ; i--)
//    {
//        UILocalNotification* notification = [[UILocalNotification alloc] init];
//        
//        NSDate* inIdays = [[NSDate alloc] initWithTimeInterval:i*24*3600
//                                                     sinceDate:today];
//        notification.fireDate = inIdays;
//        notification.alertBody = @"Please keep DataMobile running and remember to reopen DataMobile if your phone has been turned off.";
//        notification.alertAction = @"Run DataMobile";
//        notification.soundName = UILocalNotificationDefaultSoundName;
//        
//        [app scheduleLocalNotification:notification];
//    }
//}

@end
