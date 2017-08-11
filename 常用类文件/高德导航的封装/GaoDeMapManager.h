//
//  GaoDeMapManager.h
//  HUDAssitantProject
//
//  Created by Eric on 2017/7/14.
//  Copyright © 2017年 Eric. All rights reserved.
//

#import "BaseModel.h"
#import <MAMapKit/MAMapKit.h>
#import <AMapFoundationKit/AMapFoundationKit.h>
#import <AMapSearchKit/AMapSearchKit.h>
#import <AMapLocationKit/AMapLocationKit.h>
#import <AMapNaviKit/AMapNaviKit.h>
#import "DriveNaviViewController.h"
@protocol GaoDeMapDelegate <NSObject>

@end
@protocol GaoDeMapSearchDelegate <NSObject>
@optional
-(void)reGoecodeSearchSuccess:(AMapReGeocodeSearchResponse *)response;

-(void)keyWordSearchSuccess:(NSArray *)arr;
@end
@interface GaoDeMapManager : BaseModel<AMapSearchDelegate,AMapLocationManagerDelegate,MAMapViewDelegate,DriveNaviViewControllerDelegate,AMapNaviDriveManagerDelegate,AMapNaviDriveDataRepresentable>
///当前坐标
@property(nonatomic,assign)CLLocationCoordinate2D currentLocation;
///当前城市信息
@property(nonatomic,assign)AMapReGeocodeSearchResponse *response;
//AMapNaviDriveManagerDelegate
@property (nonatomic, strong) AMapNaviDriveManager *driveManager;

@property(nonatomic,retain)NSString *tiShiKeyWord;

@property(nonatomic,retain)DriveNaviViewController *driverViewController;

+(GaoDeMapManager *)shareGaoDeMapManager;
///获取高德地图
-(MAMapView *)getMapViewWithFrame:(CGRect)frame andMapViewDelegate:(id)delegate;
///开始 定位
- (void)startSerialLocation;
///结束定位
- (void)stopSerialLocation;
///查询代理；
@property(nonatomic,weak)id<GaoDeMapSearchDelegate>searchDelegate;
///发起地理逆编码查询
-(void)startReGoecodeSearchWithLoction:(CLLocationCoordinate2D)location andDelegate:(id)delegate;

///关键词搜索
-(void)searchRequestWithCity:(NSString *)city  andKeyWord:(NSString *)key andDelegate:(id)delegate;
///附近搜索
-(void)searchNearbywithKeyWord:(NSString *)key andDelegate:(id)delegate;
///两点之间的距离
-(CGFloat)distanceInStart:(CLLocationCoordinate2D)start withEnd:(CLLocationCoordinate2D)end;


///导航
-(void)startNaviWithStartPoint:(CLLocationCoordinate2D)start andEndPoint:(CLLocationCoordinate2D)end andDelegate:(id)delegate;
///存文件
-(void)archiverHistoryWithArr:(NSArray *)arr andFileName:(NSString *)name;
///取文件
-(NSArray *)unarchiverHistoryWithFilename:(NSString *)name;
@end
