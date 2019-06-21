/*///////////////////////////////////////////////////////////////////
 GNU PUBLIC LICENSE - The copying permission statement
 --------------------------------------------------------------------
 This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.
 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 You should have received a copy of the GNU General Public License
 along with this program.  If not, see <http://www.gnu.org/licenses/>.
 ///////////////////////////////////////////////////////////////////*/

//
//  DMDebugLogViewController.m
//  DataMobile
//
//  Created by Takeshi MUKAI on 2/19/16.
//  Copyright (c) 2016 MML-Concordia. All rights reserved.
//

#import "DMDebugLogViewController.h"
#import "DMAppDelegate.h"

@interface DMDebugLogViewController ()

@end

@implementation DMDebugLogViewController
@synthesize viewAccuracy, labelAccuracy, indicatorUpdated, indicatorRecorded, btnDebugLog;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    if (isDebugLogEnabled||isDebugLogLiteEnabled) {
        btnDebugLog.alpha = 1.0;
        viewAccuracy.alpha = 1.0;
    }else{
        btnDebugLog.alpha = 0.4;
        viewAccuracy.alpha = 0.0;
    }
}

- (void)showUpdated:(CLLocation *)location
{
    labelAccuracy.text = [NSString stringWithFormat:@"%.2f", location.horizontalAccuracy];
    
    // show indicatorUpdated
    indicatorUpdated.alpha = 1.0;
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:1.0];
    [UIView setAnimationDelay:1.0];
    indicatorUpdated.alpha = 0.0;
    [UIView commitAnimations];
}

- (void)showRecorded:(CLLocation *)location
{
    labelAccuracy.text = [NSString stringWithFormat:@"%.2f", location.horizontalAccuracy];
    
    // show indicatorUpdated
    indicatorRecorded.alpha = 1.0;
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:1.0];
    [UIView setAnimationDelay:1.0];
    indicatorRecorded.alpha = 0.0;
    [UIView commitAnimations];
}

- (void)notifyDebugLog:(NSString *)text region:(CLRegion *)region location:(CLLocation *)location
{
    // set localNotification
    NSString *textBody = text;
    if (region) {
        textBody = [textBody stringByAppendingString:region.identifier];
    }
    if (location) {
        textBody = [textBody stringByAppendingString:[NSString stringWithFormat:@": %.1f", location.horizontalAccuracy]];
    }
    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
    localNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:0];
    localNotification.timeZone = [NSTimeZone defaultTimeZone];
    localNotification.soundName = UILocalNotificationDefaultSoundName;
    localNotification.alertBody = textBody;
    localNotification.alertAction = @"OK";
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
}

- (IBAction)btnDebugLogTapped
{
    isDebugLogEnabled = !isDebugLogEnabled;
    if (isDebugLogEnabled) {
        btnDebugLog.alpha = 1.0;
        viewAccuracy.alpha = 1.0;
    }else{
        btnDebugLog.alpha = 0.4;
        viewAccuracy.alpha = 0.0;
    }
    
//    isDebugLogLiteEnabled = !isDebugLogLiteEnabled;
//    if (isDebugLogLiteEnabled) {
//        btnDebugLog.alpha = 1.0;
//        viewAccuracy.alpha = 1.0;
//    }else{
//        btnDebugLog.alpha = 0.4;
//        viewAccuracy.alpha = 0.0;
//    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
