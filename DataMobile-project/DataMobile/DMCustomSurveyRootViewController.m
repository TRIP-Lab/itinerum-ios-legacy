//
//  DMCustomSurveyRootViewController.m
//  DataMobile
//
//  Created by Takeshi MUKAI on 8/22/16.
//  Copyright (c) 2016 MML-Concordia. All rights reserved.
//

#import "DMCustomSurveyRootViewController.h"
#import "Config.h"
#import "DMAppDelegate.h"
#import "CoreDataHelper.h"
#import "EntityManager.h"
#import "DMUSDataManager.h"

@interface DMCustomSurveyRootViewController ()

@property (nonatomic, retain) IBOutlet UINavigationItem* naviItem;
@property (nonatomic, retain) IBOutlet UIButton* btnNext;
@property (nonatomic, retain) DMUSDataManager *usDataManager;
@property (nonatomic, retain) NSArray *arrayAllSurveies;
@property (nonatomic) BOOL isNotFirstTime;
@property (nonatomic) BOOL isFinalIndex;
@property (nonatomic, retain) NSString* strID;
@property (nonatomic, retain) NSString* strLang;
@property (nonatomic, retain) NSDictionary* dictMandatoryQuestions;

@end

@implementation DMCustomSurveyRootViewController
@synthesize csTableViewController, csLocationViewController, csEmailViewController, csNumberViewController, csTextViewController;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // set backBarButton - hide Text
    self.navigationItem.backBarButtonItem  = [[UIBarButtonItem alloc] initWithTitle:@""
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:nil
                                                                             action:nil];
    
    // get instance from usDataManager
    self.usDataManager = [DMUSDataManager instance];
    
    // check if this is the first time load
    if (self.usDataManager.arrayAnswers.count<=self.usDataManager.customSurveyIndex) {
        self.isNotFirstTime = NO;
    }else{
        // if this is not the firstTime loaded - for back and forth
        self.isNotFirstTime = YES;
    }
    
    // load appropriate survey for this view
    NSDictionary* dictSurvey = [self loadSurvey];
    
    // choose survey field type by id
    NSString *strFieldsType = [self chooseFiledType:dictSurvey];
    
    // set viewProperty
    [self setViewProperty:dictSurvey];
    
    int posY, height;
    posY = self.view.frame.origin.y+self.navigationController.navigationBar.bounds.size.height+[UIApplication sharedApplication].statusBarFrame.size.height;
    height = self.view.frame.size.height-self.navigationController.navigationBar.bounds.size.height-[UIApplication sharedApplication].statusBarFrame.size.height-self.btnNext.frame.size.height;
    
    if ([strFieldsType isEqualToString:@"choice"]||[strFieldsType isEqualToString:@"choices"]||[strFieldsType isEqualToString:@"choice_memberType"]) {
        // if field type, choices - tableView
        // alloc DMCSTableViewController
        // use StoryBoard
        UIStoryboard *customTableStoryboard = [UIStoryboard storyboardWithName:@"DMCSCustomTable" bundle:nil];
        csTableViewController = [customTableStoryboard instantiateViewControllerWithIdentifier:@"DMCSTable"];
        csTableViewController.delegate = self;
        csTableViewController.dictSurvey = dictSurvey;
        // if this is not the firstTime loaded - for back and forth
        if (self.isNotFirstTime) {
            // if this page was not skipped - for multiple routes
            if (self.usDataManager.arrayAnswers[self.usDataManager.customSurveyIndex]!=[NSNull null]) {
                // set data from the last time
                csTableViewController.arrayAnswer = self.usDataManager.arrayAnswers[self.usDataManager.customSurveyIndex];
            }
        }
        // put filedType to detect
        csTableViewController.strFieldsType = strFieldsType;
        // if mandatory type
        // give dictMandatoryQuestions
        if (self.dictMandatoryQuestions[@"colName"]) {
            csTableViewController.dictMandatoryQuestions = self.dictMandatoryQuestions;
        }
        // set position for tableView
        csTableViewController.view.frame = CGRectMake(self.view.frame.origin.x, posY, self.view.frame.size.width, height);
        [self.view insertSubview:csTableViewController.view atIndex:0];
    }
    else if ([strFieldsType isEqualToString:@"location"]) {
        // if field type, location - locationView
        // alloc DMCSLocatioViewController
        // use StoryBoard
        UIStoryboard *customTableStoryboard = [UIStoryboard storyboardWithName:@"DMCSCustomTable" bundle:nil];
        csLocationViewController = [customTableStoryboard instantiateViewControllerWithIdentifier:@"DMCSLocation"];
        csLocationViewController.delegate = self;
        csLocationViewController.dictSurvey = dictSurvey;
        // if this is not the firstTime loaded - for back and forth
        if (self.isNotFirstTime) {
            // if this page was not skipped - for multiple routes
            if (self.usDataManager.arrayAnswers[self.usDataManager.customSurveyIndex]!=[NSNull null]) {
                // set data from the last time
                csLocationViewController.arrayAnswer = self.usDataManager.arrayAnswers[self.usDataManager.customSurveyIndex];
            }
        }
        // if mandatory type
        // give dictMandatoryQuestions
        if (self.dictMandatoryQuestions[@"colName"]) {
            csLocationViewController.dictMandatoryQuestions = self.dictMandatoryQuestions;
        }
        // sned lang info to change text
        csLocationViewController.strLang = self.strLang;
        // set position for tableView
        csLocationViewController.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y+self.navigationController.navigationBar.bounds.size.height+[UIApplication sharedApplication].statusBarFrame.size.height, self.view.frame.size.width, self.view.frame.size.height-self.navigationController.navigationBar.bounds.size.height-[UIApplication sharedApplication].statusBarFrame.size.height);
        [self.view insertSubview:csLocationViewController.view atIndex:0];
    }
    else if ([strFieldsType isEqualToString:@"email"]) {
        // if field type, email
        // alloc DMCSEmailViewController
        // use StoryBoard becuse it uses static table view
        UIStoryboard *customTableStoryboard = [UIStoryboard storyboardWithName:@"DMCSCustomTable" bundle:nil];
        csEmailViewController = [customTableStoryboard instantiateViewControllerWithIdentifier:@"DMCSEmail"];
        csEmailViewController.delegate = self;
        csEmailViewController.dictSurvey = dictSurvey;
        // if this is not the firstTime loaded - for back and forth
        if (self.isNotFirstTime) {
            // if this page was not skipped - for multiple routes
            if (self.usDataManager.arrayAnswers[self.usDataManager.customSurveyIndex]!=[NSNull null]) {
                // set data from the last time
                csEmailViewController.arrayAnswer = self.usDataManager.arrayAnswers[self.usDataManager.customSurveyIndex];
            }
        }
        // if mandatory type
        // give dictMandatoryQuestions
        if (self.dictMandatoryQuestions[@"colName"]) {
            csEmailViewController.dictMandatoryQuestions = self.dictMandatoryQuestions;
        }
        // sned lang info to change text
        csEmailViewController.strLang = self.strLang;
        // set position
        csEmailViewController.view.frame = CGRectMake(self.view.frame.origin.x, posY, self.view.frame.size.width, height);
        [self.view insertSubview:csEmailViewController.view atIndex:0];
    }
    else if ([strFieldsType isEqualToString:@"number"]) {
        // if field type, number
        // alloc DMCSNumberViewController
        // use StoryBoard becuse it uses static table view
        UIStoryboard *customTableStoryboard = [UIStoryboard storyboardWithName:@"DMCSCustomTable" bundle:nil];
        csNumberViewController = [customTableStoryboard instantiateViewControllerWithIdentifier:@"DMCSNumber"];
        csNumberViewController.delegate = self;
        csNumberViewController.dictSurvey = dictSurvey;
        // if this is not the firstTime loaded - for back and forth
        if (self.isNotFirstTime) {
            // if this page was not skipped - for multiple routes
            if (self.usDataManager.arrayAnswers[self.usDataManager.customSurveyIndex]!=[NSNull null]) {
                // set data from the last time
                csNumberViewController.arrayAnswer = self.usDataManager.arrayAnswers[self.usDataManager.customSurveyIndex];
            }
        }
        // set position
        csNumberViewController.view.frame = CGRectMake(self.view.frame.origin.x, posY, self.view.frame.size.width, height);
        [self.view insertSubview:csNumberViewController.view atIndex:0];
    }
    else if ([strFieldsType isEqualToString:@"text_box"]||[strFieldsType isEqualToString:@"text_description"]) {
        // if field type, text
        // alloc DMCSTextlViewController
        // use StoryBoard becuse it uses static table view
        UIStoryboard *customTableStoryboard = [UIStoryboard storyboardWithName:@"DMCSCustomTable" bundle:nil];
        csTextViewController = [customTableStoryboard instantiateViewControllerWithIdentifier:@"DMCSText"];
        csTextViewController.delegate = self;
        csTextViewController.dictSurvey = dictSurvey;
        // if this is not the firstTime loaded - for back and forth
        if (self.isNotFirstTime) {
            // if this page was not skipped - for multiple routes
            if (self.usDataManager.arrayAnswers[self.usDataManager.customSurveyIndex]!=[NSNull null]) {
                // set data from the last time
                csTextViewController.arrayAnswer = self.usDataManager.arrayAnswers[self.usDataManager.customSurveyIndex];
            }
        }
        // put filedType to detect
        csTextViewController.strFieldsType = strFieldsType;
        // set position
        csTextViewController.view.frame = CGRectMake(self.view.frame.origin.x, posY, self.view.frame.size.width, height);
        [self.view insertSubview:csTextViewController.view atIndex:0];
    }
}

