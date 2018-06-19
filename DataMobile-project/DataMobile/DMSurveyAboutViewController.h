//
//  DMSurveyAboutViewController.h
//  DataMobile
//
//  Created by Takeshi MUKAI on 1/16/17.
//  Copyright (c) 2017 MML-Concordia. All rights reserved.
//

#import <UIKit/UIKit.h>

// delegate to DMMainView, DMSplashScreenView
@protocol DMSurveyAboutViewDelegate
- (void)closeDMSurveyAboutView;
- (void)openDMSettingsView;
@end

@interface DMSurveyAboutViewController : UIViewController <UIScrollViewDelegate>

@property (nonatomic, retain) id delegate;
@property (nonatomic) BOOL isLogin;

@end
