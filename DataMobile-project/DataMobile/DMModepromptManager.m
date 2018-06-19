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
//  DMModepromptManager.m
//  DataMobile
//
//  Created by Takeshi MUKAI on 12/21/15.
//  Copyright (c) 2015 MML-Concordia. All rights reserved.
//

#import "DMModepromptManager.h"
#import "DMAppDelegate.h"
#import "Config.h"
#import "CoreDataHelper.h"
#import "EntityManager.h"

@interface DMModepromptManager ()
@property (nonatomic, retain) NSArray *arrayPrompts;
@property (nonatomic, retain) NSMutableArray *mArrayAnswers;
@property (nonatomic, retain) NSMutableArray *mArrayPromptsID;
@property (nonatomic) int promptIndex;
@property (nonatomic) BOOL isCustomSurvey;
@property (nonatomic) int modepromptCountMax;
@property (nonatomic, retain) IBOutlet UIView *viewFade;
@property (strong, nonatomic) CLLocation* preCancelledPromptLocation;  // cancelledPrompt
@property (strong, nonatomic) UIAlertController *alertController;  // use UIAlertController instead of UIAlertView, because UIAlertView has a bug which sometimes clears views on the root(TRIPS VALIDATED)
@end

@implementation DMModepromptManager
@synthesize delegate;
@synthesize mmRootViewController;
@synthesize modepromptDoneViewController;  // new

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.viewFade.alpha = 0.0;
    
    [self allocModepromptAlertView];
}

// this is called from DMEfficientLocationManger, and from DMAppDelegate
// it should be called twice? because to show alertView when it is called from both of DMEfficientLocationManger and DMAppDelegate
- (void)allocModepromptAlertView
{
    if ([[[CoreDataHelper instance] entityManager] fetchCustomSurveyData]) {
        NSDictionary* dictResults = [[[CoreDataHelper instance] entityManager] fetchCustomSurveyData];
        NSDictionary* dictSurveies = [dictResults objectForKey:@"results"];
        NSDictionary* dictPrompt = [dictSurveies objectForKey:@"prompt"];
        self.arrayPrompts = [dictPrompt objectForKey:@"prompts"];
        self.isCustomSurvey = YES;
        
        // check if custom propmpts exists
        if (self.arrayPrompts.count==0) {
            // if custom ptompts are not created on the dashboard
            isModepromptDisabled = YES;
        }else{
            // if custom prompts exist
            // load num_prompts
            NSString *strNumPrompts = [NSString stringWithFormat:@"%@",[dictPrompt objectForKey:@"maxPrompts"]];
            self.modepromptCountMax = [strNumPrompts intValue];
            if (self.modepromptCountMax<=0) {
                isModepromptDisabled = YES;
            }
        }
    }else{
        // if not custom survey
        // load all prompts from Config
        NSString *currentLanguage = [[NSLocale preferredLanguages] objectAtIndex:0];
        // change file by language
        if ([currentLanguage hasPrefix:@"fr"]) {
            self.arrayPrompts = [[Config instance] arrayValueForKey:@"dmapiPrompts_fr"];
        }else{
            self.arrayPrompts = [[Config instance] arrayValueForKey:@"dmapiPrompts"];
        }
    }
    self.mArrayAnswers = [[NSMutableArray alloc] init];
    self.mArrayPromptsID = [[NSMutableArray alloc] init];
}

// add cacelled_at  // cancelledPrompt
- (void)cancelPromptByUser:(NSString*)isTravelling
{
    if (lastPromptedLocation) {
        // check if the lastPromptedLocation is already submitted (the prompt is answered)
        if (lastSubmittedPromptedLocation!=lastPromptedLocation) {
            // since here could be called many times at once, put it just once
            if (self.preCancelledPromptLocation!=lastPromptedLocation) {
                // if not submitted
                // insert cancelledprompt, delegate to DMLocationManager
                [delegate insertCancelledPrompt:lastPromptedLocation and:YES and:isTravelling];
                self.preCancelledPromptLocation = lastPromptedLocation;
                lastCancelledByUserPromptedLocation = lastPromptedLocation;
            }
        }
    }
}

// this is called from DMEfficientLocationManger - when stopped
- (void)readyModeprompt:(CLLocation*)lastLocation
{
    lastPromptedLocation = lastLocation;
    isModeprompting = YES;
    
    // if app is active(foreground), it will show alertViewConfirm, (or alertViewConfirm depends on notification)
    UIApplicationState applicationState = [[UIApplication sharedApplication] applicationState];
    if (applicationState == UIApplicationStateActive) {
        [self showAlertViewConfirm];
    }
    
    // set local notification instantly
    [self setLocalNotificationModeprompt:0];
}

