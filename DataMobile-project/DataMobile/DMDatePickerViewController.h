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
//  DMDatePickerViewController.h
//  DataMobile
//
//  Created by Colin Rofls on 2014-07-16.
//  Copyright (c) 2014 MML-Concordia. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DMDatePickerViewController;

typedef NS_ENUM(NSInteger, DMDatePickerValue) {
    DMDatePickerValueToday = 0,
    DMDatePickerValueYesterday,
    DMDatePickerValueLastSevenDays,
    DMDatePickerValueAll,
    DMDatePickerValueCustom = 1000
};

#define SECONDS_IN_A_DAY (24 * 60 * 60)

@protocol DMDatePickerDelegate <NSObject>
-(void)datePicker:(DMDatePickerViewController*)datePicker didPickValue:(DMDatePickerValue)datePickerValue;
@property (nonatomic, readonly) DMDatePickerValue datePickerValue;
@property (nonatomic, readonly) NSDate *startDate;
@property (nonatomic, readonly) NSDate *endDate;
@end



@interface DMDatePickerViewController : UITableViewController
@property (nonatomic) id<DMDatePickerDelegate> delegate;
@property (strong, nonatomic, readonly) NSDate* startDate;
@property (strong, nonatomic, readonly) NSDate* endDate;


@end
