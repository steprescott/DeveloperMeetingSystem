//
//  Meeting.m
//  Developer meeting system
//
//  Created by Ste Prescott on 08/12/2014.
//  Copyright (c) 2014 Ste Prescott. All rights reserved.
//

#import "Meeting.h"
#import "Invite.h"
#import "MeetingRoom.h"
#import <NSDate+CupertinoYankee.h>

@implementation Meeting

@dynamic endDate;
@dynamic isPublic;
@dynamic meetingID;
@dynamic startDate;
@dynamic subject;
@dynamic hasBeenUpdated;
@dynamic notes;
@dynamic invites;
@dynamic meetingRoom;

- (NSDate *)day
{
    return [self.startDate beginningOfDay];
}

@end
