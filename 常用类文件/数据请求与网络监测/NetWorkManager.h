//
//  NetWorkManager.h
//  KuaJingChe
//
//  Created by Eric on 16/10/9.
//  Copyright © 2016年 Eric. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"
@interface NetWorkManager : NSObject
+(void)requestGETWithURLStr:(NSString *)urlStr parDic:(NSDictionary *)dic finish:(void (^)(id(respondObject)))finish conError: (void (^)(NSError *error))conError noNet:(void(^)())noNet;
+(void)requestPOSTWithURLStr:(NSString *)urlStr parDic:(NSDictionary *)dic finish:(void (^)(id(respondObject)))finish conError: (void (^)(NSError *error))conError noNet:(void(^)())noNet;
+(void)netStatus;
@end
