//
//  Meeting+DMS.m
//  Developer meeting system
//
//  Created by Ste Prescott on 05/12/2014.
//  Copyright (c) 2014 Ste Prescott. All rights reserved.
//

#import "Meeting+DMS.h"
#import "User+DMS.h"
#import "Invite+DMS.h"
#import "ContextManager.h"

@implementation Meeting (DMS)

+ (NSDictionary *)testMeetingData
{
    NSArray *fetchedMeetings = [[ContextManager mainContext] executeFetchRequest:[Meeting sqk_fetchRequest]
                                                                            error:NULL];
    if(fetchedMeetings.count > 0)
    {
        return @{@"meetings" : @[]};
    }
    
    NSMutableArray *meetings = [NSMutableArray array];
    NSDate *endOfLastMeeting;
    
    for (NSInteger i = 0; i < 100; i++)
    {
        NSString *meetingID = [[NSUUID UUID] UUIDString];
        NSString *subject = [NSString stringWithFormat:@"Meeting %i", i + 1];
        NSString *location = @"Some location";
        NSDate *startDate;
        NSDate *endDate;
        
        if(i == 0)
        {
            startDate = [NSDate dateWithTimeIntervalSinceNow:((60 * 60 * 48) * -1)];
        }
        else
        {
            startDate = [NSDate dateWithTimeInterval:(60 * 15) sinceDate:endOfLastMeeting];
        }
        
        endDate = [NSDate dateWithTimeInterval:(60 * 30) sinceDate:startDate];
        endOfLastMeeting = endDate;
        
        [meetings addObject:@{@"meetingId" : meetingID,
                              @"subject" : subject,
                              @"location" : location,
                              @"startDate" : startDate,
                              @"endDate" : endDate}];
    }
    
    return @{@"meetings" : meetings};
}

+ (BOOL)importMeetings:(NSArray *)meetings intoContext:(NSManagedObjectContext *)context
{
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZ"];
    
    NSError *error;
    
    [Meeting sqk_insertOrUpdate:meetings
                 uniqueModelKey:@"meetingID"
                uniqueRemoteKey:@"Id"
            propertySetterBlock:^(NSDictionary *dictionary, Meeting *managedObject) {
                managedObject.meetingID = dictionary[@"Id"];
                managedObject.subject = dictionary[@"Subject"];
                managedObject.startDate = [dateFormatter dateFromString:dictionary[@"StartDateTime"]];
                managedObject.endDate = [dateFormatter dateFromString:dictionary[@"EndDateTime"]];
                
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

- (NSDate *)day
{
    return [self.startDate beginningOfDay];
}

@end