// this is called from DMEfficientLocationManger - when switchToGps - left from geofence
- (void)deleteModeprompt
{
    // delete all from notificationCenter
    if (!isDebugLogEnabled&&!isDebugLogLiteEnabled) {
        //            [[UIApplication sharedApplication] cancelAllLocalNotifications];
        // to remove notification in iOS10
        UIApplication *application = [UIApplication sharedApplication];
        [application cancelAllLocalNotifications];
        application.applicationIconBadgeNumber = 1;
        application.applicationIconBadgeNumber = 0;
    }
    
    isModeprompting = NO;
    
    // dismiss alertController
    [self dismissViewControllerAnimated:YES completion:nil];
    
    // cancelledPrompt
    if (lastPromptedLocation) {
        // check if the lastPromptedLocation is already submitted (the prompt is answered)
        if (lastSubmittedPromptedLocation!=lastPromptedLocation) {
            // check if the lastCancelledByUserLocation is already submitted (the prompt is answered)
            if (lastCancelledByUserPromptedLocation!=lastPromptedLocation) {
                // since here could be called many times at once, put it just once
                if (self.preCancelledPromptLocation!=lastPromptedLocation) {
                    // if not submitted
                    // insert cancelledprompt, delegate to DMLocationManager
                    [delegate insertCancelledPrompt:lastPromptedLocation and:NO and:@"NULL"];
                    self.preCancelledPromptLocation = lastPromptedLocation;
                }
            }
        }
    }
}

// show AlerViewConfirm
// it is also called from DMAppDelegate when app becomes foreground - to show alertview if app becomes foreground without touching nitification
- (void)showAlertViewConfirm
{
    if (isModeprompting) {
        // delete all from notificationCenter
        if (!isDebugLogEnabled&&!isDebugLogLiteEnabled) {
            //            [[UIApplication sharedApplication] cancelAllLocalNotifications];
            // to remove notification in iOS10
            UIApplication *application = [UIApplication sharedApplication];
            [application cancelAllLocalNotifications];
            application.applicationIconBadgeNumber = 1;
            application.applicationIconBadgeNumber = 0;
        }
        
        // show alertViewConfirm
        self.alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"You seem to have stopped.", @"") message:NSLocalizedString(@"Have you reached a destination?", @"") preferredStyle:UIAlertControllerStyleAlert];
        [self.alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"No", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self cancelPromptByUser:@"NULL"];
        }]];
        [self.alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Yes", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self showAlertViewPrompt];
        }]];
        [self presentViewController:self.alertController animated:YES completion:nil];
        
        isModeprompting = NO;
    }
}

// from DMAppDelegate - with notification
- (void)dealModepromptFromNotif:(BOOL)isShowModePrompt
{
    // hide (not showing) alertViewConfirm
    isModeprompting = NO;
    
    if (isShowModePrompt) {
        // will show alerViewModeTravel directly
        [self showAlertViewPrompt];
    }
    else{  // cancelledPrompt
        [self cancelPromptByUser:@"NULL"];
    }
}

// set alertViewPrompt - title and choices
- (void)showAlertViewPrompt
{
    // alloc DMMMRootView
    [self allocDMMMRootView];
}

// add prompt answer to mArrayAnswers
- (void)addPromptAnswer:(NSDictionary*)dictPromptAnswer;
{
    // reset mArray first
    [self.mArrayAnswers removeAllObjects];
    [self.mArrayPromptsID removeAllObjects];
    
    for (int i=0; i<self.arrayPrompts.count; i++) {
        NSString *strPrompt = [NSString stringWithFormat:@"%@",[self.arrayPrompts[i] objectForKey:@"prompt"]];
        NSArray *arrayAnswer = [dictPromptAnswer objectForKey:strPrompt];
        [self.mArrayAnswers addObject:arrayAnswer];
        [self.mArrayPromptsID addObject:strPrompt];
    }
    
    // if final prompt ends
    // insert modeprompt, delegate to DMLocationManager
    [delegate insertModeprompt:lastPromptedLocation prompts:self.mArrayAnswers promptsID:self.mArrayPromptsID];
    // put lastSubmittedPopmtedLocation  // cancelledPrompt
    lastSubmittedPromptedLocation = lastPromptedLocation;
    
    // add mode promptCount
    modepromptCount++;
    // if modeprompt count is over modepromptCountMax, disable modeprompt
    if (modepromptCount>=self.modepromptCountMax) {
        modepromptCount = self.modepromptCountMax;
        isModepromptDisabled = YES;
        
        // new
        // modepropmpt is over, show DMModepromptDoneView
        [self allocDMModepromptDoneView];
    }
    // new
    // to DMEfficientLocationManager - update UILabel TripValidated
    [delegate updateTripValidated];
}

