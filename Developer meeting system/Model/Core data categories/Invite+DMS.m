//
//  Invite+DMS.m
//  Developer meeting system
//
//  Created by Ste Prescott on 08/12/2014.
//  Copyright (c) 2014 Ste Prescott. All rights reserved.
//

#import "Invite+DMS.h"

@implementation Invite (DMS)

+ (void)createInviteForMeeting:(Meeting *)meeting withUser:(User *)user forStatus:(InviteStatus)inviteStauts intoContext:(NSManagedObjectContext *)context
{
    Invite *invite = [Invite sqk_insertInContext:context];
    invite.meeting = meeting;
    invite.user = user;
    invite.status = @(inviteStauts);
}
@end
