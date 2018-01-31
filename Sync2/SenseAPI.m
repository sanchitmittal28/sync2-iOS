//
//  SenseAPI.m
//  Sync2
//
//  Created by Ricky Kirkendall on 1/17/18.
//  Copyright © 2018 Sixgill. All rights reserved.
//

#import "SenseAPI.h"
#import "Project.h"
#import "DataChannel.h"
#import "Landmark.h"
#define SERVER_ADDRESS @"http://sense-api-staging.sixgill.run"

@implementation SenseAPI

#pragma mark - Authentication

-(void) LoginWithEmail:(NSString *_Nonnull)email andPassword:(NSString *_Nonnull)password
        withCompletion:(void ( ^ _Nullable )(NSError * _Nullable error))completed{
    
    NSDictionary *headers = @{ @"content-type": @"application/json" };
    NSDictionary *parameters = @{ @"email": email,
                                  @"password": password };
    
    NSData *postData = [NSJSONSerialization dataWithJSONObject:parameters options:0 error:nil];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[self urlForEndPoint:@"/v2/login"]]
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:10.0];
    [request setHTTPMethod:@"POST"];
    [request setAllHTTPHeaderFields:headers];
    [request setHTTPBody:postData];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request
                                                completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                    if (error) {
                                                        NSLog(@"%@", error);
                                                    } else {
                                                        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
                                                        NSLog(@"%@", httpResponse);
                                                        
                                                        SGToken *token = [[SGToken alloc]initWithData:data];
                                                        self.jwToken = token;
                                                        completed(nil);
                                                    }
                                                }];
    [dataTask resume];
}

# pragma mark - Get Projects

-(void) GetProjectsWithCompletion:(void ( ^ _Nullable )(NSArray * projects, NSError * _Nullable error))completed{
    
    NSDictionary *headers = @{ @"authorization": [self bearerToken],
                               @"accept": @"application/json",
                               @"connection": @"keep-alive" };
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[self urlForEndPoint:@"/v2/projects"]]
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:10.0];
    [request setHTTPMethod:@"GET"];
    [request setAllHTTPHeaderFields:headers];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request
                                                completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                    if (error) {
                                                        NSLog(@"%@", error);
                                                    } else {
                                                        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
                                                        NSLog(@"%@", httpResponse);
                                                        
                                                        NSArray *projects = [self projectsFromData:data];
                                                        completed(projects, nil);
                                                    }
                                                }];
    [dataTask resume];
}

# pragma mark - Get Data Channels

-(void) GetDataChannelsWithCompletion:(void ( ^ _Nullable )(NSArray *dataChannels, NSError * _Nullable error))completed{
    
    NSDictionary *headers = @{ @"authorization": [self bearerToken],
                               @"accept": @"application/json",
                               @"connection": @"keep-alive" };
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[self urlForEndPoint:@"/v2/channels"]]
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:10.0];
    [request setHTTPMethod:@"GET"];
    [request setAllHTTPHeaderFields:headers];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request
                                                completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                    if (error) {
                                                        NSLog(@"%@", error);
                                                    } else {
                                                        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
                                                        NSLog(@"%@", httpResponse);
                                                        
                                                        NSArray *channels = [self channelsFromData:data];
                                                        completed(channels, nil);
                                                    }
                                                }];
    [dataTask resume];
    
}


# pragma mark - Get Landmarks

-(void) GetLandmarksForProject:(NSString *_Nonnull)projectId WithCompletion:(void ( ^ _Nullable )(NSArray *landmarks, NSError * _Nullable error))completed{
    
    NSDictionary *headers = @{ @"authorization": [self bearerToken],
                               @"accept": @"application/json",
                               @"connection": @"keep-alive" };
    
    NSString *url = [NSString stringWithFormat:@"%@/%@/landmarks", [self urlForEndPoint:@"/v2/projects"],projectId];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:10.0];
    [request setHTTPMethod:@"GET"];
    [request setAllHTTPHeaderFields:headers];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request
                                                completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                    if (error) {
                                                        NSLog(@"%@", error);
                                                    } else {
                                                        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
                                                        NSLog(@"%@", httpResponse);
                                                        
                                                        NSArray *landmarks = [self landmarksFromData:data];
                                                        completed(landmarks, nil);
                                                    }
                                                }];
    [dataTask resume];
}


-(NSArray *) landmarksFromData:(NSData *) data{
    NSMutableArray *toReturn = [NSMutableArray array];
    
    NSError *error = nil;
    id object = [NSJSONSerialization
                 JSONObjectWithData:data
                 options:0
                 error:&error];
    
    
    if ([object isKindOfClass:[NSDictionary class]]) {
        NSDictionary *responseDict = (NSDictionary *)object;
        if(responseDict[@"data"]){
            NSArray *landmarkObjects = (NSArray *)responseDict[@"data"];
            for (NSDictionary *lmo in landmarkObjects) {
                Landmark *p = [[Landmark alloc] initWithData:lmo];
                [toReturn addObject:p];
            }
        }
    }
    
    
    return toReturn;
}


-(NSArray *) channelsFromData:(NSData *) data{
    NSMutableArray *toReturn = [NSMutableArray array];
    
    NSError *error = nil;
    id object = [NSJSONSerialization
                 JSONObjectWithData:data
                 options:0
                 error:&error];
    
    
    if ([object isKindOfClass:[NSDictionary class]]) {
        NSDictionary *responseDict = (NSDictionary *)object;
        if(responseDict[@"data"]){
            NSArray *projectObjects = (NSArray *)responseDict[@"data"];
            for (NSDictionary *projectObject in projectObjects) {
                DataChannel *p = [[DataChannel alloc] initWithData:projectObject];
                [toReturn addObject:p];
            }
        }
    }
    
    
    return toReturn;
}

-(NSArray *) projectsFromData:(NSData *) data{
    NSMutableArray *toReturn = [NSMutableArray array];
    
    NSError *error = nil;
    id object = [NSJSONSerialization
                 JSONObjectWithData:data
                 options:0
                 error:&error];
    
    
    if ([object isKindOfClass:[NSDictionary class]]) {
        NSDictionary *responseDict = (NSDictionary *)object;
        if(responseDict[@"data"]){
            NSArray *projectObjects = (NSArray *)responseDict[@"data"];
            for (NSDictionary *projectObject in projectObjects) {
                Project *p = [[Project alloc] initWithData:projectObject];
                [toReturn addObject:p];
            }
        }
    }
    
    
    return toReturn;
}

-(NSString *) bearerToken{
    if (self.jwToken) {
        return [NSString stringWithFormat:@"Bearer %@",self.jwToken.token];
    }
    
    return @"";
}


-(NSString *) urlForEndPoint:(NSString *)endpoint{
    return [NSString stringWithFormat:@"%@%@", SERVER_ADDRESS, endpoint];
}


@end
