//
//  DMCSTextViewController.m
//  DataMobile
//
//  Created by Takeshi MUKAI on 11/17/16.
//  Copyright (c) 2016 MML-Concordia. All rights reserved.
//

#import "DMCSTextViewController.h"

@interface DMCSTextViewController ()

@property (nonatomic, retain) NSString *strPrompt;
@property (weak, nonatomic) IBOutlet UITextView *textView;

@end

@implementation DMCSTextViewController
@synthesize delegate, dictSurvey, arrayAnswer, strFieldsType;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // set notification for keybord shown/hidden
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    
    // customize textView and keyboard
    [self customizeTextViewAndKeyboard];
    
    
    // get header text
    self.strPrompt = [NSString stringWithFormat:@"%@", [dictSurvey objectForKey:@"prompt"]];
    
    // if survey has been answered already - for back and forth
    // set data from the last time
    if (arrayAnswer.count>0) {
        self.textView.text = [NSString stringWithFormat:@"%@", arrayAnswer[0]];
    }
    
    // set view by strFieldsType
    if ([strFieldsType isEqualToString:@"text_box"]) {
        self.textView.editable = YES;
        self.textView.textColor = [UIColor colorWithRed:53.0/255.0 green:112.0/255.0 blue:251.0/255.0 alpha:1.0];
    }
    else if ([strFieldsType isEqualToString:@"text_description"]) {
        self.textView.editable = NO;
        self.textView.textColor = [UIColor darkGrayColor];
        
        // get cell's contents
        NSDictionary* dictFields = [dictSurvey objectForKey:@"fields"];
        NSString *str = [NSString stringWithFormat:@"%@", [dictFields objectForKey:@"choices"]];
        // trim to make appropriate text
        self.textView.text = [str substringWithRange:NSMakeRange(7, ([str length]-10))];
        
        // enable btn because this is non editable
        // set answer to array
        NSArray *array = [[NSArray alloc]init];
        [delegate textEntered:array];
    }
    
    // enable scroll later, to fix display problem
    self.textView.scrollEnabled = YES;
}

// customize textView and keyboard
- (void)customizeTextViewAndKeyboard
{
    // customize textView
    self.textView.clipsToBounds = YES;
    self.textView.layer.cornerRadius = 8.0f;
    
    // customize doneBtn in keyboard
    UIToolbar* keyboardDoneButtonView = [[UIToolbar alloc] init];
    keyboardDoneButtonView.barStyle  = UIBarStyleDefault;
    keyboardDoneButtonView.translucent = YES;
    keyboardDoneButtonView.tintColor = [UIColor colorWithRed:53.0/255.0 green:112.0/255.0 blue:251.0/255.0 alpha:1.0];
    [keyboardDoneButtonView sizeToFit];
    
    // set doneBtn
    UIBarButtonItem* doneButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Done", @"") style:UIBarButtonItemStyleDone target:self action:@selector(doneBtnClicked)];
    UIBarButtonItem *spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    [keyboardDoneButtonView setItems:[NSArray arrayWithObjects:spacer, doneButton, nil]];
    
    // place textView
    self.textView.inputAccessoryView = keyboardDoneButtonView;
}

// beginEditing - clear placeHolder
- (void)textViewDidBeginEditing:(UITextView *)textView
{
    // show keyboard
    [textView becomeFirstResponder];
}

// endEditing - restore placeHolder if empty
- (void)textViewDidEndEditing:(UITextView *)textView
{
    // hide keyboard
    [textView resignFirstResponder];
}

- (void)doneBtnClicked
{
    // hide keyboard
    [self.textView resignFirstResponder];
    
    // set answer to array
    NSArray *array = [NSArray arrayWithObjects:self.textView.text, nil];
    [delegate textEntered:array];
}

// hide keyboard when other area is tapped
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
//    [self.view endEditing:YES];
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

// set cell's height
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int height = 168;
    if ([strFieldsType isEqualToString:@"text_description"]) {
        height = height*2;
    }
    return height;
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
