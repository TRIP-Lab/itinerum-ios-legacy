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
//  DMUSLocationViewController.m
//  DataMobile
//
//  Created by Takeshi MUKAI on 10/29/15.
//  Copyright (c) 2015 MML-Concordia. All rights reserved.
//

#import "DMUSLocationViewController.h"

@interface DMUSLocationViewController ()

@end

@implementation DMUSLocationViewController
@synthesize usDataManager, locationMapViewController;
@synthesize btnNext, naviItem, labelText, searchBar;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // set backBarButton - hide Text
    self.navigationItem.backBarButtonItem  = [[UIBarButtonItem alloc] initWithTitle:@""
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:nil
                                                                             action:nil];
    
    // set searchBar placeholder
    searchBar.placeholder = NSLocalizedString(@"Enter an address or touch the map", @"");
    
    // get instance from usDataManager
    usDataManager = [DMUSDataManager instance];
    
    // set viewProperty by memberType
    [self setViewProperty];
    
    // set data
    if ((mType==1&&!usDataManager.locationWork)||(mType==2&&!usDataManager.locationStudy)||(mType==0&&!usDataManager.locationHome)) {
        // if this is the firstTime loaded
        // set button disabled, first
        btnNext.enabled = NO;
    }else{
        // if this is not the firstTime loaded - for back and forth
        // set data from the last time
        // in LocationMapViewController
    }
    
    // alloc locationMapView
    locationMapViewController = [[LocationMapViewController alloc] initWithNibName:@"LocationMapViewController" bundle:nil];
    locationMapViewController.delegate = self;
    locationMapViewController.view.frame = [[UIScreen mainScreen] bounds];
    [self.view  insertSubview:locationMapViewController.view atIndex:0];
}

- (void)setViewProperty
{
    if (usDataManager.memberType==0||usDataManager.memberType==1||(usDataManager.memberType==3&&!usDataManager.isWorkInfoEnded)) {
        // work
        mType = 1;
        naviItem.title = NSLocalizedString(@"Work Location", @"");
        labelText.text = NSLocalizedString(@"Please indicate your approximate\nwork location.", @"");
        segueID = @"usTravelSegue";
    }else if (usDataManager.memberType==2||(usDataManager.memberType==3&&usDataManager.isWorkInfoEnded)) {
        // study
        mType = 2;
        naviItem.title = NSLocalizedString(@"Study Location", @"");
        labelText.text = NSLocalizedString(@"Please indicate your approximate\nstudy location.", @"");
        segueID = @"usTravelSegue";
    }else{
        // home
        mType = 0;
        naviItem.title = NSLocalizedString(@"Home Location", @"");
        labelText.text = NSLocalizedString(@"Please indicate your approximate\nhome location.", @"");
        segueID = @"usOccupationSegue";
    }
}

// delegate from
- (void)locationEntered
{
    // set button enabled
    btnNext.enabled = YES;
}

- (IBAction)btnTouched:(id)sender {
    if (mType==1) {
        usDataManager.isWorkInfoEnded = NO;
    }
    [self performSegueWithIdentifier:segueID sender:self];
}

// searchBar delegate
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    // hide keyboard
    [self.searchBar resignFirstResponder];
    
    // MKLocalSearch
    [locationMapViewController localSearch:self.searchBar.text];
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
