//
//  DMSettingsViewController.m
//  Itinerum
//
//  Created by Takeshi MUKAI on 8/20/17.
//  Copyright (c) 2017 MML-Concordia. All rights reserved.
//

#import "DMSettingsViewController.h"
#import "DMAppDelegate.h"
#import "DMSplashScreenViewController.h"
#import "CoreDataHelper.h"
#import "EntityManager.h"
#import <UIKit/UIKit.h>
#import "DMUSDataManager.h"

@interface DMSettingsViewController ()

@property (strong, nonatomic) IBOutlet UISwitch* swRecording;

@end

@implementation DMSettingsViewController
@synthesize delegate;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if (isRecordingStopped) {
        self.swRecording.on = NO;
    }else{
        self.swRecording.on = YES;
    }
    if (isMaxDaysCompleted) {
        self.swRecording.on = NO;
    }
}

- (IBAction)SwitchChangedRecording:(id)sender
{
    if (!isMaxDaysCompleted) {
        if (self.swRecording.on) {
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"Start Recording", @"")
                                                               message:NSLocalizedString(@"Would you like to start the recording of locations?", @"")
                                                              delegate:self
                                                     cancelButtonTitle:NSLocalizedString(@"Cancel", @"")
                                                     otherButtonTitles:NSLocalizedString(@"Yes", @""),nil];
            [alertView show];
        }else{
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"Pause Recording", @"")
                                                               message:NSLocalizedString(@"Would you like to pause the recording of locations?", @"")
                                                              delegate:self
                                                     cancelButtonTitle:NSLocalizedString(@"Cancel", @"")
                                                     otherButtonTitles:NSLocalizedString(@"Yes", @""),nil];
            [alertView show];
        }
    }
}

- (void)alertView:(UIAlertView*)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 100) {
        switch (buttonIndex) {
            case 0:
            break;
                
            case 1:
                [self performSelector:@selector(showLoginView) withObject:nil afterDelay:0.5];
                break;
        }
    }else{
        switch (buttonIndex) {
            case 0:
                // if canceled
                self.swRecording.on = !self.swRecording.on;
                break;
            case 1:
                if (self.swRecording.on) {
                    // delegate to DMMainView
                    [delegate recordingStarted];
                }else{
                    // delegate to DMMainView
                    [delegate recordingStopped];
                }
                break;
        }
    }
}

-(void)showLoginView{
    
    // delete all database
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"CancelledPrompt"];
    NSBatchDeleteRequest *delete = [[NSBatchDeleteRequest alloc] initWithFetchRequest:request];
    NSError *deleteError = nil;
    [[[CoreDataHelper instance]persistentStoreCoordinator]executeRequest:delete withContext:[[CoreDataHelper instance]managedObjectContext] error:&deleteError];


    request = [[NSFetchRequest alloc] initWithEntityName:@"Data"];
    delete = [[NSBatchDeleteRequest alloc] initWithFetchRequest:request];
    deleteError = nil;
    [[[CoreDataHelper instance]persistentStoreCoordinator]executeRequest:delete withContext:[[CoreDataHelper instance]managedObjectContext] error:&deleteError];

    
    request = [[NSFetchRequest alloc] initWithEntityName:@"Location"];
    delete = [[NSBatchDeleteRequest alloc] initWithFetchRequest:request];
    deleteError = nil;
    [[[CoreDataHelper instance]persistentStoreCoordinator]executeRequest:delete withContext:[[CoreDataHelper instance]managedObjectContext] error:&deleteError];

    
    request = [[NSFetchRequest alloc] initWithEntityName:@"Modeprompt"];
    delete = [[NSBatchDeleteRequest alloc] initWithFetchRequest:request];
    deleteError = nil;
    [[[CoreDataHelper instance]persistentStoreCoordinator]executeRequest:delete withContext:[[CoreDataHelper instance]managedObjectContext] error:&deleteError];

    
    request = [[NSFetchRequest alloc] initWithEntityName:@"User"];
    delete = [[NSBatchDeleteRequest alloc] initWithFetchRequest:request];
    deleteError = nil;
    [[[CoreDataHelper instance]persistentStoreCoordinator]executeRequest:delete withContext:[[CoreDataHelper instance]managedObjectContext] error:&deleteError];

    [DMUSDataManager clearSharedInstance];
    
    [[NSUserDefaults standardUserDefaults]setInteger:0 forKey:@"MODEPROMPTCOUNT_USER_DEFAULT"];
    [[NSUserDefaults standardUserDefaults]synchronize];
    
    // change storyboard
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"NewSurvey" bundle:nil];
    DMSplashScreenViewController *vc = [sb instantiateViewControllerWithIdentifier:@"DMSplashScreenViewController"];
    [[UIApplication sharedApplication].keyWindow setRootViewController:vc];
    [[UIApplication sharedApplication].keyWindow makeKeyAndVisible];
    
}

- (IBAction)closeView:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
    [delegate closeDMSettingsView];
}
- (IBAction)changeSurveyButtonClick:(id)sender {
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:nil
                                                       message:NSLocalizedString(@"You are about to change surveys. All local data for the current survey will be deleted. Are you sure you want to continue?", @"")
                                                      delegate:self
                                             cancelButtonTitle:NSLocalizedString(@"Cancel", @"")
                                             otherButtonTitles:NSLocalizedString(@"Change Survey", @""),nil];
    alertView.tag = 100 ;
    [alertView show];
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
