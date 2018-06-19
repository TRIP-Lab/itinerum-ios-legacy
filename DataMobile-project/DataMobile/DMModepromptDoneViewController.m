//
//  DMModepromptDoneViewController.m
//  DataMobile
//
//  Created by Takeshi MUKAI on 7/27/16.
//  Copyright (c) 2016 MML-Concordia. All rights reserved.
//

#import "DMModepromptDoneViewController.h"
#import "ScaleFontSize.h"
#import "CoreDataHelper.h"
#import "EntityManager.h"
#import "DMAppDelegate.h"

@interface DMModepromptDoneViewController ()

@property (strong, nonatomic) IBOutlet UIView* plate;
@property (strong, nonatomic) IBOutlet UILabel* label1;
@property (strong, nonatomic) IBOutlet UILabel* label2;

@end

@implementation DMModepromptDoneViewController
@synthesize delegate;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // scaleFontSizeByScreenWidth
    CGFloat scaleFontSize = [ScaleFontSize scaleFontSizeByScreenWidth];
    self.label1.font = [UIFont fontWithName:@"AvenirNext-DemiBold" size:17*scaleFontSize];
    self.label2.font = [UIFont fontWithName:@"AvenirNext-DemiBold" size:14*scaleFontSize];
    
    // radius
    self.plate.layer.cornerRadius = 20.0*scaleFontSize;
    
    // make blur - plate
    self.plate.clipsToBounds = YES;
    // for Blur effect - dummy UIToolbar - if ios7 above
    UIToolbar *blurToolbar = [[UIToolbar alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    blurToolbar.barStyle = UIBarStyleDefault;
    [self.plate insertSubview:blurToolbar atIndex:0];
    
    // change text for max days
    // get current language to change display by langulage(fr)
    NSString *currentLanguage = [[NSLocale preferredLanguages] objectAtIndex:0];
    if ([currentLanguage hasPrefix:@"fr"]) {
        // get customSurveyData
        if ([[[CoreDataHelper instance] entityManager] fetchCustomSurveyData]) {
            NSDictionary* dictResults = [[[CoreDataHelper instance] entityManager] fetchCustomSurveyData];
            NSDictionary* dictSurveies = [dictResults objectForKey:@"results"];
            
            // dayDuration of survey
            NSDictionary *dictPrompt = [dictSurveies objectForKey:@"prompt"];
            NSString *strNumDays = [NSString stringWithFormat:@"%@",[dictPrompt objectForKey:@"maxDays"]];
            int dayDuration = [strNumDays intValue];
            if (dayDuration<=0) {
                dayDuration = DM_DAY_DURATION_OF_SURVEY;
            }
            
            NSString *str = [NSString stringWithFormat:@"Vous ne recevrez plus d’alertes mais vous pourrez continuer à participer jusqu’à %d jours.\nSi vous ne voulez plus participer, vous pouvez simplement désinstaller l’application.", dayDuration];
            self.label2.text = str;
        }
    }
}

// delegate to DMModepromptManager
- (IBAction)touchedBtn:(id)sender {
    [delegate closeDMModepromptDoneView];
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
