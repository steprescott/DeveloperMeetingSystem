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
    
    request = [Invite sqk_fetchRequest];
    objects = [context executeFetchRequest:request error:&error];
    
    if(error)
    {
        NSLog(@"Error when executing fetch request. %s %@", __PRETTY_FUNCTION__, error.localizedDescription);
        return NO;
    }
    
    [objects makeObjectsPerformSelector:@selector(setHasBeenUpdated:) withObject:@NO];
    
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
    
    [Meeting sqk_insertOrUpdate:meetings
                 uniqueModelKey:@"meetingID"
                uniqueRemoteKey:@"Id"
            propertySetterBlock:^(NSDictionary *dictionary, Meeting *managedObject) {
                managedObject.meetingID = dictionary[@"Id"];
                managedObject.subject = dictionary[@"Subject"];
                managedObject.startDate = [dateFormatter dateFromString:dictionary[@"StartDateTime"]];
                managedObject.endDate = [dateFormatter dateFromString:dictionary[@"EndDateTime"]];
                managedObject.isPublic = dictionary[@"IsPublic"];
                managedObject.notes = dictionary[@"MeetingNotes"];
                managedObject.hasBeenUpdated = @YES;
                
                managedObject.meetingRoom = [MeetingRoom meetingRoomWithName:dictionary[@"MeetingRoom"][@"Name"] inContext:context];
                
                managedObject.host = [User userWithUsername:dictionary[@"HostUser"][@"Username"] inContext:context];
                managedObject.host.firstName = dictionary[@"HostUser"][@"Firstname"];
                managedObject.host.lastName = dictionary[@"HostUser"][@"Surname"];
                managedObject.host.contactNumber = dictionary[@"HostUser"][@"ContactNumber"];
                
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

+ (void)deleteInvalidMeetingsInContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *request = [Meeting sqk_fetchRequest];
    request.predicate = [NSPredicate predicateWithFormat:@"hasBeenUpdated == NO"];
    
    NSError *error;
    NSArray *objects = [context executeFetchRequest:request error:&error];
    [objects makeObjectsPerformSelector:@selector(sqk_deleteObject)];
    
    if(error)
    {
        NSLog(@"Error when deleting invalid meetings. %s %@", __PRETTY_FUNCTION__, error.localizedDescription);
    }
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
    
    [set addObject:self.host];
    
    return set;
}

- (NSSet *)usersInMeetingWithInvitesWithStatus:(InviteStatus)inviteStauts
{
    NSSet *filteredInvites = [self.invites filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"status = %i", inviteStauts]];
    NSMutableSet *set = [NSMutableSet set];
    
    [filteredInvites enumerateObjectsUsingBlock:^(Invite *invite, BOOL *stop) {
        [set addObject:invite.user];
    }];
    
    return set;
}

- (NSSet *)usernamesForUsers:(NSSet *)users
{
    NSMutableSet *set = [NSMutableSet set];
    
    [users enumerateObjectsUsingBlock:^(User *user, BOOL *stop) {
        [set addObject:user.username];
    }];
    
    return set;
}

- (NSDictionary *)JSONRepresentation
{
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
    
    return @{@"Id": self.meetingID ? self.meetingID : @"",
             @"Subject": self.subject ? self.subject : @"",
             @"StartDateTime": [dateFormatter stringFromDate:self.startDate],
             @"EndDateTime": [dateFormatter stringFromDate:self.endDate],
             @"IsPublic": [self.isPublic boolValue] ? @"true" : @"false",
             @"MeetingNotes": self.notes ? self.notes : @"",
             @"HostUser": @{
                     @"Username": self.host.username ? self.host.username : @"",
                     @"Firstname": self.host.firstName ? self.host.firstName : @"",
                     @"Surname": self.host.lastName ? self.host.lastName : @"",
                     @"ContactNumber": self.host.contactNumber ? self.host.contactNumber : @""
                     },
             @"MeetingRoom": @{
                     @"Name": self.meetingRoom.name ? self.meetingRoom.name : @"",
                     @"Details": self.meetingRoom.details ? self.meetingRoom.details : @"",
                     @"ContainsProjector": [self.meetingRoom.containsProjector boolValue] ? @"true" : @"false"
                     },
             @"UsersInvited": [[self usernamesForUsers:[self usersInMeetingWithInvitesWithStatus:InviteStatusInvited]] allObjects],
             @"UsersAccepted": [[self usernamesForUsers:[self usersInMeetingWithInvitesWithStatus:InviteStatusAccepted]] allObjects],
             @"UsersTentative": [[self usernamesForUsers:[self usersInMeetingWithInvitesWithStatus:InviteStatusTentative]] allObjects],
             @"UsersDeclined": [[self usernamesForUsers:[self usersInMeetingWithInvitesWithStatus:InviteStatusDeclined]] allObjects]};
}

@end