- (void)setViewProperty:(NSDictionary*)dict
{
    // set naviTitle
    // if mandatory type
    if ([self.strID intValue]>=100) {
        self.naviItem.title = [self.dictMandatoryQuestions objectForKey:@"colName"];
    }else if ([self.strID intValue]==98) {
        // if terms of service
        if ([self.strLang isEqualToString:@"fr"]) {
            self.naviItem.title = @"Formulaire de consentement";
        }else{
            self.naviItem.title = @"Consent Agreement";
        }
    }else{
        // if not mandatory type
        self.naviItem.title = [dict objectForKey:@"colName"];
    }
    
    // set progressBar
    UIImageView *progressBar = [[UIImageView alloc] init];
    progressBar.backgroundColor = [UIColor colorWithRed:53.0/255.0 green:112.0/255.0 blue:251.0/255.0 alpha:0.88];
    progressBar.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y+self.navigationController.navigationBar.bounds.size.height+[UIApplication sharedApplication].statusBarFrame.size.height, self.view.frame.size.width*((self.usDataManager.customSurveyIndex)/(float)self.arrayAllSurveies.count), 3);
    [self.view addSubview:progressBar];
    // make animation
    [UIView beginAnimations:nil context:nil];
    //    UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    [UIView setAnimationDuration:0.4];
    [UIView setAnimationDelay:0.1];
    progressBar.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y+self.navigationController.navigationBar.bounds.size.height+[UIApplication sharedApplication].statusBarFrame.size.height, self.view.frame.size.width*((self.usDataManager.customSurveyIndex+1)/(float)self.arrayAllSurveies.count), 3);
    [UIView commitAnimations];
    
    // if this is the firstTime loaded
    // set button disabled, first
    if (!self.isNotFirstTime) {
        self.btnNext.enabled = NO;
    }else{
        // if this page was just skipped, set button disabled - for multiple routes
        if (self.usDataManager.arrayAnswers[self.usDataManager.customSurveyIndex]==[NSNull null]) {
            self.btnNext.enabled = NO;
        }
    }
    
    // if this is the final index, change button to SUBMIT
    if (self.usDataManager.customSurveyIndex+1>=self.arrayAllSurveies.count) {
        [self.btnNext setTitle:NSLocalizedString(@"SUBMIT", @"") forState:UIControlStateNormal];
        self.isFinalIndex = YES;
    }
}

