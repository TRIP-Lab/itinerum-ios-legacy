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
//  DMAppDelegate.h
//  DataMobile
//
//  Created by Kim Sawchuk on 11-11-25.
//  Copyright (c) 2011 MML-Concordia. All rights reserved.
//
// Modified by MUKAI Takeshi in 2015-11

#import <UIKit/UIKit.h>

#define DM_DAY_DURATION_OF_SURVEY 14  // this is default, but it would be overridden by user
#define DM_MAX_MODEPROMPT_COUNT 25 // this is default, but it would be overridden by user, -1 means no limits

@class CoreDataHelper;

@interface DMAppDelegate : UIResponder <UIApplicationDelegate, NSURLConnectionDataDelegate>

@property (strong, nonatomic) UIWindow *window;

// these are used in (called from) DMAppDelegate and DMEfficientLocation (and DMModePrompt)
// it should be global to work correctly
extern BOOL isModeprompting;
extern CLLocation* lastPromptedLocation;
extern BOOL isAppTerminated;
extern BOOL isModepromptingOnAppTerminated;
extern CLLocation* lastPromptedLocationOnAppTerminated;
extern BOOL isMonitoringForRegionExit;
extern int promptTimeOnAppTerminated;
// for custom survey
extern int modepromptCount;
extern BOOL isModepromptDisabled;

extern BOOL isDebugLogEnabled;
extern BOOL isDebugLogLiteEnabled;

// new
extern UILabel *totalTripsLabelELM;
extern BOOL isMaxDaysCompleted;

// cancelledPrompt
extern CLLocation* lastSubmittedPromptedLocation;
extern CLLocation* lastCancelledByUserPromptedLocation;

// recording
extern BOOL isRecordingStopped;

@end
