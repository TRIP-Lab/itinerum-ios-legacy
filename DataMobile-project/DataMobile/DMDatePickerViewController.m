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
//  DMDatePickerViewController.m
//  DataMobile
//
//  Created by Colin Rofls on 2014-07-16.
//  Copyright (c) 2014 MML-Concordia. All rights reserved.
//
// Modified by MUKAI Takeshi in 2015-10

#import "DMDatePickerViewController.h"
#import "User.h"
#import "CoreDataHelper.h"
#import "EntityManager.h"

@interface DMDatePickerViewController ()
@property (strong, nonatomic, readwrite) NSDate* startDate;
@property (strong, nonatomic, readwrite) NSDate* endDate;
@property (strong, nonatomic) NSIndexPath* selectedIndexPath;

@property (weak, nonatomic) IBOutlet UITableViewCell *customRangeStartCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *customRangeEndCell;

@property (weak, nonatomic) IBOutlet UILabel *startDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *endDateLabel;
@property (strong, nonatomic) UIDatePicker* datePicker;

@property (nonatomic) BOOL userHasPickedCustomDate;

@end

@implementation DMDatePickerViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

#define SYSTEM_DEFAULT_CELL_HEIGHT 44.0

- (UIDatePicker*)datePicker {
    if (!_datePicker) {
        _datePicker = [[UIDatePicker alloc]init];
        _datePicker.frame = CGRectOffset(self.datePicker.frame, 0, SYSTEM_DEFAULT_CELL_HEIGHT);
        _datePicker.frame = CGRectMake(self.datePicker.frame.origin.x, self.datePicker.frame.origin.y, self.customRangeStartCell.frame.size.width, self.datePicker.frame.size.height);  // to diaplay center on iPad correctly
        [_datePicker addTarget:self action:@selector(userChangedCustomDateValue:) forControlEvents:UIControlEventValueChanged];
    }
    return _datePicker;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSAssert(self.delegate, @"datepicker must have a delegate set");
    self.startDate = self.delegate.startDate;
    self.endDate = self.delegate.endDate;
    self.userHasPickedCustomDate = NO;
    self.selectedIndexPath = [NSIndexPath indexPathForRow:self.delegate.datePickerValue inSection:0];
}

