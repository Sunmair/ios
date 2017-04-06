//
//  HZYNewsCell.m
//  LOLProject
//
//  Created by MS on 16-3-10.
//  Copyright (c) 2016年 passionHan. All rights reserved.
//

#import "HZYNewsCell.h"
#import "HZYNewsModel.h"
#import "UIImageView+WebCache.h"
@interface HZYNewsCell()

@property (weak, nonatomic) IBOutlet UIImageView *iconView;

@property (weak, nonatomic) IBOutlet UILabel *titleView;
@property (weak, nonatomic) IBOutlet UILabel *detatilView;

@end

@implementation HZYNewsCell

+ (instancetype)cellWithTableView:(UITableView *)tableView{
    
    //需要绑定Xib上的重用标识符
    static NSString *ID = @"newsCell";
    
    HZYNewsCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    
    if (!cell) {
        
        NSLog(@"df");
        cell = [[[NSBundle mainBundle] loadNibNamed:@"HZYNewsCell" owner:nil options:nil] firstObject];
        
    }
    
    return cell;
}


- (void)setNews:(HZYNewsModel *)news{
    
    _news = news;
    
    [self.iconView sd_setImageWithURL:[NSURL URLWithString:news.icon]];
    self.titleView.text = news.title;
    self.detatilView.text = news.shortIntroduce;
}


@end
// 版权属于原作者
// http://code4app.com (cn) http://code4app.net (en)
// 发布代码于最专业的源码分享网站: Code4App.com