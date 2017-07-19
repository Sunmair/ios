//
//  ViewController.m
//  03-base64加密
//
//  Created by 王鹏飞 on 16/2/16.
//  Copyright © 2016年 王鹏飞. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    // 加密字符串
    NSDictionary *dic = @{@"v":@"1.0",@"sign" :@"3b2434ba9be53e1b7ffdebbe9e4860bcdab7a5d9",@"timestamp":@"1495856140"};
    NSData *data;
    NSString *jsonString;
    data = [self toJSONData:dic];
    jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    NSData *SECdata = [jsonString dataUsingEncoding:NSUTF8StringEncoding];

    NSLog(@"data:%@", SECdata);
    
    // 进行base64 加密
//    NSData *base64Data = [data base64EncodedDataWithOptions:0];
    
    NSString *base64String = [SECdata base64EncodedStringWithOptions:0];
    
    NSLog(@"base64Data:%@", base64String);
    
    // 直接将加密后的字符串进行base64 解密(可以反向)
    NSData *baseData = [[NSData alloc] initWithBase64EncodedString:base64String options:0];
    
    // 将解密后产生的二进制数据转为字符串
    NSString *baseStr = [[NSString alloc] initWithData:baseData encoding:NSUTF8StringEncoding];
    
    NSLog(@"baseStr:%@", baseStr);
    
    /*
    输出结果：
     data:<49204d49 53532059 4f55>
     base64Data:SSBNSVNTIFlPVQ==
     baseStr:I MISS YOU
     */
    
}



-(NSData *)toJSONData:(id)theData{
    
    NSError *error = nil;
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:theData
                        
                                                       options:NSJSONWritingPrettyPrinted
                        
                                                         error:&error];
    
    
    
    if ([jsonData length] > 0 && error == nil){
        
        return jsonData;
        
    }else{
        
        return nil;
        
    }
    
}


// 解密图片
- (void)test2 {
    
    // 获得加密后的二进制数据
    NSData *base64Data = [NSData dataWithContentsOfFile:@"/Users/wangpengfei/Desktop/123"];
    
    // 解密 base64 数据
    NSData *baseData = [[NSData alloc] initWithBase64EncodedData:base64Data options:0];
    
    // 写入桌面
    [baseData writeToFile:@"/Users/wangpengfei/Desktop/IMG_5551.jpg" atomically:YES];
}

// 将图片进行加密
- (void)test1 {
    
    // 获取需要加密文件的二进制数据
    NSData *data = [NSData dataWithContentsOfFile:@"/Users/wangpengfei/Desktop/photo/IMG_5551.jpg"];
    
    // 打印该图片二进制数据
    NSLog(@"data:%@", data);
    
    // base64 加密是 Xcode7.0 之后出现的
    // 或 base64EncodedStringWithOptions
    NSData *base64Data = [data base64EncodedDataWithOptions:0];
    
    // 将加密后的文件存储到桌面
    [base64Data writeToFile:@"/Users/wangpengfei/Desktop/123" atomically:YES];
}

@end
