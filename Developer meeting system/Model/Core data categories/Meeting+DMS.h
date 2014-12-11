//
//  Meeting+DMS.h
//  Developer meeting system
//
//  Created by Ste Prescott on 05/12/2014.
//  Copyright (c) 2014 Ste Prescott. All rights reserved.
//

#import "Meeting.h"
#import "Invite+DMS.h"

@interface Meeting (DMS)

+ (BOOL)importMeetings:(NSArray *)meetings intoContext:(NSManagedObjectContext *)context;
+ (void)deleteInvalidMeetingsInContext:(NSManagedObjectContext *)context;

- (NSSet *)invitesWithStatus:(InviteStatus)inviteStauts;
- (NSSet *)usersInMeeting;
- (NSSet *)usersInMeetingWithInvitesWithStatus:(InviteStatus)inviteStauts;
- (NSDictionary *)JSONRepresentation;

@end
