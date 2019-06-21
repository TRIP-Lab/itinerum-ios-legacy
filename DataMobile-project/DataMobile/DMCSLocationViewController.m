//
//  DMCSLocationViewController.m
//  DataMobile
//
//  Created by Takeshi MUKAI on 8/22/16.
//  Copyright (c) 2016 MML-Concordia. All rights reserved.
//

#import "DMCSLocationViewController.h"
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@interface DMCSLocationViewController () <CLLocationManagerDelegate, MKMapViewDelegate, UISearchBarDelegate>

@property (strong, nonatomic) CLLocationManager* locationManager;
@property (nonatomic, strong) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) MKPointAnnotation* userLocation;
@property (strong, nonatomic) CLGeocoder* geocoder;
@property (strong, nonatomic) MKPinAnnotationView* pin;
@property (nonatomic) BOOL isMapViewStarted;
@property (weak, nonatomic) IBOutlet UILabel *labelHeader;
@property (nonatomic, retain) IBOutlet UISearchBar* searchBar;

@end

@implementation DMCSLocationViewController
@synthesize delegate, dictSurvey, arrayAnswer, dictMandatoryQuestions, strLang;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // ready longPressGesture
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                                                                   action:@selector(handleLongPressGesture:)];
    [self.mapView addGestureRecognizer:longPressGesture];
    
    // change text, if French
    if ([strLang isEqualToString:@"fr"]) {
        self.searchBar.placeholder = @"Entrez une adresse ou appuyez sur l'écran";
    }
    
    // get header text
    // if mandatory type
    if (self.dictMandatoryQuestions[@"prompt"]) {
        self.labelHeader.text = [NSString stringWithFormat:@"%@", [self.dictMandatoryQuestions objectForKey:@"prompt"]];
    }else{
        // if not mandatory type
        self.labelHeader.text = [NSString stringWithFormat:@"%@", [dictSurvey objectForKey:@"prompt"]];
    }
    
    
    // start locationManager
    if(!self.locationManager){
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        self.locationManager.distanceFilter = kCLDistanceFilterNone;
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    }
    
    // for iOS8 above - authorization
    if( [[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0 ) {
//        [locationManager requestWhenInUseAuthorization];
        [self.locationManager requestAlwaysAuthorization];
    }
    
    // get location - start updatingLocation
    if([CLLocationManager locationServicesEnabled]){
        [self.locationManager startUpdatingLocation];
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
    [self.locationManager stopUpdatingLocation];
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
    [self.locationManager stopUpdatingLocation];
}

- (void)startMapViewWithoutLocationServices
{
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(45.4937774, -73.5774114);  // Concordia location
    [self startMapView:coordinate];
}

- (void)startMapView:(CLLocationCoordinate2D)coordinate
{
    if (!self.isMapViewStarted) {
        
        // make zoom to
        [self makeZoomToRegion:coordinate];
        
        // if survey has been answered already - for back and forth
        // set data from the last time
        if (arrayAnswer.count>0) {
            CLLocation *location = arrayAnswer[0];
            coordinate = location.coordinate;
            [self setAnnotation:coordinate];
        }
        
        self.isMapViewStarted = YES;
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
    if (!self.isMapViewStarted) {
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
    // set answer to array
    NSArray *array = [NSArray arrayWithObjects:location, nil];
    // delegate to DMCustomSurveyRootView
    [delegate locationEntered:array];
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

// searchBar delegate
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    // hide keyboard
    [self.searchBar resignFirstResponder];
    
    // MKLocalSearch
    [self localSearch:self.searchBar.text];
}

// hide keyboard when otehr area is tapped
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
