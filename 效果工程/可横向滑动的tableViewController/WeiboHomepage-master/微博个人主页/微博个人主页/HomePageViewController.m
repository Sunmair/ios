//
//  HomePageViewController.m
//  微博个人主页
//
//  Created by zenglun on 16/5/4.
//  Copyright © 2016年 chengchengxinxi. All rights reserved.
//

#import "HomePageViewController.h"
#import "BaseTableViewController.h"
#import "LeftTableViewController.h"
#import "MiddleTableViewController.h"
#import "RightTableViewController.h"
#import "CommualHeaderView.h"
#import "HMSegmentedControl.h"
#import "ColorUtility.h"

@interface HomePageViewController () <TableViewScrollingProtocol> {
    BOOL _stausBarColorIsBlack;
}

@property (nonatomic, weak) UIView *navView;
@property (nonatomic, strong) HMSegmentedControl *segCtrl;
@property (nonatomic, strong) CommualHeaderView *headerView;

@property (nonatomic, strong) NSArray  *titleList;
@property (nonatomic, weak) UIViewController *showingVC;
@property (nonatomic, strong) NSMutableDictionary *offsetYDict; // 存储每个tableview在Y轴上的偏移量

@end

@implementation HomePageViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.automaticallyAdjustsScrollViewInsets = NO;
    _titleList = @[@"主页", @"微博", @"相册"];
    
    [self configNav];
    [self addController];
    [self addHeaderView];
    [self segmentedControlChangedValue:_segCtrl];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new]forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = nil;
}

-(UIStatusBarStyle)preferredStatusBarStyle
{
    return _stausBarColorIsBlack ? UIStatusBarStyleDefault : UIStatusBarStyleLightContent;
}

#pragma mark - BaseTabelView Delegate
- (void)tableViewScroll:(UITableView *)tableView offsetY:(CGFloat)offsetY{
    if (offsetY > headerImgHeight - topBarHeight) {
        if (![_headerView.superview isEqual:self.view]) {
            [self.view insertSubview:_headerView belowSubview:_navView];
        }
        CGRect rect = self.headerView.frame;
        rect.origin.y = topBarHeight - headerImgHeight;
        self.headerView.frame = rect;
    } else {
        if (![_headerView.superview isEqual:tableView]) {
            for (UIView *view in tableView.subviews) {
                if ([view isKindOfClass:[UIImageView class]]) {
                    [tableView insertSubview:_headerView belowSubview:view];
                    break;
                }
            }
        }
        CGRect rect = self.headerView.frame;
        rect.origin.y = 0;
        self.headerView.frame = rect;
    }

    
    if (offsetY>0) {
        CGFloat alpha = offsetY/136;
        self.navView.alpha = alpha;
        
        if (alpha > 0.6 && !_stausBarColorIsBlack) {
            self.navigationController.navigationBar.tintColor = [UIColor blackColor];
            _stausBarColorIsBlack = YES;
            [self setNeedsStatusBarAppearanceUpdate];
        } else if (alpha <= 0.6 && _stausBarColorIsBlack) {
            self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
            _stausBarColorIsBlack = NO;
            [self setNeedsStatusBarAppearanceUpdate];
        }
    } else {
        self.navView.alpha = 0;
        self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
        _stausBarColorIsBlack = NO;
        [self setNeedsStatusBarAppearanceUpdate];
    }
}

- (void)tableViewDidEndDragging:(UITableView *)tableView offsetY:(CGFloat)offsetY {
//    _headerView.canNotResponseTapTouchEvent = NO;  这四行被屏蔽内容，每行下面一行的效果一样
    _headerView.userInteractionEnabled = YES;
    
    NSString *addressStr = [NSString stringWithFormat:@"%p", _showingVC];
    if (offsetY > headerImgHeight - topBarHeight) {
        [self.offsetYDict enumerateKeysAndObjectsUsingBlock:^(NSString  *key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            if ([key isEqualToString:addressStr]) {
                _offsetYDict[key] = @(offsetY);
            } else if ([_offsetYDict[key] floatValue] <= headerImgHeight - topBarHeight) {
                _offsetYDict[key] = @(headerImgHeight - topBarHeight);
            }
        }];
    } else {
        if (offsetY <= headerImgHeight - topBarHeight) {
            [self.offsetYDict enumerateKeysAndObjectsUsingBlock:^(NSString  *key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                _offsetYDict[key] = @(offsetY);
            }];
        }
    }
}

- (void)tableViewDidEndDecelerating:(UITableView *)tableView offsetY:(CGFloat)offsetY {
//    _headerView.canNotResponseTapTouchEvent = NO; 这四行被屏蔽内容，每行下面一行的效果一样
    _headerView.userInteractionEnabled = YES;
    
    NSString *addressStr = [NSString stringWithFormat:@"%p", _showingVC];
    if (offsetY > headerImgHeight - topBarHeight) {
        [self.offsetYDict enumerateKeysAndObjectsUsingBlock:^(NSString  *key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            if ([key isEqualToString:addressStr]) {
                _offsetYDict[key] = @(offsetY);
            } else if ([_offsetYDict[key] floatValue] <= headerImgHeight - topBarHeight) {
                _offsetYDict[key] = @(headerImgHeight - topBarHeight);
            }
        }];
    } else {
        if (offsetY <= headerImgHeight - topBarHeight) {
            [self.offsetYDict enumerateKeysAndObjectsUsingBlock:^(NSString  *key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                _offsetYDict[key] = @(offsetY);
            }];
        }
    }
}

