//
//  DMSettingsViewController.h
//  Itinerum
//
//  Created by Takeshi MUKAI on 8/20/17.
//  Copyright (c) 2017 MML-Concordia. All rights reserved.
//

#import <UIKit/UIKit.h>

// delegate to DMMainView
@protocol DMSettingsViewDelegate
- (void)recordingStarted;
- (void)recordingStopped;
- (void)closeDMSettingsView;
@end

@interface DMSettingsViewController : UITableViewController

@property (nonatomic, retain) id delegate;

@end
