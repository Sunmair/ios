//
//  STColorSelectView.h
//  ColorPicker
//
//  Created by Eric on 2018/9/13.
//  Copyright © 2018年 zws. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface STColorSelectView : UIView
- (instancetype)initWithFrame:(CGRect)frame andImage:(UIImage *)image;
@property (copy, nonatomic) void(^currentColorBlock)(UIColor *color);
@end
