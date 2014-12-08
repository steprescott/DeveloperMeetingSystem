//
//  ContextManager.m
//  Developer meeting system
//
//  Created by Ste Prescott on 05/12/2014.
//  Copyright (c) 2014 Ste Prescott. All rights reserved.
//

#import "ContextManager.h"

static SQKContextManager *sharedManager;

@implementation ContextManager

+ (SQKContextManager *)sharedManager
{
    if (!sharedManager)
    {
        NSManagedObjectModel *model = [NSManagedObjectModel mergedModelFromBundles:nil];
        sharedManager = [[SQKContextManager alloc] initWithStoreType:NSSQLiteStoreType managedObjectModel:model storeURL:nil];
    }
    
    return sharedManager;
}

+ (NSManagedObjectContext *)mainContext
{
    return [[ContextManager sharedManager] mainContext];
}

+ (NSManagedObjectContext *)newPrivateContext
{
    return [[ContextManager sharedManager] newPrivateContext];
}

@end
