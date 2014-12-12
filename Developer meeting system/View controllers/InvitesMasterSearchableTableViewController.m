//
//  InvitesMasterSearchableTableViewController.m
//  Developer meeting system
//
//  Created by Ste Prescott on 11/12/2014.
//  Copyright (c) 2014 Ste Prescott. All rights reserved.
//

#import "InvitesMasterSearchableTableViewController.h"
#import "InviteDetailTableViewController.h"

#import "ContextManager.h"
#import "WebServiceClient.h"

static NSString *cellIdentifier = @"inviteCell";

@interface InvitesMasterSearchableTableViewController () <UISplitViewControllerDelegate>

@property (nonatomic, strong) User *activeUser;
@property (nonatomic, strong) Invite *selectedInvite;
@property (nonatomic, strong) InviteDetailTableViewController *inviteDetailTableViewController;

@end

@implementation InvitesMasterSearchableTableViewController

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    
    if (self)
    {
        self.managedObjectContext = [ContextManager mainContext];
        self.searchingEnabled = YES;
        self.searchController.delegate = self;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.splitViewController.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.activeUser = [User activeUser];
    [self reloadFetchedResultsControllers];
}

- (NSString *)sectionKeyPathForSearchableFetchedResultsController:(SQKFetchedTableViewController *)controller
{
    return @"status";
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *title;
    NSString *sectionName = [[[[self fetchedResultsControllerForTableView:tableView] sections] objectAtIndex:section] name];
    
    if([sectionName isEqualToString:@"0"])
    {
        title = @"Pending invites";
    }
    else if([sectionName isEqualToString:@"1"])
    {
        title = @"Accepted invites";
    }
    else if([sectionName isEqualToString:@"2"])
    {
        title = @"Tentative invites";
    }
    else if([sectionName isEqualToString:@"3"])
    {
        title = @"Declined invites";
    }
    
    return title;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:cellIdentifier];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];

    [self fetchedResultsController:[self fetchedResultsControllerForTableView:tableView] configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)fetchedResultsController:(NSFetchedResultsController *)fetchedResultsController configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    Invite *invite = [fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = invite.meeting.subject;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
}

- (NSFetchRequest *)fetchRequestForSearch:(NSString *)searchString
{
    NSFetchRequest *request = [Invite sqk_fetchRequest];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"meeting.subject" ascending:YES]];

    if(searchString.length)
    {
        request.predicate = [NSPredicate predicateWithFormat:@"user.username == %@ AND meeting.subject CONTAINS[cd] %@", self.activeUser.username, searchString];
    }
    else
    {
        request.predicate = [NSPredicate predicateWithFormat:@"user.username == %@", self.activeUser.username];
    }
    
    return request;
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
    self.inviteDetailTableViewController.invite = nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectedInvite = [[self fetchedResultsControllerForTableView:tableView] objectAtIndexPath:indexPath];
    [self performSegueWithIdentifier:@"showDetail" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSString *segueIdentifier = segue.identifier;
    
    if([segueIdentifier isEqualToString:@"showDetail"])
    {
        UINavigationController *navigationController = (UINavigationController *)segue.destinationViewController;
        self.inviteDetailTableViewController = (InviteDetailTableViewController *)[navigationController topViewController];
        self.inviteDetailTableViewController.invite = self.selectedInvite;
        self.inviteDetailTableViewController.navigationItem.leftBarButtonItem = self.splitViewController.displayModeButtonItem;
    }
}

- (BOOL)splitViewController:(UISplitViewController *)splitViewController collapseSecondaryViewController:(UIViewController *)secondaryViewController ontoPrimaryViewController:(UIViewController *)primaryViewController
{
    return YES;
}

@end
