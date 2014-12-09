//
//  User.h
//  Developer meeting system
//
//  Created by Ste Prescott on 08/12/2014.
//  Copyright (c) 2014 Ste Prescott. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Invite;

@interface User : NSManagedObject

@property (nonatomic, retain) NSString * contactNumber;
@property (nonatomic, retain) NSString * firstName;
@property (nonatomic, retain) NSString * lastName;
@property (nonatomic, retain) NSString * role;
@property (nonatomic, retain) NSString * username;
@property (nonatomic, retain) NSNumber * hasBeenUpdated;
@property (nonatomic, retain) NSSet *invites;
@end

@interface User (CoreDataGeneratedAccessors)

- (void)addInvitesObject:(Invite *)value;
- (void)removeInvitesObject:(Invite *)value;
- (void)addInvites:(NSSet *)values;
- (void)removeInvites:(NSSet *)values;

@end
