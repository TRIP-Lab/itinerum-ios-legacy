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
//  DMUserSurveyForm.m
//  DataMobile
//
//  Created by Colin Rofls on 2014-07-27.
//  Copyright (c) 2014 MML-Concordia. All rights reserved.
//
// Modified by MUKAI Takeshi in 2015-10
// based on Concordia version

#import "DMUserSurveyForm.h"
#import "DMTextCell.h"
#import "CustomButtonCell.h"

@interface DMUserSurveyForm ()
@property (strong, nonatomic) NSMutableArray *itemsFailingValidation;
@end

@implementation DMUserSurveyForm
@synthesize usDataManager;

- (instancetype)init {
    if (self == [super init]) {
        // get instance from usDataManager
        usDataManager = [DMUSDataManager instance];
    }
    
    return self;
}

// load values from DMUSDataManager to resolve the problem of resetting when view is back
- (void)reloadValue {
    self.sex = usDataManager.sex;
    self.ageBracket = usDataManager.ageBracket;
    self.licenseXorTransitPass = usDataManager.licenseXorTransitPass;
    self.livingArrangement = usDataManager.livingArrangement;
    self.totalPeopleInHome = usDataManager.totalPeopleInHome;
    self.totalCarsInHome = usDataManager.totalCarsInHome;
    self.peopleUnder16InHome = usDataManager.peopleUnder16InHome;
    self.email = usDataManager.email;
    self.useReminders = usDataManager.useReminders;
}

// save values to DMUSDataManager when view is back
- (void)saveValue {
    usDataManager.sex = self.sex;
    usDataManager.ageBracket = self.ageBracket;
    usDataManager.licenseXorTransitPass = self.licenseXorTransitPass;
    usDataManager.livingArrangement = self.livingArrangement;
    usDataManager.totalPeopleInHome = self.totalPeopleInHome;
    usDataManager.totalCarsInHome = self.totalCarsInHome;
    usDataManager.peopleUnder16InHome = self.peopleUnder16InHome;
    usDataManager.email = self.email;
    usDataManager.useReminders = self.useReminders;
}

- (NSMutableArray*)itemsFailingValidation {
    if (!_itemsFailingValidation) {
        _itemsFailingValidation = [[NSMutableArray alloc]init];
    }
    return _itemsFailingValidation;
}

- (NSArray*)fields {
    return @[
             @{FXFormFieldKey: DM_SEX_FIELD_KEY,
               FXFormFieldOptions: @[NSLocalizedString(@"Male", @""), NSLocalizedString(@"Female", @""), NSLocalizedString(@"Other/Neither", @"")],
               FXFormFieldTitle: NSLocalizedString(@"Sex", @""),
               FXFormFieldInline: @YES},
             
             @{FXFormFieldKey: DM_AGE_FIELD_KEY,
               FXFormFieldOptions: @[NSLocalizedString(@"16 to 24", @""), NSLocalizedString(@"25 to 34", @""), NSLocalizedString(@"35 to 44", @""), NSLocalizedString(@"45 to 54", @""), NSLocalizedString(@"55 to 64", @""), NSLocalizedString(@"65 or older", @"")],
               FXFormFieldTitle: NSLocalizedString(@"Age bracket", @""),
               FXFormFieldInline: @YES},
             
             @{FXFormFieldKey: DM_LICENCE_XOR_TRANSIT_FIELD_KEY,
               FXFormFieldHeader: NSLocalizedString(@"Do you have a driver's license and/or\na monthly transit pass?", @""),
               FXFormFieldTitle: @"",
               FXFormFieldOptions: @[NSLocalizedString(@"Driver's License", @""),
                                     NSLocalizedString(@"Monthly Transit Pass", @"")],
               FXFormFieldType: FXFormFieldTypeBitfield,
               FXFormFieldInline: @YES},
             
             @{FXFormFieldKey: DM_LIVING_ARRANGEMENT_KEY,
               FXFormFieldOptions: @[NSLocalizedString(@"With my parents", @""), NSLocalizedString(@"By myself", @""), NSLocalizedString(@"With roommates", @""), NSLocalizedString(@"With my family", @"")],
               FXFormFieldTitle: NSLocalizedString(@"Who do you live with?", @""),
               FXFormFieldInline: @YES},
                   
             @{FXFormFieldKey: DM_TOTAL_PEOPLE_FIELD_KEY,
               FXFormFieldHeader: NSLocalizedString(@"How many people live in your home?", @""),
               FXFormFieldTitle: @"",
               FXFormFieldCell: [FXFormStepperCell class]},
             
             @{FXFormFieldKey: DM_YOUNG_PEOPLE_FIELD_KEY,
               FXFormFieldTitle: @"",
               FXFormFieldHeader: NSLocalizedString(@"How many are under 16?", @""),
               FXFormFieldCell: [FXFormStepperCell class]},
             
             @{FXFormFieldKey: DM_TOTAL_CARS_FIELD_KEY,
               FXFormFieldHeader: NSLocalizedString(@"How many cars are in your home?", @""),
               FXFormFieldTitle: @"",
               FXFormFieldCell: [FXFormStepperCell class]},
             
//             text in this cell is set in a nib
//             @{FXFormFieldKey: DM_SURVEY_CONTEST_HEADER_KEY,
//               FXFormFieldCell: [DMTextCell class],
//               FXFormFieldHeader: @"Enter to win an ipad?"},
             
//             @{FXFormFieldKey: DM_OPT_IN_FIELD_KEY,
//               FXFormFieldTitle: @"Enter the contest?",
//               FXFormFieldDefaultValue: @YES},
             
             @{FXFormFieldKey: DM_EMAIL_FIELD_KEY,
               FXFormFieldHeader: NSLocalizedString(@"Email", @""),
               FXFormFieldPlaceholder: @"name@concordia.ca",
               FXFormFieldType: FXFormFieldTypeEmail},
             
//             @{FXFormFieldKey: DM_REMINDERS_FIELD_KEY,
//               FXFormFieldHeader: @"We can send you a notification\nif datamobile isn't running.",
//               FXFormFieldTitle: @"Use Notifications",
//               FXFormFieldAction: @"notificationOptionChanged:"},
             
             @{FXFormFieldKey: @"submitButton",
               FXFormFieldHeader: @" ",
               FXFormFieldCell: [CustomButtonCell class],
               FXFormFieldAction: @"submitFormAction"}
             ];
}

