//
//  ForgetPasswordViewController.m
//  ParkingProject
//
//  Created by Eric on 16/10/13.
//  Copyright © 2016年 Eric. All rights reserved.
//

#import "ForgetPasswordViewController.h"

@interface ForgetPasswordViewController ()
@property (weak, nonatomic) IBOutlet UIButton *sendCodeButton;
@property(nonatomic,strong)NSTimer *timer;
@property(nonatomic,assign)NSInteger timeValue;
@end

@implementation ForgetPasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.sendCodeButton setTitle:@"重新获取" forState:UIControlStateNormal];
}
- (IBAction)getCode:(UIButton *)sender {
        sender.userInteractionEnabled = NO;
        self.timeValue = 60;
      self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timerDecress:) userInfo:nil repeats:YES];
}
//时间减少
-(void)timerDecress:(NSTimer *)timer{
    _timeValue--;
    if (_timeValue == 0) {
        [self.sendCodeButton setTitle:@"重新获取" forState:UIControlStateNormal];
         [self.sendCodeButton setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
        self.sendCodeButton.userInteractionEnabled = YES;
        [self.timer invalidate];
        self.timer = nil;
    }else{
        [self.sendCodeButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [self.sendCodeButton setTitle:[NSString stringWithFormat:@"%lds后重新获取",(long)self.timeValue] forState:UIControlStateNormal];
    }

    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
