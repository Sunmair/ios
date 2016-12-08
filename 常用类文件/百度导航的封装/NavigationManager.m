//
//  NavigationManager.m
//  HFWParkingProject
//
//  Created by Eric on 2016/11/24.
//  Copyright © 2016年 Eric. All rights reserved.
//

#import "NavigationManager.h"

@implementation NavigationManager
+(NavigationManager *)shareNavigation{
    static  NavigationManager *share ;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        share = [[NavigationManager alloc]init];
    });
    return share;
}
#pragma mark  监测导航服务是否开启
- (BOOL)checkServicesInited
{
    if(![BNCoreServices_Instance isServicesInited])
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示"
                                                            message:@"引擎尚未初始化完成，请稍后再试"
                                                           delegate:nil
                                                  cancelButtonTitle:@"我知道了"
                                                  otherButtonTitles:nil];
        [alertView show];
        return NO;
    }
    return YES;
}
#pragma mark 判断
//真实GPS导航
//-(void)realNavi{
//    if (![self checkServicesInited]) return;
//    [self startNavi];
//}

#pragma mark 开始导航
-(void)startNaviWithStartPoint:(CLLocationCoordinate2D)start andEndPoint:(CLLocationCoordinate2D)end{
     if (![self checkServicesInited]) return;
    NSMutableArray *nodesArray = [[NSMutableArray alloc]initWithCapacity:2];
    //起点 传入的是原始的经纬度坐标，若使用的是百度地图坐标，可以使用BNTools类进行坐标转化
    //起点
    BNRoutePlanNode *startNode = [[BNRoutePlanNode alloc] init];
    startNode.pos = [[BNPosition alloc] init];
//    startNode.pos.x = start.longitude;
//    startNode.pos.y = start.latitude;
    startNode.pos.x = 113.948222;
        startNode.pos.y = 22.549555;
    startNode.pos.eType = BNCoordinate_BaiduMapSDK;
    [nodesArray addObject:startNode];
    //终点
    BNRoutePlanNode *endNode = [[BNRoutePlanNode alloc] init];
    endNode.pos = [[BNPosition alloc] init];
//    endNode.pos.x = end.longitude;
//    endNode.pos.y = end.latitude;
    endNode.pos.x = 113.977004;
    endNode.pos.y = 22.556393;
    endNode.pos.eType = BNCoordinate_BaiduMapSDK;
    [nodesArray addObject:endNode];
    
    [BNCoreServices_RoutePlan startNaviRoutePlan:BNRoutePlanMode_Recommend naviNodes:nodesArray time:nil delegete:self userInfo:nil];
}
-(void)startNavi{
   
}
#pragma mark  导航回调
//算路成功回调
-(void)routePlanDidFinished:(NSDictionary *)userInfo
{
    NSLog(@"算路成功");
    //路径规划成功，开始导航
    [BNCoreServices_UI showPage:BNaviUI_NormalNavi delegate:self extParams:nil];
    
}

//算路失败回调
- (void)routePlanDidFailedWithError:(NSError *)error andUserInfo:(NSDictionary*)userInfo
{
    switch ([error code]%10000)
    {
        case BNAVI_ROUTEPLAN_ERROR_LOCATIONFAILED:
            NSLog(@"暂时无法获取您的位置,请稍后重试");
            break;
        case BNAVI_ROUTEPLAN_ERROR_ROUTEPLANFAILED:
            NSLog(@"无法发起导航");
            break;
        case BNAVI_ROUTEPLAN_ERROR_LOCATIONSERVICECLOSED:
            NSLog(@"定位服务未开启,请到系统设置中打开定位服务。");
            break;
        case BNAVI_ROUTEPLAN_ERROR_NODESTOONEAR:
            NSLog(@"起终点距离起终点太近");
            break;
        default:
            NSLog(@"算路失败");
            break;
    }
}

//算路取消回调
-(void)routePlanDidUserCanceled:(NSDictionary*)userInfo {
    NSLog(@"算路取消");
}
#pragma mark - 安静退出导航
- (void)exitNaviUI
{
    [BNCoreServices_UI exitPage:EN_BNavi_ExitTopVC animated:YES extraInfo:nil];
}

#pragma mark - BNNaviUIManagerDelegate

//退出导航页面回调
- (void)onExitPage:(BNaviUIType)pageType  extraInfo:(NSDictionary*)extraInfo
{
    if (pageType == BNaviUI_NormalNavi)
    {
//        self.tabBarController.tabBar.hidden = YES;
        NSLog(@"退出导航");
    }
    else if (pageType == BNaviUI_Declaration)
    {
        NSLog(@"退出导航声明页面");
    }
}


@end
