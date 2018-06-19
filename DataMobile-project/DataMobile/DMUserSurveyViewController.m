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
//  DMUserSurveyViewController.m
//  DataMobile
//
//  Created by Colin Rofls on 2014-07-27.
//  Copyright (c) 2014 MML-Concordia. All rights reserved.
//
// Modified by MUKAI Takeshi in 2015-10

#import "DMUserSurveyViewController.h"
#import "DMAppDelegate.h"
#import "CoreDataHelper.h"
#import "EntityManager.h"
//#import "NotificationDispatcher.h"
#import "DMUserSurveyRootForm.h"

@interface DMUserSurveyViewController ()
@property (strong, nonatomic) NSMutableArray* itemsFailingValidation;
@property (weak, nonatomic) DMUserSurveyRootForm *userSurveyRoot;
@end

@implementation DMUserSurveyViewController


- (DMUserSurveyRootForm*)userSurveyRoot {
    return (DMUserSurveyRootForm*)self.formController.form;
}


- (void)viewDidLoad {
    [super viewDidLoad];

    _itemsFailingValidation = [NSMutableArray array];
    
    self.formController.form = [[DMUserSurveyRootForm alloc]init];
    // load values from DMUSDataManager to fxform field.value
    [self.userSurveyRoot.userSurvey reloadValue];
}

// it is called when backBtn(iOS Default UiNavigation) is pressed, to save fxform field.value to DMUSDataManager
- (void)viewWillDisappear:(BOOL)animated
{
    if ([self.navigationController.viewControllers indexOfObject:self] == NSNotFound)
    {
        [self.userSurveyRoot.userSurvey saveValue];
    }
    [super viewWillDisappear:animated];
}

#pragma mark - actions sent by FXForm buttons:

// from Concordia ver
- (void)submitFormAction {
//    validate a form?
    NSSet *incompleteFieldKeys = [self incompleteFieldKeys];
    if (incompleteFieldKeys.count) {
        NSIndexPath *topmostInvalidIndexPath = [self smallestIndexPathOfInvalidFields:incompleteFieldKeys];
        [self.tableView scrollToRowAtIndexPath:topmostInvalidIndexPath
                              atScrollPosition:UITableViewScrollPositionTop
                                      animated:YES];
    }else {

        [self saveForm];
        
//        set the survey start date if needed:
        NSDate *startDate = [[NSUserDefaults standardUserDefaults]objectForKey:DM_SURVEY_START_DATE_KEY];
        if (!startDate) {
            [[NSUserDefaults standardUserDefaults]setObject:[NSDate date] forKey:DM_SURVEY_START_DATE_KEY];
            DDLogInfo(@"set survey start date: %@", [NSDate date]);
            [[NSUserDefaults standardUserDefaults]synchronize];
        }
        [self switchToMainViewController];
    }
}

//- (void)notificationOptionChanged:(id<FXFormFieldCell>)sender {
//    //    TODO: unstub me
//    BOOL notifactionsEnabled = [sender.field.value boolValue];
//    DDLogInfo(@"notification changed to %@", notifactionsEnabled ? @"YES" : @"NO");
//    [[NSUserDefaults standardUserDefaults]setBool:notifactionsEnabled forKey:DM_REMINDERS_FIELD_KEY];
//    if (notifactionsEnabled) {
//        [NotificationDispatcher requestNotificationAuthorization];
//    }
//    
//}

#pragma mark - private

- (void)switchToMainViewController {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"NewLook" bundle:nil];
    UIViewController *vc = [storyboard instantiateInitialViewController];
    DMAppDelegate *appDelegate = (DMAppDelegate*)[[UIApplication sharedApplication]delegate];
    appDelegate.window.rootViewController = vc;
    
    // to hide navigationController
    // but cannot [self dismissViewControllerAnimated:YES completion:nil];, because of requesting POST
    [self.view removeFromSuperview];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)saveForm {
    CoreDataHelper *helper = [CoreDataHelper instance];
    [helper.entityManager updateUserSurveyWithForm:self.userSurveyRoot.userSurvey];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


/*  
 this is all working around the structure of FXForms. Basically for inline lists, FXForms creates new
 field objects with the titles of the options provided for the list.
 here we collect all those names. 
 */

- (NSSet*)incompleteFieldKeys {
    NSMutableSet *incompleteFields = [NSMutableSet set];
    
    // from Concordia ver
    // means we want to highlight this thing
    if ((NSInteger)self.userSurveyRoot.userSurvey.sex == -1) {
        [incompleteFields addObjectsFromArray:@[NSLocalizedString(@"Male", @""), NSLocalizedString(@"Female", @""), NSLocalizedString(@"Other/Neither", @"")]];
    }
    if ((NSInteger)self.userSurveyRoot.userSurvey.ageBracket == -1) {
        [incompleteFields addObjectsFromArray:@[NSLocalizedString(@"16 to 24", @""), NSLocalizedString(@"25 to 34", @""), NSLocalizedString(@"35 to 44", @""), NSLocalizedString(@"45 to 54", @""), NSLocalizedString(@"55 to 64", @""), NSLocalizedString(@"65 or older", @"")]];
    }
    if ((NSInteger)self.userSurveyRoot.userSurvey.livingArrangement == -1) {
        [incompleteFields addObjectsFromArray:@[NSLocalizedString(@"With my parents", @""), NSLocalizedString(@"By myself", @""), NSLocalizedString(@"With roommates", @""), NSLocalizedString(@"With my family", @"")]];
    }
    
    return incompleteFields;
}

/*
 we've added a 'validate' property to FXForm fields. Here we find the fields with the specified titles
 and set this new property to @YES if they need failed validation. We modifed FXforms to check for this vlaue
 and draw the fields differently (red highlight) if it's missing.
 */

- (NSIndexPath*)smallestIndexPathOfInvalidFields:(NSSet*)fields {
    __block NSIndexPath *smallestIndexPath;
    
    [self.formController enumerateFieldsWithBlock:^(FXFormField *field, NSIndexPath *indexPath) {
        
        if ([fields containsObject:field.title] || [fields containsObject:field.key]) {
            [field setValue:@YES forKey:FXFormFieldValidate];
            if (!smallestIndexPath) {
                smallestIndexPath = indexPath;
            }else if (indexPath.section <= smallestIndexPath.section && indexPath.row <= smallestIndexPath.row){
                smallestIndexPath = indexPath;
            }
            
        }else{
            [field setValue:@NO forKey:FXFormFieldValidate];
        }
    }];
    
    return smallestIndexPath;
}


- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if (viewController == self) {
        navigationController.navigationBarHidden = YES;
    }else{
        navigationController.navigationBarHidden = NO;
    }
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
