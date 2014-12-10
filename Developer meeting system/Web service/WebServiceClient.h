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

@interface WebServiceClient : NSObject

+ (instancetype)sharedInstance;

/**
 *  If we have previously validated a User then the Web Client will have a User Token.
 *
 *  @return Bool that shows if the Web Client has a valid User Token
 */
+ (BOOL)hasUserToken;

/**
 *  This method is the only one that calls an endpoint that doesn't require a User Token.
 *  Use this to return a User Token that can be used to validate access level.
 *
 *  @param username     The username of the User you wish to validate
 *  @param password     The password of the User you wish to validate
 *  @param successBlock This is the block that will be called when the API endpoint returns a 200.
 *                      Within this JSON is the User Token for the user.
 *  @param failureBlock This is the block that will be called when the API endpoint returns anything other than a 200.
 *                      401 = Invalid API Key
                        403 = IP not whitelisted
                        404 = User not found
 */
- (void)loginWithUsername:(NSString *)username password:(NSString *)password success:(void (^)(NSDictionary *JSON))successBlock failure:(void (^)(NSError *error))failureBlock;

/**
 *  GET Methods. These aim to retreive infomation from the API.
 *
 *  @param successBlock This is the block that will be called when the API endpoint returns a 200.
 *  @param failureBlock This is the block that will be called when the API endpoint returns anything other than a 200.
 */
- (void)GETAllMeetingsSuccess:(void (^)(NSDictionary *JSON))successBlock failure:(void (^)(NSError *error))failureBlock;
- (void)GETAllMeetingsRoomsSuccess:(void (^)(NSDictionary *JSON))successBlock failure:(void (^)(NSError *error))failureBlock;
- (void)GETAllUserDetailsSuccess:(void (^)(NSDictionary *JSON))successBlock failure:(void (^)(NSError *error))failureBlock;
- (void)GETAllRolesSuccess:(void (^)(NSDictionary *JSON))successBlock failure:(void (^)(NSError *error))failureBlock;

/**
 *  POST Methods. POST requests inserts a new object on the API.
 *
 *  @param successBlock This is the block that will be called when the API endpoint returns a 200.
 *  @param failureBlock This is the block that will be called when the API endpoint returns anything other than a 200.
 */
- (void)POSTMeeting:(NSDictionary *)meetingJSON success:(void (^)(NSDictionary *JSON))successBlock failure:(void (^)(NSError *error))failureBlock;

/**
 *  PUT Methods. PUT requests updates objects currently on the API.
 *
 *  @param successBlock This is the block that will be called when the API endpoint returns a 200.
 *  @param failureBlock This is the block that will be called when the API endpoint returns anything other than a 200.
 */
- (void)PUTMeeting:(NSDictionary *)meetingJSON success:(void (^)(NSDictionary *JSON))successBlock failure:(void (^)(NSError *error))failureBlock;

/**
 *  DELETE Methods. DELETE requests deletes the object from the API.
 *
 *  @param successBlock This is the block that will be called when the API endpoint returns a 200.
 *  @param failureBlock This is the block that will be called when the API endpoint returns anything other than a 200.
 */
- (void)DELETEMeetingWithID:(NSString *)meetingID success:(void (^)(NSDictionary *JSON))successBlock failure:(void (^)(NSError *error))failureBlock;

@end
