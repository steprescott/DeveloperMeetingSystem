//
//  MeetingDetailsTableViewController.m
//  Developer meeting system
//
//  Created by Ste Prescott on 05/12/2014.
//  Copyright (c) 2014 Ste Prescott. All rights reserved.
//

#import "MeetingDetailsTableViewController.h"
#import "TextFieldTableViewCell.h"
#import "YesNoTableViewCell.h"
#import "DateCellsController.h"
#import "SelectableListTableViewController.h"
#import "SearchableSelectableTableViewController.h"
#import "TextViewViewController.h"
#import "WebServiceClient.h"

#import "ContextManager.h"
#import "Meeting+DMS.h"
#import "MeetingRoom.h"

typedef NS_ENUM(NSUInteger, TableViewSection) {
    TableViewSectionMeetingDetails = 0,
    TableViewSectionInvites,
    TableViewSectionAcceptedInvites,
    TableViewSectionTentativeInvites,
    TableViewSectionDeclinedInvites,
    TableViewSectionActions,
    TableViewSectionCount
};

typedef NS_ENUM(NSUInteger, TableViewSectionMeetingDetailsRow) {
    TableViewSectionMeetingDetailsRowSubject = 0,
    TableViewSectionMeetingDetailsRowRoom,
    TableViewSectionMeetingDetailsRowStartDate,
    TableViewSectionMeetingDetailsRowEndDate,
    TableViewSectionMeetingDetailsRowIsPublic,
    TableViewSectionMeetingDetailsRowNotes,
    TableViewSectionMeetingDetailsRowCount
};

typedef NS_ENUM(NSUInteger, TableViewSectionActionsRow) {
    TableViewSectionActionsRowInviteUser = 0,
    TableViewSectionActionsRowDeleteMeeting,
};

static NSString *textFieldCellWithIdentifier = @"textFieldCell";
static NSString *yesNoCellWithIdentifier = @"yesNoCell";
static NSString *rightDetailCellWithIdentifier = @"rightDetailCell";
static NSString *basicCellWithIdentifier = @"basicCell";

@interface MeetingDetailsTableViewController () <UITableViewDataSource, UITableViewDelegate, DateCellsControllerDelegate>

@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic, strong) DateCellsController *dateCellsController;
@property (nonatomic, strong) NSIndexPath *subjectIndexPath;
@property (nonatomic, strong) NSIndexPath *roomIndexPath;
@property (nonatomic, strong) NSIndexPath *startDateIndexPath;
@property (nonatomic, strong) NSIndexPath *endDateIndexPath;
@property (nonatomic, strong) NSIndexPath *isPublicIndexPath;
@property (nonatomic, strong) NSIndexPath *notesIndexPath;

@property (nonatomic, strong) NSString *meetingSubject;
@property (nonatomic, strong) NSDate *meetingStartDate;
@property (nonatomic, strong) NSDate *meetingEndDate;
@property (nonatomic, strong) MeetingRoom *meetingMeetingRoom;

- (IBAction)cancelButtonWasTapped:(id)sender;
- (IBAction)doneButtonWasTapped:(id)sender;

@end

@implementation MeetingDetailsTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.dateFormatter = [[NSDateFormatter alloc] init];
    self.dateFormatter.dateStyle = NSDateFormatterMediumStyle;
    self.dateFormatter.timeStyle = NSDateFormatterMediumStyle;
    
    self.subjectIndexPath = [NSIndexPath indexPathForRow:TableViewSectionMeetingDetailsRowSubject
                                               inSection:TableViewSectionMeetingDetails];
    self.roomIndexPath = [NSIndexPath indexPathForRow:TableViewSectionMeetingDetailsRowRoom
                                            inSection:TableViewSectionMeetingDetails];
    self.startDateIndexPath = [NSIndexPath indexPathForRow:TableViewSectionMeetingDetailsRowStartDate
                                                 inSection:TableViewSectionMeetingDetails];
    self.endDateIndexPath = [NSIndexPath indexPathForRow:TableViewSectionMeetingDetailsRowEndDate
                                               inSection:TableViewSectionMeetingDetails];
    self.isPublicIndexPath = [NSIndexPath indexPathForRow:TableViewSectionMeetingDetailsRowIsPublic
                                                inSection:TableViewSectionMeetingDetails];
    self.notesIndexPath = [NSIndexPath indexPathForRow:TableViewSectionMeetingDetailsRowNotes
                                               inSection:TableViewSectionMeetingDetails];
    
    self.meetingSubject = self.meeting.subject;
    self.meetingStartDate = self.meeting.startDate ? self.meeting.startDate : [NSDate new];
    self.meetingEndDate = self.meeting.endDate ? self.meeting.endDate : [NSDate dateWithTimeIntervalSinceNow:(60 * 60)];
    self.meetingMeetingRoom = self.meeting.meetingRoom;
    
    self.dateCellsController = [[DateCellsController alloc] init];
    [self.dateCellsController attachToTableView:self.tableView
                                   withDelegate:self
                                    withMapping:[@{self.startDateIndexPath : self.meetingStartDate,
                                                   self.endDateIndexPath : self.meetingEndDate} mutableCopy]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    TextFieldTableViewCell *subjectCell = (TextFieldTableViewCell *)[self.dateCellsController cellForIndexPath:self.subjectIndexPath ignoringPickerCells:YES];
    self.meetingSubject = subjectCell.textField.text;
}

