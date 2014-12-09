//
//  MeetingRoom+DMS.h
//  Developer meeting system
//
//  Created by Ste Prescott on 08/12/2014.
//  Copyright (c) 2014 Ste Prescott. All rights reserved.
//

#import "MeetingRoom.h"

@interface MeetingRoom (DMS)

+ (BOOL)importMeetingRooms:(NSArray *)meetingRooms intoContext:(NSManagedObjectContext *)context;
+ (MeetingRoom *)meetingRoomWithName:(NSString *)meetingRoomName inContext:(NSManagedObjectContext *)context;

@end