- (void)setSelectedIndexPath:(NSIndexPath *)selectedIndexPath {
    if (selectedIndexPath != _selectedIndexPath) {
//        deselect
        if (_selectedIndexPath && _selectedIndexPath.section == 0) {
            UITableViewCell *oldCell = [self.tableView cellForRowAtIndexPath:_selectedIndexPath];
            oldCell.accessoryType = UITableViewCellAccessoryNone;
        }
        if (selectedIndexPath.section == 0) {
            UITableViewCell *newCell = [self.tableView cellForRowAtIndexPath:selectedIndexPath];
            newCell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
         _selectedIndexPath = selectedIndexPath;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// use backBtn insted of table cell
- (IBAction)btnTouched:(id)sender
{
    if (self.userHasPickedCustomDate) {
        [self.delegate datePicker:self didPickValue:DMDatePickerValueCustom];
    }
    [self.presentingViewController dismissViewControllerAnimated:YES completion:NULL];
}


#pragma mark - tableView Delegate

#define CUSTOM_DATE_TABLE_SECTION 1

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 0:
            self.selectedIndexPath = indexPath;
            DMDatePickerValue value = (DMDatePickerValue)indexPath.row;
            [self setDatesForDatePickerValue:value];
            [self.delegate datePicker:self didPickValue:value];
            [self.presentingViewController dismissViewControllerAnimated:YES completion:NULL];
            break;
        case 1:
            self.selectedIndexPath = indexPath;
            if (indexPath.row == 0) {
//                this is our start date
                [self.customRangeStartCell.contentView addSubview:self.datePicker];
                self.datePicker.date = self.startDate;
                self.datePicker.minimumDate = nil;
                self.datePicker.maximumDate = self.endDate;
            }else {
                [self.customRangeEndCell.contentView addSubview:self.datePicker];
                self.datePicker.date = self.endDate;
                self.datePicker.minimumDate = self.startDate;
                self.datePicker.maximumDate = nil;
            }
            
            [tableView beginUpdates];
            [tableView endUpdates];
            [self.tableView scrollToNearestSelectedRowAtScrollPosition:UITableViewScrollPositionTop animated:YES];
            break;
        case 2:
            if (self.userHasPickedCustomDate) {
                [self.delegate datePicker:self didPickValue:DMDatePickerValueCustom];
            }
            [self.presentingViewController dismissViewControllerAnimated:YES completion:NULL];
            break;
        default:
            break;
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([indexPath isEqual:self.selectedIndexPath] && self.selectedIndexPath.section == CUSTOM_DATE_TABLE_SECTION) {
        self.selectedIndexPath = nil;
        
        [tableView beginUpdates];
        [tableView endUpdates];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height = SYSTEM_DEFAULT_CELL_HEIGHT;
    if ([indexPath isEqual:self.selectedIndexPath] && self.selectedIndexPath.section == CUSTOM_DATE_TABLE_SECTION) {
        height = SYSTEM_DEFAULT_CELL_HEIGHT + CGRectGetHeight(self.datePicker.bounds);
    }
    // to make Btn's height 50 - prevent from showing separator line in Btn
    if (indexPath.section == 2) {
        height = 50.0;
    }
    return height;
}


#pragma mark - private

- (void)setStartDate:(NSDate *)startDate {
    if (startDate != _startDate) {
        _startDate = startDate;
        self.startDateLabel.text = [NSDateFormatter localizedStringFromDate:startDate
                                                                  dateStyle:NSDateFormatterMediumStyle
                                                                  timeStyle:NSDateFormatterShortStyle];
    }
}

- (void)setEndDate:(NSDate *)endDate {
    if (endDate != _endDate) {
        _endDate = endDate;
        self.endDateLabel.text = [NSDateFormatter localizedStringFromDate:endDate
                                                           dateStyle:NSDateFormatterMediumStyle
                                                           timeStyle:NSDateFormatterShortStyle];
    }
}

- (void)userChangedCustomDateValue:(UIDatePicker*)datePicker {
    self.userHasPickedCustomDate = YES;
    
    if (self.selectedIndexPath.row == 0) {
        self.startDate = datePicker.date;
    }else{
        self.endDate = datePicker.date;
    }
}

- (void)setDatesForDatePickerValue:(DMDatePickerValue)value {
    switch (value) {
        case DMDatePickerValueToday:
            self.startDate = [self todayStartDate];
            self.endDate = [self.startDate dateByAddingTimeInterval:SECONDS_IN_A_DAY];
            break;
        case DMDatePickerValueYesterday:
            self.endDate = [self todayStartDate];
            self.startDate = [self.endDate dateByAddingTimeInterval:-SECONDS_IN_A_DAY];
            break;
        case DMDatePickerValueLastSevenDays:
            self.endDate = [[self todayStartDate]dateByAddingTimeInterval:SECONDS_IN_A_DAY];
            self.startDate = [self.endDate dateByAddingTimeInterval:- (7 * SECONDS_IN_A_DAY)];
            break;
        case DMDatePickerValueAll:
            self.endDate = [[self todayStartDate]dateByAddingTimeInterval:SECONDS_IN_A_DAY];
            self.startDate = [self allStartDate];
            break;
        default:
            break;
    }
}

- (NSDate*)todayStartDate
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:(NSCalendarUnitYear | NSCalendarUnitDay | NSCalendarUnitMonth)
                                               fromDate:[NSDate date]];
    components.hour = 0;
    components.minute = 0;
    components.second = 0;
    
    return [calendar dateFromComponents:components];
}

- (NSDate*)allStartDate {
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components;
    
    User* user = [[[CoreDataHelper instance] entityManager] fetchUser];
    if (user.created_at) {
        // if user.created_at exists, set the date with user.created_at
        components = [calendar components:(NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|
                                           NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond)
                                                   fromDate:user.created_at];
    }else{
        // if user.created_at doesn't exist
        //    return a date covering any possible use of the app
        components = [calendar components:(NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay)
                                 fromDate:[NSDate date]];
        components.year = 2015;
        components.month = 12;
        components.day = 1;
    }
    
    return [calendar dateFromComponents:components];
}

@end
