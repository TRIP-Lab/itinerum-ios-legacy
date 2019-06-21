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
//  DMMainViewController.m
//  DataMobile
//
//  Created by Colin Rofls on 2014-07-14.
//  Copyright (c) 2014 MML-Concordia. All rights reserved.
//
// Modified by MUKAI Takeshi in 2015-10

#import "DMMainViewController.h"

//#import "NotificationDispatcher.h"
#import "CoreDataHelper.h"
#import "EntityManager.h"

#import "DMLocationManager.h"
#import "DMPathOverlay.h"
#import "DMPathOverlayRenderer.h"

#import <MapKit/MapKit.h>
#import <MessageUI/MessageUI.h>

#import "DMAppDelegate.h"
#import "ScaleFontSize.h"


@interface DMMainViewController () <MKMapViewDelegate, MFMailComposeViewControllerDelegate>

@property (strong, nonatomic) IBOutlet UIButton* locationButton;
@property (strong, nonatomic) IBOutlet UIButton* infoButton;

@property (weak, nonatomic) IBOutlet UILabel *surveyCompleteLabel;
@property (strong, nonatomic) NSDate* surveyStartDate;
@property (strong, nonatomic) NSDate* displayStartDate;
@property (strong, nonatomic) NSDate* displayEndDate;

@property (strong, nonatomic) DMLocationManager *locationManager;
@property (strong, nonatomic) CLLocation* lastLocation;
@property (strong, nonatomic) DMPathOverlay* overlay;
@property (strong, nonatomic) DMPathOverlayRenderer* overlayRenderer;
@property (strong, nonatomic) MKCircle* monitoredRegionOverlay;
@property (strong, nonatomic) MKCircleRenderer* monitoredRegionOverlayRenderer;

@property (nonatomic) BOOL needsToCenterOnUserLocation;
@property (nonatomic) BOOL shouldAddNewPoints;

@property (nonatomic) NSInteger totalPoints;
@property (nonatomic) NSInteger totalDays;
@property (nonatomic) NSInteger dayDuration;
@property (strong, nonatomic) IBOutlet UILabel* totalPointsLabel;
@property (strong, nonatomic) IBOutlet UILabel* totalDaysLabel;
@property (strong, nonatomic) IBOutlet UIButton* dateButton;
@property (strong, nonatomic) IBOutlet UIImageView* divideLine1;
@property (strong, nonatomic) IBOutlet UIImageView* divideLine2;
@property (strong, nonatomic) IBOutlet UIView* surveyCompleteFadeView;

@property (strong, nonatomic) IBOutlet UILabel* labelPointRecorded;
@property (strong, nonatomic) IBOutlet UILabel* labelDaysRemaining;
@property (strong, nonatomic) IBOutlet UILabel* labelDisplaying;
@property (strong, nonatomic) IBOutlet UILabel* labelDayDuration;

// for avatar
@property (strong, nonatomic) IBOutlet UIView* viewAvatar;
@property (strong, nonatomic) IBOutlet UIImageView* avatar;
@property (strong, nonatomic) UIToolbar *blurToolbarFade;
//@property (strong, nonatomic) UIImageView *imgFadeBlack;

// new
@property (strong, nonatomic) IBOutlet UILabel* labelTripsValidated;
@property (strong, nonatomic) IBOutlet UILabel* labelModepromptMaxCount;
@property (strong, nonatomic) IBOutlet UILabel* totalTripsLabel;
@property (strong, nonatomic) IBOutlet UIView* viewPointRecorded;
@property (strong, nonatomic) IBOutlet UIView* viewTripsValidated;
@property (nonatomic) int modepromptCountMax;
@property (strong, nonatomic) IBOutlet UIView* byDataMobile;

// recording
@property (weak, nonatomic) IBOutlet UILabel *labelRecordingStopped;

@end

@implementation DMMainViewController
{
    DMDatePickerValue _datePickerValue;
}

// for avatar
@synthesize surveyAboutViewController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

// make statusbar white
- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (DMLocationManager*)locationManager {
    if (!_locationManager) {
        _locationManager = [DMLocationManager defaultLocationManager];
        _locationManager.displayDelegate = self;
    }
    return _locationManager;
}

