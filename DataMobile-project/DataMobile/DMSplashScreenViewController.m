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
//  DMSplashScreenViewController.m
//  DataMobile
//
//  Created by Colin Rofls on 2014-07-27.
//  Copyright (c) 2014 MML-Concordia. All rights reserved.
//
// Modified by MUKAI Takeshi in 2015-10

#import "DMSplashScreenViewController.h"
#import "DMUserSurveyViewController.h"
#import "ScaleFontSize.h"
// for custom survey
#import "CoreDataHelper.h"
#import "EntityManager.h"


@interface DMSplashScreenViewController ()

@property (strong, nonatomic) IBOutlet UILabel* label1;
@property (strong, nonatomic) IBOutlet UILabel* label2;
@property (strong, nonatomic) IBOutlet UIButton* btnStart;

// for custom survey
@property (nonatomic, retain) LoginViewController *loginViewController;
@property (nonatomic, retain) UIToolbar *blurToolbar;
@property (nonatomic, retain) UIImageView *imgFadeBlack;
@property (nonatomic) BOOL isLoginViewShown;
@property (nonatomic, retain) DMSurveyAboutViewController *surveyAboutViewController;

@end

@implementation DMSplashScreenViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // scaleFontSizeByScreenWidth
    CGFloat scaleFontSize = [ScaleFontSize scaleFontSizeByScreenWidth];
    self.label1.font = [UIFont fontWithName:@"AvenirNext-DemiBold" size:17*scaleFontSize];
    self.label2.font = [UIFont fontWithName:@"AvenirNext-DemiBold" size:15*scaleFontSize];
    // change btn's font size only on iPhone
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        self.btnStart.titleLabel.font = [UIFont fontWithName:@"AvenirNextCondensed-DemiBold" size:20*scaleFontSize];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

- (IBAction)yesAction:(id)sender {
    // move to DMUserSurveyViewController
//    [self performSegueWithIdentifier:DM_USER_SURVEY_SEGUE sender:self];
    
    // for custom survey
    // alloc loginView
    if (!self.isLoginViewShown) {
        [self allocLoginView];
        self.isLoginViewShown = YES;
    }
}


// for custom survey
- (void)switchToSurveyView;
{
    // if customSurvey exists, go to custom survey
    if ([[[CoreDataHelper instance] entityManager] fetchCustomSurveyData]) {
        // move to DMCustomSurveyViewController
        [self performSegueWithIdentifier:@"customSurveySegue" sender:self];
    }else{
        // move to DMUserSurveyViewController
        [self performSegueWithIdentifier:DM_USER_SURVEY_SEGUE sender:self];
    }
}

