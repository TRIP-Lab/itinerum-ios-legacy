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
//  OtherViewController.m
//  DataMobile
//
//  Created by DataMobile on 13-04-11.
//  Copyright (c) 2013 MML-Concordia. All rights reserved.
//
// Modified by MUKAI Takeshi in 2015-10

#import "OtherViewController.h"
#import "AlertViewManager.h"
#import "UIDevice-Hardware.h"

@interface OtherViewController ()

@end

@implementation OtherViewController

@synthesize alertManager;
@synthesize scrollView, bottomShadow;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (IBAction)backButtonAction:(UIBarButtonItem *)sender {
    [[self presentingViewController]dismissViewControllerAnimated:YES
                                                       completion:NULL];
}

- (IBAction)touchedURLButton:(id)sender
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://www.itinerum.ca/"]];
}

- (IBAction)sendFeedBackButtonTouchUpInside:(id)sender
{
    if([MFMailComposeViewController canSendMail])
    {
        // Creating new Mail
        MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
        mc.mailComposeDelegate = self;
        [mc setToRecipients:[[NSArray alloc] initWithObjects:@"itinerum@concordia.ca", nil]];  // from Concordia ver
        [mc setSubject:NSLocalizedString(@"Feedback for Itinerum™", @"")];
        [mc setMessageBody:[self getDeviceInfo] isHTML:NO];  // get device info
        
        // Present mail view controller on screen
        [self presentViewController:mc animated:YES completion:NULL];
    }
    else
    {
        [[alertManager createOkAlert:NSLocalizedString(@"Mail account not setup", @"")
                         withMessage:NSLocalizedString(@"You need to setup a mail account to send feedback.", @"")
                              setTag:0] show];
    }
}

- (IBAction)emailButtonTouchUpInside:(id)sender
{
    if([MFMailComposeViewController canSendMail])
    {
        // Creating new Mail
        MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
        mc.mailComposeDelegate = self;
        [mc setSubject:NSLocalizedString(@"Itinerum™ Consent Form", @"")];
        [mc setMessageBody:NSLocalizedString(@"Please see attached the Itinerum™ Consent Form.", @"") isHTML:NO];
        
        NSString *consentFormPath = [[NSBundle mainBundle] pathForResource:NSLocalizedString(@"Consent_Form", @"")
                                                                    ofType:@"pdf"];  // from Concordia ver
        NSData* consentFormData = [[NSData alloc] initWithContentsOfFile:consentFormPath];
        [mc addAttachmentData:consentFormData
                     mimeType:@"application/pdf"
                     fileName:NSLocalizedString(@"Consent_Form.pdf", @"")];
        
        // Present mail view controller on screen
        [self presentViewController:mc animated:YES completion:NULL];
    }
    else
    {
        [[alertManager createOkAlert:NSLocalizedString(@"Mail account not setup", @"")
                         withMessage:NSLocalizedString(@"You need to setup a mail account to get the consent form.", @"")
                              setTag:0] show];
    }
}

- (IBAction)sendAccessDataButtonTouchUpInside:(id)sender
{
    if([MFMailComposeViewController canSendMail])
    {
        // Creating new Mail
        MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
        mc.mailComposeDelegate = self;
        [mc setToRecipients:[[NSArray alloc] initWithObjects:@"itinerum@concordia.ca", nil]];
        [mc setSubject:NSLocalizedString(@"Access My Data on Itinerum™", @"")];
        [mc setMessageBody:[self getDeviceInfo] isHTML:NO];  // get device info
        
        // Present mail view controller on screen
        [self presentViewController:mc animated:YES completion:NULL];
    }
    else
    {
        [[alertManager createOkAlert:NSLocalizedString(@"Mail account not setup", @"")
                         withMessage:NSLocalizedString(@"You need to setup a mail account to send.", @"")
                              setTag:0] show];
    }
}

- (NSString *)getDeviceInfo
{
    NSString *model = [[UIDevice currentDevice] modelName];
    NSString *os_version = [[UIDevice currentDevice] systemVersion];
    NSString *build_number = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    
    NSString *deviceInfo = [NSString stringWithFormat:@"[%@, %@, %@]", model, os_version, build_number];
    
    return deviceInfo;
}


#pragma mark - MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved");
            break;
        case MFMailComposeResultSent:
            break;
            
        case MFMailComposeResultFailed:
            NSLog(@"Mail sent failure: %@", [error localizedDescription]);
            break;
        default:
            break;
    }
    
    // Close the Mail Interface
    [self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // For being alerted when the user uses "No"
    alertManager = [[AlertViewManager alloc] init];
    
    // set dropshadow
    bottomShadow.layer.masksToBounds = NO;
    bottomShadow.layer.shadowRadius = 16.0;
    bottomShadow.layer.shadowOpacity = 0.88;
    bottomShadow.layer.shadowOffset = CGSizeMake(0, -50);
    bottomShadow.layer.shadowColor = [UIColor whiteColor].CGColor;
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
