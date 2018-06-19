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
//  DMModepromptManager.h
//  DataMobile
//
//  Created by Takeshi MUKAI on 12/21/15.
//  Copyright (c) 2015 MML-Concordia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DMMMRootViewController.h"
// new
#import "DMModepromptDoneViewController.h"

// delegate to DMLocationManager
@protocol DMModepromptManagerDelegate
- (void)insertModeprompt:(CLLocation*)location prompts:(NSArray*)prompts promptsID:(NSArray*)promptsID;
- (void)insertCancelledPrompt:(CLLocation*)location and:(BOOL)isCancelledByUser and:(NSString*)isTravelling;  // cancelledPrompt
- (void)updateTripValidated;  // new
@end

@interface DMModepromptManager : UIViewController <DMModepromptDoneViewDelegate, DMMMRootViewDelegate>  // new

@property (nonatomic, retain) id delegate;

@property (nonatomic, retain) DMMMRootViewController *mmRootViewController;
// new
@property (nonatomic, retain) DMModepromptDoneViewController *modepromptDoneViewController;

- (void)allocModepromptAlertView;
- (void)readyModeprompt:(CLLocation*)lastLocation;
- (void)deleteModeprompt;
- (void)showAlertViewConfirm;
- (void)dealModepromptFromNotif:(BOOL)isShowModePrompt;
- (void)setLocalNotificationModeprompt:(NSTimeInterval)interval;

// from DMModepromptManager
- (void)submitDMMMRootView:(NSDictionary*)dictPromptAnswer;
- (void)closeDMMMRootView;

// new
// from DMModepromptDoneView
- (void)closeDMModepromptDoneView;

@end
