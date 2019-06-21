//
//  DMMMRootViewController.m
//  Itinerum
//
//  Created by Takeshi MUKAI on 5/24/17.
//  Copyright (c) 2017 MML-Concordia. All rights reserved.
//

#import "DMMMRootViewController.h"
#import "DMMMDataManager.h"

@interface DMMMRootViewController ()

@property (nonatomic, retain) IBOutlet UIView* viewPlate;
@property (nonatomic, retain) IBOutlet UIView* viewHeader;
@property (nonatomic, retain) IBOutlet UIView* viewBtn;
@property (nonatomic, retain) IBOutlet UILabel* labelTitle;
@property (nonatomic, retain) IBOutlet UIView* viewTable;
@property (nonatomic, retain) IBOutlet UIButton* btnNext;
@property (nonatomic, retain) IBOutlet UIButton* btnBack;
@property (nonatomic, retain) IBOutlet UIImageView* progressBar;
@property (nonatomic, retain) DMMMDataManager *mmDataManager;
@property (nonatomic) BOOL isNotFirstTime;
@property (nonatomic) BOOL isFinalIndex;
@property (nonatomic) int originalViewTableY;
@property (nonatomic) int originalViewTableHeight;
@property (nonatomic) int originalViewBtnY;
@property (nonatomic) int originalViewPlateX;
@property (nonatomic) int originalViewPlateY;
@property (nonatomic) int originalViewPlateHeight;

@end

@implementation DMMMRootViewController
@synthesize delegate;
@synthesize mmTableViewController, arrayPrompts;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // make radius
    self.viewPlate.clipsToBounds = YES;
    self.viewPlate.layer.cornerRadius = 20.0;
    
    // record original position and size
    self.originalViewTableY = self.viewTable.frame.origin.y;
    self.originalViewTableHeight = self.viewTable.frame.size.height;
    self.originalViewBtnY = self.viewBtn.frame.origin.y;
    self.originalViewPlateX = self.viewPlate.frame.origin.x;
    self.originalViewPlateY = self.viewPlate.frame.origin.y;
    self.originalViewPlateHeight = self.viewPlate.frame.size.height;
    
    // get instance from mmDataManager
//    self.mmDataManager = [DMMMDataManager instance];
    self.mmDataManager = [[DMMMDataManager alloc] init];
    // put arrayPrompts to mmDataManager because arrayPrompts is from DMModepromptManager
    if (self.mmDataManager.arrayPrompts.count<=0) {
        self.mmDataManager.arrayPrompts = arrayPrompts;
    }
    
    // alloc DMMMTableViewController
    // use StoryBoard
    UIStoryboard *mmTableStoryboard = [UIStoryboard storyboardWithName:@"DMMMTable" bundle:nil];
    mmTableViewController = [mmTableStoryboard instantiateViewControllerWithIdentifier:@"DMMMTable"];
    mmTableViewController.delegate = self;
    // set position for tableView
    mmTableViewController.view.frame = CGRectMake(0, 0, self.viewTable.frame.size.width, self.viewTable.frame.size.height);
    [self.viewTable addSubview:mmTableViewController.view];
    
    [self refreshView];
}

- (void)refreshView
{
    // popUp animation
    [UIView beginAnimations:nil context:nil];
    //	[UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    [UIView setAnimationDuration:0.1];
//    [UIView setAnimationDelay:0.2];
//    [UIView setAnimationDelegate:self];
//    [UIView setAnimationDidStopSelector:@selector(hideViewDone)];
    self.view.alpha = 1.0;
    [UIView commitAnimations];
    
    // check if this is the first time load
    if (self.mmDataManager.arrayAnswers.count<=self.mmDataManager.promptIndex) {
        self.isNotFirstTime = NO;
    }else{
        // if this is not the firstTime loaded - for back and forth
        self.isNotFirstTime = YES;
    }
    
    // set viewProperty
    [self setViewProperty];
    
    
    // set mmTableView
    mmTableViewController.arrayChoices = [self.mmDataManager.arrayPrompts[self.mmDataManager.promptIndex] objectForKey:@"choices"];
    // if MultipleChoices
    if ([[self.mmDataManager.arrayPrompts[self.mmDataManager.promptIndex] objectForKey:@"id"] integerValue]==2) {
        mmTableViewController.isMultipleChoices = YES;
    }else{
        mmTableViewController.isMultipleChoices = NO;
    }
    // if this is not the firstTime loaded - for back and forth
    if (self.isNotFirstTime) {
        if (self.mmDataManager.arrayAnswers[self.mmDataManager.promptIndex]!=[NSNull null]) {
            // set data from the last time
            mmTableViewController.arrayAnswer = [self.mmDataManager.arrayAnswers[self.mmDataManager.promptIndex] mutableCopy];
        }
    }
    [mmTableViewController refreshView];
}

