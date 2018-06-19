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
//  LocationMapViewController.m
//  BasicExample
//
//  Created by Nick Lockwood on 24/03/2014.
//  Copyright (c) 2014 Charcoal Design. All rights reserved.
//
// Modified by MUKAI Takeshi in 2015-10

#import "LocationMapViewController.h"
#import <MapKit/MapKit.h>


@interface LocationMapViewController () <MKMapViewDelegate>

@property (nonatomic, strong) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) MKPointAnnotation* userLocation;
@property (strong, nonatomic) CLGeocoder* geocoder;
@property (strong, nonatomic) MKPinAnnotationView* pin;

@end


@implementation LocationMapViewController
@synthesize usDataManager;
@synthesize delegate;

//- (void)viewWillAppear:(BOOL)animated
//{
//    [super viewWillAppear:animated];
//}
//
//// this is all stuff for disabling the swipe-from-edge gesture that was causing a weird display bug
//// see http://stackoverflow.com/a/23271841/1529922
//- (void)viewDidAppear:(BOOL)animated {
//    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
//        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
//        self.navigationController.interactivePopGestureRecognizer.delegate = self;
//    }
//}
//
//- (void)viewWillDisappear:(BOOL)animated
//{
//    [super viewWillDisappear:animated];
//    
//    // Enable iOS 7 back gesture
//    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
//        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
//        self.navigationController.interactivePopGestureRecognizer.delegate = nil;
//    }
//}
//
//- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
//{
//    return NO;
//}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // ready longPressGesture
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                                     action:@selector(handleLongPressGesture:)];
    [self.mapView addGestureRecognizer:longPressGesture];
    
    
    // get instance from usDataManager
    usDataManager = [DMUSDataManager instance];
    // choose mType
    if (usDataManager.memberType==0||usDataManager.memberType==1||(usDataManager.memberType==3&&!usDataManager.isWorkInfoEnded)) {
        // work
        mType = 1;
    }else if (usDataManager.memberType==2||(usDataManager.memberType==3&&usDataManager.isWorkInfoEnded)) {
        // study
        mType = 2;
    }else{
        // home
        mType = 0;
    }
    
    
    // start locationManager
    if(!locationManager){
        locationManager = [[CLLocationManager alloc] init];
        locationManager.delegate = self;
        locationManager.distanceFilter = kCLDistanceFilterNone;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    }
    
    // for iOS8 above - authorization
    if( [[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0 ) {
        //        [locationManager requestWhenInUseAuthorization];
        [locationManager requestAlwaysAuthorization];
    }
    
    // get location - start updatingLocation
    if([CLLocationManager locationServicesEnabled]){
        [locationManager startUpdatingLocation];
    }else{
        // if locationService is disabled
        [self startMapViewWithoutLocationServices];
    }
}

// updateLocation
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(newLocation.coordinate.latitude, newLocation.coordinate.longitude);
    [self startMapView:coordinate];
    // stopUpdating just for one time
    [locationManager stopUpdatingLocation];
}

// updateLocation - failed
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    if (error) {
        switch ([error code]) {
            case kCLErrorDenied:
                NSLog(@"%@", @"locationServices is disabled");
                break;
            default:
                NSLog(@"%@", @"failed to get location");
                break;
        }
    }
    [self startMapViewWithoutLocationServices];
    [locationManager stopUpdatingLocation];
}

- (void)startMapViewWithoutLocationServices
{
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(45.4937774, -73.5774114);  // Concordia location
    [self startMapView:coordinate];
}

- (void)startMapView:(CLLocationCoordinate2D)coordinate
{
    if (!isMapViewStarted) {
        
        // make zoom to
        [self makeZoomToRegion:coordinate];
        
        // set data from the last time
        if ((mType==1&&usDataManager.locationWork.count)||(mType==2&&usDataManager.locationStudy.count)||(mType==0&&usDataManager.locationHome.count)) {
            CLLocation *location;
            if (mType==1) {
                location = (CLLocation*)usDataManager.locationWork[@"location"];
            }else if (mType==2) {
                location = (CLLocation*)usDataManager.locationStudy[@"location"];
            }else if (mType==0) {
                location = (CLLocation*)usDataManager.locationHome[@"location"];
            }
            coordinate = location.coordinate;
            [self setAnnotation:coordinate];
        }
        
        isMapViewStarted = YES;
    }
}

// add annotation - drop pin
- (void)addAnnotation:(CLLocationCoordinate2D)coordinate
{
    self.userLocation = [[MKPointAnnotation alloc]init];
    self.userLocation.coordinate = coordinate;
//    self.userLocation.title = title;
//    self.userLocation.subtitle = subtitle;
    [self.mapView addAnnotation:self.userLocation];
    [self.mapView selectAnnotation:self.userLocation animated:YES];
}

// make zoom to
- (void)makeZoomToRegion:(CLLocationCoordinate2D)coordinate
{
    MKCoordinateRegion viewRegion;
    if (!isMapViewStarted) {
        viewRegion = MKCoordinateRegionMakeWithDistance(coordinate, 4000, 4000);
    } else {
        viewRegion = MKCoordinateRegionMakeWithDistance(coordinate, 400, 400);
    }
    MKCoordinateRegion adjustedRegion = [self.mapView regionThatFits:viewRegion];
    [self.mapView setRegion:adjustedRegion animated:YES];
}