static const int MIN_HORIZONTAL_ACCURACY_DISPLAY = 100;


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // scaleFontSizeByScreenWidth
    CGFloat scaleFontSize = [ScaleFontSize scaleFontSizeByScreenWidth];
    self.labelPointRecorded.font = [UIFont fontWithName:@"AvenirNextCondensed-Medium" size:11*scaleFontSize];
    self.labelDaysRemaining.font = [UIFont fontWithName:@"AvenirNextCondensed-Medium" size:11*scaleFontSize];
    self.labelDisplaying.font = [UIFont fontWithName:@"AvenirNextCondensed-Medium" size:11*scaleFontSize];
    self.labelDayDuration.font = [UIFont fontWithName:@"AvenirNextCondensed-Medium" size:11*scaleFontSize];
    self.totalPointsLabel.font = [UIFont fontWithName:@"AvenirNextCondensed-Bold" size:24*scaleFontSize];
    self.totalDaysLabel.font = [UIFont fontWithName:@"AvenirNextCondensed-Bold" size:24*scaleFontSize];
    self.dateButton.titleLabel.font = [UIFont fontWithName:@"AvenirNextCondensed-Bold" size:12*scaleFontSize];
    self.labelTripsValidated.font = [UIFont fontWithName:@"AvenirNextCondensed-Medium" size:11*scaleFontSize]; // new
    self.labelModepromptMaxCount.font = [UIFont fontWithName:@"AvenirNextCondensed-Medium" size:11*scaleFontSize];  // new
    self.totalTripsLabel.font = [UIFont fontWithName:@"AvenirNextCondensed-Bold" size:24*scaleFontSize];  // new
    
    // set default start dates:
    _datePickerValue = DMDatePickerValueToday;
    self.displayStartDate = [self todayStartDate];
    self.displayEndDate = [NSDate dateWithTimeInterval:(24*60*60) sinceDate:self.displayStartDate];
    
    // byDataMobile view
    // make radius
    self.byDataMobile.layer.cornerRadius = 10.0;
    self.byDataMobile.clipsToBounds = YES;
    // for Blur effect - dummy UIToolbar - if ios7 above
    UIToolbar *blurToolbar = [[UIToolbar alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    blurToolbar.barStyle = UIBarStyleDefault;
    [self.byDataMobile insertSubview:blurToolbar atIndex:0];
    
    // mapView
    self.mapView.delegate = self;
    self.mapView.showsUserLocation = YES;

    // set dropshadow
    self.topContainerView.layer.masksToBounds = NO;
    self.topContainerView.layer.shadowRadius = 1.6;
    self.topContainerView.layer.shadowOpacity = 0.72;
    self.topContainerView.layer.shadowOffset = CGSizeMake(0,0);
    
    self.locationButton.layer.masksToBounds = NO;
    self.locationButton.layer.shadowRadius = 1.6;
    self.locationButton.layer.shadowOpacity = 0.32;
    self.locationButton.layer.shadowOffset = CGSizeMake(0,0);
    
    self.infoButton.layer.masksToBounds = NO;
    self.infoButton.layer.shadowRadius = 1.6;
    self.infoButton.layer.shadowOpacity = 0.48;
    self.infoButton.layer.shadowOffset = CGSizeMake(0,0);
    
    // make divideLine radius
    self.divideLine1.layer.cornerRadius = 1.0;
    self.divideLine2.layer.cornerRadius = 1.0;
    
    
    // get customSurveyData
    if ([[[CoreDataHelper instance] entityManager] fetchCustomSurveyData]) {
        NSDictionary* dictResults = [[[CoreDataHelper instance] entityManager] fetchCustomSurveyData];
        NSDictionary* dictSurveies = [dictResults objectForKey:@"results"];
        
        // dayDuration of survey
        NSDictionary *dictPrompt = [dictSurveies objectForKey:@"prompt"];
        NSString *strNumDays = [NSString stringWithFormat:@"%@",[dictPrompt objectForKey:@"maxDays"]];
        self.dayDuration = [strNumDays integerValue];
        if (self.dayDuration<=0) {
            self.dayDuration = DM_DAY_DURATION_OF_SURVEY;
        }
        
        // new
        // maxPrompts
        // if custom prompts exist
        // load num_prompts
        // check if custom propmpts exists
        BOOL isNotPromptExist = NO;
        NSArray *arrayPrompts = [dictPrompt objectForKey:@"prompts"];
        if (arrayPrompts.count==0) {
            // if custom ptompts are not created on the dashboard
            isNotPromptExist = YES;
        }else{
            // if custom prompts exist
            // load num_prompts
            NSString *strNumPrompts = [NSString stringWithFormat:@"%@",[dictPrompt objectForKey:@"maxPrompts"]];
            self.modepromptCountMax = [strNumPrompts intValue];
            if (self.modepromptCountMax<=0) {
                isNotPromptExist = YES;
            }
        }
        // show PointRecorded instead of TripsValidated, if prompts doesn't exsit
        if (isNotPromptExist) {
            self.viewTripsValidated.hidden = YES;
            self.viewPointRecorded.hidden = NO;
        }
    
        // for avatar
        // load avatar image
        NSString *strUrl = @"";
        // if custom avatar exists
        if (![[dictSurveies objectForKey:@"avatar"] isEqual:[NSNull null]]&&![[dictSurveies objectForKey:@"avatar"] isEqualToString:@""])
        {
            strUrl = [dictSurveies objectForKey:@"avatar"];
            strUrl = [@"https://dashboard.server.com" stringByAppendingString:strUrl];
            NSURL *url = [NSURL URLWithString:strUrl];
            NSData *data = [NSData dataWithContentsOfURL:url];
            // if data exists, use custom avatar on the server
            if (data) {
                UIImage *image = [UIImage imageWithData:data];
                self.avatar.image = image;
            }
        }
//        else {
//            strUrl = [dictSurveies objectForKey:@"defaultAvatar"];
//        }
        
        // change radius size on iPhone or iPad
        float avatarRadius;
        float viewAvatarRadius;
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            avatarRadius = self.avatar.frame.size.width/2.0*scaleFontSize;
            viewAvatarRadius = self.viewAvatar.frame.size.width/2.0*scaleFontSize;
        } else {
            avatarRadius = self.avatar.frame.size.width;
            viewAvatarRadius = self.viewAvatar.frame.size.width;
        }
        
        // make radius
        self.avatar.clipsToBounds = true;
        self.avatar.layer.cornerRadius = avatarRadius;
        self.viewAvatar.layer.cornerRadius = viewAvatarRadius;
        // set dropshadow
        self.viewAvatar.layer.masksToBounds = NO;
        self.viewAvatar.layer.shadowRadius = 2.4;
        self.viewAvatar.layer.shadowOpacity = 0.4;
        self.viewAvatar.layer.shadowOffset = CGSizeMake(0,0);
        
        // alloc DMSurveyAboutView
        [self allocDMSurveyAboutView];
    } else {
        // if not custom survey
        self.dayDuration = DM_DAY_DURATION_OF_SURVEY;
        self.viewAvatar.hidden = YES;
    }
    
    
    // set DayDuration in UILabel
    self.labelDayDuration.text = [NSLocalizedString(@"of", @"") stringByAppendingString:[NSString localizedStringWithFormat:@" %ld", self.dayDuration]];
    
    // new
    // set MaxModepromptCount in UILabel
    self.labelModepromptMaxCount.text = [NSLocalizedString(@"of", @"") stringByAppendingString:[NSString localizedStringWithFormat:@" %d", self.modepromptCountMax]];
    
    
//    we use didEnterForeground to make sure our date-based views are up to date
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(didBecomeActive)
                                                name:UIApplicationDidBecomeActiveNotification
                                              object:nil];
    
    
