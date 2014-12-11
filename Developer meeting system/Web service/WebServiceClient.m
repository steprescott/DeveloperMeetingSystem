//
//  WebServiceClient.m
//  Developer meeting system
//
//  Created by Ste Prescott on 04/12/2014.
//  Copyright (c) 2014 Ste Prescott. All rights reserved.
//

#import "WebServiceClient.h"
#import "ContextManager.h"
#import <AFNetworking/AFNetworking.h>

static NSString *webAPIBaseURLString = @"http://www.shouldibuyamac.co.uk/api";
static NSString *webAPIKey = @"3456973d-a4da-486f-a595-73eba8854e07";

static NSString *debugUserTokenAdmin = @"1bb78f99-75de-417c-af07-5db40d362bb3";
static NSString *debugUsernameAdmin = @"Admin";

static NSString *debugUserTokenHost = @"13ad1268-46fe-4b7e-8350-37ea76f529c7";
static NSString *debugUsernameHost = @"HostUser";

static NSString *debugUserTokenGuest = @"ce240744-ed9a-4bcd-85df-1d2437baaf6b";
static NSString *debugUsernameGuest = @"GuestUser1";

static NSString *tokenEndPoint = @"token";
static NSString *meetingsEndPoint = @"meeting";
static NSString *meetingRoomEndPoint = @"meetingRoom";
static NSString *userDetailsEndPoint = @"userDetails";
static NSString *rolesEndPoint = @"role";

static NSString *GETWebMethod  = @"GET";
static NSString *POSTWebMethod = @"POST";
static NSString *PUTWebMethod  = @"PUT";
static NSString *DELETEWebMethod  = @"DELETE";

static NSString *webserviceClientErrorDomain = @"DeveloperMeetingSystem.webServiceClientErrorDomain";
static NSString *HTTPErrorDomain = @"DeveloperMeetingSystem.HTTPErrorDomain";
static NSString *webServiceClientErrorMessage = @"WebServiceClientErrorMessage";

@interface WebServiceClient ()

@property (nonatomic, strong) NSString *userToken;

@end

@implementation WebServiceClient

+ (instancetype)sharedInstance
{
    static WebServiceClient *sharedInstance = nil;
    static dispatch_once_t pred;
    
    if (sharedInstance)
    {
        return sharedInstance;
    }
    
    dispatch_once(&pred, ^{
        sharedInstance = [[WebServiceClient alloc] init];
//        sharedInstance.userToken = debugUserTokenHost;
//        sharedInstance.username = debugUsernameHost;
    });
    
    return sharedInstance;
}

+ (BOOL)hasUserToken
{
    return [[WebServiceClient sharedInstance] userToken] ? YES : NO;
}

+ (void)synchronizeWithError:(NSError **)error
{
    NSManagedObjectContext *context = [ContextManager newPrivateContext];
    
    NSError *APIError;
    
    NSArray *meetingRooms = (NSArray *)[[WebServiceClient sharedInstance] GETAllMeetingsRoomsWithError:&APIError];
    NSArray *userDetails = (NSArray *)[[WebServiceClient sharedInstance] GETAllUserDetailsWithError:&APIError];
    NSArray *meetings =(NSArray *)[[WebServiceClient sharedInstance] GETAllMeetingsWithError:&APIError];
    
    if(APIError)
    {
        NSLog(@"Error when talking to the API. %@", APIError.localizedDescription);
        *error = APIError;
    }
    
    [MeetingRoom importMeetingRooms:meetingRooms intoContext:context];
    [User importUsers:userDetails intoContext:context];
    [Meeting importMeetings:meetings intoContext:context];
    [Meeting deleteInvalidMeetingsInContext:context];
    [Invite deleteInvalidInvitesInContext:context];
    
    NSError *saveError;
    [context save:&saveError];
    
    if(saveError)
    {
        NSLog(@"Error when synchronizing. %@", saveError.localizedDescription);
    }
}

+ (NSString *)reasonForStatusCode:(NSInteger)statusCode
{
    NSString *reason = @"Unknown";
    
    switch (statusCode)
    {
        case 304:
        {
            reason = @"Database error, no changes made.";
            break;
        }
            
        case 400:
        {
            reason = @"Bad request, try again later.";
            break;
        }
            
        case 401:
        {
            reason = @"Unauthorised request";
            break;
        }
            
        case 403:
        {
            reason = @"Invalid access level";
            break;
        }
        
        case 404:
        {
            reason = @"Resource not found";
            break;
        }
            
        case 405:
        {
            reason = @"Unauthorised to perform action";
            break;
        }
            
        case 409:
        {
            reason = @"Conflict";
            break;
        }
            
        case 412:
        {
            reason = @"IP is not whitelisted";
            break;
        }
            
        case 498:
        {
            reason = @"User token has expired";
            break;
        }
            
        case 499:
        {
            reason = @"Unauthorised application";
            break;
        }
    }
    
    return reason;
}