// show placemark
- (void)reverseGeocodeLocation:(CLLocation*)location
{
    // reverse geoLocation
    [self.geocoder cancelGeocode];
    self.geocoder = [[CLGeocoder alloc] init];
    [self.geocoder reverseGeocodeLocation:location
                        completionHandler:^(NSArray *placemarks, NSError *error) {
                            CLPlacemark *placemark = (CLPlacemark*)placemarks.firstObject;
                            NSString *locality = placemark.locality;
                            NSString *subLocality = placemark.subLocality;
                            NSString *administrativeArea = placemark.administrativeArea;
                            NSString *inlandWater = placemark.inlandWater;
                            NSString *country = placemark.country;
                            NSString *placename, *subPlacename;
                            
                            placename = subLocality;
                            subPlacename = [self makeSubPlacename:locality and:administrativeArea and:country];
                            
                            if (!placename) {
                                placename = locality;
                                subPlacename = [self makeSubPlacename:nil and:administrativeArea and:country];
                            }
                            if (!placename) {
                                placename = inlandWater;
                                subPlacename = [self makeSubPlacename:nil and:administrativeArea and:country];
                            }
                            if (!placename) {
                                placename = administrativeArea;
                                subPlacename = [self makeSubPlacename:nil and:nil and:country];
                            }
                            if (!placename) {
                                placename = country;
                                subPlacename = [self makeSubPlacename:nil and:nil and:nil];
                            }
                            
                            // remove annotation first
                            [self.mapView removeAnnotations: self.mapView.annotations];
                            // add annotation
                            [self addAnnotation:location.coordinate];
                            
                            self.userLocation.title = placename;
                            self.userLocation.subtitle = subPlacename;
                        }];
}

- (NSString*)makeSubPlacename:(NSString*)locality and:(NSString*)administrativeArea and:(NSString*)country
{
    NSString *subPlacename = @"";
    if (locality) {
        subPlacename = [subPlacename stringByAppendingString:[NSString stringWithFormat:@"%@, ", locality]];
    }
    if (administrativeArea) {
        subPlacename = [subPlacename stringByAppendingString:[NSString stringWithFormat:@"%@, ", administrativeArea]];
    }
    if (country) {
        subPlacename = [subPlacename stringByAppendingString:[NSString stringWithFormat:@"%@", country]];
    }
    
    if ([subPlacename isEqualToString:@""]) {
        subPlacename = nil;
    }
    
    return subPlacename;
}

- (void)setAnnotation:(CLLocationCoordinate2D)coordinate
{
    CLLocation *location = [[CLLocation alloc] initWithLatitude:coordinate.latitude longitude:coordinate.longitude];
    
    // make zoom to, first, because sometimes doesn't reflect annotaion animation
    [self makeZoomToRegion:coordinate];
    // make delay, because sometimes doesn't reflect annotaion animation
    [self performSelector:@selector(setAnnotationAfterDelay:) withObject:location afterDelay:0.2];
}

- (void)setAnnotationAfterDelay:(CLLocation*)location
{
    // make placemark, and add annotation
    [self reverseGeocodeLocation:location];
    
    // set location data
    [self setLocationData:location];
}

// set location data
- (void)setLocationData:(CLLocation*)location
{
    // set data
    if (mType==1) {
        usDataManager.locationWork = @{@"location": location};
    }else if (mType==2) {
        usDataManager.locationStudy = @{@"location": location};
    }else if (mType==0) {
        usDataManager.locationHome = @{@"location": location};
    }
    
    // delegate to
    [delegate locationEntered];
}

// called when longPressGesture
- (void)handleLongPressGesture:(UILongPressGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateBegan) {
        // get touched point on view
        CGPoint touchedPoint = [gesture locationInView:self.mapView];
        // convert touchedPoint to coordinate
        CLLocationCoordinate2D coordinate = [self.mapView convertPoint:touchedPoint toCoordinateFromView:self.mapView];
        
        [self setAnnotation:coordinate];
    }
}

// MKLocalSearch - from DMUSLocationView
- (void)localSearch:(NSString*)text
{
    // ready localSearchRequest
    MKLocalSearchRequest *request = [[MKLocalSearchRequest alloc] init];
    request.naturalLanguageQuery = text;
    request.region = self.mapView.region;
    MKLocalSearch *search = [[MKLocalSearch alloc] initWithRequest:request];
    
    [search startWithCompletionHandler:^(MKLocalSearchResponse *response, NSError *error)
     {
         if (error||!response.mapItems) {
             // if no results
             [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"No Results Found", @"")
                                         message:nil
                                        delegate:self
                               cancelButtonTitle:NSLocalizedString(@"OK", @"")
                               otherButtonTitles:nil] show];
         } else {
             // put first item from mapItems
             MKMapItem *item = response.mapItems[0];
             CLLocationCoordinate2D coordinate = item.placemark.coordinate;
             
             [self setAnnotation:coordinate];
         }
     }];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    self.pin = [[MKPinAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:nil];
//    self.pin.draggable = YES;
    self.pin.canShowCallout = YES;
    self.pin.pinColor = 2;
    self.pin.animatesDrop = YES;
    return self.pin;
}

- (void)mapViewDidFinishLoadingMap:(MKMapView *)mapView {
    // set annotaion, but this is called when map is loaded first time(next time even in new viewDidLoad, will not call this, because of cache).
    //    [mapView selectAnnotation:self.userLocation animated:YES];
}

//- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view didChangeDragState:(MKAnnotationViewDragState)newState fromOldState:(MKAnnotationViewDragState)oldState {
//    if (newState == MKAnnotationViewDragStateEnding) {
//    }
//}

@end