#pragma mark - helpers

- (NSString*)validatePostalCode:(NSString*)postalCode short:(BOOL)isShort {
    postalCode = [postalCode stringByReplacingOccurrencesOfString:@" " withString:@""];
    postalCode = [postalCode uppercaseString];
    
    if (postalCode.length < 3) {
        return @"";
    }
    
    if ([self characterIsLetter:[postalCode characterAtIndex:0]] &&
        [self characterIsNumeral:[postalCode characterAtIndex:1]] &&
        [self characterIsLetter:[postalCode characterAtIndex:2]])
    {
        if (isShort || postalCode.length < 6) {
            // == we're only looking for first three characters
            return [postalCode substringWithRange:NSMakeRange(0, 3)];
        }else {
            //            keep looking
            if ([self characterIsNumeral:[postalCode characterAtIndex:3]] &&
                [self characterIsLetter:[postalCode characterAtIndex:4]] &&
                [self characterIsNumeral:[postalCode characterAtIndex:5]]) {
                
                return [NSString stringWithFormat:@"%@ %@",
                        [postalCode substringWithRange:NSMakeRange(0, 3)],
                        [postalCode substringWithRange:NSMakeRange(3, 3)]];
            }
        }
    }
    
    return nil;
}

- (BOOL)characterIsLetter:(unichar)character
{
    static NSCharacterSet *_letters;
    
    if (!_letters) {
        _letters = [NSCharacterSet letterCharacterSet];
    }
    return [_letters characterIsMember:character];
}

- (BOOL)characterIsNumeral:(unichar)character
{
    static NSCharacterSet *_numerals;
    
    if (!_numerals) {
        _numerals = [NSCharacterSet characterSetWithCharactersInString:@"1234567890"];
    }
    return [_numerals characterIsMember:character];
}

- (NSString*)userDocumentsString {
    NSString *result = @"None";
    
    if (self.licenseXorTransitPass & DMSurveyQualificationDriversLicense) {
        result = @"Driver's License";
    }
    if (self.licenseXorTransitPass & DMSurveyQualificationBusPass) {
        result = [result isEqualToString:@"None"] ? @"Monthly transit pass" : @"Both";
    }
    return result;
}
@end

/*

 I'm leaving this email open so I can jot down thoughts as I work on the survey.
 
 1) The second question asks for a primary travel mode. The question afterward asks for the frequency of this mode, as a percentage. One of the options is 'zero', which seems like a strange option for a primary travel mode. So does 25%, really. This is annoying for the user, but I'm not even sure it's getting you the data you really want. *what* do we actually want? A breakdown of different travel modes by frequency? Maybe this should just be a single list where the user can check of modes they use regularly?
 

 2) postal code: I was thinking of asking the user to drop a pin on a map near their home, and I can then use that to both determine postal code and to set up another geofence. I don't know if you have any thoughts on this? It might not be necessary. Let's ignore this for the time being
 
 3) The 'sex' section is just 'male/female', which seems potentially problematic, especially in a university setting. Maybe consider an 'other/prefer not to say' option? I'm not really sure what best practices are with this stuff right now.
 
 4) not sure how to work the cars question?
 5) 16 is ambiguous, maybe. I prefer "16 and under" or "15 and under"?
 
*/