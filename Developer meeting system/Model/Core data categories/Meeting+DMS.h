//
//  Meeting+DMS.h
//  Developer meeting system
//
//  Created by Ste Prescott on 05/12/2014.
//  Copyright (c) 2014 Ste Prescott. All rights reserved.
//

#import "Meeting.h"

@interface Meeting (DMS)

+ (NSDictionary *)testMeetingData;
+ (BOOL)importMeetings:(NSArray *)meetings intoContext:(NSManagedObjectContext *)context;

- (NSDate *)day;

@end
