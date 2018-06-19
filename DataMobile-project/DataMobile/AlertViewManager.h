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
//  AlertViewManager.h
//  GPSRecorder
//
//  Created by Kim Sawchuk on 11-11-24.
//  Copyright (c) 2011 MML-Concordia. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "AlertObserver.h"

/**
 * Helper that wraps the functionnalities of an alert View.
 */
@interface AlertViewManager : NSObject <UIAlertViewDelegate> 

// for tagging alertviews
typedef enum
{
    ERROR_OCCURED = 3,
    RECORD_STARTED = 4,
    RECORD_STOPPED = 5,
    RECORD_STOPPED_CONFIRM = 6,
    DATA_SENT = 7
} alertViewTag;

@property (weak, nonatomic) id<AlertObserver> observer;

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;

- (UIAlertView*)createSuccessfullStartAlert;
- (UIAlertView*)createSuccessfullStopAlert;
- (UIAlertView*)createSuccessfullSentAlert;
- (UIAlertView*)createConfirmStopAlert;
- (UIAlertView*)createErrorAlertWithMessage:(NSString*)message;

- (UIAlertView*)createOkAlert:(NSString*)title withMessage:(NSString*)message setTag:(alertViewTag)tag;

@end