- (void)setMeeting:(Meeting *)meeting
{
    _meeting = meeting;
    self.title = meeting.subject ? meeting.subject : @"Create new meeting";
}

- (IBAction)cancelButtonWasTapped:(id)sender
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    
    if([self.delegate respondsToSelector:@selector(meetingDetailsFormDissmissed)])
    {
        [self.delegate meetingDetailsFormDissmissed];
    }
}

- (IBAction)doneButtonWasTapped:(id)sender
{
    [self.dateCellsController hidePicker];
    
    TextFieldTableViewCell *subjectCell = (TextFieldTableViewCell *)[self.dateCellsController cellForIndexPath:self.subjectIndexPath ignoringPickerCells:YES];
    YesNoTableViewCell *isPublicCell = (YesNoTableViewCell *)[self.dateCellsController cellForIndexPath:self.isPublicIndexPath ignoringPickerCells:YES];
    self.meetingSubject = subjectCell.textField.text;
    
    if(!self.meeting)
    {
        self.meeting = [Meeting sqk_insertInContext:[ContextManager mainContext]];
    }
    
    self.meeting.subject = self.meetingSubject;
    self.meeting.isPublic = @([isPublicCell isYes]);
    self.meeting.startDate = self.meetingStartDate;
    self.meeting.endDate = self.meetingEndDate;
    self.meeting.hasBeenUpdated = @YES;
    self.meeting.meetingRoom = self.meetingMeetingRoom;
    
    NSError *error;
    [self.meeting.managedObjectContext save:&error];
    
    if(error)
    {
        NSLog(@"%s Error %@", __PRETTY_FUNCTION__, error.localizedDescription);
    }
    
    if(!self.meeting.meetingID)
    {
        [[WebServiceClient sharedInstance] POSTMeeting:[self.meeting JSONRepresentation]
                                               success:^(NSDictionary *JSON) {
                                                   [self.navigationController dismissViewControllerAnimated:YES completion:nil];
                                                   
                                                   if([self.delegate respondsToSelector:@selector(meetingDetailsFormDissmissed)])
                                                   {
                                                       [self.delegate meetingDetailsFormDissmissed];
                                                   }
                                               }
                                               failure:^(NSError *error) {
                                                   NSLog(@"%s Error when exicuting POST request to meeting %@", __PRETTY_FUNCTION__, error.localizedDescription);
                                               }];
    }
    else
    {
        [[WebServiceClient sharedInstance] PUTMeeting:[self.meeting JSONRepresentation]
                                              success:^(NSDictionary *JSON) {
                                                  [self.navigationController dismissViewControllerAnimated:YES completion:nil];
                                                  
                                                  if([self.delegate respondsToSelector:@selector(meetingDetailsFormDissmissed)])
                                                  {
                                                      [self.delegate meetingDetailsFormDissmissed];
                                                  }
                                              }
                                              failure:^(NSError *error) {
                                                  NSLog(@"%s Error when exicuting PUT request to meeting %@", __PRETTY_FUNCTION__, error.localizedDescription);
                                              }];

    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return TableViewSectionCount;
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
            numberOfRows = [self.meeting invitesWithStatus:InviteStatusInvited].count;
            break;
        }
            
        case TableViewSectionAcceptedInvites:
        {
            numberOfRows = [self.meeting invitesWithStatus:InviteStatusAccepted].count;
            break;
        }
            
        case TableViewSectionTentativeInvites:
        {
            numberOfRows = [self.meeting invitesWithStatus:InviteStatusTentative].count;
            break;
        }
            
        case TableViewSectionDeclinedInvites:
        {
            numberOfRows = [self.meeting invitesWithStatus:InviteStatusDeclined].count;
            break;
        }
            
        case TableViewSectionActions:
        {
            numberOfRows = 2;
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
            switch (indexPath.row)
            {
                case TableViewSectionMeetingDetailsRowSubject:
                {
                    TextFieldTableViewCell *textFieldCell = (TextFieldTableViewCell *)[tableView dequeueReusableCellWithIdentifier:textFieldCellWithIdentifier forIndexPath:indexPath];
                    textFieldCell.label.text = @"Subject";
                    textFieldCell.textField.text = self.meetingSubject;
                    
                    cell = textFieldCell;
                    break;
                }
                    
                case TableViewSectionMeetingDetailsRowRoom:
                {
                    cell = [tableView dequeueReusableCellWithIdentifier:rightDetailCellWithIdentifier forIndexPath:indexPath];
                    cell.textLabel.text = @"Room";
                    cell.detailTextLabel.text = self.meetingMeetingRoom.name;
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    break;
                }
                    
                case TableViewSectionMeetingDetailsRowStartDate:
                {
                    cell = [tableView dequeueReusableCellWithIdentifier:rightDetailCellWithIdentifier forIndexPath:indexPath];
                    cell.textLabel.text = @"Start date";
                    cell.detailTextLabel.text = [self.dateFormatter stringFromDate:self.meeting.startDate];
                    break;
                }
                    
                case TableViewSectionMeetingDetailsRowEndDate:
                {
                    cell = [tableView dequeueReusableCellWithIdentifier:rightDetailCellWithIdentifier forIndexPath:indexPath];
                    cell.textLabel.text = @"End date";
                    cell.detailTextLabel.text = [self.dateFormatter stringFromDate:self.meeting.endDate];
                    break;
                }
                    
                case TableViewSectionMeetingDetailsRowIsPublic:
                {
                    YesNoTableViewCell *yesNoCell = (YesNoTableViewCell *)[tableView dequeueReusableCellWithIdentifier:yesNoCellWithIdentifier forIndexPath:indexPath];
                    
                    yesNoCell.label.text = @"Is public";
                    
                    if([self.meeting.isPublic boolValue])
                    {
                        [yesNoCell setToYes];
                    }
                    
                    cell = yesNoCell;
                    break;
                }
                
                case TableViewSectionMeetingDetailsRowNotes:
                {
                    cell = [tableView dequeueReusableCellWithIdentifier:rightDetailCellWithIdentifier forIndexPath:indexPath];
                    cell.textLabel.text = @"Notes";
                    cell.detailTextLabel.text = self.meeting.notes;
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    break;
                }
            }
            break;
        }
            
        case TableViewSectionInvites:
        {
            cell = [tableView dequeueReusableCellWithIdentifier:basicCellWithIdentifier forIndexPath:indexPath];
            Invite *invite = (Invite *)[[self.meeting invitesWithStatus:InviteStatusInvited] allObjects][indexPath.row];
            cell.textLabel.text = invite.user.username;
            cell.textLabel.textAlignment = NSTextAlignmentLeft;
            cell.textLabel.textColor = [UIColor blackColor];
            break;
        }
            
        case TableViewSectionAcceptedInvites:
        {
            cell = [tableView dequeueReusableCellWithIdentifier:basicCellWithIdentifier forIndexPath:indexPath];
            Invite *invite = (Invite *)[[self.meeting invitesWithStatus:InviteStatusAccepted] allObjects][indexPath.row];
            cell.textLabel.text = invite.user.username;
            cell.textLabel.textAlignment = NSTextAlignmentLeft;
            cell.textLabel.textColor = [UIColor blackColor];
            break;
        }
        
        case TableViewSectionTentativeInvites:
        {
            cell = [tableView dequeueReusableCellWithIdentifier:basicCellWithIdentifier forIndexPath:indexPath];
            Invite *invite = (Invite *)[[self.meeting invitesWithStatus:InviteStatusTentative] allObjects][indexPath.row];
            cell.textLabel.text = invite.user.username;
            cell.textLabel.textAlignment = NSTextAlignmentLeft;
            cell.textLabel.textColor = [UIColor blackColor];
            break;
        }
            
        case TableViewSectionDeclinedInvites:
        {
            cell = [tableView dequeueReusableCellWithIdentifier:basicCellWithIdentifier forIndexPath:indexPath];
            Invite *invite = (Invite *)[[self.meeting invitesWithStatus:InviteStatusDeclined] allObjects][indexPath.row];
            cell.textLabel.text = invite.user.username;
            cell.textLabel.textAlignment = NSTextAlignmentLeft;
            cell.textLabel.textColor = [UIColor blackColor];
            break;
        }
        
        case TableViewSectionActions:
        {
            cell = [tableView dequeueReusableCellWithIdentifier:basicCellWithIdentifier forIndexPath:indexPath];
            
            switch (indexPath.row)
            {
                case TableViewSectionActionsRowInviteUser:
                {
                    cell.textLabel.text = @"Invite user";
                    cell.textLabel.textAlignment = NSTextAlignmentCenter;
                    cell.textLabel.textColor = self.view.tintColor;
                    break;
                }
                    
                case TableViewSectionActionsRowDeleteMeeting:
                {
                    cell.textLabel.text = @"Delete meeting";
                    cell.textLabel.textAlignment = NSTextAlignmentCenter;
                    cell.textLabel.textColor = [UIColor redColor];
                    break;
                }
            }
        }
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section)
    {
        case TableViewSectionMeetingDetails:
        {
            switch (indexPath.row)
            {
                case TableViewSectionMeetingDetailsRowSubject:
                {
                    break;
                }
                    
                case TableViewSectionMeetingDetailsRowRoom:
                {
                    SearchableSelectableTableViewController *searchableSelectableTableViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SelectableListTableViewController"];
                    searchableSelectableTableViewController.classOfItems = [MeetingRoom class];
                    searchableSelectableTableViewController.itemTextProperty = @"name";
                    searchableSelectableTableViewController.itemSearchProperty = @"name";
                    searchableSelectableTableViewController.didSelectItemBlock = ^void(id selectedItem, NSInteger selectedIndex) {
                        
                        self.meetingMeetingRoom = selectedItem;
                    };
                    
                    [self.navigationController showViewController:searchableSelectableTableViewController sender:self];
                    break;
                }
                    
                case TableViewSectionMeetingDetailsRowStartDate:
                {
                    break;
                }
                    
                case TableViewSectionMeetingDetailsRowEndDate:
                {
                    break;
                }
                    
                case TableViewSectionMeetingDetailsRowIsPublic:
                {
                    break;
                }
                    
                case TableViewSectionMeetingDetailsRowNotes:
                {
                    TextViewViewController *textViewViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"TextViewViewController"];
                    textViewViewController.currentText = self.meeting.notes;
                    textViewViewController.doneButtonWasTappedBlock = ^void(NSString *updatedText) {
                        self.meeting.notes = updatedText;
                        [self.tableView reloadData];
                    };
                    
                    [self.navigationController showViewController:textViewViewController sender:self];
                    break;
                }
            }
            break;
        }
            
        case TableViewSectionAcceptedInvites:
        {
            break;
        }
            
        case TableViewSectionDeclinedInvites:
        {
            break;
        }
            
        case TableViewSectionInvites:
        {
            break;
        }
            
        case TableViewSectionActions:
        {
            switch (indexPath.row)
            {
                case TableViewSectionActionsRowInviteUser:
                {
                    SearchableSelectableTableViewController *searchableSelectableTableViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SelectableListTableViewController"];
                    searchableSelectableTableViewController.classOfItems = [User class];
                    searchableSelectableTableViewController.itemTextProperty = @"username";
                    searchableSelectableTableViewController.itemSearchProperty = @"username";
                    searchableSelectableTableViewController.filterItems = [User usernamesForUsers:[self.meeting usersInMeeting]];
                    searchableSelectableTableViewController.didSelectItemBlock = ^void(id selectedItem, NSInteger selectedIndex) {
                        
                        [Invite createInviteForMeeting:self.meeting
                                              withUser:selectedItem
                                             forStatus:InviteStatusInvited
                                           intoContext:self.meeting.managedObjectContext];
                        
                        [self.tableView reloadData];
                    };
                    
                    [self.navigationController showViewController:searchableSelectableTableViewController sender:self];
                    break;
                }
                
                case TableViewSectionActionsRowDeleteMeeting:
                {
                    [[WebServiceClient sharedInstance] DELETEMeetingWithID:self.meeting.meetingID
                                                          success:^(NSDictionary *JSON) {
                                                              [self.meeting sqk_deleteObject];
                                                              [self.navigationController dismissViewControllerAnimated:YES completion:nil];
                                                              
                                                              if([self.delegate respondsToSelector:@selector(meetingDetailsFormDissmissed)])
                                                              {
                                                                  [self.delegate meetingDetailsFormDissmissed];
                                                              }
                                                          }
                                                          failure:^(NSError *error) {
                                                              NSLog(@"%s Error when exicuting DELETE request to meeting %@", __PRETTY_FUNCTION__, error.localizedDescription);
                                                          }];
                    break;
                }
            }
            break;
        }
    }
}

#pragma mark - Date Cells Controller delegate methods

- (void)dateCellsController:(DateCellsController *)controller
            didSelectedDate:(NSDate *)date
               forIndexPath:(NSIndexPath *)path
{
    [self.tableView reloadRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationAutomatic];
    
    if(path.row == self.startDateIndexPath.row)
    {
        self.meeting.startDate = date;
    }
    else
    {
        self.meeting.endDate = date;
    }
}

@end
