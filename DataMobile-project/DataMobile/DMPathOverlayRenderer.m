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
//  DMPathOverlayRenderer.m
//  DataMobile
//
//  Created by Colin Rofls on 2014-07-15.
//  Copyright (c) 2014 MML-Concordia. All rights reserved.
//
// Modified by MUKAI Takeshi in 2016-01

#import "DMPathOverlayRenderer.h"
#import "DMPathOverlay.h"

@implementation DMPathOverlayRenderer

-(void)drawMapRect:(MKMapRect)mapRect
         zoomScale:(MKZoomScale)zoomScale
         inContext:(CGContextRef)context
{
    DMPathOverlay *pathOverlay = (DMPathOverlay*)self.overlay;
    CGFloat lineWidth = MKRoadWidthAtZoomScale(zoomScale) * 0.64;  // lineWidth
    MKMapRect clipRect = MKMapRectInset(mapRect, -lineWidth, -lineWidth);
    
    [pathOverlay lockForReading];
    CGPathRef path = [self newPathForPoints:pathOverlay.points
                                 pointCount:pathOverlay.pointCount
                                   clipRect:clipRect
                                  zoomScale:zoomScale];
    
    [pathOverlay unlock];
    
    if (path != nil)
    {
        CGContextAddPath(context, path);
        CGContextSetRGBStrokeColor(context, 88.0/255.0, 82.0/255.0, 229.0/255.0, 0.64);  // lineColor
        CGContextSetLineJoin(context, kCGLineJoinRound);
        CGContextSetLineCap(context, kCGLineCapRound);
        CGContextSetLineWidth(context, lineWidth);
        CGContextStrokePath(context);
        CGPathRelease(path);
    }
    

    
//    draw significant maap points, region entry and exit
    [pathOverlay lockForReading];
    CGColorRef redColor = [[UIColor colorWithRed:252.0/255.0 green:83.0/255.0 blue:109.0/255.0 alpha:0.88]CGColor];  // stopPointColor
    CGColorRef greenColor = [[UIColor colorWithRed:177.0/255.0 green:240.0/255.0 blue:101.0/255.0 alpha:0.88]CGColor];  // startPointColor
    CGColorRef lightBlueColor = [[UIColor colorWithRed:185.0/255.0 green:147.0/255.0 blue:225.0/255.0 alpha:0.32]CGColor];  // dashLineColor
    
    CGFloat pointSize = lineWidth * 2;
    
    for (NSUInteger i = 0; i < pathOverlay.pointCount; i++) {
        if (pathOverlay.points[i].options) {
            DMPointOptions options = pathOverlay.points[i].options;
            CGPoint point = [self pointForMapPoint:pathOverlay.points[i].mapPoint];
            
            
//            if ((options & DMPointMonitorRegionStartPoint) && MKMapRectContainsPoint(MKMapRectInset(mapRect, pointSize, pointSize), pathOverlay.points[i].mapPoint)) {
//                pointSize = lineWidth * 10;
//                CGRect pointRect = CGRectMake(point.x, point.y, pointSize, pointSize);
//                pointRect = CGRectOffset(pointRect, -(pointSize/2), -(pointSize/2));
//                CGContextSetFillColorWithColor(context, lightBlueColor);
//                CGContextFillEllipseInRect(context, pointRect);
//            }
            
            if ((options & DMPointLaunchPoint) &&
                MKMapRectContainsPoint(MKMapRectInset(mapRect, pointSize, pointSize), pathOverlay.points[i].mapPoint)) {
//                we draw launch points larger than region exit points
                pointSize = lineWidth * 3.12;  // startPointSize
                CGRect pointRect = CGRectMake(point.x, point.y, pointSize, pointSize);
                pointRect = CGRectOffset(pointRect, -(pointSize/2), -(pointSize/2));
                CGContextSetFillColorWithColor(context, greenColor);
                CGContextFillEllipseInRect(context, pointRect);
            }
            
            if ((options & DMPointApplicationTerminatePoint) && MKMapRectContainsPoint(MKMapRectInset(mapRect, pointSize, pointSize), pathOverlay.points[i].mapPoint)) {
                pointSize = lineWidth * 2.34;  // stopPointSize
                CGRect pointRect = CGRectMake(point.x, point.y, pointSize, pointSize);
                pointRect = CGRectOffset(pointRect, -(pointSize/2), -(pointSize/2));
                CGContextSetFillColorWithColor(context, redColor);
                CGContextFillRect(context, pointRect);
            }
            
            if ((options & DMPointMonitorRegionExitPoint) && (i > 0)) {
                DMMapPoint_t prevPoint = pathOverlay.points[i-1];
                if (lineIntersectsRect(prevPoint.mapPoint, pathOverlay.points[i].mapPoint, clipRect)) {
                    CGPoint exitPoint = [self pointForMapPoint:prevPoint.mapPoint];
                    CGMutablePathRef regionPath = CGPathCreateMutable();
                    CGPathMoveToPoint(regionPath, NULL, point.x, point.y);
                    CGPathAddLineToPoint(regionPath, NULL, exitPoint.x, exitPoint.y);
                    
                    CGContextAddPath(context, regionPath);
                    CGContextSetStrokeColorWithColor(context, lightBlueColor);
                    CGContextSetLineJoin(context, kCGLineJoinRound);
                    CGContextSetLineCap(context, kCGLineCapRound);
                    CGContextSetLineWidth(context, lineWidth);
                    
                    CGFloat dashLengths[2] = {lineWidth*0.16, lineWidth*2.48};  // dashLine
                    CGContextSetLineDash(context, 0, dashLengths, 2);
                    CGContextStrokePath(context);
                    CGPathRelease(regionPath);
                }
            }


        }
    }
    
    [pathOverlay unlock];
}

