//
//  DMCSLocationViewController.h
//  DataMobile
//
//  Created by Takeshi MUKAI on 8/22/16.
//  Copyright (c) 2016 MML-Concordia. All rights reserved.
//

#import <UIKit/UIKit.h>

// delegate to DMCustomSurveyRootViewController
@protocol DMCSLocationViewDelegate
- (void)locationEntered:(NSArray*)arrayAnswer;
@end

@interface DMCSLocationViewController : UIViewController

@property (nonatomic, retain) id delegate;
@property (nonatomic, retain) NSDictionary *dictSurvey;
@property (nonatomic, retain) NSArray *arrayAnswer;
@property (nonatomic, retain) NSDictionary *dictMandatoryQuestions;
@property (nonatomic, retain) NSString *strLang;

@end
