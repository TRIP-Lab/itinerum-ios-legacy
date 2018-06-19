//
//  DMCustomSurveyRootViewController.h
//  DataMobile
//
//  Created by Takeshi MUKAI on 8/22/16.
//  Copyright (c) 2016 MML-Concordia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DMCSTableViewController.h"
#import "DMCSLocationViewController.h"
#import "DMCSEmailViewController.h"
#import "DMCSNumberViewController.h"
#import "DMCSTextViewController.h"

@interface DMCustomSurveyRootViewController : UIViewController <DMCSTableViewDelegate, DMCSLocationViewDelegate, DMCSEmailViewDelegate, DMCSNumberViewDelegate, DMCSTextViewDelegate>

@property (nonatomic, retain) DMCSTableViewController *csTableViewController;
@property (nonatomic, retain) DMCSLocationViewController *csLocationViewController;
@property (nonatomic, retain) DMCSEmailViewController *csEmailViewController;
@property (nonatomic, retain) DMCSNumberViewController *csNumberViewController;
@property (nonatomic, retain) DMCSTextViewController *csTextViewController;

// delegate from DMCSTableView
- (void)cellSelected:(NSArray*)arrayAnswer;
- (void)memberTypeSelected:(NSInteger)indexRow;
// delegate from DMCSLocationView
- (void)locationEntered:(NSArray*)arrayAnswer;
// delegate from DMCSEmailView
- (void)emailEntered:(NSArray*)arrayAnswer;
// delegate from DMCSNumberView
- (void)numberEntered:(NSArray*)arrayAnswer;
// delegate from DMCSTextView
- (void)textEntered:(NSArray*)arrayAnswer;

@end
