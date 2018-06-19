//
//  DMMMTableViewController.m
//  Itinerum
//
//  Created by Takeshi MUKAI on 5/23/17.
//  Copyright (c) 2017 MML-Concordia. All rights reserved.
//

#import "DMMMTableViewController.h"

@interface DMMMTableViewController ()

@property (nonatomic, retain) NSMutableArray *mArray;

@property (nonatomic) NSInteger checkedIndex;  // for scroll issue
@end

@implementation DMMMTableViewController
@synthesize delegate;
@synthesize arrayChoices, isMultipleChoices, arrayAnswer;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    arrayAnswer = [NSMutableArray array];
    
    self.tableView.estimatedRowHeight = 64 ;
    self.tableView.rowHeight = UITableViewAutomaticDimension ;
    
    
    [self refreshView];
}

- (void)refreshView
{
    // flash scrollbar once when page is reloaded
    [self.tableView flashScrollIndicators];
    
    [self.tableView reloadData];
    
    // for multipleChoices
    if (isMultipleChoices) {
        // multipleChoices mode
        self.tableView.allowsMultipleSelectionDuringEditing = YES;
        [self.tableView setEditing:YES animated:YES];
    }else{
        // if single choice
        self.tableView.allowsMultipleSelectionDuringEditing = NO;
        [self.tableView setEditing:NO animated:YES];
        [self resetCell];
        self.checkedIndex = -1;  // for scroll issue
    }
    self.mArray = [NSMutableArray array];
    
    // if has been answered already - for back and forth
    // set data from the last time
    if (arrayAnswer.count>0) {
        if (!isMultipleChoices) {
            [self checkSelectedCellWith:[arrayAnswer[0] integerValue] and:0];
        }else{
            self.mArray = [arrayAnswer mutableCopy];
            for (int i=0; i<self.mArray.count; i++) {
                // set the cell seleceted from code
                [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:[arrayAnswer[i] integerValue] inSection:0] animated:YES scrollPosition:0];
            }
        }
    }
    [arrayAnswer removeAllObjects];
}

- (void)resetCell {
    // uncheck deselectedCell
    for (NSInteger index=0; index<[self.tableView numberOfRowsInSection:0]; index++) {
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
        // uncheck all
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.indentationLevel = 0;  // keep textAlignCenter
    }
}

- (void)checkSelectedCellWith:(NSInteger)indexRow and:(NSInteger)indexSection {
    
    [self.tableView reloadData];
    
    // check selectedCell and uncheck deselectedCell
    for (NSInteger index=0; index<[self.tableView numberOfRowsInSection:indexSection]; index++) {
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:indexSection]];
        // uncheck all first
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.indentationLevel = 0;  // keep textAlignCenter
        
        // check selected index
        if (indexRow == index) {
            
            self.checkedIndex = index;  // for scroll issue
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            cell.indentationLevel = 4;  // keep textAlignCenter
            // set answer to array
            NSArray *array = [NSArray arrayWithObjects:[NSString stringWithFormat:@"%ld", (long)indexRow], nil];
            // delegate to DMMMRootView
            [delegate cellSelected:array];
        }
    }
}

- (void)checkMultipleSelectedCellWith:(NSInteger)indexRow and:(NSInteger)indexSection {
    for (NSInteger index=0; index<[self.tableView numberOfRowsInSection:indexSection]; index++) {
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:indexSection]];
        
        // check selected index
        if (indexRow == index) {
            if (cell.selected) {
                // add it to mArray
                [self.mArray addObject:[NSString stringWithFormat:@"%ld", (long)indexRow]];
                // delegate to DMMMRootView
                [delegate cellSelected:self.mArray];
            }else if(self.mArray.count>1) {
                // remove it from mArray
                [self.mArray removeObject:[NSString stringWithFormat:@"%ld", (long)indexRow]];
                // delegate to DMMMRootView
                [delegate cellSelected:self.mArray];
            }else{
                // if selected cell is ony one, keep it selected
                // set the cell seleceted from code
                [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:indexRow inSection:0] animated:YES scrollPosition:0];
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
    cell.textLabel.font = [UIFont fontWithName:@"AvenirNext-Medium" size:18];
    // asjust fontsize auto
    cell.textLabel.adjustsFontSizeToFitWidth = YES;
    cell.textLabel.textColor = [UIColor colorWithRed:53.0/255.0 green:112.0/255.0 blue:251.0/255.0 alpha:1.0];
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    cell.textLabel.numberOfLines = 0;
    
    // set cell's text
    cell.textLabel.text = [NSString stringWithFormat:@"%@", self.arrayChoices[indexPath.row]];
    
    // make cell's background clear
    cell.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:0.5];
    tableView.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:0.5];
    
    // for scroll issue
    if (!isMultipleChoices){
        // uncheck all
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.indentationLevel = 0;  // keep textAlignCenter
        if (indexPath.row==self.checkedIndex) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            cell.indentationLevel = 4;  // keep textAlignCenter
        }
    }
    
    return cell;
}

// set header text
//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
//    
//    return @"headerTitle";
//}

// set cell's height
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    return 64;
    return UITableViewAutomaticDimension;  // for long text
}

// do not indent in editing mode - for isMultipleChoices, keep textAlignCenter
- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
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
    
    if (!isMultipleChoices) {
        [self checkSelectedCellWith:indexPath.row and:indexPath.section];
    }else{
        [self checkMultipleSelectedCellWith:indexPath.row and:indexPath.section];
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (isMultipleChoices) {
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
