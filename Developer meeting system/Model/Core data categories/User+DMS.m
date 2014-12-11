//
//  User+DMS.m
//  Developer meeting system
//
//  Created by Ste Prescott on 08/12/2014.
//  Copyright (c) 2014 Ste Prescott. All rights reserved.
//

#import "User+DMS.h"
#import "WebServiceClient.h"
#import "ContextManager.h"

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

+ (User *)userWithUsername:(NSString *)username inContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *request = [User sqk_fetchRequest];
    request.predicate = [NSPredicate predicateWithFormat:@"username == %@", username];
    
    NSError *error;
    NSArray *objects = [context executeFetchRequest:request error:&error];
    
    if(error)
    {
        NSLog(@"Error when importing. %s %@", __PRETTY_FUNCTION__, error.localizedDescription);
    }
    
    return [objects firstObject];
}

+ (User *)activeUser
{
    return [self userWithUsername:[WebServiceClient sharedInstance].username inContext:[ContextManager mainContext]];
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
