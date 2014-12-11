//
//  ContextManager.h
//  Developer meeting system
//
//  Created by Ste Prescott on 05/12/2014.
//  Copyright (c) 2014 Ste Prescott. All rights reserved.
//

#import "Meeting+DMS.h"
#import "MeetingRoom+DMS.h"
#import "User+DMS.h"
#import "Invite+DMS.h"

@interface ContextManager : SQKContextManager

+ (NSManagedObjectContext *)mainContext;
+ (NSManagedObjectContext *)newPrivateContext;
+ (void)deleteAllData;

@end
