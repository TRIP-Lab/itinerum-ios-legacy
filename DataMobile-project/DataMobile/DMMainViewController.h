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
//  DMMainViewController.h
//  DataMobile
//
//  Created by Colin Rofls on 2014-07-14.
//  Copyright (c) 2014 MML-Concordia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DMLocationDisplayDelegate.h"
#import "DMDatePickerViewController.h"
#import "DMSurveyAboutViewController.h"
#import "DMSettingsViewController.h"

@class MKMapView;

@interface DMMainViewController : UIViewController <DMLocationDisplayDelegate, DMDatePickerDelegate, DMSurveyAboutViewDelegate, DMSettingsViewDelegate>
@property (weak, nonatomic) IBOutlet UIView *topContainerView;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (nonatomic) DMDatePickerValue datePickerValue;

// for avatar
@property (nonatomic, retain) DMSurveyAboutViewController *surveyAboutViewController;
// from DMSurveyAboutView
- (void)closeDMSurveyAboutView;
- (void)openDMSettingsView;

// from DMSettingsView
- (void)recordingStarted;
- (void)recordingStopped;
- (void)closeDMSettingsView;

@end
