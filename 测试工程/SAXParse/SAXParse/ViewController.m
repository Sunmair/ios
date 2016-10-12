//
//  ViewController.m
//  SAXParse
//
//  Created by Eric on 16/10/12.
//  Copyright © 2016年 Eric. All rights reserved.
//

#import "ViewController.h"
#import "XMLParseManger.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
     NSString *file =  [[NSBundle mainBundle]pathForResource:@"Students" ofType:@"xml"];
    NSData *data = [NSData dataWithContentsOfFile:file];
    XMLParseManger *xml = [[XMLParseManger alloc]initWithXmlData:data andResultBlock:^(NSMutableArray *resultArrary) {
        NSLog(@"%@",resultArrary);
    }];
    [xml startParse];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
