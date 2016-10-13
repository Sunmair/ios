//
//  HomePageViewController.m
//  ParkingProject
//
//  Created by Eric on 16/10/13.
//  Copyright © 2016年 Eric. All rights reserved.
//

#import "HomePageViewController.h"

@interface HomePageViewController ()
@property(nonatomic,strong)UIButton *naviButton;
@end

@implementation HomePageViewController
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
   self.naviButton.hidden = YES;
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
      [self handleCASpringAnimation];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.naviButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.naviButton.frame = CGRectMake(kDeviceWidth/2-10,200, 80, 20);
    [self.naviButton setTitle:@"动画" forState:UIControlStateNormal];
    [self.naviButton setBackgroundColor:[UIColor orangeColor]];
    [self.view addSubview:self.naviButton];
   
}
-(void)handleCASpringAnimation{
    CGRect screen = [UIScreen mainScreen].bounds;
    CATransform3D move = CATransform3DIdentity;
    CGFloat initAlertViewYPosition = (CGRectGetHeight(screen) + CGRectGetHeight(_naviButton.frame)) / 2;
    
    move = CATransform3DMakeTranslation(0, -initAlertViewYPosition, 0);
    move = CATransform3DRotate(move, 40 * M_PI/180, 0, 0, 1.0f);
    
    _naviButton.layer.transform = move;
    
    [UIView animateWithDuration:1.0f
                          delay:0.0f
         usingSpringWithDamping:0.4f
          initialSpringVelocity:0.0f
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         self.naviButton.hidden = NO;
                         CATransform3D init = CATransform3DIdentity;
                         _naviButton.layer.transform = init;
                         
                     }
                     completion:^(BOOL finished) {
                     }];
    
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
