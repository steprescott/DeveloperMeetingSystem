//
//  MeetingRoom+DMS.m
//  Developer meeting system
//
//  Created by Ste Prescott on 08/12/2014.
//  Copyright (c) 2014 Ste Prescott. All rights reserved.
//

#import "MeetingRoom+DMS.h"

@implementation MeetingRoom (DMS)

+ (BOOL)importMeetingRooms:(NSArray *)meetingRooms intoContext:(NSManagedObjectContext *)context
{
    NSError *error;
    
    [MeetingRoom sqk_insertOrUpdate:meetingRooms
              uniqueModelKey:@"name"
             uniqueRemoteKey:@"Name"
         propertySetterBlock:^(NSDictionary *dictionary, MeetingRoom *managedObject) {
             managedObject.meetingRoomID = dictionary[@"Id"];
             managedObject.name = dictionary[@"Name"];
             managedObject.details = dictionary[@"Details"];
             managedObject.containsProjector = dictionary[@"ContainsProjector"];
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

+ (MeetingRoom *)meetingRoomWithName:(NSString *)meetingRoomName inContext:(NSManagedObjectContext *)context
{
    NSError *error;
    NSFetchRequest *request = [MeetingRoom sqk_fetchRequest];
    request.predicate = [NSPredicate predicateWithFormat:@"name == %@", meetingRoomName];
    
    NSArray *objects = [context executeFetchRequest:request error:&error];
    
    if(error)
    {
        NSLog(@"Error when executing fetch request. %s %@", __PRETTY_FUNCTION__, error.localizedDescription);
    }
    
    return [objects firstObject];
}

@end
