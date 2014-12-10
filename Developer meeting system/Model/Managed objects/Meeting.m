//
//  Meeting.m
//  Developer meeting system
//
//  Created by Ste Prescott on 09/12/2014.
//  Copyright (c) 2014 Ste Prescott. All rights reserved.
//

#import "Meeting.h"
#import "Invite.h"
#import "MeetingRoom.h"
#import "User.h"
#import <NSDate+CupertinoYankee.h>

@implementation Meeting

@dynamic endDate;
@dynamic hasBeenUpdated;
@dynamic isPublic;
@dynamic meetingID;
@dynamic notes;
@dynamic startDate;
@dynamic subject;
@dynamic invites;
@dynamic meetingRoom;
@dynamic host;

- (NSDate *)day
{
    return [self.startDate beginningOfDay];
}

@end
