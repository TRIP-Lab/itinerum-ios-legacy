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
//  DMPathOverlay.h
//  DataMobile
//
//  Created by Colin Rofls on 2014-07-15.
//  Copyright (c) 2014 MML-Concordia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MKOverlay.h>
#import "Location+Functionality.h"

typedef struct DMMapPoint{
    DMPointOptions options;
    MKMapPoint mapPoint;
}DMMapPoint_t;

@interface DMPathOverlay : NSObject <MKOverlay>

@property (nonatomic, readonly) MKMapRect boundingMapRect;
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;

-(instancetype)initWithLocations:(NSArray*)locations;
-(instancetype)initWithCoordinate:(CLLocationCoordinate2D)coordinate;

-(void)addLocation:(CLLocationCoordinate2D)location pointOptions:(DMPointOptions)pointType;
-(MKMapRect)mapRectToUpdate;

-(void)lockForReading;
-(void)unlock;

-(MKMapRect)computedMapRect;

@property (readonly) DMMapPoint_t *points;
@property (readonly) NSUInteger pointCount;

//construction helpers:
DMMapPoint_t DMMapPointWithPointAndOptions (MKMapPoint, DMPointOptions);

@end
