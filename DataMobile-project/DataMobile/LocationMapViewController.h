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
//  LocationMapViewController.h
//  BasicExample
//
//  Created by Nick Lockwood on 24/03/2014.
//  Copyright (c) 2014 Charcoal Design. All rights reserved.
//
// Modified by MUKAI Takeshi in 2015-10

#import <UIKit/UIKit.h>
//#import "FXForms.h"
#import <CoreLocation/CoreLocation.h>
#import "DMUSDataManager.h"

// delegate to
@protocol LocationMapViewDelegate
- (void)locationEntered;
@end

@interface LocationMapViewController : UIViewController <CLLocationManagerDelegate> {
    CLLocationManager* locationManager;
    BOOL isMapViewStarted;
    int mType;
}

//@property (nonatomic, strong) FXFormField *field;
@property (nonatomic, retain) DMUSDataManager *usDataManager;
@property (nonatomic, retain) id delegate;

// from DMUSLocationView
- (void)localSearch:(NSString*)text;

@end