//    check to make sure that the survey is ongoing:
    // get survey_start_date
    self.surveyStartDate = [[[CoreDataHelper instance] entityManager] fetchSurveyStartDate];
    NSAssert([self.surveyStartDate isKindOfClass:[NSDate class]], @"surveyStartDate is required, must be a date");
    
    NSTimeInterval surveyDurationSeconds = self.dayDuration * SECONDS_IN_A_DAY;
    if ([[NSDate date]timeIntervalSinceDate:self.surveyStartDate] > surveyDurationSeconds) {
//        the survey is complete. We do not want to start updating the location.
        [self maxDaysCompleted];
        
        // new
        // if DMEfficientLocationManager is not alloced, totalTripsLabelELM will not be displayed.
        // so show totalTripsLabel instead of it
        self.totalTripsLabel.hidden = NO;
        // load UserDefaults
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        modepromptCount = (int)[userDefaults integerForKey:@"MODEPROMPTCOUNT_USER_DEFAULT"];
        self.totalTripsLabel.text = [NSString localizedStringWithFormat:@"%d", modepromptCount];
    }else{
        // if the survey is not completed, ready to start
        // check if we can use notifications, and do so
        [self checkAuthorizationStatus];
        
        // set notfication for alert when the app is not running
//        [NotificationDispatcher startNotificationDispatcher];
        
        // startDMLocationManager in DMEfficientLocationManager
        [self.locationManager startDMLocatinoManager];
        
        // recording
        // show surveyCompleteFadeView - to make mapView blur
        // for Blur effect - dummy UIToolbar - if ios7 above
        UIToolbar *blurToolbar = [[UIToolbar alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        blurToolbar.barStyle = UIBarStyleBlack;
        [self.surveyCompleteFadeView addSubview:blurToolbar];
        self.surveyCompleteFadeView.hidden = NO;
        
        if (isRecordingStopped) {
            self.surveyCompleteFadeView.alpha = 0.64;
            self.labelRecordingStopped.alpha = 1.0;
            self.locationButton.alpha = 0.0;
        }else{
            self.surveyCompleteFadeView.alpha = 0.0;
            self.mapView.showsUserLocation = YES;
            // refresh
            [self refreshViews];
            [self centerOnUserLocation];
            [self performSelector:@selector(refreshViewAgain) withObject:nil afterDelay:2];
        }
    }
}

- (void)maxDaysCompleted
{
//        self.mapView.showsUserLocation = NO;
    self.surveyCompleteLabel.hidden = NO;
    self.locationButton.hidden = YES;
    self.labelRecordingStopped.hidden = YES;
    
    // show surveyCompleteFadeView - to make mapView blur
    // for Blur effect - dummy UIToolbar - if ios7 above
    UIToolbar *blurToolbar = [[UIToolbar alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    blurToolbar.barStyle = UIBarStyleBlack;
    [self.surveyCompleteFadeView addSubview:blurToolbar];
    self.surveyCompleteFadeView.hidden = NO;
    
    isMaxDaysCompleted = YES;
}

// recording
// delegate from DMSettingsView
- (void)recordingStarted
{
    [UIView beginAnimations:nil context:nil];
    //	[UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    [UIView setAnimationDuration:0.4];
    [UIView setAnimationDelay:0.2];
    self.surveyCompleteFadeView.alpha = 0.0;
    self.labelRecordingStopped.alpha = 0.0;
    self.locationButton.alpha = 1.0;
    [UIView commitAnimations];
    
    self.mapView.showsUserLocation = YES;
    // startRecording in DMEfficientLocationManager
    [self.locationManager startRecording];
    
    // refresh
    [self refreshViews];
    [self centerOnUserLocation];
    [self performSelector:@selector(refreshViewAgain) withObject:nil afterDelay:2];
}

- (void)recordingStopped
{
    [UIView beginAnimations:nil context:nil];
    //	[UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    [UIView setAnimationDuration:0.4];
    [UIView setAnimationDelay:0.2];
    self.surveyCompleteFadeView.alpha = 0.64;
    self.labelRecordingStopped.alpha = 1.0;
    self.locationButton.alpha = 0.0;
    [UIView commitAnimations];
    
    [self performSelectorOnMainThread:@selector(turnOffUserLocation) withObject:nil waitUntilDone:NO];
    // stopRecording in DMEfficientLocationManager
    [self.locationManager stopRecording];
}

- (void)closeDMSettingsView
{
    [self closeDMSurveyAboutView];
}

// to turn off userLocation from AlerView, it needs to call it on mainThread
- (void)turnOffUserLocation
{
    self.mapView.showsUserLocation = NO;
}

- (void)checkAuthorizationStatus {
    // location
    CLAuthorizationStatus status = [self.locationManager authorizationStatus];
    NSString *prompt;
    if (status != kCLAuthorizationStatusAuthorizedAlways) {  // for iOS11, it prompts when Allow Location Access is not "Always"
        prompt = NSLocalizedString(@"For Itinerum™ to function properly, please allow it to “Always” access your location in Settings. If it is greyed out, please check “Settings.app > Privacy > Location Services.", @"");
    }
    if (prompt) {
        NSString *title = NSLocalizedString(@"Access to Location Not Authorized", @"");
        
        // if iOS8 or above
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
            // Open Setting
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:prompt preferredStyle:UIAlertControllerStyleAlert];
            [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            }]];
            [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Settings", @"") style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
                // URL Scheme to Setting
                NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                [[UIApplication sharedApplication] openURL:url];
            }]];
            [self presentViewController:alertController animated:YES completion:nil];
            
        }else {
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:title
                                                               message:prompt
                                                              delegate:self
                                                     cancelButtonTitle:NSLocalizedString(@"OK", @"")
                                                     otherButtonTitles:nil];
            [alertView show];
        }
    }
    
    // background app refresh
    if([[UIApplication sharedApplication] backgroundRefreshStatus] != UIBackgroundRefreshStatusAvailable)
    {
        NSString *prompt = NSLocalizedString(@"For Itinerum™ to function, please allow Background App Refresh in Settings. If it is greyed out, please check “Settings.app > General > Background App Refresh.", @"");
        NSString *title = NSLocalizedString(@"Background App Refresh", @"");
        // if iOS8 or above
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
            // Open Setting
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:prompt preferredStyle:UIAlertControllerStyleAlert];
            [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            }]];
            [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Settings", @"") style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
                // URL Scheme to Setting
                NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                [[UIApplication sharedApplication] openURL:url];
            }]];
            [self presentViewController:alertController animated:YES completion:nil];
            
        }else {
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:title
                                                               message:prompt
                                                              delegate:self
                                                     cancelButtonTitle:NSLocalizedString(@"OK", @"")
                                                     otherButtonTitles:nil];
            [alertView show];
        }
    }
}


