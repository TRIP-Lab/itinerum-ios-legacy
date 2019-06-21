//
//  DMCSNumberViewController.h
//  DataMobile
//
//  Created by Takeshi MUKAI on 11/17/16.
//  Copyright (c) 2016 MML-Concordia. All rights reserved.
//

#import <UIKit/UIKit.h>

// delegate to DMCustomSurveyRootViewController
@protocol DMCSNumberViewDelegate
- (void)numberEntered:(NSArray*)arrayAnswer;
@end

@interface DMCSNumberViewController : UITableViewController

@property (nonatomic, retain) id delegate;
@property (nonatomic, retain) NSDictionary *dictSurvey;
@property (nonatomic, retain) NSArray *arrayAnswer;

@end