- (void)setLocalNotificationModeprompt:(NSTimeInterval)interval
{
    // set local notification for Modeprompt
    // cancel all notifications first
    if (!isDebugLogEnabled&&!isDebugLogLiteEnabled) {
        //        [[UIApplication sharedApplication] cancelAllLocalNotifications];
        // to remove notification in iOS10
        UIApplication *application = [UIApplication sharedApplication];
        [application cancelAllLocalNotifications];
        application.applicationIconBadgeNumber = 1;
        application.applicationIconBadgeNumber = 0;
    }
    
    // set localNotification
    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
    localNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:interval];
    localNotification.timeZone = [NSTimeZone defaultTimeZone];
    localNotification.soundName = UILocalNotificationDefaultSoundName;
    
    localNotification.alertBody = NSLocalizedString(@"You seem to have stopped.\nHave you reached a destination?", @"");
    localNotification.alertAction = NSLocalizedString(@"Open", @"");
    // if iOS8 or above
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
        localNotification.category = @"INVITE_CATEGORY";
    }
    if (interval==0) {  // if this is called when normal geofence is created
        localNotification.userInfo = [NSDictionary dictionaryWithObject:@"modePrompt" forKey:@"NOTIFICATION_ID"];
    }else{  // if this is called when app terminated geofence is created - to delete specific notification
        localNotification.userInfo = [NSDictionary dictionaryWithObject:@"modePromptOnAppTerminated" forKey:@"NOTIFICATION_ID"];
    }
    
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
}

// alloc DMMMRootView
- (void)allocDMMMRootView
{
    self.view.userInteractionEnabled = YES;
    
    // use StoryBoard
    UIStoryboard *mmRootStoryboard = [UIStoryboard storyboardWithName:@"DMMMRoot" bundle:nil];
    mmRootViewController = [mmRootStoryboard instantiateViewControllerWithIdentifier:@"DMMMRoot"];
    mmRootViewController.delegate = self;
    mmRootViewController.arrayPrompts = self.arrayPrompts;
    mmRootViewController.view.frame = [[UIScreen mainScreen] bounds];
    [self.view addSubview:mmRootViewController.view];
    mmRootViewController.view.alpha = 0.0;
    
    // popUp animation
    [UIView beginAnimations:nil context:nil];
    //	[UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    [UIView setAnimationDuration:0.2];
    [UIView setAnimationDelay:0.2];
//    [UIView setAnimationDelegate:self];
//    [UIView setAnimationDidStopSelector:@selector(removeDMMMRootView)];
    mmRootViewController.view.alpha = 1.0;
    self.viewFade.alpha = 0.24;
    [UIView commitAnimations];
}

// delegate from DMMMRootView
- (void)submitDMMMRootView:(NSDictionary*)dictPromptAnswer
{
    [self addPromptAnswer:dictPromptAnswer];
    [self closeDMMMRootView];
}

- (void)closeDMMMRootView
{
    if (!isModepromptDisabled) {  // if modepromptDoneView is not showing
        self.view.userInteractionEnabled = NO;
    }
    
    // popUp animation
    [UIView beginAnimations:nil context:nil];
    //	[UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    [UIView setAnimationDuration:0.2];
    [UIView setAnimationDelay:0.2];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(removeDMMMRootView)];
    mmRootViewController.view.alpha = 0.0;
    if (!isModepromptDisabled) {
        self.viewFade.alpha = 0.0;
    }
    [UIView commitAnimations];
}

- (void)removeDMMMRootView
{
    [mmRootViewController.view removeFromSuperview];
}

// new
// alloc DMModeprompDoneView
- (void)allocDMModepromptDoneView
{
    self.view.userInteractionEnabled = YES;
    
    // alloc DMModeprompDoneView
    modepromptDoneViewController = [[DMModepromptDoneViewController alloc] initWithNibName:@"DMModepromptDoneViewController" bundle:nil];
    modepromptDoneViewController.delegate = self;
    modepromptDoneViewController.view.frame = [[UIScreen mainScreen] bounds];
    [self.view addSubview:modepromptDoneViewController.view];
    modepromptDoneViewController.view.frame = CGRectMake(modepromptDoneViewController.view.frame.origin.x, modepromptDoneViewController.view.frame.size.height, modepromptDoneViewController.view.frame.size.width, modepromptDoneViewController.view.frame.size.height);
    
    // popUp animation
    [UIView beginAnimations:nil context:nil];
    //	[UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    [UIView setAnimationDuration:0.4];
    [UIView setAnimationDelay:0.4];
    modepromptDoneViewController.view.frame = CGRectMake(modepromptDoneViewController.view.frame.origin.x, 0, modepromptDoneViewController.view.frame.size.width, modepromptDoneViewController.view.frame.size.height);
    self.viewFade.alpha = 0.24;
    [UIView commitAnimations];
    
    // close DMModepromptDoneView automatically after for a while
    [self performSelector:@selector(closeDMModepromptDoneView) withObject:nil afterDelay:10];
}

// delegate from DMModepromptDoneView
- (void)closeDMModepromptDoneView
{
    self.view.userInteractionEnabled = NO;
    
    // popUp animation
    [UIView beginAnimations:nil context:nil];
    //	[UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    [UIView setAnimationDuration:0.4];
    [UIView setAnimationDelay:0.2];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(removeDMModepromptDoneView)];
    modepromptDoneViewController.view.frame = CGRectMake(modepromptDoneViewController.view.frame.origin.x, modepromptDoneViewController.view.frame.size.height, modepromptDoneViewController.view.frame.size.width, modepromptDoneViewController.view.frame.size.height);
    self.viewFade.alpha = 0.0;
    [UIView commitAnimations];
}

- (void)removeDMModepromptDoneView
{
    [modepromptDoneViewController.view removeFromSuperview];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
