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

#import "Meeting+DMS.h"
#import "MeetingRoom.h"

typedef NS_ENUM(NSUInteger, TableViewSection) {
    TableViewSectionMeetingDetails = 0,
    TableViewSectionAcceptedInvites,
    TableViewSectionRejectedInvites,
    TableViewSectionInvites,
    TableViewSectionCount
};

typedef NS_ENUM(NSUInteger, TableViewSectionMeetingDetailsRow) {
    TableViewSectionMeetingDetailsRowSubject = 0,
    TableViewSectionMeetingDetailsRowLocation,
    TableViewSectionMeetingDetailsRowStartDate,
    TableViewSectionMeetingDetailsRowEndDate,
    TableViewSectionMeetingDetailsRowIsPublic,
    TableViewSectionMeetingDetailsRowCount
};

static NSString *textFieldCellWithIdentifier = @"textFieldCell";
static NSString *yesNoCellWithIdentifier = @"yesNoCell";
static NSString *rightDetailCellWithIdentifier = @"rightDetailCell";

@interface MeetingDetailsTableViewController () <UITableViewDataSource, UITableViewDelegate, DateCellsControllerDelegate>

@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic, strong) DateCellsController *dateCellsController;
@property (nonatomic, strong) NSIndexPath *subjectIndexPath;
@property (nonatomic, strong) NSIndexPath *locationIndexPath;
@property (nonatomic, strong) NSIndexPath *isPublicIndexPath;
@property (nonatomic, strong) NSIndexPath *startDateIndexPath;
@property (nonatomic, strong) NSIndexPath *endDateIndexPath;

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
    self.locationIndexPath = [NSIndexPath indexPathForRow:TableViewSectionMeetingDetailsRowLocation
                                               inSection:TableViewSectionMeetingDetails];
    self.isPublicIndexPath = [NSIndexPath indexPathForRow:TableViewSectionMeetingDetailsRowIsPublic
                                               inSection:TableViewSectionMeetingDetails];
    self.startDateIndexPath = [NSIndexPath indexPathForRow:TableViewSectionMeetingDetailsRowStartDate
                                               inSection:TableViewSectionMeetingDetails];
    self.endDateIndexPath = [NSIndexPath indexPathForRow:TableViewSectionMeetingDetailsRowEndDate
                                               inSection:TableViewSectionMeetingDetails];
    
    self.dateCellsController = [[DateCellsController alloc] init];
    [self.dateCellsController attachToTableView:self.tableView
                                   withDelegate:self
                                    withMapping:[@{self.startDateIndexPath : self.meeting.startDate,
                                                   self.endDateIndexPath : self.meeting.endDate} mutableCopy]];
}

- (void)setMeeting:(Meeting *)meeting
{
    _meeting = meeting;
    self.title = meeting.subject;
}

- (IBAction)doneButtonWasTapped:(id)sender
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    
    TextFieldTableViewCell *subjectCell = (TextFieldTableViewCell *)[self.tableView cellForRowAtIndexPath:self.subjectIndexPath];
    TextFieldTableViewCell *locationCell = (TextFieldTableViewCell *)[self.tableView cellForRowAtIndexPath:self.locationIndexPath];
    YesNoTableViewCell *isPublicCell = (YesNoTableViewCell *)[self.tableView cellForRowAtIndexPath:self.isPublicIndexPath];
    
    self.meeting.subject = subjectCell.textField.text;
    
    NSError *error;
    [self.meeting.managedObjectContext save:&error];
    
    if(error)
    {
        NSLog(@"%s Error %@", __PRETTY_FUNCTION__, error.localizedDescription);
    }
    
    if([self.delegate respondsToSelector:@selector(meetingDetailsFormDissmissed)])
    {
        [self.delegate meetingDetailsFormDissmissed];
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
    }
    
    return numberOfRows;
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

                    textFieldCell.label.text = @"Subject :";
                    textFieldCell.textField.text = self.meeting.subject;
                    
                    cell = textFieldCell;
                    break;
                }
                    
                case TableViewSectionMeetingDetailsRowLocation:
                {
                    TextFieldTableViewCell *textFieldCell = (TextFieldTableViewCell *)[tableView dequeueReusableCellWithIdentifier:textFieldCellWithIdentifier forIndexPath:indexPath];
                    
                    textFieldCell.label.text = @"Location :";
                    textFieldCell.textField.text = self.meeting.meetingRoom.name;
                    
                    cell = textFieldCell;
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
                    
                    cell = yesNoCell;
                    break;
                }
            }
            break;
        }
            
        case TableViewSectionAcceptedInvites:
        {
            break;
        }
        
        case TableViewSectionRejectedInvites:
        {
            break;
        }
            
        case TableViewSectionInvites:
        {
            break;
        }
    }
    
    return cell ? cell : [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"defaultCell"];
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
                    
                case TableViewSectionMeetingDetailsRowLocation:
                {
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
            }
            break;
        }
            
        case TableViewSectionAcceptedInvites:
        {
            break;
        }
            
        case TableViewSectionRejectedInvites:
        {
            break;
        }
            
        case TableViewSectionInvites:
        {
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
