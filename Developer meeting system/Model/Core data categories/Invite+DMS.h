//
//  Invite+DMS.h
//  Developer meeting system
//
//  Created by Ste Prescott on 08/12/2014.
//  Copyright (c) 2014 Ste Prescott. All rights reserved.
//

#import "Invite.h"

typedef NS_ENUM(NSUInteger, InviteStatus) {
    InviteStatusInvited = 0,
    InviteStatusAccepted,
    InviteStatusTentative,
    InviteStatusDeclined
};
@interface Invite (DMS)

+ (void)createInviteForMeeting:(Meeting *)meeting withUser:(User *)user forStatus:(InviteStatus)inviteStauts intoContext:(NSManagedObjectContext *)context;

@end
