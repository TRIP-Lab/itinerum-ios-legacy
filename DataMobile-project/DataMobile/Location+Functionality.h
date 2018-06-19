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
//  Location+Functionality.h
//  
//
//  Created by Colin Rofls on 2014-07-22.
//
//

#import "Location.h"


typedef NS_OPTIONS(uint32_t, DMPointOptions)
{
    DMPointLaunchPoint                  = 1 << 0,
    DMPointMonitorRegionStartPoint      = 1 << 1,
    DMPointMonitorRegionExitPoint       = 1 << 2,
    DMPointApplicationTerminatePoint    = 1 << 3

};

@interface Location (Functionality)

-(CLLocation*)cllLocation;
/**
 @returns a CLLocationCoordinate2D object from the latitude and longitude
 properties.
 */
- (CLLocationCoordinate2D)coordinate;


/**
 Returns the distance in meters between this Location and the passed Location
 @param location
 @returns the distance in meters between this Location and the passed Location
 */
- (CLLocationDistance)distanceWithLocation:(Location*)location;

/**
 Returns a csv string equivalent of the location object.
 @param formatTimeStamp YES if the timestamp should be formatted, NO otherwise.
 @returns a csv string equivalent of the location object
 */
- (NSString*)csvStringWithFormattedTimeStamp:(BOOL)formatTimeStamp;
- (NSString*)jsonDictWithFormattedTimeStampForCustomSurvey;  // Modified by MUKAI Takeshi in 2016-08 // for custom survey

@end