#pragma mark - UI logic

// refresh - UI, location overlays
- (void)refreshViews {
    
    if ([self.displayEndDate timeIntervalSinceNow] < 0) {
        //                if our end date is in the past we don't want to draw new points
        self.shouldAddNewPoints = NO;
    }else{
        self.shouldAddNewPoints = YES;
    }

    // get all locations on seleced dates
    NSArray* locations = [[CoreDataHelper instance].entityManager
                          fetchLocationsFromDate:self.displayStartDate
                          ToDate:self.displayEndDate];
    
    // remove overlays (init)
    self.overlayRenderer = nil;
    if (self.overlay) {
        [self.mapView removeOverlay:self.overlay];
    }
    NSUInteger points = 0;
    CLLocationDistance distance = 0;
//    NSTimeInterval time = 0.0;  // it can be used as totalTime of the app's running time

    
    // set overlays on selected dates, and get totalPoints info
    if (locations.count) {
        self.overlay = [[DMPathOverlay alloc]initWithLocations:locations];

        CLLocation *previousLocation;
        CLLocation *location;
        NSTimeInterval previousLocationTimestamp = 0.0f;
        
        for (Location *locationRep in locations) {
            // if location's h_accuracy is better than MIN_HORIZONTAL_ACCURACY_DISPLAY,
            // update with the point
            if (locationRep.h_accuracy<=MIN_HORIZONTAL_ACCURACY_DISPLAY) {
                points++;
                location = [[CLLocation alloc]initWithLatitude:locationRep.latitude longitude:locationRep.longitude];
                
                if (previousLocation) {
                    distance += [previousLocation distanceFromLocation:location];
                }
                //            if (!(locationRep.pointType & DMPointLaunchPoint) && previousLocationTimestamp) {
                //                time += locationRep.timestamp - previousLocationTimestamp;
                //            }
                
                previousLocationTimestamp = locationRep.timestamp;
                previousLocation = location;
            }
        }
        
        [self.mapView addOverlay:self.overlay];
        self.lastLocation = location;
        
//        set map rect to encompass all visible points:
        MKMapRect overlayMapRect = [self.overlay computedMapRect];
        [self.mapView setVisibleMapRect:overlayMapRect edgePadding:UIEdgeInsetsMake(5, 5, 5, 5) animated:YES];
    }else{
        // if no locations, center (and zoom) the current user location on Map
        self.needsToCenterOnUserLocation = YES;
    }
    
    
    // set textLabel on topContainer
    // Point Recoded
    self.totalPoints = points;
    self.totalPointsLabel.text = [NSString stringWithFormat:@"%ld", (long)self.totalPoints];
    
    // Days Remaining of survey
    NSTimeInterval timeIntervalSinceSurveyStart = [[NSDate date]timeIntervalSinceDate:self.surveyStartDate];
    NSInteger dayOfSurvey = timeIntervalSinceSurveyStart / SECONDS_IN_A_DAY;
    self.totalDays = MAX(self.dayDuration - dayOfSurvey, 0);
    self.totalDaysLabel.text = [NSString localizedStringWithFormat:@"%ld", (long)self.totalDays];
}

