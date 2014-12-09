//
//  SelectableListTableViewController.m
//  Developer meeting system
//
//  Created by Ste Prescott on 08/12/2014.
//  Copyright (c) 2014 Ste Prescott. All rights reserved.
//

#import "SelectableListTableViewController.h"

static NSString *cellIdentifier = @"selectableCell";

@interface SelectableListTableViewController ()

@end

@implementation SelectableListTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)setItems:(NSArray *)items
{
    _items = items;
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    id item = self.items[indexPath.row];
    cell.textLabel.text = [item valueForKey:self.itemTextProperty];
    
    if([self.selectedItem valueForKey:self.itemTextProperty] == [item valueForKey:self.itemTextProperty])
    {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        cell.backgroundColor = [UIColor colorWithRed:0.843 green:0.937 blue:0.988 alpha:1];
    }
    else
    {
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.backgroundColor = [UIColor whiteColor];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    cell.backgroundColor = [UIColor colorWithRed:0.843 green:0.937 blue:0.988 alpha:1];
    
    if(self.didSelectItemBlock)
    {
        id item = self.items[indexPath.row];
        
        self.didSelectItemBlock(item, indexPath.row);
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

@end