- (void)asyncLoginUsername:(NSString *)username password:(NSString *)password success:(void (^)(NSDictionary *JSON))successBlock failure:(void (^)(NSError *error))failureBlock
{
    NSOperationQueue *operationQueue = [[NSOperationQueue alloc] init];
    
    [operationQueue addOperationWithBlock: ^{
        NSURLRequest *request = [self requestForAPIEndPoint:@"token"
                                                  webMethod:GETWebMethod
                                                 parameters:@{@"Username" : username,
                                                              @"Password" : password}];
        
        NSError *error = nil;
        id responseObject = [self sendSynchronousRequest:request error:&error];
        
        [[NSOperationQueue mainQueue] addOperationWithBlock: ^{
            
            if(error && failureBlock)
            {
                failureBlock(error);
            }
            else if(successBlock)
            {
                self.userToken = responseObject[@"Token"];
                self.username = username;
                successBlock(responseObject);
            }
        }];
    }];
}

- (id)GETAllMeetingsRoomsWithError:(NSError **)error
{
    NSURLRequest *request = [self requestForAPIEndPoint:meetingRoomEndPoint
                                              webMethod:GETWebMethod
                                             parameters:nil];
    
    return [self sendSynchronousRequest:request error:error];
}

- (id)GETAllUserDetailsWithError:(NSError **)error
{
    NSURLRequest *request = [self requestForAPIEndPoint:userDetailsEndPoint
                                              webMethod:GETWebMethod
                                             parameters:nil];
    
    return [self sendSynchronousRequest:request error:error];
}

- (id)GETAllMeetingsWithError:(NSError **)error
{
    NSURLRequest *request = [self requestForAPIEndPoint:meetingsEndPoint
                                              webMethod:GETWebMethod
                                             parameters:nil];
    
    return [self sendSynchronousRequest:request error:error];
}

- (id)POSTMeeting:(NSDictionary *)JSON error:(NSError **)error
{
    NSURLRequest *request = [self requestForAPIEndPoint:meetingsEndPoint
                                              webMethod:POSTWebMethod
                                             parameters:JSON];
    
    return [self sendSynchronousRequest:request error:error];
}

- (id)PUTMeeting:(NSDictionary *)JSON error:(NSError **)error
{
    NSURLRequest *request = [self requestForAPIEndPoint:meetingsEndPoint
                                              webMethod:PUTWebMethod
                                             parameters:JSON];
    
    return [self sendSynchronousRequest:request error:error];
}

- (id)DELETEMeetingWithID:(NSString *)meetingID error:(NSError **)error
{
    NSURLRequest *request = [self requestForAPIEndPoint:meetingsEndPoint
                                              webMethod:DELETEWebMethod
                                             parameters:@{@"meetingId" : meetingID}];
    
    return [self sendSynchronousRequest:request error:error];
}

- (NSURLRequest *)requestForAPIEndPoint:(NSString *)endPointString webMethod:(NSString *)webMethod parameters:(NSDictionary *)parameters
{
    NSMutableString *parametersString = [NSMutableString string];
    
    if(webMethod == GETWebMethod || webMethod == DELETEWebMethod)
    {
        [[parameters allKeys] enumerateObjectsUsingBlock:^(NSString *key, NSUInteger idx, BOOL *stop) {
            if(idx == 0)
            {
                [parametersString appendFormat:@"?%@=%@", key, parameters[key]];
            }
            else
            {
                [parametersString appendFormat:@"&%@=%@", key, parameters[key]];
            }
        }];
    }
    
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@%@", webAPIBaseURLString, endPointString, parametersString]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:URL];
    [request setValue:webAPIKey forHTTPHeaderField:@"X-APIKey"];
    [request setHTTPMethod:webMethod];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    if(self.userToken)
    {
        [request setValue:self.userToken forHTTPHeaderField:@"X-UserToken"];
    }
    
    if(webMethod == POSTWebMethod || webMethod == PUTWebMethod)
    {
        NSData *body = [NSJSONSerialization dataWithJSONObject:parameters options:NSJSONWritingPrettyPrinted error:NULL];
        [request setHTTPBody:body];
    }

    return request;
}

- (id)sendSynchronousRequest:(NSURLRequest *)request error:(NSError **)error
{
    NSHTTPURLResponse *response = nil;
    NSError *responseError;
    NSData *reponseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&responseError];
    
    id JSON = reponseData != nil ? [NSJSONSerialization JSONObjectWithData:reponseData options:0 error:NULL] : nil;
    
    if(error)
    {
        if([response statusCode] != 200)
        {
            NSString *message = JSON[@"Message"];
            NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithDictionary:responseError.userInfo];
            
            if(message)
            {
                userInfo[webServiceClientErrorMessage] = message;
            }
            
            *error = [NSError errorWithDomain:HTTPErrorDomain
                                         code:[response statusCode]
                                     userInfo:userInfo];
        }
        else
        {
            *error = responseError;
        }
    }
    
    return JSON;
}

@end
