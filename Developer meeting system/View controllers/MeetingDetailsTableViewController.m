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

@property (nonatomic, assign) BOOL userCanEdit;
@property (nonatomic, strong) NSString *meetingSubject;
@property (nonatomic, strong) NSDate *meetingStartDate;
@property (nonatomic, strong) NSDate *meetingEndDate;
@property (nonatomic, strong) MeetingRoom *meetingMeetingRoom;
@property (nonatomic, strong) NSString *meetingNotes;
@property (nonatomic, strong) NSMutableDictionary *invitesDictionary;

- (IBAction)cancelButtonWasTapped:(id)sender;
- (IBAction)doneButtonWasTapped:(id)sender;

@end

@implementation MeetingDetailsTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.allowsMultipleSelectionDuringEditing = NO;
    
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
    self.meetingNotes = self.meeting.notes;
    
    if(!self.meeting.host || [self.meeting.host.username isEqualToString:[User activeUser].username])
    {
        self.userCanEdit = YES;
        
        self.dateCellsController = [[DateCellsController alloc] init];
        [self.dateCellsController attachToTableView:self.tableView
                                       withDelegate:self
                                        withMapping:[@{self.startDateIndexPath : self.meetingStartDate,
                                                       self.endDateIndexPath : self.meetingEndDate} mutableCopy]];
    }
    else
    {
        self.userCanEdit = NO;
        self.navigationItem.rightBarButtonItem = nil;
    }
    
    NSArray *sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"username" ascending:YES]];
    self.invitesDictionary = [@{@(InviteStatusInvited) : self.meeting ? [[self.meeting usersInMeetingWithInvitesWithStatus:InviteStatusInvited] sortedArrayUsingDescriptors:sortDescriptors] : [NSSet set],
                               @(InviteStatusAccepted) : self.meeting ? [[self.meeting usersInMeetingWithInvitesWithStatus:InviteStatusAccepted] sortedArrayUsingDescriptors:sortDescriptors] : [NSSet set],
                               @(InviteStatusTentative) : self.meeting ? [[self.meeting usersInMeetingWithInvitesWithStatus:InviteStatusTentative] sortedArrayUsingDescriptors:sortDescriptors] : [NSSet set],
                               @(InviteStatusDeclined) : self.meeting ? [[self.meeting usersInMeetingWithInvitesWithStatus:InviteStatusDeclined] sortedArrayUsingDescriptors:sortDescriptors] : [NSSet set]} mutableCopy];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    TextFieldTableViewCell *subjectCell = (TextFieldTableViewCell *)[self.dateCellsController cellForIndexPath:self.subjectIndexPath ignoringPickerCells:YES];
    self.meetingSubject = subjectCell.textField.text;
    [subjectCell.textField resignFirstResponder];
}

- (void)setMeeting:(Meeting *)meeting
{
    _meeting = meeting;
    self.title = meeting.meetingID ? meeting.subject : @"Create new meeting";
}

- (void)setMeetingMeetingRoom:(MeetingRoom *)meetingMeetingRoom
{
    _meetingMeetingRoom = meetingMeetingRoom;
    UITableViewCell *cell = [self.dateCellsController cellForIndexPath:self.roomIndexPath ignoringPickerCells:YES];
    cell.detailTextLabel.text = self.meetingMeetingRoom.name;
}

- (void)setMeetingStartDate:(NSDate *)meetingStartDate
{
    _meetingStartDate = meetingStartDate;
    UITableViewCell *cell = [self.dateCellsController cellForIndexPath:self.startDateIndexPath ignoringPickerCells:YES];
    cell.detailTextLabel.text = [self.dateFormatter stringFromDate:self.meetingStartDate];
}

- (void)setMeetingEndDate:(NSDate *)meetingEndDate
{
    _meetingEndDate = meetingEndDate;
    UITableViewCell *cell = [self.dateCellsController cellForIndexPath:self.endDateIndexPath ignoringPickerCells:YES];
    cell.detailTextLabel.text = [self.dateFormatter stringFromDate:self.meetingEndDate];
}

- (void)setMeetingNotes:(NSString *)meetingNotes
{
    _meetingNotes = meetingNotes;
    UITableViewCell *cell = [self.dateCellsController cellForIndexPath:self.notesIndexPath ignoringPickerCells:YES];
    cell.detailTextLabel.text = self.meetingNotes;
}

