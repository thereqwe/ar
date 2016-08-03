//
//  HTTPServic.h
//  YoukuKidsHD
//
//  Created by leon on 15/5/14.
//  Copyright (c) 2015年 优酷. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"
@interface HTTPService : NSObject


+ (HTTPService*) Instance;
/**
 *  get http
 *
 *  @param host       <#host description#>
 *  @param path       <#path description#>
 *  @param parameters <#parameters description#>
 *  @param success    <#success description#>
 *  @param failure    <#failure description#>
 */
- (AFHTTPRequestOperation *)mobileGET:(NSString*)host
             path:(NSString*)path
       parameters:(NSMutableDictionary*)parameters
          success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
          failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

/**
 *  post http
 *
 *  @param host       <#host description#>
 *  @param path       <#path description#>
 *  @param parameters <#parameters description#>
 *  @param success    <#success description#>
 *  @param failure    <#failure description#>
 */
- (void)mobilePOST:(NSString*)host
             path:(NSString*)path
       parameters:(NSMutableDictionary*)parameters
          success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
          failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

- (NSArray *)getLiveInfoDescWithLiveItemId:(NSString *)liveItemId hfid:(NSString *)hfid;



@end

