//
//  ACYardSaleCreateViewController.m
//  YardSales
//
//  Created by Christopher Loonam on 8/6/15.
//
//

#import "ACYardSaleCreateViewController.h"
#import "ACYardSale.h"
#import "ACRequest.h"

#define PICKER_HEIGHT 200.0

@implementation ACYardSaleCreateViewController
{
    NSIndexPath *selectedIndexPath;
    UIToolbar *inputAccessory;
}

- (instancetype)init
{
    if (self = [super initWithStyle:UITableViewStyleGrouped])
    {
        self.tableViewItems = @[
                                @{@"name" : @"Address", @"type" : @"textfield", @"keyboard" : @(UIKeyboardTypeASCIICapable)},
                                @{@"name" : @"State", @"type" : @"textfield", @"keyboard" : @(UIKeyboardTypeASCIICapable)},
                                @{@"name" : @"Town", @"type" : @"textfield", @"keyboard" : @(UIKeyboardTypeASCIICapable)},
                                @{@"name" : @"Zip Code", @"type" : @"textfield", @"keyboard" : @(UIKeyboardTypeDecimalPad)},
                                @{@"name" : @"Opens", @"type" : @"date"},
                                @{@"name" : @"Closes", @"type" : @"date"},
                                @{@"name" : @"Comments", @"type" : @"textfield", @"keyboard" : @(UIKeyboardTypeASCIICapable)}
                                ];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(dismissController)];
    UIBarButtonItem *submitButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(submitYardSale)];
    self.navigationItem.leftBarButtonItem = cancelButton;
    self.navigationItem.rightBarButtonItem = submitButton;
    
    CGFloat viewHeight = self.view.frame.size.height;
    CGFloat viewWidth = self.view.frame.size.width;
    
    self.datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, viewHeight - PICKER_HEIGHT, viewWidth, PICKER_HEIGHT)];
    self.datePicker.datePickerMode = UIDatePickerModeDateAndTime;
    self.datePicker.date = [NSDate date];
    
    inputAccessory = [[UIToolbar alloc] initWithFrame:CGRectMake(0, viewHeight - PICKER_HEIGHT - 44.0, viewWidth, 44.0)];
    UIBarButtonItem *flex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *done  = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismissPickerView)];
    inputAccessory.items = @[flex, done];
    self.datePicker.hidden = YES;
    inputAccessory.hidden = YES;
    [self.view addSubview:inputAccessory];
    
    [self.datePicker addTarget:self action:@selector(pickerValueChanged) forControlEvents:UIControlEventValueChanged];
    
    [self.view addSubview:self.datePicker];
}

- (void)pickerValueChanged
{
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:selectedIndexPath];
    
    NSDate *pickerValueDate = [self.datePicker date];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"hh:mm a MM/dd/yyyy"];
    cell.detailTextLabel.text = [dateFormatter stringFromDate:pickerValueDate];

}

- (void)dismissPickerView
{
    inputAccessory.hidden = YES;
    self.datePicker.hidden = YES;
}

- (void)submitYardSale
{
    ACYardSale *yardSale = [[ACYardSale alloc] init];
    
    CFStringRef address = NULL, state = NULL, town = NULL, comments = NULL;
    ZipCode zipCode = 0.0;
    CFDateRef openDate = NULL, closeDate = NULL;
    
    for (int i = 0; i < self.tableViewItems.count; i++)
    {
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        NSString *cellTitle = cell.textLabel.text;
        
        if ([cellTitle isEqualToString:@"Address"])
            address = (__bridge CFStringRef)[(UITextField *)[cell viewWithTag:3] text];
        else if ([cellTitle isEqualToString:@"State"])
            state = (__bridge CFStringRef)[(UITextField *)[cell viewWithTag:3] text];
        else if ([cellTitle isEqualToString:@"Town"])
            town = (__bridge CFStringRef)[(UITextField *)[cell viewWithTag:3] text];
        else if ([cellTitle isEqualToString:@"Comments"])
            comments = (__bridge CFStringRef)[(UITextField *)[cell viewWithTag:3] text];
        else if ([cellTitle isEqualToString:@"Zip Code"])
            zipCode = [[(UITextField *)[cell viewWithTag:3] text] doubleValue];
        else if ([cellTitle isEqualToString:@"Opens"])
        {
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"hh:mm a MM/dd/yyyy"];
            
            NSDate *opens = [dateFormatter dateFromString:cell.detailTextLabel.text];
            openDate = (__bridge CFDateRef)opens;
        }
        else if ([cellTitle isEqualToString:@"Closes"])
        {
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"hh:mm a MM/dd/yyyy"];
            
            NSDate *closes = [dateFormatter dateFromString:cell.detailTextLabel.text];
            closeDate = (__bridge CFDateRef)closes;
        }
    }
    
    yardSale.comments = (__bridge NSString *)comments;
    yardSale.hours = hoursCreate(openDate, closeDate);
    yardSale.location = locationCreate(state, town, zipCode, address);
    
    [ACRequest uploadYardSale:yardSale error:nil];
    [self dismissController];
}

- (void)dismissController
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.tableViewItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellID];
    
    cell.textLabel.text = self.tableViewItems[indexPath.row][@"name"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    NSString *cellType = self.tableViewItems[indexPath.row][@"type"];
    
    if ([cellType isEqualToString:@"textfield"])
    {
        UIKeyboardType keyboardType = [self.tableViewItems[indexPath.row][@"keyboard"] integerValue];
        
        cell.detailTextLabel.hidden = YES;
        [[cell viewWithTag:3] removeFromSuperview];
        UITextField *textField = [[UITextField alloc] init];
        textField.tag = 3;
        textField.keyboardType = keyboardType;
        textField.translatesAutoresizingMaskIntoConstraints = NO;
        [cell.contentView addSubview:textField];
        [cell addConstraint:[NSLayoutConstraint constraintWithItem:textField attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:cell.textLabel attribute:NSLayoutAttributeTrailing multiplier:1 constant:8]];
        [cell addConstraint:[NSLayoutConstraint constraintWithItem:textField attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:cell.contentView attribute:NSLayoutAttributeTop multiplier:1 constant:8]];
        [cell addConstraint:[NSLayoutConstraint constraintWithItem:textField attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:cell.contentView attribute:NSLayoutAttributeBottom multiplier:1 constant:-8]];
        [cell addConstraint:[NSLayoutConstraint constraintWithItem:textField attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:cell.contentView attribute:NSLayoutAttributeTrailing multiplier:1 constant:-16]];
        textField.textAlignment = NSTextAlignmentRight;
        
        [textField addTarget:textField action:@selector(resignFirstResponder) forControlEvents:UIControlEventEditingDidEndOnExit];
    }
    else if ([cellType isEqualToString:@"date"])
    {
        NSDate *currentDate = [NSDate date];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"hh:mm a MM/dd/yyyy"];
        cell.detailTextLabel.text = [dateFormatter stringFromDate:currentDate];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellType = self.tableViewItems[indexPath.row][@"type"];

    if ([cellType isEqualToString:@"date"])
    {
        inputAccessory.hidden = NO;
        self.datePicker.hidden = NO;
        selectedIndexPath = indexPath;
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"hh:mm a MM/dd/yyyy"];
        
        NSString *dateString = [tableView cellForRowAtIndexPath:indexPath].detailTextLabel.text;
        self.datePicker.date = [dateFormatter dateFromString:dateString];
    }
}

@end
