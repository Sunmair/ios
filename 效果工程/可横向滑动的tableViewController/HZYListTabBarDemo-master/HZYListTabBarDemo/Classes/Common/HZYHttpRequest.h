//
//  HZYHttpRequest.h
//  LOLProject
//
//  Created by MS on 16-3-9.
//  Copyright (c) 2016年 passionHan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFHTTPRequestOperationManager.h"

typedef void (^CompleteBlock)(AFHTTPRequestOperation *operation,id responseObject,NSError *error);

@interface HZYHttpRequest : NSObject

/**
 *  用于发送HTTP GET 方式的请求
 *
 *  @param URLString 请求的URL
 *  @param complete  请求完成后的回调
 */
+ (void)GET:(NSString *)URLString complete:(CompleteBlock)complete;

@end
// 版权属于原作者
// http://code4app.com (cn) http://code4app.net (en)
// 发布代码于最专业的源码分享网站: Code4App.com