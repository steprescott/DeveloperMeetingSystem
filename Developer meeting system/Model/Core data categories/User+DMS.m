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
             managedObject.username = dictionary[@"username"];
             managedObject.firstName = dictionary[@"firstName"];
             managedObject.lastName = dictionary[@"lastName"];
             managedObject.role = dictionary[@"role"];
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
    
    if(error)
    {
        NSLog(@"Error when importing. %s %@", __PRETTY_FUNCTION__, error.localizedDescription);
    }
    
    return user;
}

@end
