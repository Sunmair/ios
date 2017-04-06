//
//  ViewController.m
//  微博个人主页
//
//  Created by zenglun on 16/5/4.
//  Copyright © 2016年 chengchengxinxi. All rights reserved.
//

#import "ViewController.h"
#import "HomePageViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)enterHomePage:(UIButton *)sender {
    HomePageViewController *controller = [[HomePageViewController alloc] init];
    [self.navigationController pushViewController:controller animated:YES];
}


@end
