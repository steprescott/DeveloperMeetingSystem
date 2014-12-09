//
//  User+DMS.m
//  Developer meeting system
//
//  Created by Ste Prescott on 08/12/2014.
//  Copyright (c) 2014 Ste Prescott. All rights reserved.
//

#import "User+DMS.h"

@implementation User (DMS)

+ (BOOL)importUsers:(NSArray *)users intoContext:(NSManagedObjectContext *)context
{
    NSError *error;
    
    [User sqk_insertOrUpdate:users
              uniqueModelKey:@"username"
             uniqueRemoteKey:@"Username"
         propertySetterBlock:^(NSDictionary *dictionary, User *managedObject) {
             managedObject.username = dictionary[@"Username"];
             managedObject.firstName = dictionary[@"Firstname"];
             managedObject.lastName = dictionary[@"Surname"];
             managedObject.contactNumber = dictionary[@"ContactNumber"];
             managedObject.role = dictionary[@"Role"];
             managedObject.hasBeenUpdated = @YES;
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

+ (User *)importUserWithUsername:(NSString *)username intoContext:(NSManagedObjectContext *)context
{
    NSError *error;
    
    User *user = [User sqk_insertOrFetchWithKey:@"username"
                                          value:username
                                        context:context
                                          error:&error];
    user.hasBeenUpdated = @YES;
    
    if(error)
    {
        NSLog(@"Error when importing. %s %@", __PRETTY_FUNCTION__, error.localizedDescription);
    }
    
    return user;
}

+ (NSSet *)usernamesForUsers:(NSSet *)users
{
    NSMutableSet *set = [NSMutableSet set];
    
    [users enumerateObjectsUsingBlock:^(User *user, BOOL *stop) {
        [set addObject:[NSString stringWithFormat:@"%@", user.username]];
    }];
    
    return set;
}

@end
