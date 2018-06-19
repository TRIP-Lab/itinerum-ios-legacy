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
//  EthicsViewController.m
//  DataMobile
//
//  Created by Colin Rofls on 2014-09-07.
//  Copyright (c) 2014 MML-Concordia. All rights reserved.
//
// Modified by MUKAI Takeshi in 2015-10

#import "EthicsViewController.h"

@interface EthicsViewController ()
@property (weak, nonatomic) IBOutlet UIButton *agreeButton;

@end

@implementation EthicsViewController

//- (BOOL)prefersStatusBarHidden {
//    return YES;
//}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // use new design btn
    // make corner radius
    self.agreeButton.layer.cornerRadius = 6.0;
    self.agreeButton.titleLabel.textAlignment = NSTextAlignmentCenter;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)agreeAction:(id)sender {
    // move to DMSplashScreenView
    [self performSegueWithIdentifier:@"splashSegue" sender:self];
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