- (MKOverlayRenderer*)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay {

    if (overlay == self.overlay) {
        if (!_overlayRenderer) {
            _overlayRenderer = [[DMPathOverlayRenderer alloc]initWithOverlay:overlay];
        }
        return _overlayRenderer;
    }else if (overlay == self.monitoredRegionOverlay) {
        if (!_monitoredRegionOverlayRenderer) {
            _monitoredRegionOverlayRenderer = [[MKCircleRenderer alloc]initWithCircle:overlay];
            // set color for region overlay, size depends on region radius
            _monitoredRegionOverlayRenderer.fillColor = [UIColor colorWithRed:88.0/255.0 green:82.0/255.0 blue:229.0/255.0 alpha:0.2];
        }
        return _monitoredRegionOverlayRenderer;
    }
    return nil;
}


#pragma mark - user interactions

#define DMInfoSegueIdentifier @"infoSegue"
#define DMDatePickerSegueIdentifer @"datePickerSegue"

- (IBAction)centerOnUserLocation {

    if (self.mapView.showsUserLocation) {
        
        CLLocationCoordinate2D userLocationCoordinate = self.mapView.userLocation.coordinate;
    //    if coordinate is (0,0) wait to center
        if (!userLocationCoordinate.latitude && !userLocationCoordinate.longitude) {
            self.needsToCenterOnUserLocation = YES;
        }else{
            [self centerOnCoordinate:userLocationCoordinate];
        }
        
    }else{
//        if no user location is visible it's probably because we've switched to region tracking, so:
        MKMapRect monitoredArea = self.monitoredRegionOverlay.boundingMapRect;
        [self.mapView setVisibleMapRect:monitoredArea edgePadding:UIEdgeInsetsMake(30, 30, 30, 30) animated:YES];
    }
}

