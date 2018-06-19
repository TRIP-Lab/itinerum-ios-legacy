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
//  DMUSOccupationViewController.m
//  DataMobile
//
//  Created by Takeshi MUKAI on 10/29/15.
//  Copyright (c) 2015 MML-Concordia. All rights reserved.
//

#import "DMUSOccupationViewController.h"

@interface DMUSOccupationViewController ()

@end

@implementation DMUSOccupationViewController
@synthesize usDataManager;
@synthesize btnNext, tableViewCellBtn;

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
    
    // set data
    if (usDataManager.memberType==-1) {
        // if this is the firstTime loaded
        // set button disabled, first
        btnNext.enabled = NO;
        tableViewCellBtn.userInteractionEnabled = NO;
    }else{
        // if this is not the firstTime loaded - for back and forth
        // set data from the last time
        [self checkSelectedCellWith:usDataManager.memberType and:0];
    }
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
    usDataManager.memberType = indexRow;
    
    if (usDataManager.memberType==0||usDataManager.memberType==1||(usDataManager.memberType==3&&!usDataManager.isWorkInfoEnded)) {
        // work
        segueID = @"usLocationSegue";
    }else if (usDataManager.memberType==2||(usDataManager.memberType==3&&usDataManager.isWorkInfoEnded)) {
        // study
        segueID = @"usLocationSegue";
    }else{
        // home
        segueID = @"userSurveySegue";
    }
    
    // set button enabled
    btnNext.enabled = YES;
    tableViewCellBtn.userInteractionEnabled = YES;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self checkSelectedCellWith:indexPath.row and:indexPath.section];
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
}

- (IBAction)btnTouched:(id)sender {
    usDataManager.isWorkInfoEnded = NO;
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
