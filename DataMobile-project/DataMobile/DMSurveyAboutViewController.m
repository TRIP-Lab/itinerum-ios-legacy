//
//  DMSurveyAboutViewController.m
//  DataMobile
//
//  Created by Takeshi MUKAI on 1/16/17.
//  Copyright (c) 2017 MML-Concordia. All rights reserved.
//

#import "DMSurveyAboutViewController.h"
#import "CoreDataHelper.h"
#import "EntityManager.h"
#import "ScaleFontSize.h"

@interface DMSurveyAboutViewController ()

@property (weak, nonatomic) IBOutlet UIView *plate;
@property (weak, nonatomic) IBOutlet UIImageView *plateTop;
@property (weak, nonatomic) IBOutlet UIImageView *whiteShadowTop;
@property (weak, nonatomic) IBOutlet UIImageView *whiteShadowBottom;
@property (weak, nonatomic) IBOutlet UIImageView *btnDoneCover;
@property (weak, nonatomic) IBOutlet UIButton *btnDone;
@property (strong, nonatomic) IBOutlet UIView* viewAvatar;
@property (strong, nonatomic) IBOutlet UIImageView* avatar;
@property (strong, nonatomic) IBOutlet UILabel* labelSurveyName;
@property (strong, nonatomic) IBOutlet UILabel* labelTitle1;
@property (strong, nonatomic) IBOutlet UILabel* labelTitle2;
@property (strong, nonatomic) IBOutlet UILabel* labelText1;
@property (strong, nonatomic) IBOutlet UILabel* labelText2;
@property (strong, nonatomic) IBOutlet UIScrollView* scrollView;
@property (weak, nonatomic) IBOutlet UIButton *btnBack;
@property (strong, nonatomic) IBOutlet UIView* viewBtnSettings;
@property (strong, nonatomic) IBOutlet UIImageView* btnSettingsPlate;
@property (weak, nonatomic) IBOutlet UIButton *btnSettings;
@property (weak, nonatomic) IBOutlet UIButton *btnClose;

@end

@implementation DMSurveyAboutViewController
@synthesize delegate;
@synthesize isLogin;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // scaleFontSizeByScreenWidth
    CGFloat scaleFontSize = [ScaleFontSize scaleFontSizeByScreenWidth];
    self.labelSurveyName.font = [UIFont fontWithName:@"AvenirNext-Bold" size:17*scaleFontSize];
    self.labelTitle1.font = [UIFont fontWithName:@"AvenirNextCondensed-DemiBold" size:17*scaleFontSize];
    self.labelTitle2.font = [UIFont fontWithName:@"AvenirNextCondensed-DemiBold" size:17*scaleFontSize];
    self.labelText1.font = [UIFont fontWithName:@"AvenirNext-Medium" size:14*scaleFontSize];
    self.labelText2.font = [UIFont fontWithName:@"AvenirNext-Medium" size:14*scaleFontSize];
    self.btnDone.titleLabel.font = [UIFont fontWithName:@"AvenirNextCondensed-DemiBold" size:20*scaleFontSize];
    self.btnSettings.titleLabel.font = [UIFont fontWithName:@"AvenirNextCondensed-Bold" size:12*scaleFontSize];
    
    // radius
    self.plate.layer.cornerRadius = 16.0*scaleFontSize;
    self.plateTop.layer.cornerRadius = 16.0*scaleFontSize;
    self.btnDone.layer.cornerRadius = 16.0*scaleFontSize;
    self.btnSettingsPlate.layer.cornerRadius = 16.0*scaleFontSize;
    // set dropshadow
    self.plate.layer.masksToBounds = NO;
    self.plate.layer.shadowRadius = 1.6;
    self.plate.layer.shadowOpacity = 0.24;
    self.plate.layer.shadowOffset = CGSizeMake(0,0);
    
    // load avatar image
    NSDictionary* dictResults = [[[CoreDataHelper instance] entityManager] fetchCustomSurveyData];
    NSDictionary* dictSurveies = [dictResults objectForKey:@"results"];
    // for avatar
    // load avatar image
    NSString *strUrl = @"";
    // if custom avatar exists
    if (![[dictSurveies objectForKey:@"avatar"] isEqual:[NSNull null]]&&![[dictSurveies objectForKey:@"avatar"] isEqualToString:@""])
    {
        strUrl = [dictSurveies objectForKey:@"avatar"];
        strUrl = [@"https://itinerum.api.host" stringByAppendingString:strUrl];
        NSURL *url = [NSURL URLWithString:strUrl];
        NSData *data = [NSData dataWithContentsOfURL:url];
        // if data exists, use custom avatar on the server
        if (data) {
            UIImage *image = [UIImage imageWithData:data];
            self.avatar.image = image;
        }
    }
