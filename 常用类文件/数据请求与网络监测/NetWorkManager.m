//
//  NetWorkManager.m
//  KuaJingChe
//
//  Created by Eric on 16/10/9.
//  Copyright © 2016年 Eric. All rights reserved.
//

#import "NetWorkManager.h"

@implementation NetWorkManager
static  NSString *state;
+(void)requestGETWithURLStr:(NSString *)urlStr parDic:(NSDictionary *)dic finish:(void (^)(id))finish conError:(void (^)(NSError *))conError noNet:(void (^)())noNet{
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc]initWithBaseURL:[NSURL URLWithString:@"https"]];
    manager.responseSerializer.acceptableContentTypes =[NSSet setWithArray:@[@"text/html", @"application/json"]];
    if ([state isEqualToString:@"0"]) {
        noNet();
        return;
    }
    [manager GET:urlStr parameters:dic progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
         finish(responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        conError(error);
    }];
}
+(void)requestPOSTWithURLStr:(NSString *)urlStr parDic:(NSDictionary *)dic finish:(void (^)(id))finish conError:(void (^)(NSError *))conError noNet:(void (^)())noNet{
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc]initWithBaseURL:[NSURL URLWithString:@"https"]];
    manager.responseSerializer.acceptableContentTypes =[NSSet setWithArray:@[@"text/html", @"application/json"]];
    if ([state isEqualToString:@"0"]) {
        noNet();
        return;
    }
    [manager POST:urlStr parameters:dic progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        finish(responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        conError(error);
    }];
}
+(void)netStatus{
    id netManager = [AFNetworkReachabilityManager sharedManager];
    [netManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        switch (status) {
            case AFNetworkReachabilityStatusNotReachable:
                state = @"0";
                break;
             case AFNetworkReachabilityStatusReachableViaWiFi:
                state = @"1";
                break;
                case  AFNetworkReachabilityStatusReachableViaWWAN:
                state = @"2";
                break;
                case AFNetworkReachabilityStatusUnknown:
                state = @"3";
                break;
            default:
                break;
        }
        [[NSNotificationCenter defaultCenter]postNotificationName:@"netStatusHaveChange" object:nil userInfo:@{@"netStatus":state}];
    }];
}
@end









