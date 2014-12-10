//
//  Invite.h
//  Developer meeting system
//
//  Created by Ste Prescott on 09/12/2014.
//  Copyright (c) 2014 Ste Prescott. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Meeting, User;

@interface Invite : NSManagedObject

@property (nonatomic, retain) NSString * inviteID;
@property (nonatomic, retain) NSNumber * status;
@property (nonatomic, retain) Meeting *meeting;
@property (nonatomic, retain) User *user;

@end
