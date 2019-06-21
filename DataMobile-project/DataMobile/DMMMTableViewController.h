//
//  DMMMTableViewController.h
//  Itinerum
//
//  Created by Takeshi MUKAI on 5/23/17.
//  Copyright (c) 2017 MML-Concordia. All rights reserved.
//

#import <UIKit/UIKit.h>

// delegate to DMMMRootViewController
@protocol DMMMTableViewDelegate
- (void)cellSelected:(NSArray*)arrayAnswer;
@end

@interface DMMMTableViewController : UITableViewController

@property (nonatomic, retain) id delegate;
@property (nonatomic, retain) NSArray *arrayChoices;
@property (nonatomic) BOOL isMultipleChoices;
@property (nonatomic, retain) NSMutableArray *arrayAnswer;

- (void)refreshView;

@end
