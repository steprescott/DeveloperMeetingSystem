//
//  MeetingRoom.h
//  Developer meeting system
//
//  Created by Ste Prescott on 08/12/2014.
//  Copyright (c) 2014 Ste Prescott. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Meeting;

@interface MeetingRoom : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * meetingRoomID;
@property (nonatomic, retain) NSNumber * containsProjector;
@property (nonatomic, retain) NSString * details;
@property (nonatomic, retain) NSSet *meetings;
@end

@interface MeetingRoom (CoreDataGeneratedAccessors)

- (void)addMeetingsObject:(Meeting *)value;
- (void)removeMeetingsObject:(Meeting *)value;
- (void)addMeetings:(NSSet *)values;
- (void)removeMeetings:(NSSet *)values;

@end
