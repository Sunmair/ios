//
//  CorRadiusButton.m
//  ParkingProject
//
//  Created by Eric on 16/10/13.
//  Copyright © 2016年 Eric. All rights reserved.
//

#import "CorRadiusButton.h"

@implementation CorRadiusButton


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    self.layer.cornerRadius = 5;
    self.layer.borderWidth = 1;
    self.layer.masksToBounds = YES;
    self.layer.borderColor = (__bridge CGColorRef _Nullable)([UIColor clearColor]);
}

@end
