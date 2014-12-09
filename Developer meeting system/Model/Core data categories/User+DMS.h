//
//  User+DMS.h
//  Developer meeting system
//
//  Created by Ste Prescott on 08/12/2014.
//  Copyright (c) 2014 Ste Prescott. All rights reserved.
//

#import "User.h"

@interface User (DMS)

+ (BOOL)importUsers:(NSArray *)users intoContext:(NSManagedObjectContext *)context;
+ (User *)importUserWithUsername:(NSString *)username intoContext:(NSManagedObjectContext *)context;
+ (NSSet *)usernamesForUsers:(NSSet *)users;

@end