- (void)allocLoginView
{
    // fadeBlack
//    self.imgFadeBlack = [[UIImageView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
//    self.imgFadeBlack.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.72];
//    [self.view addSubview:self.imgFadeBlack];
//    self.imgFadeBlack.alpha = 0.0;
    
    // make background blur
    // for Blur effect - dummy UIToolbar
    self.blurToolbar = [[UIToolbar alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.blurToolbar.barStyle = UIBarStyleBlack;
    [self.view addSubview:self.blurToolbar];
    self.blurToolbar.alpha = 0.0;
    
    // alloc loginViewController
    self.loginViewController = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
    self.loginViewController.delegate = self;
    self.loginViewController.view.frame = [[UIScreen mainScreen] bounds];
    [self.view addSubview:self.loginViewController.view];
    self.loginViewController.view.frame = CGRectMake(self.loginViewController.view.frame.origin.x, self.loginViewController.view.frame.size.height, self.loginViewController.view.frame.size.width, self.loginViewController.view.frame.size.height);
    
    // popUp animation
    [UIView beginAnimations:nil context:nil];
    //	[UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    [UIView setAnimationDuration:0.4];
    [UIView setAnimationDelay:0.2];
//    self.imgFadeBlack.alpha = 1.0;
    self.blurToolbar.alpha = 0.48;
    self.loginViewController.view.frame = CGRectMake(self.loginViewController.view.frame.origin.x, 0, self.loginViewController.view.frame.size.width, self.loginViewController.view.frame.size.height);
    [UIView commitAnimations];
}

// delegate from LoginView
- (void)closeLoginView;
{
    // if user's terms_of_service exists, alloc DMSurveyAboutView
    NSDictionary* dictResults = [[[CoreDataHelper instance] entityManager] fetchCustomSurveyData];
    NSDictionary* dictSurveies = [dictResults objectForKey:@"results"];
    if ((![[dictSurveies objectForKey:@"termsOfService"] isEqual:[NSNull null]]&&![[dictSurveies objectForKey:@"termsOfService"] isEqualToString:@""])) {
        
        // popUp animation - hide
        [UIView beginAnimations:nil context:nil];
        //	[UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
        [UIView setAnimationDuration:0.4];
        [UIView setAnimationDelay:0.2];
        self.loginViewController.view.frame = CGRectMake(self.loginViewController.view.frame.origin.x, self.loginViewController.view.frame.size.height, self.loginViewController.view.frame.size.width, self.loginViewController.view.frame.size.height);
        [UIView commitAnimations];
        
        [self allocDMSurveyAboutView];
    }else{
        
        // popUp animation - hide
        [UIView beginAnimations:nil context:nil];
        //	[UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
        [UIView setAnimationDuration:0.4];
        [UIView setAnimationDelay:0.2];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(removeLoginView)];
        self.blurToolbar.alpha = 0.0;
        self.loginViewController.view.frame = CGRectMake(self.loginViewController.view.frame.origin.x, self.loginViewController.view.frame.size.height, self.loginViewController.view.frame.size.width, self.loginViewController.view.frame.size.height);
        [UIView commitAnimations];
        
        // if not, go to survey
        [self switchToSurveyView];
        
    }
}

- (void)removeLoginView
{
    [self.loginViewController.view removeFromSuperview];
    [self.blurToolbar removeFromSuperview];
//    [self.imgFadeBlack removeFromSuperview];
}

// show terms_of_service if user's terms_of_service exists
- (void)allocDMSurveyAboutView
{
//    // make background blur
//    // for Blur effect - dummy UIToolbar
//    self.blurToolbarFade = [[UIToolbar alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
//    self.blurToolbarFade.barStyle = UIBarStyleBlack;
//    [self.view addSubview:self.blurToolbarFade];
//    self.blurToolbarFade.alpha = 0.0;
    
    // alloc DMSurveyAboutViewController
    self.surveyAboutViewController = [[DMSurveyAboutViewController alloc] initWithNibName:@"DMSurveyAboutViewController" bundle:nil];
    self.surveyAboutViewController.delegate = self;
    self.surveyAboutViewController.isLogin = YES;
    self.surveyAboutViewController.view.frame = [[UIScreen mainScreen] bounds];
    [self.view addSubview:self.surveyAboutViewController.view];
    self.surveyAboutViewController.view.frame = CGRectMake(self.surveyAboutViewController.view.frame.origin.x, self.surveyAboutViewController.view.frame.size.height, self.surveyAboutViewController.view.frame.size.width, self.surveyAboutViewController.view.frame.size.height);
    self.surveyAboutViewController.view.hidden = YES;
    
    // popUp animation
    [UIView beginAnimations:nil context:nil];
    //	[UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    [UIView setAnimationDuration:0.4];
    [UIView setAnimationDelay:0.2];
//    self.imgFadeBlack.alpha = 1.0;
//    self.blurToolbarFade.alpha = 0.4;
    self.surveyAboutViewController.view.hidden = NO;
    self.surveyAboutViewController.view.frame = CGRectMake(self.surveyAboutViewController.view.frame.origin.x, 0, self.surveyAboutViewController.view.frame.size.width, self.surveyAboutViewController.view.frame.size.height);
    [UIView commitAnimations];
}

// delegate from DMSurveyAboutView
- (void)closeDMSurveyAboutView
{
    // popUp animation
    [UIView beginAnimations:nil context:nil];
    //	[UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    [UIView setAnimationDuration:0.4];
    [UIView setAnimationDelay:0.2];
    [UIView setAnimationDidStopSelector:@selector(removeDMSurveyAboutView)];
    //    self.imgFadeBlack.alpha = 0.0;
    self.blurToolbar.alpha = 0.0;
    self.surveyAboutViewController.view.frame = CGRectMake(self.surveyAboutViewController.view.frame.origin.x, self.surveyAboutViewController.view.frame.size.height, self.surveyAboutViewController.view.frame.size.width, self.surveyAboutViewController.view.frame.size.height);
    [UIView commitAnimations];
    
    [self switchToSurveyView];
}

- (void)openDMSettingsView
{
}

- (void)removeDMSurveyAboutView
{
    [self.loginViewController.view removeFromSuperview];
    [self.surveyAboutViewController.view removeFromSuperview];
    [self.blurToolbar removeFromSuperview];
    //    [self.imgFadeBlack removeFromSuperview];
}


/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
