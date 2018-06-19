//
//  DMCSTableViewController.m
//  DataMobile
//
//  Created by Takeshi MUKAI on 8/22/16.
//  Copyright (c) 2016 MML-Concordia. All rights reserved.
//

#import "DMCSTableViewController.h"
#import "Config.h"

@interface DMCSTableViewController ()

@property (nonatomic, retain) NSString *strPrompt;
@property (nonatomic, retain) NSArray *arrayChoices;
@property (nonatomic) BOOL isMultipleChoices;
@property (weak, nonatomic) IBOutlet UITableView *_tableView;
@property (nonatomic, retain) NSMutableArray *mArray;
@property (nonatomic) BOOL isMemberType;

@end

@implementation DMCSTableViewController
@synthesize delegate, dictSurvey, arrayAnswer, strFieldsType, dictMandatoryQuestions;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    
    // set value by strFieldsType
    if ([strFieldsType isEqualToString:@"choices"]) {
        // multipleChoices mode
        self._tableView.allowsMultipleSelectionDuringEditing = YES;
        [self._tableView setEditing:YES animated:YES];
        self.isMultipleChoices = YES;
    }
    // for multipleChoices
    self.mArray = [NSMutableArray array];
    
    
    // memberType - for multiple routes
    if ([strFieldsType isEqualToString:@"choice_memberType"]) {
        self.isMemberType = YES;
    }
    
    // get header text
    // if mandatory type
    if (self.dictMandatoryQuestions[@"prompt"]) {
        self.strPrompt = [NSString stringWithFormat:@"%@", [self.dictMandatoryQuestions objectForKey:@"prompt"]];
    }else{
        // if not mandatory type
        self.strPrompt = [NSString stringWithFormat:@"%@", [dictSurvey objectForKey:@"prompt"]];
    }
    // get cell's contents
    // if mandatory type
    if (self.dictMandatoryQuestions[@"choices"]) {
        self.arrayChoices = [self.dictMandatoryQuestions objectForKey:@"choices"];
    }else{
        // if not mandatory type
        NSDictionary* dictFields = [dictSurvey objectForKey:@"fields"];
        self.arrayChoices = [dictFields objectForKey:@"choices"];
    }
    
    // if survey has been answered already - for back and forth
    // set data from the last time
    if (arrayAnswer.count>0) {
        if (!self.isMultipleChoices) {
            [self checkSelectedCellWith:[arrayAnswer[0] integerValue] and:0];
        }else{
            self.mArray = [arrayAnswer mutableCopy];
            for (int i=0; i<self.mArray.count; i++) {
                // set the cell seleceted from code
                [self._tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:[arrayAnswer[i] integerValue] inSection:0] animated:YES scrollPosition:0];
            }
        }
    }
    
    // set Height Dynamic
    self.tableView.estimatedRowHeight = 44 ;
    self.tableView.rowHeight = UITableViewAutomaticDimension ;
    
}

- (void)checkSelectedCellWith:(NSInteger)indexRow and:(NSInteger)indexSection {
    
    [self._tableView reloadData];
    
    // check selectedCell and uncheck deselectedCell
    for (NSInteger index=0; index<[self._tableView numberOfRowsInSection:indexSection]; index++) {
        UITableViewCell *cell = [self._tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:indexSection]];
        // uncheck all first
        cell.accessoryType = UITableViewCellAccessoryNone;
        
        // check selected index
        if (indexRow == index) {
            // memberType - for multiple routes
            if (self.isMemberType){
                // delegate to DMCustomSurveyRootView
                [delegate memberTypeSelected:indexRow];
            }
            
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            // set answer to array
            NSArray *array = [NSArray arrayWithObjects:[NSString stringWithFormat:@"%ld", (long)indexRow], nil];
            // delegate to DMCustomSurveyRootView
            [delegate cellSelected:array];
        }
    }
}

- (void)checkMultipleSelectedCellWith:(NSInteger)indexRow and:(NSInteger)indexSection {
    for (NSInteger index=0; index<[self._tableView numberOfRowsInSection:indexSection]; index++) {
        UITableViewCell *cell = [self._tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:indexSection]];
        
        // check selected index
        if (indexRow == index) {
            if (cell.selected) {
                // add it to mArray
                [self.mArray addObject:[NSString stringWithFormat:@"%ld", (long)indexRow]];
                // delegate to DMCustomSurveyRootView
                [delegate cellSelected:self.mArray];
            }else if(self.mArray.count>1) {
                // remove it from mArray
                [self.mArray removeObject:[NSString stringWithFormat:@"%ld", (long)indexRow]];
                // delegate to DMCustomSurveyRootView
                [delegate cellSelected:self.mArray];
            }else{
                // if selected cell is ony one, keep it selected
                // set the cell seleceted from code
                [self._tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:indexRow inSection:0] animated:YES scrollPosition:0];
            }
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return self.arrayChoices.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // change font and color in cell
    cell.textLabel.font = [UIFont fontWithName:@"AvenirNext-Medium" size:16];
    // asjust fontsize auto
    cell.textLabel.adjustsFontSizeToFitWidth = YES;
    cell.textLabel.textColor = [UIColor darkGrayColor];
    cell.textLabel.numberOfLines = 0 ;
    cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping ;
    // set cell's text
    cell.textLabel.text = [NSString stringWithFormat:@"%@", self.arrayChoices[indexPath.row]];
    
    // change selected cell's backgoundColor
    UIView *view = [[UIView alloc] initWithFrame:cell.frame];
    view.backgroundColor = [UIColor clearColor];
    cell.selectedBackgroundView = view;

    return cell;
}

// set header text
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    return self.strPrompt;
}

// set cell's height // set Height Dynamic
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewAutomaticDimension;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here, for example:
    // Create the next view controller.
//    <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:<#@"Nib name"#> bundle:nil];
    
    // Pass the selected object to the new view controller.
    
    // Push the view controller.
//    [self.navigationController pushViewController:detailViewController animated:YES];
    
    if (!self.isMultipleChoices) {
        [self checkSelectedCellWith:indexPath.row and:indexPath.section];
    }else{
        [self checkMultipleSelectedCellWith:indexPath.row and:indexPath.section];
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.isMultipleChoices) {
        [self checkMultipleSelectedCellWith:indexPath.row and:indexPath.section];
    }
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
