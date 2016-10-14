//
//  BaseViewController.m
//  ParkingProject
//
//  Created by Eric on 16/10/12.
//  Copyright © 2016年 Eric. All rights reserved.
//

#import "BaseViewController.h"
#import "NetWorkManager.h"
@interface BaseViewController ()

@end

@implementation BaseViewController
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(netStateChange:) name:@"netStatusHaveChange" object:nil];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
}
-(void)netStateChange:(NSNotification *)noti{
    NSDictionary *info = noti.userInfo;
    NSString *state = info[@"netStatus"];
    NSInteger num = [state integerValue];
    NSString *message;
    switch (num) {
        case 0:
             message = @"网络未连接";
            break;
            case 1:
            message = @"当前使用wifi";
            break;
            case 2:
            message = @"当前使用流量偶";
            break;
        default:
            message = @"网络状态未知";
            break;
    }
    [self showAlertWithMessage:message];
}
-(void)showAlertWithMessage:(NSString *)str{
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:str preferredStyle: UIAlertControllerStyleAlert];
    [self presentViewController:alert animated:YES completion:^{
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        //添加延迟任务
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t )(0.5*NSEC_PER_SEC)),queue , ^{
            [alert dismissViewControllerAnimated:YES completion:nil];
        });
    }];
    

}
-(void)viewWillDisappear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"netStatusHaveChange" object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
   [self.view  endEditing:YES];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
