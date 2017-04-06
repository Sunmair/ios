//
//  HZYHttpRequest.m
//  LOLProject
//
//  Created by MS on 16-3-9.
//  Copyright (c) 2016年 passionHan. All rights reserved.
//

#import "HZYHttpRequest.h"

@implementation HZYHttpRequest

+ (void)GET:(NSString *)URLString complete:(CompleteBlock)complete{
    
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    //设置各种属性(返回数据的类型,content-type)
    
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    //调用GET方法
    
   // NSString *urlString = [NSString stringWithFormat:@"http://lol.data.shiwan.com/%@",URLString];
    [manager GET:URLString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        complete(operation,responseObject,nil);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        complete(operation,nil,error);

    }];
    
}

@end
// 版权属于原作者
// http://code4app.com (cn) http://code4app.net (en)
// 发布代码于最专业的源码分享网站: Code4App.com