- (void)setViewProperty
{
    // set title
    self.labelTitle.text = [NSString stringWithFormat:@"%@", [self.mmDataManager.arrayPrompts[self.mmDataManager.promptIndex] objectForKey:@"prompt"]];
    
    // adjust tableView size by contents
    NSArray *array = [self.mmDataManager.arrayPrompts[self.mmDataManager.promptIndex] objectForKey:@"choices"];
//    int viewTableHeight = (int)array.count*44;
    int viewTableHeight = (int)array.count*64;  // for long text
    if (viewTableHeight>=self.originalViewTableHeight) {
        viewTableHeight = self.originalViewTableHeight;
    }
    self.viewTable.frame = CGRectMake(self.viewTable.frame.origin.x, self.originalViewTableY, self.viewTable.frame.size.width, viewTableHeight);
    // adjust viewBtn position
    self.viewBtn.frame = CGRectMake(self.viewBtn.frame.origin.x, self.originalViewBtnY-(self.originalViewTableHeight-self.viewTable.frame.size.height), self.viewBtn.frame.size.width, self.viewBtn.frame.size.height);
    // adjust viewPlate position and size
    int viewPlateHeight = self.viewHeader.frame.size.height+self.viewTable.frame.size.height+self.btnNext.frame.size.height;
    self.viewPlate.frame = CGRectMake(self.originalViewPlateX+(self.view.frame.size.width-320)/2, self.originalViewPlateY+(self.originalViewPlateHeight-viewPlateHeight)/2+(self.view.frame.size.height-480)/2, self.viewPlate.frame.size.width, viewPlateHeight);
    
    // set progressBar
    // make animation
    [UIView beginAnimations:nil context:nil];
    //    UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    [UIView setAnimationDuration:0.2];
    [UIView setAnimationDelay:0.0];
    self.progressBar.alpha = 1.0;
    self.progressBar.frame = CGRectMake(self.progressBar.frame.origin.x, self.progressBar.frame.origin.y, self.viewPlate.frame.size.width*((self.mmDataManager.promptIndex+1)/(float)self.mmDataManager.arrayPrompts.count), self.progressBar.frame.size.height);
    [UIView commitAnimations];
    
    // if this is the firstTime loaded
    // set button disabled, first
    if (!self.isNotFirstTime) {
        self.btnNext.enabled = NO;
    }else{
        self.btnNext.enabled = YES;
    }
    
    // if this is the first index, change button to CANCEL
    if (self.mmDataManager.promptIndex<=0) {
        [self.btnBack setTitle:NSLocalizedString(@"CANCEL", @"") forState:UIControlStateNormal];
    }else{
        [self.btnBack setTitle:NSLocalizedString(@"BACK", @"") forState:UIControlStateNormal];
    }

    // if this is the final index, change button to SUBMIT
    if (self.mmDataManager.promptIndex+1>=self.mmDataManager.arrayPrompts.count) {
        [self.btnNext setTitle:NSLocalizedString(@"SUBMIT", @"") forState:UIControlStateNormal];
        self.isFinalIndex = YES;
    }else{
        [self.btnNext setTitle:NSLocalizedString(@"NEXT", @"") forState:UIControlStateNormal];
        self.isFinalIndex = NO;
    }
}