- (void)tableViewWillBeginDecelerating:(UITableView *)tableView offsetY:(CGFloat)offsetY {
//    _headerView.canNotResponseTapTouchEvent = YES; 这四行被屏蔽内容，每行下面一行的效果一样
    _headerView.userInteractionEnabled = NO;
}

- (void)tableViewWillBeginDragging:(UITableView *)tableView offsetY:(CGFloat)offsetY {
//    _headerView.canNotResponseTapTouchEvent = YES; 这四行被屏蔽内容，每行下面一行的效果一样
    _headerView.userInteractionEnabled = NO;
}

#pragma mark - Private
- (void)configNav {
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    UIView *navView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 64)];
    navView.backgroundColor = [UIColor whiteColor];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 32, kScreenWidth, 20)];
    titleLabel.text = @"我帮你打水";
    titleLabel.font = [UIFont systemFontOfSize:17];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [navView addSubview:titleLabel];
    navView.alpha = 0;
    [self.view addSubview:navView];
    
    _navView = navView;
}

- (void)addController {
    LeftTableViewController *vc1 = [[LeftTableViewController alloc] init];
    vc1.delegate = self;
    MiddleTableViewController *vc2 = [[MiddleTableViewController alloc] init];
    vc2.delegate = self;
    RightTableViewController *vc3 = [[RightTableViewController alloc] init];
    vc3.delegate = self;
    [self addChildViewController:vc1];
    [self addChildViewController:vc2];
    [self addChildViewController:vc3];
}

- (void)addHeaderView {
    CommualHeaderView *headerView = [[[NSBundle mainBundle] loadNibNamed:@"CommualHeaderView" owner:nil options:nil] lastObject];
    headerView.frame = CGRectMake(0, 0, kScreenWidth, headerImgHeight+switchBarHeight);
    headerView.label.text = @"我帮你打水";
    self.headerView = headerView;
    self.segCtrl = headerView.segCtrl;
    
    _segCtrl.sectionTitles = _titleList;
    _segCtrl.backgroundColor = [ColorUtility colorWithHexString:@"e9e9e9"];
    _segCtrl.selectionIndicatorHeight = 2.0f;
    _segCtrl.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationDown;
    _segCtrl.selectionStyle = HMSegmentedControlSelectionStyleTextWidthStripe;
    _segCtrl.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor grayColor], NSFontAttributeName : [UIFont systemFontOfSize:15]};
    _segCtrl.selectedTitleTextAttributes = @{NSForegroundColorAttributeName : [ColorUtility colorWithHexString:@"fea41a"]};
    _segCtrl.selectionIndicatorColor = [ColorUtility colorWithHexString:@"fea41a"];
    _segCtrl.selectedSegmentIndex = 0;
    _segCtrl.borderType = HMSegmentedControlBorderTypeBottom;
    _segCtrl.borderColor = [UIColor lightGrayColor];
    
    [_segCtrl addTarget:self action:@selector(segmentedControlChangedValue:) forControlEvents:UIControlEventValueChanged];
}

- (void)segmentedControlChangedValue:(HMSegmentedControl*)sender {
    [_showingVC.view removeFromSuperview];
    
    BaseTableViewController *newVC = self.childViewControllers[sender.selectedSegmentIndex];
    if (!newVC.view.superview) {
        [self.view addSubview:newVC.view];
        newVC.view.frame = self.view.bounds;
    }
    
    NSString *nextAddressStr = [NSString stringWithFormat:@"%p", newVC];
    CGFloat offsetY = [_offsetYDict[nextAddressStr] floatValue];
    newVC.tableView.contentOffset = CGPointMake(0, offsetY);
    
    [self.view insertSubview:newVC.view belowSubview:self.navView];
    if (offsetY <= headerImgHeight - topBarHeight) {
        [newVC.view addSubview:_headerView];
        for (UIView *view in newVC.view.subviews) {
            if ([view isKindOfClass:[UIImageView class]]) {
                [newVC.view insertSubview:_headerView belowSubview:view];
                break;
            }
        }
        CGRect rect = self.headerView.frame;
        rect.origin.y = 0;
        self.headerView.frame = rect;
    }  else {
        [self.view insertSubview:_headerView belowSubview:_navView];
        CGRect rect = self.headerView.frame;
        rect.origin.y = topBarHeight - headerImgHeight;
        self.headerView.frame = rect;
    }
    _showingVC = newVC;
}

#pragma mark - Getter/Setter
- (NSMutableDictionary *)offsetYDict {
    if (!_offsetYDict) {
        _offsetYDict = [NSMutableDictionary dictionary];
        for (BaseTableViewController *vc in self.childViewControllers) {
            NSString *addressStr = [NSString stringWithFormat:@"%p", vc];
            _offsetYDict[addressStr] = @(CGFLOAT_MIN);
        }
    }
    return _offsetYDict;
}

@end
