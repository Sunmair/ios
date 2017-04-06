//
//  HZYNewsCell.h
//  LOLProject
//
//  Created by MS on 16-3-10.
//  Copyright (c) 2016年 passionHan. All rights reserved.
//

#import <UIKit/UIKit.h>
@class HZYNewsModel;
@interface HZYNewsCell : UITableViewCell

+ (instancetype)cellWithTableView:(UITableView *)tableView;

@property (nonatomic, strong) HZYNewsModel *news;


@end
// 版权属于原作者
// http://code4app.com (cn) http://code4app.net (en)
// 发布代码于最专业的源码分享网站: Code4App.com