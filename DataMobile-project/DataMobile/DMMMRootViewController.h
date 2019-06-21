//
//  DMMMRootViewController.h
//  Itinerum
//
//  Created by Takeshi MUKAI on 5/24/17.
//  Copyright (c) 2017 MML-Concordia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DMMMTableViewController.h"

// delegate to DMModepromptManager
@protocol DMMMRootViewDelegate
- (void)submitDMMMRootView:(NSDictionary*)dictPromptAnswer;
- (void)closeDMMMRootView;
@end

@interface DMMMRootViewController : UIViewController <DMMMTableViewDelegate>

@property (nonatomic, retain) id delegate;
@property (nonatomic, retain) DMMMTableViewController *mmTableViewController;
@property (nonatomic, retain) NSArray *arrayPrompts;

// delegate from DMMMTableView
- (void)cellSelected:(NSArray*)arrayAnswer;

@end
