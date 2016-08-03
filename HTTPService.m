//
//  HTTPService.m
//  YoukuKidsHD
//
//  Created by leon on 15/5/14.
//  Copyright (c) 2015年 优酷. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonDigest.h>
#import "HTTPService.h"
#import <UIKit/UIKit.h>
static HTTPService * _instance = NULL;
typedef NS_ENUM(NSInteger, liveViewMode) {
    eOrdinary=0,
    eFullView,
    e3DView
};
@implementation HTTPService
{
    NSString* _Cookie;
    AFHTTPRequestOperationManager* manager;
}

+ (HTTPService*) Instance
{
    if(NULL == _instance)
    {
        _instance = [[HTTPService alloc]init];
        _instance->manager = [AFHTTPRequestOperationManager manager];
        [_instance->manager.requestSerializer setTimeoutInterval:30];
        _instance->manager.responseSerializer = [[AFJSONResponseSerializer alloc] init];
        _instance->manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html", @"text/json", @"application/json", @"text/javascript", @"text/plain", nil];
    }
    
    NSArray *cookieStorage = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
    NSDictionary *cookieHeaders = [NSHTTPCookie requestHeaderFieldsWithCookies:cookieStorage];
    for (NSString *key in cookieHeaders) {
        [_instance->manager.requestSerializer setValue:[NSString stringWithFormat:@"%@=%@",key,cookieHeaders[key]] forHTTPHeaderField:@"Cookie"];
    }
    return _instance;
}



- (AFHTTPRequestOperation *)mobileGET:(NSString*)host
             path:(NSString*)path
       parameters:(NSMutableDictionary*)parameters
          success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
          failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    NSString *stringParameter = [self getStringByParameters:parameters];
    NSString *serviceUrl = [host stringByAppendingFormat: @"%@?%@", path, stringParameter];//完整的一个路径
    return [manager GET:serviceUrl
       parameters:nil
          success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
              success(operation,responseObject);
    }
          failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
              failure(operation,error);
    }];
}


- (void)mobilePOST:(NSString*)host
             path:(NSString*)path
       parameters:(NSMutableDictionary*)parameters
          success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
          failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    NSString *stringParameter = [self getStringByParameters:parameters];
    NSString *serviceUrl = [host stringByAppendingFormat: @"%@?%@", path, stringParameter];//完整的一个路径
    [manager POST:serviceUrl
      parameters:nil
         success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
             success(operation,responseObject);
         }
         failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
             failure(operation,error);
         }];
}

/**
 *  字典拼成get参数字符串
 *
 *  @param parameters 参数
 *
 *  @return 参数
 */

- (NSString*)getStringByParameters:(NSObject*)parameters
{
    // modified by luke
    //return AFQueryStringFromParametersWithEncoding(parameters,NSUTF8StringEncoding);
    NSString* stringParameter = @"";
    if(nil != parameters)
    {
        if([parameters isKindOfClass:[NSString class]]) {//直接是字符串,直接用
            stringParameter = (NSString*)parameters;
        } else if([parameters isKindOfClass:[NSDictionary class]]) {//数组形式的传参
            NSDictionary* dictParameter = (NSDictionary*)parameters;
            for (NSString* strKey in dictParameter) {
            
                if (![[dictParameter objectForKey:strKey] isKindOfClass:[NSString class]] &&
                    ![[dictParameter objectForKey:strKey] isKindOfClass:[NSNumber class]]) {
                    continue;
                }
                
                if ([[dictParameter objectForKey:strKey] isKindOfClass:[NSString class]]) {
                    NSString* strValue = [[dictParameter objectForKey:strKey] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                    if (0 != stringParameter.length) {
                        stringParameter = [stringParameter stringByAppendingFormat:@"&%@=%@", strKey, strValue];
                    } else {
                        stringParameter = [stringParameter stringByAppendingFormat:@"%@=%@", strKey, strValue];
                    }
                } else {
                    stringParameter = [stringParameter stringByAppendingFormat:@"&%@=%@", strKey, [dictParameter objectForKey:strKey]];
                }
            }
        }
    }
    NSString *mid = [[NSUserDefaults standardUserDefaults] objectForKey:@"mid"];
    stringParameter = [stringParameter stringByAppendingFormat:@"&mid=%@",mid];
    return stringParameter;
}


@end