//
//  NavigationController.m
//  微博个人主页
//
//  Created by zenglun on 16/5/8.
//  Copyright © 2016年 chengchengxinxi. All rights reserved.
//

#import "NavigationController.h"

@implementation NavigationController

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
}

- (UIViewController *)childViewControllerForStatusBarStyle {
    return self.topViewController;
}


@end
