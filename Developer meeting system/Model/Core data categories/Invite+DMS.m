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
    invite.hasBeenUpdated = @YES;
}

+ (void)deleteInvalidInvitesInContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *request = [Invite sqk_fetchRequest];
    request.predicate = [NSPredicate predicateWithFormat:@"hasBeenUpdated == NO"];
    
    NSError *error;
    NSArray *objects = [context executeFetchRequest:request error:&error];
    [objects makeObjectsPerformSelector:@selector(sqk_deleteObject)];
    
    if(error)
    {
        NSLog(@"Error when deleting invalid invites. %s %@", __PRETTY_FUNCTION__, error.localizedDescription);
    }
}

@end
