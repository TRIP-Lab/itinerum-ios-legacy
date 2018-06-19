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
//  AlertViewManager.m
//  GPSRecorder
//
//  Created by Kim Sawchuk on 11-11-24.
//  Copyright (c) 2011 MML-Concordia. All rights reserved.
//

#import "AlertViewManager.h"

@interface AlertViewManager ()


- (UIAlertView*)createOkCancelAlert:(NSString*)title withMessage:(NSString*)message setTag:(alertViewTag)tag;

@end

@implementation AlertViewManager

@synthesize observer;

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    switch ([alertView tag]) 
    { 
        case RECORD_STOPPED_CONFIRM:
        {
            if([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"OK"])
            {
                [self.observer stopRecordingConfirmed];
            }
        }
            
        default:
            break;
    }
}

- (UIAlertView*)createSuccessfullStartAlert
{
    return [self createOkAlert:@"Recording started" 
                   withMessage:@"You can put the recorder in background now, please dont reboot your iphone, as you would need to start this application again."
                        setTag:RECORD_STARTED];
}

- (UIAlertView*)createSuccessfullStopAlert
{
    return [self createOkAlert:@"Recording Stopped" 
                   withMessage:@"If you data has recorded data, we would grateful if you send them to us." 
                        setTag:RECORD_STOPPED];
}

- (UIAlertView*)createSuccessfullSentAlert
{
    return [self createOkAlert:@"Data successfully Sent" 
                   withMessage:@"Thank you for participating"
                        setTag:DATA_SENT];
}

- (UIAlertView*)createConfirmStopAlert
{
    return [self createOkCancelAlert:@"Are you sure ?" 
                         withMessage:@"The application will stop recording your movements" 
                              setTag:RECORD_STOPPED_CONFIRM];
}

- (UIAlertView*)createErrorAlertWithMessage:(NSString*)message
{
    return [self createOkAlert:@"Error Occured" 
                   withMessage:message
                        setTag:ERROR_OCCURED];
}

- (UIAlertView*)createOkCancelAlert:(NSString*)title 
                        withMessage:(NSString*)message
                             setTag:(alertViewTag)tag
{
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:title
                                                        message:message
                                                       delegate:self
                                              cancelButtonTitle:@"OK" 
                                              otherButtonTitles:@"Cancel", nil];
    
    [alertView setTag:tag];
    [alertView setAccessibilityLabel:title];    
    return alertView;
}

- (UIAlertView*)createOkAlert:(NSString*)title withMessage:(NSString*)message setTag:(alertViewTag)tag
{
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:title
                                                        message:message
                                                       delegate:self
                                              cancelButtonTitle:@"OK" 
                                              otherButtonTitles:nil];
    [alertView setTag:tag];
    [alertView setAccessibilityLabel:title];
    return alertView;
}

@end