- (void)hideView
{
    // popUp animation
    [UIView beginAnimations:nil context:nil];
    //	[UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    [UIView setAnimationDuration:0.1];
    [UIView setAnimationDelay:0.1];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(hideViewDone)];
    self.view.alpha = 0.0;
    [UIView commitAnimations];
}

- (void)hideViewDone
{
    [self refreshView];
}

- (IBAction)nextBtnTouched:(id)sender {
    if (!self.isFinalIndex) {
        self.mmDataManager.promptIndex++;
        if (self.mmDataManager.promptIndex>=self.mmDataManager.arrayPrompts.count) {
            self.mmDataManager.promptIndex = self.mmDataManager.arrayPrompts.count;
        }
        // go to next survey
//        [self performSegueWithIdentifier:@"nextModepromptSegue" sender:self];
        [self hideView];
    }else{
        // if this is the final index, make dict with all prompts answers
        NSDictionary *dictPromptAnswer = [self wrapPromptAnswerData];
        
        // delegate to DMModepromptManager
        [delegate submitDMMMRootView:dictPromptAnswer];
    }
}

- (IBAction)cancelBtnTouched:(id)sender {
    // if this is the first index
    if (self.mmDataManager.promptIndex<=0) {
        // delegate to DMModepromptManager
        [delegate closeDMMMRootView];
    }else{
        // called when back to previous pag
        self.mmDataManager.promptIndex--;
        if (self.mmDataManager.promptIndex<=0) {
            self.mmDataManager.promptIndex = 0;
        }
        [self hideView];
    }
}

- (NSDictionary *)wrapPromptAnswerData
{
    // create promptAnswer object
    NSMutableDictionary *promptAnswerData = [[NSMutableDictionary alloc] init];
    
    for (int i=0; i<self.mmDataManager.arrayPrompts.count; i++) {
        NSString* strKey = [self.mmDataManager.arrayPrompts[i] objectForKey:@"prompt"];
        NSString* strIDType = [self.mmDataManager.arrayPrompts[i] objectForKey:@"id"];
        
        NSArray* arrayAnswer = self.mmDataManager.arrayAnswers[i];
        
        // choose by id
        NSString* strAnswer = @"";
        NSMutableArray *mArray = [NSMutableArray array];
        
        if ([strIDType integerValue]!=2) {
            // if single choice - tableView
            // choose correct answer by strAnswer(number)
            NSMutableArray* arrayChoices = [NSMutableArray array];
            arrayChoices = [self.mmDataManager.arrayPrompts[i] objectForKey:@"choices"];
            strAnswer = arrayChoices[[arrayAnswer[0] intValue]];
        }
        else if ([strIDType integerValue]==2) {
            // if multiple choices - tableView - dropDown, multipleAnswers
            // choose correct answer by strAnswer(number)
            NSMutableArray* arrayChoices = [NSMutableArray array];
            arrayChoices = [self.mmDataManager.arrayPrompts[i] objectForKey:@"choices"];
            
            for (int i=0; i<arrayAnswer.count; i++) {
                [mArray insertObject:arrayChoices[[arrayAnswer[i] intValue]] atIndex:i];
            }
        }
        
        // set answer into dict
        if ([mArray count]>0) {
            [promptAnswerData setObject:mArray forKey:strKey];
        }else{
            [promptAnswerData setObject:strAnswer forKey:strKey];
        }
    }
    
    return promptAnswerData;
}

- (void)promptAnswered:(NSArray*)arrayAnswer
{
    if (!self.isNotFirstTime) {
        // if this is first time, set answer into array
        [self.mmDataManager.arrayAnswers insertObject:arrayAnswer atIndex:self.mmDataManager.promptIndex];
    }else{
        // if this is not first time, replace answer with new
        [self.mmDataManager.arrayAnswers replaceObjectAtIndex:self.mmDataManager.promptIndex withObject:arrayAnswer];
    }
    
    // set button enabled
    self.btnNext.enabled = YES;
    self.isNotFirstTime = YES;
}

// delegate from DMMMTableView
- (void)cellSelected:(NSArray*)arrayAnswer
{
    [self promptAnswered:arrayAnswer];
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
