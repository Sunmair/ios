//
//  XMLParseManger.m
//  WeiXinPayDemo
//
//  Created by Eric on 16/10/11.
//  Copyright © 2016年 Eric. All rights reserved.
//

#import "XMLParseManger.h"

@interface XMLParseManger()<NSXMLParserDelegate>
@property(nonatomic,strong)NSData *xmlData;
@property(nonatomic,copy)ResultBlock resultBlock;
@property(nonatomic,strong)NSXMLParser *xmlParse;
@property(nonatomic,strong)NSMutableDictionary *resultDictionary;
@property(nonatomic,strong)NSMutableString *contentString;
@end

@implementation XMLParseManger
-(XMLParseManger *)initWithXmlData:(NSData *)xmlData andResultBlock:(ResultBlock)resultBlock{
    if (self = [super init]) {
        self.xmlData = xmlData;
        self.resultBlock = resultBlock;
    }
    return self;
}
-(void)startParse{
    _xmlParse = [[NSXMLParser alloc]initWithData:self.xmlData];
    self.xmlParse.delegate = self;
    [_xmlParse parse];
}
//开始解析时,初始化要解析的内容
-(void)parserDidStartDocument:(NSXMLParser *)parser{
    _resultDictionary = [NSMutableDictionary dictionary];
    _contentString = [NSMutableString string];
}
//记录节点内容
-(void)parser:(NSXMLParser *)parser foundCharacters:(nonnull NSString *)string{
    [_contentString setString:string];
}
//
-(void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName{
    if (![_contentString isEqualToString:@"\n"]&&![elementName isEqualToString:@"root"]) {
        [_resultDictionary setObject:[_contentString copy] forKey: elementName];
    }
}
//解析结束时传入一个字典
-(void)parserDidEndDocument:(NSXMLParser *)parser{
    _resultBlock(_resultDictionary);
}
@end