- (void)centerOnCoordinate:(CLLocationCoordinate2D)coordinate {
    MKCoordinateRegion region = { coordinate, { 0.0078, 0.0068 } };
    [self.mapView setRegion:region animated:YES];
}

- (IBAction)infoButtonAction:(id)sender {
    [self performSegueWithIdentifier:DMInfoSegueIdentifier sender:sender];
}

- (IBAction)datePickerAction:(id)sender {
    [self performSegueWithIdentifier:DMDatePickerSegueIdentifer sender:sender];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([[segue identifier] isEqualToString:DMDatePickerSegueIdentifer])
    {
        DMDatePickerViewController *vc = (DMDatePickerViewController*)[segue destinationViewController];
        vc.delegate = self;
    }
    if([segue.identifier isEqualToString:@"settingsSegue"]) {
        DMSettingsViewController *settingsView = segue.destinationViewController;
        settingsView.delegate = self;
    }
}

- (void)allocDMSurveyAboutView
{
//    // fadeBlack
//    self.imgFadeBlack = [[UIImageView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
//    self.imgFadeBlack.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.72];
//    [window.rootViewController.view addSubview:self.imgFadeBlack];
//    self.imgFadeBlack.alpha = 0.0;
    
    // make background blur
    // for Blur effect - dummy UIToolbar
    self.blurToolbarFade = [[UIToolbar alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.blurToolbarFade.barStyle = UIBarStyleBlack;
    [self.view addSubview:self.blurToolbarFade];
    self.blurToolbarFade.alpha = 0.0;
    
    // alloc DMSurveyAboutViewController
    surveyAboutViewController = [[DMSurveyAboutViewController alloc] initWithNibName:@"DMSurveyAboutViewController" bundle:nil];
    surveyAboutViewController.delegate = self;
    surveyAboutViewController.view.frame = [[UIScreen mainScreen] bounds];
    [self.view addSubview:surveyAboutViewController.view];
    surveyAboutViewController.view.frame = CGRectMake(surveyAboutViewController.view.frame.origin.x, surveyAboutViewController.view.frame.size.height, surveyAboutViewController.view.frame.size.width, surveyAboutViewController.view.frame.size.height);
    surveyAboutViewController.view.hidden = YES;
}

- (IBAction)showDMSurveyAboutView
{
    // popUp animation
    [UIView beginAnimations:nil context:nil];
    //	[UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    [UIView setAnimationDuration:0.4];
    [UIView setAnimationDelay:0.16];
    //    self.imgFadeBlack.alpha = 1.0;
    self.blurToolbarFade.alpha = 0.4;
    surveyAboutViewController.view.hidden = NO;
    surveyAboutViewController.view.frame = CGRectMake(surveyAboutViewController.view.frame.origin.x, 0, surveyAboutViewController.view.frame.size.width, surveyAboutViewController.view.frame.size.height);
    [UIView commitAnimations];
}

// delegate from DMSurveyAboutView
- (void)closeDMSurveyAboutView
{
    // popUp animation
    [UIView beginAnimations:nil context:nil];
    //	[UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    [UIView setAnimationDuration:0.4];
    [UIView setAnimationDelay:0.16];
    //    self.imgFadeBlack.alpha = 0.0;
    self.blurToolbarFade.alpha = 0.0;
    surveyAboutViewController.view.frame = CGRectMake(surveyAboutViewController.view.frame.origin.x, surveyAboutViewController.view.frame.size.height, surveyAboutViewController.view.frame.size.width, surveyAboutViewController.view.frame.size.height);
    [UIView commitAnimations];
}

- (void)openDMSettingsView
{
    [self performSegueWithIdentifier:@"settingsSegue" sender:self];
}

- (IBAction)poweredByDataMobile:(id)sender
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://www.itinerum.ca/"]];
}

#pragma mark - display delegate

// delegate from DMLocationManager - when new location is inserted - update viewContents
- (void)locationDataSource:(id)dataSource didAddLocation:(CLLocation *)location pointOptions:(DMPointOptions)pointOptions {
    
    // if location's h_accuracy is better than MIN_HORIZONTAL_ACCURACY_DISPLAY,
    // update with the point
    if (location.horizontalAccuracy<=MIN_HORIZONTAL_ACCURACY_DISPLAY) {
        // center (and zoom) the added location on Map
        if (self.needsToCenterOnUserLocation) {
            self.needsToCenterOnUserLocation = NO;
            [self centerOnCoordinate:location.coordinate];
        }
        
        if (self.shouldAddNewPoints) {
            // set overlays
            if (!self.overlay) {
                self.overlay = [[DMPathOverlay alloc]initWithCoordinate:location.coordinate];
                [self.mapView addOverlay:self.overlay];
            }else{
                [self.overlay addLocation:location.coordinate pointOptions:pointOptions];
            }
            
            //    we only update the rect that has changes; this is from the breadcrumbs sample project
            MKMapRect updateRect = [self.overlay mapRectToUpdate];
            if (!MKMapRectIsNull(updateRect))
            {
                // There is a non null update rect.
                // Compute the currently visible map zoom scale
                MKZoomScale currentZoomScale = (CGFloat)(self.mapView.bounds.size.width / self.mapView.visibleMapRect.size.width);
                // Find out the line width at this zoom scale and outset the updateRect by that amount
                CGFloat lineWidth = MKRoadWidthAtZoomScale(currentZoomScale);
                updateRect = MKMapRectInset(updateRect, -lineWidth, -lineWidth);
                // Ask the overlay view to update just the changed area.
                [self.overlayRenderer setNeedsDisplayInMapRect:updateRect];
            }
            
            // set textLabel on topContainer
            self.totalPoints += 1;
            self.totalPointsLabel.text = [NSString stringWithFormat:@"%ld", (long)self.totalPoints];
            self.lastLocation = location;
        }
    }
}

// delegate from DMLocationManager - when it is switched(created) to region geofence - update viewContents
- (void)locationDataSource:(id)dataSource didStartMonitoringRegionWithCenter:(CLLocationCoordinate2D)center radius:(CLLocationDistance)radius {
    if (self.monitoredRegionOverlay) {
        [self.mapView removeOverlay:self.monitoredRegionOverlay];
        self.monitoredRegionOverlay = nil;
        self.monitoredRegionOverlayRenderer = nil;
    }
    // set new regionOverlay
    self.monitoredRegionOverlay = [MKCircle circleWithCenterCoordinate:center
                                                                radius:radius];
    [self.mapView addOverlay:self.monitoredRegionOverlay];
    self.mapView.showsUserLocation = NO;
}

// delegate from DMLocationManager - when it is switched to gps(region is removed) - update viewContents
- (void)locationDataSourceStoppedMonitoringRegion {
    [self.mapView removeOverlay:self.monitoredRegionOverlay];
    self.monitoredRegionOverlay = nil;
    self.monitoredRegionOverlayRenderer = nil;
    self.mapView.showsUserLocation = YES;
}


#pragma mark - picker delegate

- (void)dateRangeDidChangeToStart:(NSDate *)startDate Stop:(NSDate *)stopDate {
    //    TODO: unstub me
    NSLog(@"stub");
}

- (DMDatePickerValue)datePickerValue {
    return _datePickerValue;
}

- (NSDate*)startDate {
    return [self.displayStartDate copy];
}

- (NSDate*)endDate {
    return [self.displayEndDate copy];
}

- (void)datePicker:(DMDatePickerViewController *)datePicker didPickValue:(DMDatePickerValue)datePickerValue {
    if (datePickerValue != _datePickerValue || datePickerValue == DMDatePickerValueCustom) {
        _datePickerValue = datePickerValue;
        
        self.displayStartDate = [datePicker.startDate copy];
        self.displayEndDate = [datePicker.endDate copy];
        
        NSString *buttonLabelText;
        switch (datePickerValue) {
            case DMDatePickerValueToday:
                buttonLabelText = NSLocalizedString(@"Today", @"");
                break;
            case DMDatePickerValueYesterday:
                buttonLabelText = NSLocalizedString(@"Yesterday", @"");
                break;
            case DMDatePickerValueLastSevenDays:
                buttonLabelText = NSLocalizedString(@"Last Seven Days", @"");
                break;
            case DMDatePickerValueAll:
                buttonLabelText = NSLocalizedString(@"All Days", @"");
                break;
            case DMDatePickerValueCustom:
                buttonLabelText = [self displayStringForDateRange:self.displayStartDate End:self.displayEndDate];
                break;
            default:
                abort(); // crash if we add a new case and forget to implement this
                break;
        }
        
        [self.dateButton setTitle:buttonLabelText forState:UIControlStateNormal];
        [self refreshViews];
    }
}


#pragma mark - notifications

- (void)didBecomeActive {
    // check if we can use notifications, and do so
    [self checkAuthorizationStatus];
    
//    check to see if our display values are still valid:
    DDLogInfo(@"didEnterForeground called");
    if (self.datePickerValue == DMDatePickerValueToday) {
        if (![self.displayStartDate isEqualToDate:[self todayStartDate]]) {
            self.displayStartDate = [self todayStartDate];
            self.displayEndDate = [self.displayStartDate dateByAddingTimeInterval:SECONDS_IN_A_DAY];
            [self refreshViews];
        }
    }
    
    // refresh view to show paths correctly when app is relaunched
    if (!self.surveyCompleteLabel.hidden) {
        [self refreshViews];
        [self centerOnUserLocation];
        [self performSelector:@selector(refreshViewAgain) withObject:nil afterDelay:2];
        
        // check if maxDaysCompleted
        NSTimeInterval surveyDurationSeconds = self.dayDuration * SECONDS_IN_A_DAY;
        if ([[NSDate date]timeIntervalSinceDate:self.surveyStartDate] > surveyDurationSeconds) {
            // if maxDaysCompleted, terminate survey
            [self maxDaysCompleted];
            
            [self performSelectorOnMainThread:@selector(turnOffUserLocation) withObject:nil waitUntilDone:NO];
            // stopRecording in DMEfficientLocationManager
            [self.locationManager stopRecording];
        }
    }
}

- (void)refreshViewAgain
{
    [self refreshViews];
    [self centerOnUserLocation];
}


#pragma mark - helpers

- (NSString*)displayStringForDateRange:(NSDate*)start End:(NSDate*)end {
    static NSDateFormatter *formatter;
    if (!formatter) {
        formatter = [[NSDateFormatter alloc]init];
        [formatter setDateFormat:@"MMM d"];
    }
    
    NSString *startString = [formatter stringFromDate:start];
    NSString *endString = [formatter stringFromDate:end];
    return [NSString stringWithFormat:@"%@ - %@", startString, endString];
}

//today currently starts at 12am. This could be a user setting?
- (NSDate*)todayStartDate
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:(NSCalendarUnitYear | NSCalendarUnitDay | NSCalendarUnitMonth)
                                               fromDate:[NSDate date]];
    components.hour = 0;
    components.minute = 0;
    components.second = 0;
    
    return [calendar dateFromComponents:components];
}

