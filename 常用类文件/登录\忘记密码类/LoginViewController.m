//
//  LoginViewController.m
//  ParkingProject
//
//  Created by Eric on 16/10/13.
//  Copyright © 2016年 Eric. All rights reserved.
//

#import "LoginViewController.h"
@interface LoginViewController ()

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
- (IBAction)LoginAction:(id)sender {
    UIStoryboard *main = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UITabBarController *tab = [main instantiateViewControllerWithIdentifier:@"tab"];
    [self presentViewController:tab animated:YES completion:nil];
    
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
