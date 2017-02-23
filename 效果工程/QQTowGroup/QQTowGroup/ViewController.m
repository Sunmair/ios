//
//  ViewController.m
//  QQTowGroup
//
//  Created by 云彦民 on 2016/11/28.
//  Copyright © 2016年 云彦民. All rights reserved.
//

#import "ViewController.h"
#import "YYMGroup.h"
#define WIDTH self.view.bounds.size.width
#define HEIGHT self.view.bounds.size.height

@interface ViewController () <UITableViewDataSource, UITableViewDelegate> {
    UITableView *myTableView;//定义tabview
    NSMutableArray *dataArray;//数据源数组
    
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //创建tableview；
    myTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, WIDTH, HEIGHT) style:UITableViewStylePlain];
    [self.view addSubview:myTableView];
    
    myTableView.dataSource = self;
    myTableView.delegate = self;
    
    //绑定数据源
    [self loadDataModel];
    
}


- (void) loadDataModel {
    if (!dataArray) {
        dataArray = [NSMutableArray array];
    }
    // Todo: 加载数据模型(后台请求的数据)
    NSArray *groupNames = @[@[@"张无忌",@"狄云",@"狄青",@"李慕白",@"张飞"],@[@"李宗宪",@"张学良",@"嬴政",@"大禹"],@[@"陆小凤",@"陆依萍",@"李云龙",@"李自成"],@[@"魏征",@"白展堂",@"花无缺",@"云彦民"]];
    //这是一个分组的模型类
    for (NSMutableArray *name in groupNames) {
        YYMGroup *group1 = [[YYMGroup alloc] initWithItem:name];
        [dataArray addObject:group1];
    }
    
    
}

#pragma mark UITableViewDataSource回调方法
//这是tabview创建多少组的回调
- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return dataArray.count;
}
//这是每个组有多少联系人的回调
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    YYMGroup *group = dataArray[section];
    return group.isFolded? 0: group.size;
}
//将tabview的cell与数据模型绑定起来
- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CELL"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"CELL"];
    }
    //将模型里的数据赋值给cell
    YYMGroup *group = dataArray[indexPath.section];
    NSArray *arr=group.items;
    cell.textLabel.text = arr[indexPath.row];
    
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}


#pragma mark UITableViewDelegate回调方法
//对hearderView进行编辑
- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    //首先创建一个大的view，nameview
    UIView *nameView=[[UIView alloc]init];
    //将分组的名字nameLabel添加到nameview上
    UILabel *nameLabel=[[UILabel alloc]initWithFrame:CGRectMake(40, 0, self.view.frame.size.width, 40)];
    [nameView addSubview:nameLabel];
    nameView.layer.borderWidth=0.2;
    nameView.layer.borderColor=[UIColor grayColor].CGColor;
    NSArray *nameArray=@[@" 老朋友",@" 同事",@" 网友",@" 游戏朋友"];
    nameLabel.text=nameArray[section];
    //添加一个button用于响应点击事件（展开还是收起）
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame=CGRectMake(0, 0, self.view.frame.size.width, 40);
    [nameView addSubview:button];
    button.tag = 200 + section;
    [button addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    //将显示展开还是收起的状态通过三角符号显示出来
    UIImageView *fuhao=[[UIImageView alloc]initWithFrame:CGRectMake(10, 10, 20, 20)];
    fuhao.tag=section;
    [nameView addSubview:fuhao];
    //根据模型里面的展开还是收起变换图片
    YYMGroup *group = dataArray[section];
    if (group.isFolded==YES) {
        fuhao.image=[UIImage imageNamed:@"右边"];
    }else{
        fuhao.image=[UIImage imageNamed:@"下边"];
    }
    //返回nameView
    return nameView;
}
//设置headerView高度
- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 40;
}
//设置cell的高度
- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}
//button的响应点击事件
- (void) buttonClicked:(UIButton *) sender {
    //改变模型数据里面的展开收起状态
    YYMGroup *group2 = dataArray[sender.tag - 200];
    group2.folded = !group2.isFolded;
    [myTableView reloadData];
}

@end
