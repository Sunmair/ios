//
//  YYMGroup.h
//  QQTowGroup
//
//  Created by 云彦民 on 2016/11/28.
//  Copyright © 2016年 云彦民. All rights reserved.
//


#import <UIKit/UIKit.h>


/**分组*/
@interface YYMGroup : NSObject

//联系人数据
@property(nonatomic,strong)NSMutableArray *items;
//大小(分组中有多少项)
@property (nonatomic, readonly) NSUInteger size;
//是否折叠
@property (nonatomic, assign, getter=isFolded) BOOL folded;

//初始化方法
- (instancetype) initWithItem:(NSMutableArray *)item;

@end