- (BOOL)isDate1:(NSDate *)date1 aheadOfDate2:(NSDate *)date2
{
    switch ([date1 compare:date2])
    {
        case NSOrderedAscending:
        case NSOrderedSame:
        {
            return NO;
            break;
        }
            
        case NSOrderedDescending:
        {
            return YES;
            break;
        }
    }
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
    
    if([self isDate1:self.meetingStartDate aheadOfDate2:self.meetingEndDate])
    {
        [SVProgressHUD showErrorWithStatus:@"Start date can not be ahead or the same as end date" maskType:SVProgressHUDMaskTypeBlack];
        return;
    }
    else if(![self isDate1:self.meetingEndDate aheadOfDate2:self.meetingStartDate])
    {
        [SVProgressHUD showErrorWithStatus:@"End date can not be before or the same as the start date." maskType:SVProgressHUDMaskTypeBlack];
        return;
    }
    
    TextFieldTableViewCell *subjectCell = (TextFieldTableViewCell *)[self.dateCellsController cellForIndexPath:self.subjectIndexPath ignoringPickerCells:YES];
    YesNoTableViewCell *isPublicCell = (YesNoTableViewCell *)[self.dateCellsController cellForIndexPath:self.isPublicIndexPath ignoringPickerCells:YES];
    self.meetingSubject = subjectCell.textField.text;
    
    NSManagedObjectContext *context = [ContextManager newPrivateContext];
    
    if(self.meeting)
    {
        self.meeting = (Meeting *)[context objectWithID:self.meeting.objectID];
    }
    else
    {
        self.meeting = [Meeting sqk_insertInContext:context];
    }
    
    self.meeting.subject = self.meetingSubject;
    self.meeting.isPublic = @([isPublicCell isYes]);
    self.meeting.startDate = self.meetingStartDate;
    self.meeting.endDate = self.meetingEndDate;
    self.meeting.meetingRoom = (MeetingRoom *)[context objectWithID:self.meetingMeetingRoom.objectID];
    self.meeting.notes = self.meetingNotes;
    self.meeting.hasBeenUpdated = @NO;
    self.meeting.host = (User *)[context objectWithID:[User activeUser].objectID];
    
    [self.meeting removeInvites:self.meeting.invites];
    
    [[self.invitesDictionary[@(InviteStatusInvited)] allObjects] enumerateObjectsUsingBlock:^(User *user, NSUInteger idx, BOOL *stop) {
        [Invite createInviteForMeeting:self.meeting
                              withUser:(User *)[context objectWithID:user.objectID]
                             forStatus:InviteStatusInvited
                           intoContext:self.meeting.managedObjectContext];
    }];
    
    [[self.invitesDictionary[@(InviteStatusAccepted)] allObjects] enumerateObjectsUsingBlock:^(User *user, NSUInteger idx, BOOL *stop) {
        [Invite createInviteForMeeting:self.meeting
                              withUser:(User *)[context objectWithID:user.objectID]
                             forStatus:InviteStatusAccepted
                           intoContext:self.meeting.managedObjectContext];
    }];
    
    [[self.invitesDictionary[@(InviteStatusTentative)] allObjects] enumerateObjectsUsingBlock:^(User *user, NSUInteger idx, BOOL *stop) {
        [Invite createInviteForMeeting:self.meeting
                              withUser:(User *)[context objectWithID:user.objectID]
                             forStatus:InviteStatusTentative
                           intoContext:self.meeting.managedObjectContext];
    }];
    
    [[self.invitesDictionary[@(InviteStatusDeclined)] allObjects] enumerateObjectsUsingBlock:^(User *user, NSUInteger idx, BOOL *stop) {
        [Invite createInviteForMeeting:self.meeting
                              withUser:(User *)[context objectWithID:user.objectID]
                             forStatus:InviteStatusDeclined
                           intoContext:self.meeting.managedObjectContext];
    }];
    
    NSError *meetingError;
    
    NSDictionary *response;
    NSString *successMessage;
    
    if(!self.meeting.meetingID)
    {
        response = [[WebServiceClient sharedInstance] POSTMeeting:[self.meeting JSONRepresentation]
                                                            error:&meetingError];
        self.meeting.meetingID = response[@"MeetingId"];
        successMessage = @"Meeting created";
        
    }
    else
    {
        [[WebServiceClient sharedInstance] PUTMeeting:[self.meeting JSONRepresentation]
                                                error:&meetingError];
        successMessage = @"Meeting updated";
    }
    
    if(meetingError)
    {
        [SVProgressHUD showErrorWithStatus:meetingError.userInfo[webServiceClientErrorMessage] maskType:SVProgressHUDMaskTypeBlack];
    }
    else
    {
        [context save:NULL];
        [SVProgressHUD showSuccessWithStatus:successMessage maskType:SVProgressHUDMaskTypeBlack];
        [self dismissViewControllerAnimated:YES completion:nil];
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
            numberOfRows = [self.invitesDictionary[@(InviteStatusInvited)] allObjects].count;
            break;
        }
            
        case TableViewSectionAcceptedInvites:
        {
            numberOfRows = [self.invitesDictionary[@(InviteStatusAccepted)] allObjects].count;
            break;
        }
            
        case TableViewSectionTentativeInvites:
        {
            numberOfRows = [self.invitesDictionary[@(InviteStatusTentative)] allObjects].count;
            break;
        }
            
        case TableViewSectionDeclinedInvites:
        {
            numberOfRows = [self.invitesDictionary[@(InviteStatusDeclined)] allObjects].count;
            break;
        }
            
        case TableViewSectionActions:
        {
            if(self.userCanEdit)
            {
                if(self.meeting.meetingID)
                {
                    numberOfRows = 2;
                }
                else
                {
                    numberOfRows = 1;
                }
            }
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
                    textFieldCell.enabled = self.userCanEdit;
                    
                    cell = textFieldCell;
                    break;
                }
                    
                case TableViewSectionMeetingDetailsRowRoom:
                {
                    cell = [tableView dequeueReusableCellWithIdentifier:rightDetailCellWithIdentifier forIndexPath:indexPath];
                    cell.textLabel.text = @"Room";
                    cell.detailTextLabel.text = self.meetingMeetingRoom.name ? self.meetingMeetingRoom.name : @"Not set";
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    break;
                }
                    
                case TableViewSectionMeetingDetailsRowStartDate:
                {
                    cell = [tableView dequeueReusableCellWithIdentifier:rightDetailCellWithIdentifier forIndexPath:indexPath];
                    cell.textLabel.text = @"Start date";
                    cell.detailTextLabel.text = [self.dateFormatter stringFromDate:self.meetingStartDate];
                    break;
                }
                    
                case TableViewSectionMeetingDetailsRowEndDate:
                {
                    cell = [tableView dequeueReusableCellWithIdentifier:rightDetailCellWithIdentifier forIndexPath:indexPath];
                    cell.textLabel.text = @"End date";
                    cell.detailTextLabel.text = [self.dateFormatter stringFromDate:self.meetingEndDate];
                    break;
                }
                    
                case TableViewSectionMeetingDetailsRowIsPublic:
                {
                    YesNoTableViewCell *yesNoCell = (YesNoTableViewCell *)[tableView dequeueReusableCellWithIdentifier:yesNoCellWithIdentifier forIndexPath:indexPath];
                    
                    yesNoCell.label.text = @"Is public";
                    yesNoCell.enabled = self.userCanEdit;
                    
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
                    cell.detailTextLabel.text = self.meetingNotes ? self.meetingNotes : @"No notes";
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    break;
                }
            }
            break;
        }
            
        case TableViewSectionInvites:
        {
            cell = [tableView dequeueReusableCellWithIdentifier:basicCellWithIdentifier forIndexPath:indexPath];
            User *user = (User *)[self.invitesDictionary[@(InviteStatusInvited)] allObjects][indexPath.row];
            cell.textLabel.text = user.username;
            cell.textLabel.textAlignment = NSTextAlignmentLeft;
            cell.textLabel.textColor = [UIColor blackColor];
            break;
        }
            
        case TableViewSectionAcceptedInvites:
        {
            cell = [tableView dequeueReusableCellWithIdentifier:basicCellWithIdentifier forIndexPath:indexPath];
            User *user = (User *)[self.invitesDictionary[@(InviteStatusAccepted)] allObjects][indexPath.row];
            cell.textLabel.text = user.username;
            cell.textLabel.textAlignment = NSTextAlignmentLeft;
            cell.textLabel.textColor = [UIColor blackColor];
            break;
        }
        
        case TableViewSectionTentativeInvites:
        {
            cell = [tableView dequeueReusableCellWithIdentifier:basicCellWithIdentifier forIndexPath:indexPath];
            User *user = (User *)[self.invitesDictionary[@(InviteStatusTentative)] allObjects][indexPath.row];
            cell.textLabel.text = user.username;
            cell.textLabel.textAlignment = NSTextAlignmentLeft;
            cell.textLabel.textColor = [UIColor blackColor];
            break;
        }
            
        case TableViewSectionDeclinedInvites:
        {
            cell = [tableView dequeueReusableCellWithIdentifier:basicCellWithIdentifier forIndexPath:indexPath];
            User *user = (User *)[self.invitesDictionary[@(InviteStatusDeclined)] allObjects][indexPath.row];
            cell.textLabel.text = user.username;
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
                case TableViewSectionMeetingDetailsRowRoom:
                {
                    if(self.userCanEdit)
                    {
                        SearchableSelectableTableViewController *searchableSelectableTableViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SelectableListTableViewController"];
                        searchableSelectableTableViewController.classOfItems = [MeetingRoom class];
                        searchableSelectableTableViewController.itemTextProperty = @"name";
                        searchableSelectableTableViewController.itemSearchProperty = @"name";
                        searchableSelectableTableViewController.didSelectItemBlock = ^void(id selectedItem, NSInteger selectedIndex) {
                            
                            self.meetingMeetingRoom = selectedItem;
                        };
                        
                        [self.navigationController showViewController:searchableSelectableTableViewController sender:self];
                        [self.dateCellsController hidePicker];
                    }
                    break;
                }

                case TableViewSectionMeetingDetailsRowNotes:
                {
                    TextViewViewController *textViewViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"TextViewViewController"];
                    textViewViewController.currentText = self.meetingNotes;
                    textViewViewController.enabled = self.userCanEdit;
                    textViewViewController.doneButtonWasTappedBlock = ^void(NSString *updatedText) {
                        self.meetingNotes = updatedText;
                    };
                    
                    [self.navigationController showViewController:textViewViewController sender:self];
                    [self.dateCellsController hidePicker];
                    break;
                }
            }
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
                    
                    NSMutableSet *filterSet = [NSMutableSet set];
                    
                    [filterSet addObjectsFromArray:[[User usernamesForUsers:self.invitesDictionary[@(InviteStatusInvited)]] allObjects]];
                    [filterSet addObjectsFromArray:[[User usernamesForUsers:self.invitesDictionary[@(InviteStatusAccepted)]] allObjects]];
                    [filterSet addObjectsFromArray:[[User usernamesForUsers:self.invitesDictionary[@(InviteStatusTentative)]] allObjects]];
                    [filterSet addObjectsFromArray:[[User usernamesForUsers:self.invitesDictionary[@(InviteStatusDeclined)]] allObjects]];
                    
                    User *activeUser = [User activeUser];
                    if(activeUser)
                    {
                        [filterSet addObject:[[[User usernamesForUsers:[NSSet setWithObject:activeUser]] allObjects] firstObject]];
                    }
                    
                    searchableSelectableTableViewController.filterItems = filterSet;
                    searchableSelectableTableViewController.didSelectItemBlock = ^void(id selectedItem, NSInteger selectedIndex) {

                        NSMutableSet *set = [self.invitesDictionary[@(InviteStatusInvited)] mutableCopy];
                        
                        if(set.count > 0)
                        {
                            [set addObject:selectedItem];
                            self.invitesDictionary[@(InviteStatusInvited)] = [set sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"username" ascending:YES]]] ;
                        }
                        else
                        {
                            self.invitesDictionary[@(InviteStatusInvited)] = [NSSet setWithObject:selectedItem];
                        }
                        
                        
                        [self.tableView reloadData];
                    };
                    
                    [self.navigationController showViewController:searchableSelectableTableViewController sender:self];
                    break;
                }
                
                case TableViewSectionActionsRowDeleteMeeting:
                {
                    NSError *deleteError;
                    [[WebServiceClient sharedInstance] DELETEMeetingWithID:self.meeting.meetingID
                                                                     error:&deleteError];
                    if(deleteError)
                    {
                        [SVProgressHUD showErrorWithStatus:deleteError.userInfo[webServiceClientErrorMessage] maskType:SVProgressHUDMaskTypeBlack];
                    }
                    else
                    {
                        [self.meeting sqk_deleteObject];
                        [self dismissViewControllerAnimated:YES completion:nil];
                    }
                    break;
                }
            }
            break;
        }
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section)
    {
        case TableViewSectionInvites:
        case TableViewSectionAcceptedInvites:
        case TableViewSectionTentativeInvites:
        case TableViewSectionDeclinedInvites:
        {
            return self.userCanEdit;
            break;
        }
            
        default:
        {
            return NO;
            break;
        }
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"Remove invite";
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        NSString *username = cell.textLabel.text;
        User *user = [User userWithUsername:username inContext:[ContextManager mainContext]];
        NSMutableSet *set = [self.invitesDictionary[@(indexPath.section - 1)] mutableCopy];
        [set removeObject:user];
        self.invitesDictionary[@(indexPath.section - 1)] = set;
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
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
        self.meetingStartDate = date;
    }
    else
    {
        self.meetingEndDate = date;
    }
}

@end
