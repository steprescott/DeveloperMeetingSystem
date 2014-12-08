//
//  WebServiceClient.m
//  Developer meeting system
//
//  Created by Ste Prescott on 04/12/2014.
//  Copyright (c) 2014 Ste Prescott. All rights reserved.
//

#import "WebServiceClient.h"
#import <AFNetworking/AFNetworking.h>

static NSString *webAPIBaseURLString = @"http://www.shouldibuyamac.co.uk/api";
static NSString *webAPIKey = @"3456973d-a4da-486f-a595-73eba8854e07";

static NSString *debugUserTokenAdmin = @"1bb78f99-75de-417c-af07-5db40d362bb3";
static NSString *debugUserTokenHost = @"13ad1268-46fe-4b7e-8350-37ea76f529c7";
static NSString *debugUserTokenGuest = @"ce240744-ed9a-4bcd-85df-1d2437baaf6b";

static NSString *tokenEndPoint = @"token";
static NSString *mettingsEndPoint = @"meeting";
static NSString *rolesEndPoint = @"role";

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
        sharedInstance.userToken = debugUserTokenHost;
    });
    
    return sharedInstance;
}

+ (BOOL)hasUserToken
{
    return [[WebServiceClient sharedInstance] userToken] ? YES : NO;
}

- (void)loginWithUsername:(NSString *)username password:(NSString *)password success:(void (^)(NSDictionary *JSON))successBlock failure:(void (^)(NSError *error))failureBlock
{
    [self performRequestOfType:RequestTypeGET
                    toEndPoint:@"token"
                withParameters:@{@"username" : username,
                                 @"password" : password}
                       success:^(NSDictionary *JSON) {
                           self.userToken = JSON[@"Token"];
                           
                           if(successBlock)
                           {
                               successBlock(JSON);
                           }
                       }
                       failure:^(NSError *error) {
                           if(failureBlock)
                           {
                               failureBlock(error);
                           }
                           
                       }];
}

- (void)GETAllMeetingsSuccess:(void (^)(NSDictionary *JSON))successBlock failure:(void (^)(NSError *error))failureBlock
{
    [self performRequestOfType:RequestTypeGET
                    toEndPoint:mettingsEndPoint
                withParameters:nil
                       success:^(NSDictionary *JSON) {
                           if(successBlock)
                           {
                               successBlock(JSON);
                           }
                       }
                       failure:^(NSError *error) {
                           if(failureBlock)
                           {
                               failureBlock(error);
                           }
                       }];
}

- (void)GETAllRolesSuccess:(void (^)(NSDictionary *JSON))successBlock failure:(void (^)(NSError *error))failureBlock
{
    [self performRequestOfType:RequestTypeGET
                    toEndPoint:rolesEndPoint
                withParameters:nil
                       success:^(NSDictionary *JSON) {
                           if(successBlock)
                           {
                               successBlock(JSON);
                           }
                       }
                       failure:^(NSError *error) {
                           if(failureBlock)
                           {
                               failureBlock(error);
                           }
                       }];
}

- (void)performRequestOfType:(RequestType)requestType toEndPoint:(NSString *)endPoint withParameters:(NSDictionary *)parameters success:(void (^)(NSDictionary *JSON))successBlock failure:(void (^)(NSError *error))failureBlock
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager.requestSerializer setValue:webAPIKey forHTTPHeaderField:@"X-APIKey"];
    
    if(self.userToken && ![self.userToken isEqualToString:@""])
    {
        [manager.requestSerializer setValue:self.userToken forHTTPHeaderField:@"X-UserToken"];
    }
    
    NSString *urlString = [NSString stringWithFormat:@"%@/%@", webAPIBaseURLString, endPoint];
    
    if(requestType == RequestTypeGET)
    {
        [manager GET:urlString
          parameters:parameters
             success:^(AFHTTPRequestOperation *operation, NSDictionary *responseObject) {
                 if(successBlock)
                 {
                     successBlock(responseObject);
                 }
             } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                 if(failureBlock)
                 {
                     failureBlock(error);
                 }
             }];
    }
    else if(requestType == RequestTypePOST)
    {
        [manager POST:urlString
           parameters:parameters
              success:^(AFHTTPRequestOperation *operation, NSDictionary *responseObject) {
                  if(successBlock)
                  {
                      successBlock(responseObject);
                  }
              } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                  if(failureBlock)
                  {
                      failureBlock(error);
                  }
              }];
    }
}

@end
