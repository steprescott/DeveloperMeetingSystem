//
//  InviteDetailTableViewController.h
//  Developer meeting system
//
//  Created by Ste Prescott on 12/12/2014.
//  Copyright (c) 2014 Ste Prescott. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Invite+DMS.h"

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
    TableViewSectionActionsRowAcceptInvite = 0,
    TableViewSectionActionsRowTentativeInvite,
    TableViewSectionActionsRowDeclineInvite,
    TableViewSectionActionsRowCount
};


@interface InviteDetailTableViewController : UITableViewController

@property (nonatomic, strong) Invite *invite;

@end
