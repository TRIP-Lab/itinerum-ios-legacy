//
//  LoginViewController.h
//  DataMobile
//
//  Created by Takeshi MUKAI on 7/27/16.
//  Copyright (c) 2016 MML-Concordia. All rights reserved.
//

#import <UIKit/UIKit.h>

// delegate to DMSplashScreenViewController
@protocol LoginViewDelegate
- (void)closeLoginView;
@end

@interface LoginViewController : UIViewController <UITextFieldDelegate>

@property (nonatomic, retain) id delegate;

@end
