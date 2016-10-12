//
//  XMLParseManger.h
//  WeiXinPayDemo
//
//  Created by Eric on 16/10/11.
//  Copyright © 2016年 Eric. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef void(^ResultBlock) (NSMutableDictionary *resultDictionary);
@interface XMLParseManger : NSObject
-(XMLParseManger *)initWithXmlData:(NSData *)xmlData andResultBlock:(ResultBlock)resultBlock;
-(void)startParse;
@end
