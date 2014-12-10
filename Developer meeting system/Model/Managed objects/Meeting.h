//
//  Meeting.h
//  Developer meeting system
//
//  Created by Ste Prescott on 09/12/2014.
//  Copyright (c) 2014 Ste Prescott. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Invite, MeetingRoom, User;

@interface Meeting : NSManagedObject

@property (nonatomic, retain) NSDate * endDate;
@property (nonatomic, retain) NSNumber * hasBeenUpdated;
@property (nonatomic, retain) NSNumber * isPublic;
@property (nonatomic, retain) NSString * meetingID;
@property (nonatomic, retain) NSString * notes;
@property (nonatomic, retain) NSDate * startDate;
@property (nonatomic, retain) NSString * subject;
@property (nonatomic, retain) NSSet *invites;
@property (nonatomic, retain) MeetingRoom *meetingRoom;
@property (nonatomic, retain) User *host;
@end

@interface Meeting (CoreDataGeneratedAccessors)

- (void)addInvitesObject:(Invite *)value;
- (void)removeInvitesObject:(Invite *)value;
- (void)addInvites:(NSSet *)values;
- (void)removeInvites:(NSSet *)values;

- (NSDate *)day;

@end
