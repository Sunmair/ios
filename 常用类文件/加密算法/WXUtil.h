//
//  WXUtil.h
//  WeiXinPayDemo
//
//  Created by Eric on 16/10/11.
//  Copyright © 2016年 Eric. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WXUtil : NSObject
//加密
+(NSString  *)md5:(NSString *)str;
+(NSString *)sha1:(NSString *)str;
//实现http数据解析后返回
+(NSData *)httSend:(NSString *)url method:(NSString *)method data:(NSString *)data;

@end
