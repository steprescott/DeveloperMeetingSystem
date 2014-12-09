//
//  Meeting+DMS.m
//  Developer meeting system
//
//  Created by Ste Prescott on 05/12/2014.
//  Copyright (c) 2014 Ste Prescott. All rights reserved.
//

#import "Meeting+DMS.h"
#import "User+DMS.h"
#import "ContextManager.h"

@implementation Meeting (DMS)

+ (BOOL)importMeetings:(NSArray *)meetings intoContext:(NSManagedObjectContext *)context
{
    NSError *error;
    NSFetchRequest *request = [Meeting sqk_fetchRequest];
    NSArray *objects = [context executeFetchRequest:request error:&error];
    
    if(error)
    {
        NSLog(@"Error when executing fetch request. %s %@", __PRETTY_FUNCTION__, error.localizedDescription);
        return NO;
    }
    
    [objects makeObjectsPerformSelector:@selector(setHasBeenUpdated:) withObject:@NO];
    
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZ"];
    
    [Meeting sqk_insertOrUpdate:meetings
                 uniqueModelKey:@"meetingID"
                uniqueRemoteKey:@"Id"
            propertySetterBlock:^(NSDictionary *dictionary, Meeting *managedObject) {
                managedObject.meetingID = dictionary[@"Id"];
                managedObject.subject = dictionary[@"Subject"];
                managedObject.startDate = [dateFormatter dateFromString:dictionary[@"StartDateTime"]];
                managedObject.endDate = [dateFormatter dateFromString:dictionary[@"EndDateTime"]];
                managedObject.hasBeenUpdated = @YES;
                managedObject.meetingRoom = [MeetingRoom meetingRoomWithName:dictionary[@"MeetingRoom"][@"Name"] inContext:context];
                
                NSArray *invitedUsers = dictionary[@"UsersInvited"];
                NSArray *acceptedUsers = dictionary[@"UsersAccepted"];
                NSArray *tentativeUsers = dictionary[@"UsersTentative"];
                NSArray *declinedUsers = dictionary[@"UsersDeclined"];
                
                [invitedUsers enumerateObjectsUsingBlock:^(NSString *username, NSUInteger idx, BOOL *stop) {
                    User *user = [User importUserWithUsername:username intoContext:context];
                    [Invite createInviteForMeeting:managedObject
                                          withUser:user
                                         forStatus:InviteStatusInvited
                                       intoContext:context];
                }];
                
                [acceptedUsers enumerateObjectsUsingBlock:^(NSString *username, NSUInteger idx, BOOL *stop) {
                    User *user = [User importUserWithUsername:username intoContext:context];
                    [Invite createInviteForMeeting:managedObject
                                          withUser:user
                                         forStatus:InviteStatusAccepted
                                       intoContext:context];
                }];
                
                [tentativeUsers enumerateObjectsUsingBlock:^(NSString *username, NSUInteger idx, BOOL *stop) {
                    User *user = [User importUserWithUsername:username intoContext:context];
                    [Invite createInviteForMeeting:managedObject
                                          withUser:user
                                         forStatus:InviteStatusTentative
                                       intoContext:context];
                }];
                
                [declinedUsers enumerateObjectsUsingBlock:^(NSString *username, NSUInteger idx, BOOL *stop) {
                    User *user = [User importUserWithUsername:username intoContext:context];
                    [Invite createInviteForMeeting:managedObject
                                          withUser:user
                                         forStatus:InviteStatusDeclined
                                       intoContext:context];
                }];
            }
                 privateContext:context
                          error:&error];
    
    if(error)
    {
        NSLog(@"Error when importing. %s %@", __PRETTY_FUNCTION__, error.localizedDescription);
        return NO;
    }
    
    return YES;
}

- (NSSet *)invitesWithStatus:(InviteStatus)inviteStauts
{
    return [self.invites filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"status = %i", inviteStauts]];
}

- (NSSet *)usersInMeeting
{
    NSMutableSet *set = [NSMutableSet set];
    
    [self.invites enumerateObjectsUsingBlock:^(Invite *invite, BOOL *stop) {
        [set addObject:invite.user];
    }];
    
    return set;
}

@end