- (IBAction)btnTouched:(id)sender {
    if (!self.isFinalIndex) {
        
        // for multiple routes
        // if memberType question page
        if ([self.strID isEqualToString:@"104"]) {
            // skip worker and student questions, if not worker nor student
            if (!self.usDataManager.isWorker&&!self.usDataManager.isStudent) {
                for (int i=0; i<6; i++) {
                    self.usDataManager.customSurveyIndex++;
                    // if the index answer is empty, put null object
                    if (self.usDataManager.arrayAnswers.count<=self.usDataManager.customSurveyIndex) {
                        [self.usDataManager.arrayAnswers insertObject:[NSNull null] atIndex:self.usDataManager.customSurveyIndex];
                    }
                }
            }
            // skip worker questions, if only student
            if (!self.usDataManager.isWorker&&self.usDataManager.isStudent) {
                for (int i=0; i<3; i++) {
                    self.usDataManager.customSurveyIndex++;
                    // if the index answer is empty, put null object
                    if (self.usDataManager.arrayAnswers.count<=self.usDataManager.customSurveyIndex) {
                        [self.usDataManager.arrayAnswers insertObject:[NSNull null] atIndex:self.usDataManager.customSurveyIndex];
                    }
                }
            }
        }
        // if travel_mode_alt_work question page
        else if ([self.strID isEqualToString:@"111"]) {
            // skip student questions, if only worker
            if (self.usDataManager.isWorker&&!self.usDataManager.isStudent) {
                for (int i=0; i<3; i++) {
                    self.usDataManager.customSurveyIndex++;
                    // if the index answer is empty, put null object
                    if (self.usDataManager.arrayAnswers.count<=self.usDataManager.customSurveyIndex) {
                        [self.usDataManager.arrayAnswers insertObject:[NSNull null] atIndex:self.usDataManager.customSurveyIndex];
                    }
                }
            }
        }
        
        self.usDataManager.customSurveyIndex++;
        if (self.usDataManager.customSurveyIndex>=self.arrayAllSurveies.count) {
            self.usDataManager.customSurveyIndex = self.arrayAllSurveies.count;
        }
        // go to next survey
        [self performSegueWithIdentifier:@"nextCustomSurveySegue" sender:self];
    }else{
        // if this is the final index, make dict with all survies answers
        NSDictionary *dictSurveyAnswer = [self wrapSurveyAnswerData];
        NSLog(@"____________%@",dictSurveyAnswer);
        
        // save
        [self saveCustomSurveyAnswer:dictSurveyAnswer];
        
        // survey is done, got to mainView
        // sync info with server later (when app is opend as well as before version)
        [self switchToMainViewController];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    // called when back to previous page by navigatoin btn
    if (![self.navigationController.viewControllers containsObject:self]) {
        
        // for multiple routes
        // if location_study question page
        if ([self.strID isEqualToString:@"106"]) {
            // skip woker questions, if only student
            if (!self.usDataManager.isWorker&&self.usDataManager.isStudent) {
                for (int i=0; i<3; i++) {
                    self.usDataManager.customSurveyIndex--;
                }
            }
        }
        // if the next page from travel_mode_alt_studey page, gender
        if ([self.strID isEqualToString:@"100"]) {
            // skip stundent questions, if only worker
            if (self.usDataManager.isWorker&&!self.usDataManager.isStudent) {
                for (int i=0; i<3; i++) {
                    self.usDataManager.customSurveyIndex--;
                }
            }
            // skip worker and student questions, if not worker nor student
            if (!self.usDataManager.isWorker&&!self.usDataManager.isStudent) {
                for (int i=0; i<6; i++) {
                    self.usDataManager.customSurveyIndex--;
                }
            }
        }
        
        self.usDataManager.customSurveyIndex--;
        if (self.usDataManager.customSurveyIndex<=0) {
            self.usDataManager.customSurveyIndex = 0;
        }
    }
}


#pragma mark - load surveyData, make surveyAnswer

- (NSDictionary*)loadSurvey
{
    NSDictionary* dictResults = [[[CoreDataHelper instance] entityManager] fetchCustomSurveyData];
    NSDictionary* dictSurveies = [dictResults objectForKey:@"results"];
    self.strLang = [dictSurveies objectForKey:@"lang"];
    NSArray *array = [dictSurveies objectForKey:@"survey"];
    
    // remove page_break section
    NSMutableArray *mArray = [[NSMutableArray alloc] init];
    int count = 0;
    for (int i=0; i<array.count; i++) {
        NSDictionary *dict = array[i];
        if (![[NSString stringWithFormat:@"%@",[dict objectForKey:@"id"]] isEqualToString:@"99" ]) {
            // put only section which is not page_break
            [mArray insertObject:dict atIndex:count];
            count++;
        }
    }
    
    self.arrayAllSurveies = mArray;
    NSDictionary* dictSurvey = self.arrayAllSurveies[self.usDataManager.customSurveyIndex];
    self.strID = [NSString stringWithFormat:@"%@",[dictSurvey objectForKey:@"id"]];
    
    // if mandatory type
    // load questions from config.plist
    if ([self.strID intValue]>=100) {
        NSDictionary *dictLang = [[Config instance] dictionaryValueForKey:@"dmapiMandatoryQuestions"];
        NSDictionary *dictID = [dictLang objectForKey:self.strLang];
        self.dictMandatoryQuestions = [dictID objectForKey:self.strID];
    }
    
    return dictSurvey;
}

- (NSString*)chooseFiledType:(NSDictionary*)dict
{
    NSString *stIDType = [NSString stringWithFormat:@"%@",[dict objectForKey:@"id"]];
    NSDictionary *surveyFieldsByID = [[Config instance] dictionaryValueForKey:@"dmapiSurveyFieldsByID"];
    NSString *strFieldsType = [surveyFieldsByID objectForKey:stIDType];
    
    return strFieldsType;
}

- (NSDictionary *)wrapSurveyAnswerData
{
    // create surveyAnswer object
    NSMutableDictionary *surveyAnswerData = [[NSMutableDictionary alloc] init];
    
    for (int i=0; i<self.arrayAllSurveies.count; i++) {
        NSDictionary* dictSurvey = self.arrayAllSurveies[i];
        NSString* strKey = [dictSurvey objectForKey:@"colName"];
        NSString* strIDType = [dictSurvey objectForKey:@"id"];
        
        // for multiple routes
        // skip not appropriate answer
        BOOL isSkipAnswer = NO;
        // if only worker
        if (self.usDataManager.isWorker&&!self.usDataManager.isStudent) {
            if ([strKey isEqualToString:@"location_study"]||[strKey isEqualToString:@"travel_mode_study"]||[strKey isEqualToString:@"travel_mode_alt_study"]) {
                isSkipAnswer = YES;
            }
        }
        // if only student
        else if (!self.usDataManager.isWorker&&self.usDataManager.isStudent) {
            if ([strKey isEqualToString:@"location_work"]||[strKey isEqualToString:@"travel_mode_work"]||[strKey isEqualToString:@"travel_mode_alt_work"]) {
                isSkipAnswer = YES;
            }
        }
        // if not worker nor student
        else if (!self.usDataManager.isWorker&&!self.usDataManager.isStudent) {
            if ([strKey isEqualToString:@"location_study"]||[strKey isEqualToString:@"travel_mode_study"]||[strKey isEqualToString:@"travel_mode_alt_study"]||[strKey isEqualToString:@"location_work"]||[strKey isEqualToString:@"travel_mode_work"]||[strKey isEqualToString:@"travel_mode_alt_work"]) {
                isSkipAnswer = YES;
            }
        }
        
        if (!isSkipAnswer) {
            NSArray* arrayAnswer = self.usDataManager.arrayAnswers[i];
            
            // choose survey field type by id
            NSString *strFieldsType = [self chooseFiledType:dictSurvey];
            NSString* strAnswer = @"";
            NSMutableArray *mArray = [NSMutableArray array];
            NSMutableDictionary *mDict = [NSMutableDictionary dictionary];
            
            if ([strFieldsType isEqualToString:@"choice"]||[strFieldsType isEqualToString:@"choice_memberType"]) {
                // if field type, choices - tableView
                // choose correct answer by strAnswer(number)
                NSMutableArray* arrayChoices = [NSMutableArray array];
                // if mandatory type
                if ([strIDType intValue]>=100) {
//                    NSDictionary *dictLang = [[Config instance] dictionaryValueForKey:@"dmapiMandatoryQuestions"];
//                    NSDictionary *dictID = [dictLang objectForKey:self.strLang];
//                    NSDictionary *dictContents = [dictID objectForKey:[NSString stringWithFormat:@"%d", [strIDType intValue]]];  // not sure, it seems we need to convert to int first, then reconvert to string
//                    arrayChoices = [dictContents objectForKey:@"choices"];
                    
                    // use as interger for mandatory(hardcoded) answers
                    strAnswer = arrayAnswer[0];
                }else{
                    // if not mandatory
                    NSDictionary* dictFields = [dictSurvey objectForKey:@"fields"];
                    arrayChoices = [dictFields objectForKey:@"choices"];
                    
                    strAnswer = arrayChoices[[arrayAnswer[0] intValue]];
                }
            }
            else if ([strFieldsType isEqualToString:@"choices"]) {
                // if field type, choices - tableView - dropDown, multipleAnswers
                // choose correct answer by strAnswer(number)
                NSMutableArray* arrayChoices = [NSMutableArray array];
                NSDictionary* dictFields = [dictSurvey objectForKey:@"fields"];
                arrayChoices = [dictFields objectForKey:@"choices"];
                
                for (int i=0; i<arrayAnswer.count; i++) {
                    [mArray insertObject:arrayChoices[[arrayAnswer[i] intValue]] atIndex:i];
                }
            }
            else if ([strFieldsType isEqualToString:@"location"]) {
                // if location
                CLLocation *location = arrayAnswer[0];
//                strAnswer = [NSString stringWithFormat:@"%0.6f, %0.6f", location.coordinate.latitude, location.coordinate.longitude];
                [mDict setObject:[NSString stringWithFormat:@"%0.6f", location.coordinate.latitude] forKey:@"latitude"];
                [mDict setObject:[NSString stringWithFormat:@"%0.6f", location.coordinate.longitude] forKey:@"longitude"];
            } else {
                strAnswer = arrayAnswer[0];
            }
            
            // set answer into dict
            if ([mArray count]>0) {
                [surveyAnswerData setObject:mArray forKey:strKey];
            }
            else if ([mDict count]>0) {
                [surveyAnswerData setObject:mDict forKey:strKey];
            }else{
                [surveyAnswerData setObject:strAnswer forKey:strKey];
            }
        }
    }
    
    return surveyAnswerData;
}


#pragma mark - delegate from children

- (void)surveyAnswered:(NSArray*)arrayAnswer
{
    if (!self.isNotFirstTime) {
        // if this is first time, set answer into array
        [self.usDataManager.arrayAnswers insertObject:arrayAnswer atIndex:self.usDataManager.customSurveyIndex];
    }else{
        // if this is not first time, replace answer with new
        [self.usDataManager.arrayAnswers replaceObjectAtIndex:self.usDataManager.customSurveyIndex withObject:arrayAnswer];
    }
    
    // set button enabled
    self.btnNext.enabled = YES;
    self.isNotFirstTime = YES;
}

// delegate from DMCSTableView
// memberType - for multiple routes
- (void)memberTypeSelected:(NSInteger)indexRow
{
    NSArray* arrayChoices = [self.dictMandatoryQuestions objectForKey:@"choices"];
    NSString* strMemberType = arrayChoices[indexRow];
    
    // search word
    if ([self.strLang isEqualToString:@"en"]) {
        NSRange searchResult = [strMemberType rangeOfString:@"Worker" options:NSCaseInsensitiveSearch];
        if(searchResult.location == NSNotFound){
            self.usDataManager.isWorker = NO;
        }else{
            self.usDataManager.isWorker = YES;
        }
        searchResult = [strMemberType rangeOfString:@"Student" options:NSCaseInsensitiveSearch];
        if(searchResult.location == NSNotFound){
            self.usDataManager.isStudent = NO;
        }else{
            self.usDataManager.isStudent = YES;
        }
    }
    else if ([self.strLang isEqualToString:@"fr"]) {
        NSRange searchResult = [strMemberType rangeOfString:@"Travailleur" options:NSCaseInsensitiveSearch];
        if(searchResult.location == NSNotFound){
            self.usDataManager.isWorker = NO;
        }else{
            self.usDataManager.isWorker = YES;
        }
        searchResult = [strMemberType rangeOfString:@"Étudiant" options:NSCaseInsensitiveSearch];
        if(searchResult.location == NSNotFound){
            self.usDataManager.isStudent = NO;
        }else{
            self.usDataManager.isStudent = YES;
        }
    }
}

// delegate from DMCSTableView
- (void)cellSelected:(NSArray*)arrayAnswer
{
    [self surveyAnswered:arrayAnswer];
}

// delegate from DMCSLocationView
- (void)locationEntered:(NSArray*)arrayAnswer
{
    [self surveyAnswered:arrayAnswer];
}

// delegate from DMCSEmailView
- (void)emailEntered:(NSArray*)arrayAnswer
{
    if (arrayAnswer) {
        [self surveyAnswered:arrayAnswer];
    }else{
        // set button disabled if email is not invalid
        self.btnNext.enabled = NO;
    }
}

// delegate from DMCSNumberView
- (void)numberEntered:(NSArray*)arrayAnswer
{
    [self surveyAnswered:arrayAnswer];
}

// delegate from DMCSTextView
- (void)textEntered:(NSArray*)arrayAnswer
{
    [self surveyAnswered:arrayAnswer];
}


#pragma mark - save answer

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

- (void)saveCustomSurveyAnswer:(NSDictionary *)dictSurveyAnswer {
    CoreDataHelper *helper = [CoreDataHelper instance];
    [helper.entityManager updateUserSurveyForCustomSurvey:dictSurveyAnswer];
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
