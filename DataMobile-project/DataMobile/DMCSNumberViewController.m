//
//  DMCSNumberViewController.m
//  DataMobile
//
//  Created by Takeshi MUKAI on 11/17/16.
//  Copyright (c) 2016 MML-Concordia. All rights reserved.
//

#import "DMCSNumberViewController.h"

@interface DMCSNumberViewController ()

@property (nonatomic, retain) NSString *strPrompt;
@property (weak, nonatomic) IBOutlet UILabel *label;
@property (weak, nonatomic) IBOutlet UIStepper *stepper;

@end

@implementation DMCSNumberViewController
@synthesize delegate, dictSurvey, arrayAnswer;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // get header text
    self.strPrompt = [NSString stringWithFormat:@"%@", [dictSurvey objectForKey:@"prompt"]];
    
    // if survey has been answered already - for back and forth
    // set data from the last time
    if (arrayAnswer.count>0) {
        self.label.text = [NSString stringWithFormat:@"%@", arrayAnswer[0]];
        self.stepper.value = [self.label.text intValue];
        self.label.textColor = [UIColor colorWithRed:53.0/255.0 green:112.0/255.0 blue:251.0/255.0 alpha:1.0];
    }
}

- (IBAction)valueChanged:(UIStepper *)sender {
    self.label.textColor = [UIColor colorWithRed:53.0/255.0 green:112.0/255.0 blue:251.0/255.0 alpha:1.0];
    self.label.text = [NSString stringWithFormat:@"%d", (int)[sender value]];
    // set answer to array
    NSArray *array = [NSArray arrayWithObjects:self.label.text, nil];
    [delegate numberEntered:array];
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