- (NSDate*)_debugStartDate {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:(NSCalendarUnitYear | NSCalendarUnitDay | NSCalendarUnitMonth)
                                               fromDate:[NSDate date]];
    components.month = 6;
    components.day = 1;
    components.hour = 4;
    components.minute = 0;
    components.second = 0;
    
    return [calendar dateFromComponents:components];
}


#pragma mark - debug

- (IBAction)debugSendLogsAction:(UIButton *)sender {
    
    MFMailComposeViewController *mailComposer = [[MFMailComposeViewController alloc] init];
    [mailComposer setSubject:@"DataMobile Log Data"];
    [mailComposer setToRecipients:@[@"colin.rothfels@gmail.com"]];
    
    NSString* logDirectoryPath = [self logDirectoryPath];
    NSArray *logFilePaths = [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:logDirectoryPath error:nil];;
    [logFilePaths enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *filename = (NSString*)obj;
        NSString *path = [logDirectoryPath stringByAppendingPathComponent:filename];
        NSData *logData = [NSData dataWithContentsOfFile:path];
        [mailComposer addAttachmentData:logData mimeType:@"text/plain" fileName:filename];
        DDLogInfo(@"attached file %@, size: %@", filename, [NSByteCountFormatter stringFromByteCount:logData.length countStyle:NSByteCountFormatterCountStyleFile]);
    }];
    
    mailComposer.mailComposeDelegate = self;
    [self presentViewController:mailComposer animated:YES completion:NULL];
}

- (NSString*)logDirectoryPath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *baseDir = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    NSString *logsDirectory = [baseDir stringByAppendingPathComponent:@"Logs"];
    return logsDirectory;
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
//    DDLogInfo(@"mail composer finished with result: %lu, error: %@", result, error.localizedDescription);
    [self dismissViewControllerAnimated:YES completion:NULL];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

@end
