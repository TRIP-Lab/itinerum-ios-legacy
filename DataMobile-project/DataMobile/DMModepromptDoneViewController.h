//
//  DMModepromptDoneViewController.h
//  DataMobile
//
//  Created by Takeshi MUKAI on 7/27/16.
//  Copyright (c) 2016 MML-Concordia. All rights reserved.
//

#import <UIKit/UIKit.h>

// delegate to DMModepromptManager
@protocol DMModepromptDoneViewDelegate
- (void)closeDMModepromptDoneView;
@end

@interface DMModepromptDoneViewController : UIViewController

@property (nonatomic, retain) id delegate;

@end
