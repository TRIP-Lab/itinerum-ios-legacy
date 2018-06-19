//
//  DMCSTableViewController.h
//  DataMobile
//
//  Created by Takeshi MUKAI on 8/22/16.
//  Copyright (c) 2016 MML-Concordia. All rights reserved.
//

#import <UIKit/UIKit.h>

// delegate to DMCustomSurveyRootViewController
@protocol DMCSTableViewDelegate
- (void)cellSelected:(NSArray*)arrayAnswer;
- (void)memberTypeSelected:(NSInteger)indexRow;
@end

@interface DMCSTableViewController : UITableViewController

@property (nonatomic, retain) id delegate;
@property (nonatomic, retain) NSDictionary *dictSurvey;
@property (nonatomic, retain) NSArray *arrayAnswer;
@property (nonatomic, retain) NSString *strFieldsType;
@property (nonatomic, retain) NSDictionary *dictMandatoryQuestions;

@end
