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
//  DMDebugLogViewController.h
//  DataMobile
//
//  Created by Takeshi MUKAI on 2/19/16.
//  Copyright (c) 2016 MML-Concordia. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DMDebugLogViewController : UIViewController

@property (nonatomic, retain) IBOutlet UIView *viewAccuracy;
@property (nonatomic, retain) IBOutlet UILabel *labelAccuracy;
@property (nonatomic, retain) IBOutlet UIImageView *indicatorUpdated;
@property (nonatomic, retain) IBOutlet UIImageView *indicatorRecorded;
@property (nonatomic, retain) IBOutlet UIButton *btnDebugLog;

- (void)showUpdated:(CLLocation *)location;
- (void)showRecorded:(CLLocation *)location;
- (void)notifyDebugLog:(NSString *)text region:(CLRegion *)region location:(CLLocation *)location;

@end
