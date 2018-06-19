//
//  LoginViewController.m
//  DataMobile
//
//  Created by Takeshi MUKAI on 7/27/16.
//  Copyright (c) 2016 MML-Concordia. All rights reserved.
//

#import "LoginViewController.h"
#import "Config.h"
#import "DataSender.h"
#import "CoreDataHelper.h"
#import "EntityManager.h"

@interface LoginViewController ()

@property (weak, nonatomic) IBOutlet UIView *plate;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UIButton *btnStart;
@property (strong, nonatomic) NSString *strSurveyName;
@property (nonatomic) BOOL isServerContacting;
@property (strong, nonatomic) IBOutlet UIView* viewAvatar;
@property (strong, nonatomic) IBOutlet UIImageView* avatar;

@end

@implementation LoginViewController
@synthesize delegate;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // set notification for keybord shown/hidden
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    self.textField.delegate = self;
    
    // set observer for textFieldEditing
    [self.textField addTarget:self
                       action:@selector(textFieldDidChange:)
             forControlEvents:UIControlEventEditingChanged];
    
    
    // make radius and set graphics
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        self.plate.layer.cornerRadius = 8.0;
        self.btnStart.layer.cornerRadius = 20.0;
        self.textField.layer.cornerRadius = 20.0;
        self.textField.layer.borderWidth = 2.0;
    } else {
        // if iPad
        self.plate.layer.cornerRadius = 16.0;
        self.btnStart.layer.cornerRadius = 40.0;
        self.textField.layer.cornerRadius = 40.0;
        self.textField.layer.borderWidth = 4.0;
    }
    self.textField.layer.borderColor = [UIColor colorWithRed:53.0/255.0 green:112.0/255.0 blue:251.0/255.0 alpha:1.0].CGColor;
    self.textField.layer.masksToBounds = YES;
    // set dropshadow
    self.plate.layer.masksToBounds = NO;
    self.plate.layer.shadowRadius = 1.6;
    self.plate.layer.shadowOpacity = 0.16;
    self.plate.layer.shadowOffset = CGSizeMake(0,0);
    
    // disable btnStart first
    self.btnStart.enabled = NO;
    self.btnStart.alpha = 0.64;
    
    // for avatar
    // make radius
    self.avatar.clipsToBounds = true;
    self.avatar.layer.cornerRadius = self.avatar.frame.size.width/2.0;
    self.viewAvatar.layer.cornerRadius = self.viewAvatar.frame.size.width/2.0;
    // set dropshadow
    self.viewAvatar.layer.masksToBounds = NO;
    self.viewAvatar.layer.shadowRadius = 2.4;
    self.viewAvatar.layer.shadowOpacity = 0.48;
    self.viewAvatar.layer.shadowOffset = CGSizeMake(0,0);
}


#pragma mark - interface

// textField delegate
// called when return is pressed
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    // hide keyboard
    [self.textField resignFirstResponder];
    
    return YES;
}

// called when textFiled is editing
- (void)textFieldDidChange:(UITextField *)textField
{
    if (![textField.text isEqualToString:@""]) {
        self.btnStart.enabled = YES;
        self.btnStart.alpha = 1.0;
    } else {
        self.btnStart.enabled = NO;
        self.btnStart.alpha = 0.64;
    }
    
    // put text from keyboard
    self.strSurveyName = textField.text;
}

// hide keyboard when other area is tapped
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

// notification - keyboardWillShow
- (void)keyboardWillShow:(NSNotification *)notification
{
    // move self.view to up
    [UIView beginAnimations:nil context:nil];
    //    UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    [UIView setAnimationDuration:0.3];
    //    [UIView setAnimationDelay:0.2];
    self.view.frame = CGRectMake(self.view.frame.origin.x, -104*(self.view.frame.size.width/320.0), self.view.frame.size.width, self.view.frame.size.height);
    [UIView commitAnimations];
}

// notification - keyboardWillHide
- (void)keyboardWillHide:(NSNotification *)notification
{
    // move self.view to origin
    [UIView beginAnimations:nil context:nil];
    //    UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    [UIView setAnimationDuration:0.3];
    //    [UIView setAnimationDelay:0.2];
    self.view.frame = CGRectMake(self.view.frame.origin.x,  0, self.view.frame.size.width, self.view.frame.size.height);
    [UIView commitAnimations];
}

- (IBAction)touchedCustomSurvey:(id)sender
{
    // hide keyboard
    [self.textField resignFirstResponder];
    
    if (!self.isServerContacting) {
        [self createUserOnServer];
        self.isServerContacting = YES;
    }
}

- (IBAction)touchedDefaultSurvey:(id)sender
{
    // save custom survey data
    // delete user.custom_survey_data
    [self saveCustomSurveyData:nil];
    
    // delegate to DMSplashScreenView
    [delegate closeLoginView];
}


#pragma mark - SyncWithServerAPI

- (void)createUserOnServer
{
    // ready a new user - save device_id, created_at
    [self readyNewUser];
    
    NSDictionary *postData = [[DataSender instance] postDataForCustomSurveyCreate:self.strSurveyName]; // ready postData
    NSString* url = [[Config instance] stringValueForKey:@"dmapiURLCreate"]; // ready URL from config.plist
    NSURLRequest *postRequest = [[DataSender instance] requestWithPostDataForCustomSurvey:postData ToURL:url]; // ready postRequest
    
    [NSURLConnection sendAsynchronousRequest:postRequest queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        DDLogInfo(@"received response to post request: %@", response);
        if (!connectionError) {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
            int statusCode = (int)[httpResponse statusCode];
            
            if (statusCode == 201) {  // if response is correct, 200 is not used anymore // 17.02.01
                // get json data from DM api
                NSDictionary *dictSurvey = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                // save custom survey data
                [self saveCustomSurveyData:dictSurvey];
                
                // delegate to DMSplashScreenView
                [delegate closeLoginView];
            }
            else{  // if response is incorrect
                if (statusCode == 400) {
                    // surveyName is incorrect
                    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"Survey Name Is Incorrect", @"")
                                                                       message:NSLocalizedString(@"Please input correct survey name.", @"")
                                                                      delegate:self
                                                             cancelButtonTitle:NSLocalizedString(@"OK", @"")
                                                             otherButtonTitles:nil];
                    [alertView show];
                }else{
                    // other reasons - e.g. surver doesn't response
                    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"Failed Connecting to Server", @"")
                                                                       message:NSLocalizedString(@"Please try it later.", @"")
                                                                      delegate:self
                                                             cancelButtonTitle:NSLocalizedString(@"OK", @"")
                                                             otherButtonTitles:nil];
                    [alertView show];
                }
            }
        }else{
            // usually, here is called when internet is not connected
            DDLogError(@"POST error: %@", connectionError);
            
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"Internet Connection Is Lost", @"")
                                                               message:NSLocalizedString(@"Please connect to internet.", @"")
                                                              delegate:self
                                                     cancelButtonTitle:NSLocalizedString(@"OK", @"")
                                                     otherButtonTitles:nil];
            [alertView show];
        }
        
        self.isServerContacting = NO;
    }];
}

- (void)readyNewUser {
    CoreDataHelper *helper = [CoreDataHelper instance];
    [helper.entityManager insertNewUserIfNotExists];
}

- (void)saveCustomSurveyData:(NSDictionary *)dictSurvey {
    CoreDataHelper *helper = [CoreDataHelper instance];
    [helper.entityManager updateCustomSurveyData:dictSurvey];
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