static BOOL lineIntersectsRect(MKMapPoint p0, MKMapPoint p1, MKMapRect r)
{
    double minX = MIN(p0.x, p1.x);
    double minY = MIN(p0.y, p1.y);
    double maxX = MAX(p0.x, p1.x);
    double maxY = MAX(p0.y, p1.y);
    
    MKMapRect r2 = MKMapRectMake(minX, minY, maxX - minX, maxY - minY);
    return MKMapRectIntersectsRect(r, r2);
}


//-(CGPathRef)newPathForPoints:(MKMapPoint*)points
//                  pointCount:(NSUInteger)pointCount
//                    clipRect:(MKMapRect)mapRect
//                   zoomScale:(MKZoomScale)zoomScale {
//    
//}

//
#define MIN_POINT_DELTA 5.0
//
- (CGPathRef)newPathForPoints:(DMMapPoint_t *)points
                   pointCount:(NSUInteger)pointCount
                     clipRect:(MKMapRect)mapRect
                    zoomScale:(MKZoomScale)zoomScale
{
    // The fastest way to draw a path in an MKOverlayView is to simplify the
    // geometry for the screen by eliding points that are too close together
    // and to omit any line segments that do not intersect the clipping rect.
    // While it is possible to just add all the points and let CoreGraphics
    // handle clipping and flatness, it is much faster to do it yourself:
    //
    if (pointCount < 2)
        return NULL;
    
    CGMutablePathRef path = NULL;
    
    BOOL needsMove = YES;
    
#define POW2(a) ((a) * (a))
    
    // Calculate the minimum distance between any two points by figuring out
    // how many map points correspond to MIN_POINT_DELTA of screen points
    // at the current zoomScale.
    double minPointDelta = MIN_POINT_DELTA / zoomScale;
    double c2 = POW2(minPointDelta);
    
    DMMapPoint_t point, lastPoint = points[0];
    NSUInteger i;
    for (i = 1; i < pointCount - 1; i++)
    {
        point = points[i];
        double a2b2 = POW2(point.mapPoint.x - lastPoint.mapPoint.x) + POW2(point.mapPoint.y - lastPoint.mapPoint.y);
        if (a2b2 >= c2) {
            if (lineIntersectsRect(point.mapPoint, lastPoint.mapPoint, mapRect))
            {
                if (!path)
                    path = CGPathCreateMutable();
                if (needsMove)
                {
                    CGPoint lastCGPoint = [self pointForMapPoint:lastPoint.mapPoint];
                    CGPathMoveToPoint(path, NULL, lastCGPoint.x, lastCGPoint.y);
                }
                CGPoint cgPoint = [self pointForMapPoint:point.mapPoint];

                //                if this is a first point move instead of drawing
                if ((point.options & DMPointLaunchPoint) || (point.options & DMPointMonitorRegionExitPoint)) {
                    CGPathMoveToPoint(path, NULL, cgPoint.x, cgPoint.y);
                }else{
                    CGPathAddLineToPoint(path, NULL, cgPoint.x, cgPoint.y);
                }
            }
            else
            {
                // discontinuity, lift the pen
                needsMove = YES;
            }
            lastPoint = point;
        }
    }
    
#undef POW2
    
    // If the last line segment intersects the mapRect at all, add it unconditionally
    point = points[pointCount - 1];
    if (lineIntersectsRect(lastPoint.mapPoint, point.mapPoint, mapRect))
    {
        if (!path)
            path = CGPathCreateMutable();
        if (needsMove)
        {
            CGPoint lastCGPoint = [self pointForMapPoint:lastPoint.mapPoint];
            CGPathMoveToPoint(path, NULL, lastCGPoint.x, lastCGPoint.y);
        }
        CGPoint cgPoint = [self pointForMapPoint:point.mapPoint];
        CGPathAddLineToPoint(path, NULL, cgPoint.x, cgPoint.y);
    }
    
    return path;
}

@end
