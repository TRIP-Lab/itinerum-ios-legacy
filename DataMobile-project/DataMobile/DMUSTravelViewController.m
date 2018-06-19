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
//  DMUSTravelViewController.m
//  DataMobile
//
//  Created by Takeshi MUKAI on 10/29/15.
//  Copyright (c) 2015 MML-Concordia. All rights reserved.
//

#import "DMUSTravelViewController.h"

@interface DMUSTravelViewController ()

@end

@implementation DMUSTravelViewController
@synthesize usDataManager;
@synthesize btnNext, tableViewCellBtn, naviItem;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // set backBarButton - hide Text
    self.navigationItem.backBarButtonItem  = [[UIBarButtonItem alloc] initWithTitle:@""
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:nil
                                                                             action:nil];
    // get instance from usDataManager
    usDataManager = [DMUSDataManager instance];
    
    // set viewProperty by memberType
    [self setViewProperty];
    
    // set data
    if ((mType==1&&usDataManager.travelModeWork==-1)||(mType==2&&usDataManager.travelModeStudy==-1)||mType==0) {
        // if this is the firstTime loaded
        // set button disabled, first
        btnNext.enabled = NO;
        tableViewCellBtn.userInteractionEnabled = NO;
    }else{
        // if this is not the firstTime loaded - for back and forth
        // set data from the last time
        if (mType==1) {
            [self checkSelectedCellWith:usDataManager.travelModeWork and:0];
            [self checkSelectedCellWith:usDataManager.travelModeAltWork and:1];
        }else if (mType==2) {
            [self checkSelectedCellWith:usDataManager.travelModeStudy and:0];
            [self checkSelectedCellWith:usDataManager.travelModeAltStudy and:1];
        }
    }
}

- (void)setViewProperty
{
    if (usDataManager.memberType==0||usDataManager.memberType==1||(usDataManager.memberType==3&&!usDataManager.isWorkInfoEnded)) {
        // work
        mType = 1;
        naviItem.title = NSLocalizedString(@"Travel to Work", @"");
        // change header text
        [self.tableView headerViewForSection:0].textLabel.text = [self tableView:self.tableView titleForHeaderInSection:0];
        [self.tableView headerViewForSection:1].textLabel.text = [self tableView:self.tableView titleForHeaderInSection:1];
        [self.tableView headerViewForSection:2].textLabel.text = [self tableView:self.tableView titleForHeaderInSection:2];
        if (usDataManager.memberType==3) {
            segueID = @"usLocationSegue";
        }else{
            segueID = @"userSurveySegue";
        }
    }else if (usDataManager.memberType==2||(usDataManager.memberType==3&&usDataManager.isWorkInfoEnded)) {
        // study
        mType = 2;
        naviItem.title = NSLocalizedString(@"Travel to Study", @"");
        // change header text
        [self.tableView headerViewForSection:0].textLabel.text = [self tableView:self.tableView titleForHeaderInSection:0];
        [self.tableView headerViewForSection:1].textLabel.text = [self tableView:self.tableView titleForHeaderInSection:1];
        [self.tableView headerViewForSection:2].textLabel.text = [self tableView:self.tableView titleForHeaderInSection:2];
        segueID = @"userSurveySegue";
    }else{
        // home
        mType = 0;
    }
}

// for setView property - change header text
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *text;
    if (section==0) {
        if (mType==1) {
            text = NSLocalizedString(@"How do you typically commute to\nyour work location?", @"");
        }else if (mType==2) {
            text = NSLocalizedString(@"How do you typically commute to\nyour studies?", @"");
        }
        return text;
    }else if (section==1){
        if (mType==1) {
            text = NSLocalizedString(@"Do you use any alternative mode of\ntravel to work?", @"");
        }else if (mType==2) {
            text = NSLocalizedString(@"Do you use any alternative mode of\ntravel to your studies?", @"");
        }
        return text;
    }else if (section==2){
        text = @" "; // to give header height of the buton
        return text;
    }
    return nil;
}

- (void)checkSelectedCellWith:(NSInteger)indexRow and:(NSInteger)indexSection {
    [self.tableView reloadData];
    
    // check selectedCell and uncheck deselectedCell
    for (NSInteger index=0; index<[self.tableView numberOfRowsInSection:indexSection]; index++) {
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:indexSection]];
        cell.accessoryType = UITableViewCellAccessoryNone;
        if (indexRow == index) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
    }
    
    // set data
    if (indexSection==0) {
        if (mType==1) {
            usDataManager.travelModeWork = indexRow;
        }else if (mType==2) {
            usDataManager.travelModeStudy = indexRow;
        }
        
        // set button enabled
        btnNext.enabled = YES;
        tableViewCellBtn.userInteractionEnabled = YES;
    }else{
        if (mType==1) {
            usDataManager.travelModeAltWork = indexRow;
        }else if (mType==2) {
            usDataManager.travelModeAltStudy = indexRow;
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self checkSelectedCellWith:indexPath.row and:indexPath.section];
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
}

- (IBAction)btnTouched:(id)sender {
    if (mType==1) {
        usDataManager.isWorkInfoEnded = YES;
    }
    [self performSegueWithIdentifier:segueID sender:self];
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
