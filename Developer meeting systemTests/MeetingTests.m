//
//  MeetingTests.m
//  Developer meeting system
//
//  Created by Ste Prescott on 08/12/2014.
//  Copyright (c) 2014 Ste Prescott. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#import "WebServiceClient.h"

#import <SQKDataKit/SQKDataKit.h>
#import "ContextManager.h"
#import "Meeting+DMS.h"

@interface MeetingTests : XCTestCase

@property (nonatomic, strong) NSManagedObjectContext *mainContext;

@end

@implementation MeetingTests

- (void)setUp
{
    [super setUp];
    
    self.mainContext = [ContextManager mainContext];
}

- (void)testImportingOfMeetings
{
    NSManagedObjectContext *privateContext = [ContextManager newPrivateContext];
    
    NSError *error;
    
    NSString *meetingID = @"71A32F1A-1439-43E9-AE31-A151514EE8C9";
    NSString *meetingSubject = @"Test meeting";
    NSString *meetingLocation = @"Test meeting location";
    NSDate *meetingStartDate = [NSDate new];
    NSDate *meetingEndDate = [NSDate dateWithTimeInterval:(60 * 30) sinceDate:meetingStartDate];
    
    NSArray *testObjects = @[@{@"meetingId" : meetingID,
                               @"subject" : meetingSubject,
                               @"location" : meetingLocation,
                               @"startDate" : meetingStartDate,
                               @"endDate" : meetingEndDate}];
    
    [Meeting importMeetings:testObjects intoContext:privateContext];
    
    NSFetchRequest *request = [Meeting sqk_fetchRequest];
    NSArray *fetchedObjects = [privateContext executeFetchRequest:request error:&error];
    
    if(error)
    {
        NSLog(@"Error when executing request. %s %@", __PRETTY_FUNCTION__, error.localizedDescription);
    }
    
    Meeting *testMeeting = [fetchedObjects firstObject];
    
    XCTAssert(fetchedObjects.count == 1);
    XCTAssert(testMeeting.meetingID = meetingID);
    XCTAssert(testMeeting.subject = meetingSubject);
    XCTAssert(testMeeting.startDate = meetingStartDate);
    XCTAssert(testMeeting.endDate = meetingEndDate);
}

- (void)testGetAllRequestTime
{
    __block NSError *mainError;
    
//    [self measureBlock:^{
//        [[WebServiceClient sharedInstance] GETAllMeetingsSuccess:nil failure:^(NSError *error, NSInteger statusCode, NSString *reason) {
//            mainError = error;
//        }];
//    }];
    
    XCTAssertFalse(mainError);
}

@end