//    else {
//        strUrl = [dictSurveies objectForKey:@"defaultAvatar"];
//    }

    // make radius
    self.avatar.clipsToBounds = true;
    self.avatar.layer.cornerRadius = self.avatar.frame.size.width/2.0*scaleFontSize;
    self.viewAvatar.layer.cornerRadius = self.viewAvatar.frame.size.width/2.0*scaleFontSize;
    // set dropshadow
    self.viewAvatar.layer.masksToBounds = NO;
    self.viewAvatar.layer.shadowRadius = 2.4;
    self.viewAvatar.layer.shadowOpacity = 0.48;
    self.viewAvatar.layer.shadowOffset = CGSizeMake(0,0);
    
    // make whiteshadow for scrollview
    self.whiteShadowTop.layer.masksToBounds = NO;
    self.whiteShadowTop.layer.shadowRadius = 8.0*scaleFontSize;
    self.whiteShadowTop.layer.shadowOpacity = 0.88;
    self.whiteShadowTop.layer.shadowOffset = CGSizeMake(0, 12*scaleFontSize);
    self.whiteShadowTop.layer.shadowColor = [UIColor whiteColor].CGColor;
    self.whiteShadowBottom.layer.masksToBounds = NO;
    self.whiteShadowBottom.layer.shadowRadius = 8.0*scaleFontSize;
    self.whiteShadowBottom.layer.shadowOpacity = 0.88;
    self.whiteShadowBottom.layer.shadowOffset = CGSizeMake(0, -12*scaleFontSize);
    self.whiteShadowBottom.layer.shadowColor = [UIColor whiteColor].CGColor;
    
    // surveyName
    self.labelSurveyName.text = [dictSurveies objectForKey:@"surveyName"];
    // aboutText
    // check if aboutText/terms_of_service is null
    if ((![[dictSurveies objectForKey:@"aboutText"] isEqual:[NSNull null]]&&![[dictSurveies objectForKey:@"aboutText"] isEqualToString:@""])||(![[dictSurveies objectForKey:@"termsOfService"] isEqual:[NSNull null]]&&![[dictSurveies objectForKey:@"termsOfService"] isEqualToString:@""])) {
        if ((![[dictSurveies objectForKey:@"aboutText"] isEqual:[NSNull null]]&&![[dictSurveies objectForKey:@"aboutText"] isEqualToString:@""]&&!isLogin)){
            self.labelTitle1.text = NSLocalizedString(@"ABOUT SURVEY", @"");
            self.labelText1.text = [dictSurveies objectForKey:@"aboutText"];
        }else{
            if ((![[dictSurveies objectForKey:@"termsOfService"] isEqual:[NSNull null]]&&![[dictSurveies objectForKey:@"termsOfService"] isEqualToString:@""])){
                self.labelTitle1.text = NSLocalizedString(@"CONSENT AGREEMENT", @"");
                self.labelText1.text = [dictSurveies objectForKey:@"termsOfService"];
            }
            self.labelTitle2.hidden = YES;
            self.labelTitle2.font = [UIFont fontWithName:@"AvenirNextCondensed-DemiBold" size:0];
            self.labelTitle2.text = @"";
            self.labelText2.hidden = YES;
            self.labelText2.font = [UIFont fontWithName:@"AvenirNext-Medium" size:0];
            self.labelText2.text = @"";
        }
        if ((![[dictSurveies objectForKey:@"termsOfService"] isEqual:[NSNull null]]&&![[dictSurveies objectForKey:@"termsOfService"] isEqualToString:@""])){
            self.labelTitle2.text = NSLocalizedString(@"CONSENT AGREEMENT", @"");
            self.labelText2.text = [dictSurveies objectForKey:@"termsOfService"];
        }else{
            self.labelTitle2.hidden = YES;
            self.labelTitle2.font = [UIFont fontWithName:@"AvenirNextCondensed-DemiBold" size:0];
            self.labelTitle2.text = @"";
            self.labelText2.hidden = YES;
            self.labelText2.font = [UIFont fontWithName:@"AvenirNext-Medium" size:0];
            self.labelText2.text = @"";
        }
    }else{
        self.labelTitle1.hidden = YES;
        self.labelTitle1.font = [UIFont fontWithName:@"AvenirNextCondensed-DemiBold" size:0];
        self.labelTitle1.text = @"";
        self.labelText1.hidden = YES;
        self.labelText1.font = [UIFont fontWithName:@"AvenirNext-Medium" size:0];
        self.labelText1.text = @"";
        self.labelTitle2.hidden = YES;
        self.labelTitle2.font = [UIFont fontWithName:@"AvenirNextCondensed-DemiBold" size:0];
        self.labelTitle2.text = @"";
        self.labelText2.hidden = YES;
        self.labelText2.font = [UIFont fontWithName:@"AvenirNext-Medium" size:0];
        self.labelText2.text = @"";
    }
    
    // if opened when user login
    // set login mode
    if (isLogin) {
        self.viewBtnSettings.hidden = YES;
        self.btnClose.hidden = YES;
        self.btnBack.enabled = NO;
        [self.btnDone setTitle:NSLocalizedString(@"I UNDERSTAND", @"") forState:UIControlStateNormal];

        // check textSize to check if all of text appear without scrolling
        NSDictionary *dictAttribute = @{ NSForegroundColorAttributeName:[UIColor whiteColor],
                                      NSFontAttributeName:[UIFont fontWithName:@"AvenirNext-Medium" size:14*scaleFontSize] };
        NSAttributedString *sttributeString1 = [[NSAttributedString alloc] initWithString:self.labelText1.text
                                                                     attributes:dictAttribute];
        CGRect labelFrame1 = [sttributeString1 boundingRectWithSize:CGSizeMake(self.labelText1.frame.size.width*scaleFontSize, CGFLOAT_MAX)
                                                options:NSStringDrawingUsesLineFragmentOrigin
                                                context:nil];
        NSAttributedString *sttributeString2 = [[NSAttributedString alloc] initWithString:self.labelText2.text
                                                                               attributes:dictAttribute];
        CGRect labelFrame2 = [sttributeString2 boundingRectWithSize:CGSizeMake(self.labelText2.frame.size.width*scaleFontSize, CGFLOAT_MAX)
                                                            options:NSStringDrawingUsesLineFragmentOrigin
                                                            context:nil];
        float textHeight = labelFrame1.size.height + labelFrame2.size.height;
        float rate ;
        if (self.labelTitle2.hidden) {
            rate = 1.5;
        }else{
            rate = 0.64;
        }
        
        // if scroll is needed to show all of text
        if (textHeight>=self.scrollView.frame.size.height*scaleFontSize*rate) {
            // disable button first
            self.scrollView.delegate = self;
            self.btnDone.enabled = NO;
            self.btnDone.backgroundColor = [UIColor colorWithRed:128.0/255.0 green:166.0/255.0 blue:250.0/255.0 alpha:1.0];
            self.btnDoneCover.backgroundColor = [UIColor colorWithRed:128.0/255.0 green:166.0/255.0 blue:250.0/255.0 alpha:1.0];
        }
    }
    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    // detect if scrollView reached to bottom
    float bottomEdge = scrollView.contentOffset.y + scrollView.frame.size.height;
    if (bottomEdge >= scrollView.contentSize.height) {
        // if reached
        self.btnDone.enabled = YES;
        self.btnDone.backgroundColor = [UIColor colorWithRed:53.0/255.0 green:112.0/255.0 blue:251.0/255.0 alpha:1.0];
        self.btnDoneCover.backgroundColor = [UIColor colorWithRed:53.0/255.0 green:112.0/255.0 blue:251.0/255.0 alpha:1.0];
    }
}

- (IBAction)closeView:(id)sender
{
    // delegate to DMMainView, DMSplashScreenView
    [delegate closeDMSurveyAboutView];
}

- (IBAction)openSettings:(id)sender
{
    // delegate to DMMainView, DMSplashScreenView
    [delegate openDMSettingsView];
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
