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
//  Location.m
//  DataMobile
//
//  Created by Colin Rofls on 2014-09-06.
//  Copyright (c) 2014 MML-Concordia. All rights reserved.
//
// Modified by MUKAI Takeshi in 2017-01

#import "Location.h"


@implementation Location

@dynamic altitude;
@dynamic direction;
@dynamic h_accuracy;
@dynamic latitude;
@dynamic longitude;
@dynamic pointType;
@dynamic speed;
@dynamic timestamp;
@dynamic v_accuracy;
@dynamic uploaded;
@dynamic modeDetected;  // Modified by MUKAI Takeshi in 2017-01
@dynamic acceleration_x;  // Modified by MUKAI Takeshi in 2017-02
@dynamic acceleration_y;  // Modified by MUKAI Takeshi in 2017-02
@dynamic acceleration_z;  // Modified by MUKAI Takeshi in 2017-02

@end
