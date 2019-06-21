//
//  DMCSEmailViewController.m
//  DataMobile
//
//  Created by Takeshi MUKAI on 11/16/16.
//  Copyright (c) 2016 MML-Concordia. All rights reserved.
//

#import "DMCSEmailViewController.h"

@interface DMCSEmailViewController ()

@property (nonatomic, retain) NSString *strPrompt;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UILabel *labelEmail;

@end

@implementation DMCSEmailViewController
@synthesize delegate, dictSurvey, arrayAnswer, dictMandatoryQuestions, strLang;

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
    
    // change text, if French
    if ([strLang isEqualToString:@"fr"]) {
        self.labelEmail.text = @"Courriel";
    }
    
    // get header text
    // if mandatory type
    if (self.dictMandatoryQuestions[@"prompt"]) {
        self.strPrompt = [NSString stringWithFormat:@"%@", [self.dictMandatoryQuestions objectForKey:@"prompt"]];
    }else{
        // if not mandatory type
        self.strPrompt = [NSString stringWithFormat:@"%@", [dictSurvey objectForKey:@"prompt"]];
    }
    
    // if survey has been answered already - for back and forth
    // set data from the last time
    if (arrayAnswer.count>0) {
        self.textField.text = [NSString stringWithFormat:@"%@", arrayAnswer[0]];
    }
}

// check provided email is vaild format or not
- (BOOL)isValidateEmail:(NSString *)email
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES%@",emailRegex];
    return [emailTest evaluateWithObject:email];
}

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
    BOOL isValidateFomrat = [self isValidateEmail:textField.text];
    if (isValidateFomrat) {
        // set answer to array
        NSArray *array = [NSArray arrayWithObjects:textField.text, nil];
        [delegate emailEntered:array];
    } else {
        [delegate emailEntered:nil];
    }
}

// hide keyboard when other area is tapped
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

// notification - keyboardWillShow
- (void)keyboardWillShow:(NSNotification *)notification
{
//    // move self.view to up
//    [UIView beginAnimations:nil context:nil];
//    //    UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
//    [UIView setAnimationDuration:0.3];
//    //    [UIView setAnimationDelay:0.2];
//    self.view.frame = CGRectMake(self.view.frame.origin.x, -88*(self.view.frame.size.width/320.0), self.view.frame.size.width, self.view.frame.size.height);
//    [UIView commitAnimations];
}

// notification - keyboardWillHide
- (void)keyboardWillHide:(NSNotification *)notification
{
//    // move self.view to origin
//    [UIView beginAnimations:nil context:nil];
//    //    UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
//    [UIView setAnimationDuration:0.3];
//    //    [UIView setAnimationDelay:0.2];
//    self.view.frame = CGRectMake(self.view.frame.origin.x,  0, self.view.frame.size.width, self.view.frame.size.height);
//    [UIView commitAnimations];
}

// set header text
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    return self.strPrompt;
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
