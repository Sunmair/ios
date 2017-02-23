//
//  YYMGroup.m
//  QQTowGroup
//
//  Created by 云彦民 on 2016/11/28.
//  Copyright © 2016年 云彦民. All rights reserved.
//

#import "YYMGroup.h"

@implementation YYMGroup
//初始化方法
- (instancetype) initWithItem:(NSMutableArray *)item{
    if (self = [super init]) {
        self.folded=YES;
        _items = item;
    }
    return self;
}

//每个组内有多少联系人
- (NSUInteger) size {
    return _items.count;
}

@end
