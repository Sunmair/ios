//
//  WXUtil.m
//  WeiXinPayDemo
//
//  Created by Eric on 16/10/11.
//  Copyright © 2016年 Eric. All rights reserved.
//

#import "WXUtil.h"
#import <CommonCrypto/CommonCrypto.h>
@implementation WXUtil
+(NSString *)md5:(NSString *)str{
    const char *CStr = str.UTF8String;
    /**
     *  @param data#> 要加密的C语言字符串
     *  @param len#>  C语言字符串的长度
     *  @param md#>   生成的16个16进制字符的数组的首地址
     */
    //声明一个字符数组  可存放16个字符
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(CStr, (CC_LONG)strlen(CStr), result);
    //遍历该C语言数组 将其中的16个字符串拼接起来,形成OC字符串
    NSMutableString *string = [NSMutableString string];
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [string appendFormat:@"%02X",result[i]];
    }
    return string;
}
+(NSString *)sha1:(NSString *)str{
    const char *cstr = [str cStringUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [NSData dataWithBytes:cstr length:str.length];
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    CC_SHA1(data.bytes, (unsigned int)data.length, digest);
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH*2];
    for (int i = 0; i< CC_SHA1_DIGEST_LENGTH; i++) {
        [output appendFormat:@"%02x",digest[i]];
    }
    return output;
}
//post/get
+(NSData *)httSend:(NSString *)url method:(NSString *)method data:(NSString *)data{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:5.0];
    [request setHTTPMethod:method];
    [request addValue:@"text/xml" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"UTF-8" forHTTPHeaderField:@"charset"];
    [request setHTTPBody:[data dataUsingEncoding:NSUTF8StringEncoding]];
    NSError *error;
    NSData *respondse = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&error];
    return respondse;
}
@end








