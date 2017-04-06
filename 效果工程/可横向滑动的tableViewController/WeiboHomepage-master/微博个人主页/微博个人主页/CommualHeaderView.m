//
//  CommualHeaderView.m
//  微博个人主页
//
//  Created by zenglun on 16/5/5.
//  Copyright © 2016年 chengchengxinxi. All rights reserved.
//

#import "CommualHeaderView.h"

@implementation CommualHeaderView

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    if (_canNotResponseTapTouchEvent) {
        return NO;
    }
    
    return [super pointInside:point withEvent:event];
}

@end
