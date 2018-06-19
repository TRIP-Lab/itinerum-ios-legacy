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
//  DMPathOverlay.m
//  DataMobile
//
//  Created by Colin Rofls on 2014-07-15.
//  Copyright (c) 2014 MML-Concordia. All rights reserved.
//
// Modified by MUKAI Takeshi in 2015-10

#import "DMPathOverlay.h"
#import <pthread.h>


@interface DMPathOverlay ()
{
    pthread_rwlock_t lock;
    NSUInteger _pointCount;
    DMMapPoint_t *_points;
    NSUInteger pointSpace;
}

//@property (strong, readwrite) NSMutableIndexSet* firstPoints;
@end

#define INITIAL_POINT_SPACE 1000

@implementation DMPathOverlay

- (instancetype)initWithCoordinate:(CLLocationCoordinate2D)coordinate {
    if (self == [super init]) {
        pointSpace = INITIAL_POINT_SPACE;
        _points = malloc(sizeof(DMMapPoint_t) * pointSpace);
        _points[0] = DMMapPointWithPointAndOptions(MKMapPointForCoordinate(coordinate), DMPointLaunchPoint);
//        self.firstPoints = [NSMutableIndexSet indexSetWithIndex:0];
        _pointCount = 1;

        pthread_rwlock_init(&lock, NULL);
        
//        this is voodoo, copied from apple's BreadCrumbs sample project (as is a lot of this)
//        because our overlay size changes dynamically we're just setting it to worldsize/4?
        
        MKMapPoint origin = _points[0].mapPoint;
        origin.x -= MKMapSizeWorld.width / 8.0;
        origin.y -= MKMapSizeWorld.height / 8.0;
        MKMapSize size = MKMapSizeWorld;
        size.width /= 4.0;
        size.height /= 4.0;
        _boundingMapRect = (MKMapRect) { origin, size };
        MKMapRect worldRect = MKMapRectMake(0, 0, MKMapSizeWorld.width, MKMapSizeWorld.height);
        _boundingMapRect = MKMapRectIntersection(_boundingMapRect, worldRect);
//        to work on the simulator you need to set this to worldRect
//        _boundingMapRect = worldRect;
    }
    return self;
}

- (instancetype)initWithLocations:(NSArray *)locations {
    NSAssert(locations.count, @"locations must contain a location");
    Location *firstLocation = [locations firstObject];

    if (self == [self initWithCoordinate:CLLocationCoordinate2DMake(firstLocation.latitude, firstLocation.longitude)]) {
        
        for (Location* location in locations) {
            [self addLocation:CLLocationCoordinate2DMake(location.latitude, location.longitude) pointOptions:location.pointType];
        }
    }
    
    return self;
}


- (void)dealloc
{
    free(_points);
    pthread_rwlock_destroy(&lock);
}


#pragma mark - public

- (void)addLocation:(CLLocationCoordinate2D)coordinate pointOptions:(DMPointOptions)pointOptions {
//    we need to use a WRITE lock:
    pthread_rwlock_wrlock(&lock);
    DMMapPoint_t newPoint = DMMapPointWithPointAndOptions(MKMapPointForCoordinate(coordinate), pointOptions);

    //    grow point space as needed:
    if (pointSpace == _pointCount) {
        pointSpace *= 2;
        _points = realloc(_points, sizeof(DMMapPoint_t) * pointSpace);
        NSLog(@"expanding pointspace to %lu", (unsigned long)pointSpace);
    }
    
//    if (pointOptions & DMPointLaunchPoint) {
//        [self.firstPoints addIndex:_pointCount];
//    }
    
    _points[_pointCount] = newPoint;
    _pointCount++;
    [self unlock];
}

- (MKMapRect)mapRectToUpdate {

    [self lockForReading];
    MKMapPoint newestPoint = _points[_pointCount-1].mapPoint;
    MKMapPoint previousPoint = _points[_pointCount-2].mapPoint;
    [self unlock];
    
    double minX = MIN(newestPoint.x, previousPoint.x);
    double minY = MIN(newestPoint.y, previousPoint.y);
    double maxX = MAX(newestPoint.x, previousPoint.x);
    double maxY = MAX(newestPoint.y, previousPoint.y);
    
    return MKMapRectMake(minX, minY, maxX - minX, maxY - minY);
}

- (MKMapRect)computedMapRect {
    double minX = MAXFLOAT, minY = MAXFLOAT;
    double maxX = 0, maxY = 0;
    [self lockForReading];
    MKMapPoint *currentPoint;
    
    for (int i = 0; i < self.pointCount; i++) {
        currentPoint = &_points[i].mapPoint;
        minX = fmin(minX, currentPoint->x);
        minY = fmin(minY, currentPoint->y);
        maxX = fmax(maxX, currentPoint->x);
        maxY = fmax(maxY, currentPoint->y);
    }
    [self unlock];
    
    return MKMapRectMake(minX, minY, maxX - minX, maxY - minY);
}

- (void)lockForReading
{
    pthread_rwlock_rdlock(&lock);
}

- (void)unlock
{
    pthread_rwlock_unlock(&lock);
}


#pragma mark - helpers

DMMapPoint_t DMMapPointWithPointAndOptions (MKMapPoint mapPoint, DMPointOptions options) {
    DMMapPoint_t point;
    point.options = options;
    point.mapPoint = mapPoint;
    return point;
}

@end
