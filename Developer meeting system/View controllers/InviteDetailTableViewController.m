//
//  InviteDetailTableViewController.m
//  Developer meeting system
//
//  Created by Ste Prescott on 12/12/2014.
//  Copyright (c) 2014 Ste Prescott. All rights reserved.
//

#import "InviteDetailTableViewController.h"
#import "TextViewViewController.h"

#import "WebServiceClient.h"
#import "Meeting+DMS.h"
#import "MeetingRoom+DMS.h"
#import "User+DMS.h"

static NSString *basicCellIdentifier = @"basicCell";
static NSString *detailedCellIdentifier = @"detailedCell";

@interface InviteDetailTableViewController ()

@property (nonatomic, strong) NSDateFormatter *dateFormatter;

@end

@implementation InviteDetailTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.dateFormatter = [[NSDateFormatter alloc] init];
    self.dateFormatter.dateStyle = NSDateFormatterMediumStyle;
    self.dateFormatter.timeStyle = NSDateFormatterMediumStyle;
}

-(void)setInvite:(Invite *)invite
{
    _invite = invite;
    self.title = self.invite.meeting.subject ? self.invite.meeting.subject : @"Select and invite to show meeting details";
    [[self.splitViewController.viewControllers firstObject] popViewControllerAnimated:YES];
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.invite ? TableViewSectionCount : 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger numberOfRows = 0;
    
    switch (section)
    {
        case TableViewSectionMeetingDetails:
        {
            numberOfRows = TableViewSectionMeetingDetailsRowCount;
            break;
        }
            
        case TableViewSectionInvites:
        {
            numberOfRows = [self.invite.meeting invitesWithStatus:InviteStatusInvited].count;
            break;
        }
            
        case TableViewSectionAcceptedInvites:
        {
            numberOfRows = [self.invite.meeting invitesWithStatus:InviteStatusAccepted].count;
            break;
        }
            
        case TableViewSectionTentativeInvites:
        {
            numberOfRows = [self.invite.meeting invitesWithStatus:InviteStatusTentative].count;
            break;
        }
            
        case TableViewSectionDeclinedInvites:
        {
            numberOfRows = [self.invite.meeting invitesWithStatus:InviteStatusDeclined].count;
            break;
        }
            
        case TableViewSectionActions:
        {
            numberOfRows = TableViewSectionActionsRowCount;
        }
    }
    
    return numberOfRows;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *title;
    NSInteger numberOfRows = [self tableView:tableView numberOfRowsInSection:section];
    
    if(numberOfRows == 0)
    {
        return nil;
    }
    
    switch (section)
    {
        case TableViewSectionInvites:
        {
            title = @"Invites";
            break;
        }
            
        case TableViewSectionAcceptedInvites:
        {
            title = @"Accepted invites";
            break;
        }
            
        case TableViewSectionTentativeInvites:
        {
            title = @"Tentative invites";
            break;
        }
            
        case TableViewSectionDeclinedInvites:
        {
            title = @"Declined invites";
            break;
        }
            
        case TableViewSectionActions:
        {
            title = @"Actions";
            break;
        }
    }
    
    return title;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    
    switch (indexPath.section)
    {
        case TableViewSectionMeetingDetails:
        {
            cell = [tableView dequeueReusableCellWithIdentifier:detailedCellIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            switch (indexPath.row)
            {
                case TableViewSectionMeetingDetailsRowSubject:
                {
                    cell.textLabel.text = @"Subject";
                    cell.detailTextLabel.text = self.invite.meeting.subject;
                    break;
                }
                    
                case TableViewSectionMeetingDetailsRowRoom:
                {
                    cell.textLabel.text = @"Room";
                    cell.detailTextLabel.text = self.invite.meeting.meetingRoom.name;
                    break;
                }
                    
                case TableViewSectionMeetingDetailsRowStartDate:
                {
                    cell.textLabel.text = @"Start date";
                    cell.detailTextLabel.text = [self.dateFormatter stringFromDate:self.invite.meeting.startDate];
                    break;
                }
                    
                case TableViewSectionMeetingDetailsRowEndDate:
                {
                    cell.textLabel.text = @"End date";
                    cell.detailTextLabel.text = [self.dateFormatter stringFromDate:self.invite.meeting.endDate];
                    break;
                }
                    
                case TableViewSectionMeetingDetailsRowIsPublic:
                {
                    cell.textLabel.text = @"Is public";
                    cell.detailTextLabel.text = self.invite.meeting.isPublic ? @"Yes" : @"No";
                    break;
                }
                    
                case TableViewSectionMeetingDetailsRowNotes:
                {
                    cell.textLabel.text = @"Notes";
                    cell.detailTextLabel.text = self.invite.meeting.notes && ![self.invite.meeting.notes isEqualToString:@""] ? self.invite.meeting.notes : @"No notes";
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    cell.selectionStyle = UITableViewCellSelectionStyleGray;
                    break;
                }
            }
            break;
        }
            
        case TableViewSectionInvites:
        {
            cell = [tableView dequeueReusableCellWithIdentifier:basicCellIdentifier forIndexPath:indexPath];
            User *user = (User *)[[self.invite.meeting usersInMeetingWithInvitesWithStatus:InviteStatusInvited] allObjects][indexPath.row];
            cell.textLabel.text = user.username;
            cell.textLabel.textAlignment = NSTextAlignmentLeft;
            cell.textLabel.textColor = [UIColor blackColor];
            break;
        }
            
        case TableViewSectionAcceptedInvites:
        {
            cell = [tableView dequeueReusableCellWithIdentifier:basicCellIdentifier forIndexPath:indexPath];
            User *user = (User *)[[self.invite.meeting usersInMeetingWithInvitesWithStatus:InviteStatusAccepted] allObjects][indexPath.row];
            cell.textLabel.text = user.username;
            cell.textLabel.textAlignment = NSTextAlignmentLeft;
            cell.textLabel.textColor = [UIColor blackColor];
            break;
        }
            
        case TableViewSectionTentativeInvites:
        {
            cell = [tableView dequeueReusableCellWithIdentifier:basicCellIdentifier forIndexPath:indexPath];
            User *user = (User *)[[self.invite.meeting usersInMeetingWithInvitesWithStatus:InviteStatusTentative] allObjects][indexPath.row];
            cell.textLabel.text = user.username;
            cell.textLabel.textAlignment = NSTextAlignmentLeft;
            cell.textLabel.textColor = [UIColor blackColor];
            break;
        }
            
        case TableViewSectionDeclinedInvites:
        {
            cell = [tableView dequeueReusableCellWithIdentifier:basicCellIdentifier forIndexPath:indexPath];
            User *user = (User *)[[self.invite.meeting usersInMeetingWithInvitesWithStatus:InviteStatusDeclined] allObjects][indexPath.row];
            cell.textLabel.text = user.username;
            cell.textLabel.textAlignment = NSTextAlignmentLeft;
            cell.textLabel.textColor = [UIColor blackColor];
            break;
        }
            
        case TableViewSectionActions:
        {
            cell = [tableView dequeueReusableCellWithIdentifier:basicCellIdentifier forIndexPath:indexPath];
            
            switch (indexPath.row)
            {
                case TableViewSectionActionsRowAcceptInvite:
                {
                    cell.textLabel.text = @"Accept invite";
                    cell.textLabel.textAlignment = NSTextAlignmentCenter;
                    cell.textLabel.textColor = self.view.tintColor;
                    break;
                }
                    
                case TableViewSectionActionsRowTentativeInvite:
                {
                    cell.textLabel.text = @"Tentative invite";
                    cell.textLabel.textAlignment = NSTextAlignmentCenter;
                    cell.textLabel.textColor = self.view.tintColor;
                    break;
                }
                    
                case TableViewSectionActionsRowDeclineInvite:
                {
                    cell.textLabel.text = @"Decline invite";
                    cell.textLabel.textAlignment = NSTextAlignmentCenter;
                    cell.textLabel.textColor = [UIColor redColor];
                    break;
                }
            }
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section)
    {
        case TableViewSectionMeetingDetails:
        {
            switch (indexPath.row)
            {
                case TableViewSectionMeetingDetailsRowNotes:
                {
                    TextViewViewController *textViewViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"TextViewViewController"];
                    textViewViewController.currentText = self.invite.meeting.notes;
                    textViewViewController.enabled = NO;
                    [self.navigationController showViewController:textViewViewController sender:self];
                    break;
                }
            }
            break;
        }
            
        case TableViewSectionActions:
        {
            InviteStatus inviteStauts = -1;
            
            switch (indexPath.row)
            {
                case TableViewSectionActionsRowAcceptInvite:
                {
                    inviteStauts = InviteStatusAccepted;
                    break;
                }
                    
                case TableViewSectionActionsRowTentativeInvite:
                {
                    inviteStauts = InviteStatusTentative;
                    break;
                }
                    
                case TableViewSectionActionsRowDeclineInvite:
                {
                    inviteStauts = InviteStatusDeclined;
                    break;
                }
            }
            
            if(inviteStauts > 0)
            {
                NSError *attendenceError;
                [[WebServiceClient sharedInstance] POSTAttendenceForMeetingWithID:self.invite.meeting.meetingID
                                                                       withStatus:inviteStauts
                                                                            error:&attendenceError];
                
                if(attendenceError)
                {
                    NSLog(@"%@", attendenceError.userInfo[webServiceClientErrorMessage]);
                }
                else
                {
                    self.invite.status = @(inviteStauts);
                    [self.invite.managedObjectContext save:NULL];
                    [self.tableView reloadData];
                    [[self.splitViewController.viewControllers firstObject] popViewControllerAnimated:YES];
                }
            }
        }
    }
}

- (BOOL)splitViewController:(UISplitViewController *)splitViewController collapseSecondaryViewController:(UIViewController *)secondaryViewController ontoPrimaryViewController:(UIViewController *)primaryViewController
{
    return YES;
}

@end
