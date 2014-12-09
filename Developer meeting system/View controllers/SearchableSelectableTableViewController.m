//
//  SearchableSelectableTableViewController.m
//  Developer meeting system
//
//  Created by Ste Prescott on 09/12/2014.
//  Copyright (c) 2014 Ste Prescott. All rights reserved.
//

#import "SearchableSelectableTableViewController.h"
#import "ContextManager.h"

static NSString *cellIdentifier = @"selectableCell";

@interface SearchableSelectableTableViewController ()

@end

@implementation SearchableSelectableTableViewController

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    
    if (self)
    {
        self.managedObjectContext = [ContextManager mainContext];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.title = [NSString stringWithFormat:@"%@s", [self readableStringFromCamelCaseString:NSStringFromClass(self.classOfItems)]];
}

- (NSString *)readableStringFromCamelCaseString:(NSString *)string
{
    NSMutableString *resultString = [NSMutableString string];
    
    for (NSInteger i=0; i<string.length; i++)
    {
        NSString *ch = [string substringWithRange:NSMakeRange(i, 1)];
        
        if ([ch rangeOfCharacterFromSet:[NSCharacterSet uppercaseLetterCharacterSet]].location != NSNotFound)
        {
            [resultString appendString:@" "];
        }
        
        [resultString appendString:ch];
    }
    
    return resultString.capitalizedString;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger numberOfRows = 0;
    
    NSFetchedResultsController *fetchController = [self fetchedResultsControllerForTableView:tableView];
    NSArray *sections = fetchController.sections;
    
    if (sections.count > 0)
    {
        id<NSFetchedResultsSectionInfo> sectionInfo = [sections objectAtIndex:section];
        numberOfRows = [sectionInfo numberOfObjects];
    }

    return numberOfRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"selectableCell"];
    
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    [self fetchedResultsController:[self fetchedResultsControllerForTableView:tableView] configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (void)fetchedResultsController:(NSFetchedResultsController *)fetchedResultsController configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    id item = [fetchedResultsController objectAtIndexPath:indexPath];
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
}

- (NSFetchRequest *)fetchRequestForSearch:(NSString *)searchString
{
    NSFetchRequest *request = [self.classOfItems sqk_fetchRequest];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:self.itemTextProperty ascending:YES]];

    if(searchString.length)
    {
        NSMutableString *predicateString = [NSMutableString stringWithFormat:@"%@ CONTAINS[cd] '%@' AND NOT(%@ IN {", self.itemSearchProperty, searchString, self.itemTextProperty];
        
        [[self.filterItems allObjects] enumerateObjectsUsingBlock:^(NSString *string, NSUInteger idx, BOOL *stop) {
            if(idx != self.filterItems.count -1)
            {
                [predicateString appendFormat:@"'%@',", string];
            }
            else
            {
                [predicateString appendFormat:@"'%@'", string];
            }
        }];
        
        [predicateString appendString:@"})"];
        
        request.predicate = [NSPredicate predicateWithFormat:predicateString];
    }
    else
    {
        NSMutableString *predicateString = [NSMutableString stringWithFormat:@"NOT(%@ IN {", self.itemTextProperty];
        
        [[self.filterItems allObjects] enumerateObjectsUsingBlock:^(NSString *string, NSUInteger idx, BOOL *stop) {
            if(idx != self.filterItems.count -1)
            {
                [predicateString appendFormat:@"'%@',", string];
            }
            else
            {
                [predicateString appendFormat:@"'%@'", string];
            }
        }];
        
        [predicateString appendString:@"})"];
        
        request.predicate = [NSPredicate predicateWithFormat:predicateString];
    }
    
    return request;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    cell.backgroundColor = [UIColor colorWithRed:0.843 green:0.937 blue:0.988 alpha:1];
    
    if(self.didSelectItemBlock)
    {
        id item = [[self fetchedResultsControllerForTableView:tableView] objectAtIndexPath:indexPath];
        
        self.didSelectItemBlock(item, indexPath.row);
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}


@end
