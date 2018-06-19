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
//  DMLocationDisplayDelegate.h
//  DataMobile
//
//  Created by Colin Rofls on 2014-07-15.
//  Copyright (c) 2014 MML-Concordia. All rights reserved.
//
// Modified by MUKAI Takeshi in 2015-10

#import <Foundation/Foundation.h>
#import "Location+Functionality.h"

@class DMLocationManager;

@protocol DMLocationDisplayDelegate <NSObject>
- (void)locationDataSource:(id)dataSource didAddLocation:(CLLocation*)location pointOptions:(DMPointOptions)pointOptions;
- (void)locationDataSource:(id)dataSource didStartMonitoringRegionWithCenter:(CLLocationCoordinate2D)center radius:(CLLocationDistance)radius;
- (void)locationDataSourceStoppedMonitoringRegion;

@end

