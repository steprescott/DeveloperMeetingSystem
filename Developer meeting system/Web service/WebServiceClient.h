//
//  WebServiceClient.h
//  Developer meeting system
//
//  Created by Ste Prescott on 04/12/2014.
//  Copyright (c) 2014 Ste Prescott. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, RequestType) {
    RequestTypeGET = 0,
    RequestTypePOST,
    RequestTypePUT,
    RequestTypeDELETE
};

static NSString *webServiceClientErrorMessage = @"WebServiceClientErrorMessage";

@interface WebServiceClient : NSObject

@property (nonatomic, strong) NSString *userToken;
@property (nonatomic, strong) NSString *username;

+ (instancetype)sharedInstance;

/**
 *  If we have previously validated a User then the Web Client will have a User Token.
 *
 *  @return Bool that shows if the Web Client has a valid User Token
 */
+ (BOOL)hasUserToken;

+ (void)synchronizeWithError:(NSError **)error;

- (void)asyncLoginUsername:(NSString *)username password:(NSString *)password success:(void (^)(NSDictionary *JSON))successBlock failure:(void (^)(NSError *error))failureBlock;

- (id)GETAllMeetingsRoomsWithError:(NSError **)error;
- (id)GETAllUserDetailsWithError:(NSError **)error;
- (id)GETAllMeetingsWithError:(NSError **)error;

- (id)POSTMeeting:(NSDictionary *)JSON error:(NSError **)error;

- (id)PUTMeeting:(NSDictionary *)JSON error:(NSError **)error;

- (id)DELETEMeetingWithID:(NSString *)meetingID error:(NSError **)error;

@end
