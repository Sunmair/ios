//
//  GaoDeMapManager.m
//  HUDAssitantProject
//
//  Created by Eric on 2017/7/14.
//  Copyright © 2017年 Eric. All rights reserved.
//

#import "GaoDeMapManager.h"
#import "SpeechSynthesizer.h"
#import "AddressModel.h"
#import "NaviSettingModel.h"
@interface GaoDeMapManager ()
@property(nonatomic,retain)AMapLocationManager *locationManager;
@property (nonatomic, strong) AMapSearchAPI *search;

@property(nonatomic,weak)BaseViewController <AMapNaviDriveManagerDelegate> *naviDelegate;
@property(nonatomic,retain)MAMapView *mapView;
@property(nonatomic,retain)NSString *nextRoadName;

@end

@implementation GaoDeMapManager
+(GaoDeMapManager *)shareGaoDeMapManager{
    static  GaoDeMapManager *share ;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        share = [[GaoDeMapManager alloc]init];
        [AMapServices sharedServices].enableHTTPS = YES;
        share.search = [[AMapSearchAPI alloc] init];
        share.search.delegate = share;
        if (share.driveManager == nil)
        {
            share.driveManager = [[AMapNaviDriveManager alloc] init];
            [share.driveManager setDelegate:share];
            
            [share.driveManager setAllowsBackgroundLocationUpdates:YES];
            [share.driveManager setPausesLocationUpdatesAutomatically:NO];
        }


    });
    return share;
}
-(MAMapView *)getMapViewWithFrame:(CGRect)frame andMapViewDelegate:(id)delegate{
    if (_mapView == nil) {
        _mapView = [[MAMapView alloc] initWithFrame:frame];
        _mapView.delegate = delegate;
        _mapView.showsUserLocation = YES;    //YES 为打开定位，NO为关闭定位
        _mapView.zoomLevel = 15;
        [_mapView setUserTrackingMode: MAUserTrackingModeFollow animated:YES]; //地图跟着位置移动
        
        //自定义定位经度圈样式
        _mapView.customizeUserLocationAccuracyCircleRepresentation = YES;
        
        _mapView.userTrackingMode = MAUserTrackingModeFollow;
        _mapView.showTraffic = YES;
        //后台定位
        _mapView.pausesLocationUpdatesAutomatically = NO;
        
        _mapView.allowsBackgroundLocationUpdates = YES;//iOS9以上系统必须配置
        
        _mapView.compassOrigin= CGPointMake(_mapView.compassOrigin.x, 130); //设置指南针位置
        _mapView.scaleOrigin= CGPointMake(10,130-69);  //设置比例尺位置
    }
    //MAUserLocationRepresentation *r = [[MAUserLocationRepresentation alloc] init];
//    MAUserLocationRepresentation *r = [[MAUserLocationRepresentation alloc] init];
//    r.showsAccuracyRing = NO;///精度圈是否显示，默认YES
//    r.showsHeadingIndicator = YES;///是否显示方向指示(MAUserTrackingModeFollowWithHeading模式开启)。默认为YES
//    r.fillColor = [UIColor redColor];///精度圈 填充颜色, 默认 kAccuracyCircleDefaultColor
//    r.strokeColor = [UIColor blueColor];///精度圈 边线颜色, 默认 kAccuracyCircleDefaultColor
//    r.lineWidth = 2;///精度圈 边线宽度，默认0
//    r.enablePulseAnnimation = NO;///内部蓝色圆点是否使用律动效果, 默认YES
//    r.locationDotBgColor = [UIColor greenColor];///定位点背景色，不设置默认白色
//    r.locationDotFillColor = [UIColor grayColor];///定位点蓝色圆点颜色，不设置默认蓝色
//    r.image = [UIImage imageNamed:@"导航"]; ///定位图标, 与蓝色原点互斥
//    [self.mapView updateUserLocationRepresentation:r];

    return _mapView;
}
- (void)startSerialLocation
{
    if (self.locationManager == nil) {
        self.locationManager = [[AMapLocationManager alloc] init];
        
        [self.locationManager setDelegate:self];
        
        [self.locationManager setPausesLocationUpdatesAutomatically:NO];
        
        [self.locationManager setAllowsBackgroundLocationUpdates:YES];

    }
       //开始定位
    [self.locationManager startUpdatingLocation];
}

- (void)stopSerialLocation
{
    //停止定位
    [self.locationManager stopUpdatingLocation];
}
#pragma mark  AMapLocationManagerDelegate
- (void)amapLocationManager:(AMapLocationManager *)manager didFailWithError:(NSError *)error
{
    //定位错误
    NSLog(@"%s, amapLocationManager = %@, error = %@", __func__, [manager class], error);
}

- (void)amapLocationManager:(AMapLocationManager *)manager didUpdateLocation:(CLLocation *)location
{
    
    [self stopSerialLocation];
    _mapView.zoomLevel = 15;
    _mapView.centerCoordinate = location.coordinate;
    self.currentLocation = location.coordinate;
    [self startReGoecodeSearchWithLoction:self.currentLocation andDelegate:self.searchDelegate];
    //定位结果
    NSLog(@"location:{lat:%f; lon:%f; accuracy:%f}", location.coordinate.latitude, location.coordinate.longitude, location.horizontalAccuracy);
}
#pragma mark  逆地理编码
-(void)startReGoecodeSearchWithLoction:(CLLocationCoordinate2D)location andDelegate:(id)delegate{
    self.searchDelegate = delegate;
    AMapReGeocodeSearchRequest *regeo = [[AMapReGeocodeSearchRequest alloc] init];
    
    regeo.location                    = [AMapGeoPoint locationWithLatitude:location.latitude longitude:location.longitude];
    regeo.requireExtension            = YES;
    
    [self.search AMapReGoecodeSearch:regeo];

}
/* 逆地理编码回调. */
- (void)onReGeocodeSearchDone:(AMapReGeocodeSearchRequest *)request response:(AMapReGeocodeSearchResponse *)response
{
    [[UserInfoManager shareUserInfoManager]saveValue: response.regeocode.addressComponent.city WithKey:@"city"];
    self.response = response;
    if ([self.searchDelegate respondsToSelector:@selector(reGoecodeSearchSuccess:)]) {
        [self.searchDelegate reGoecodeSearchSuccess:response];
    }
    

}
- (void)AMapSearchRequest:(id)request didFailWithError:(NSError *)error
{
    if ([self.searchDelegate respondsToSelector:@selector(reGoecodeSearchSuccess:)]) {
        [self.searchDelegate reGoecodeSearchSuccess:nil];
    }

    KMyLog(@"Error: %@", error);
}
#pragma mark 关键词检索
-(void)searchRequestWithCity:(NSString *)city andKeyWord:(NSString *)key andDelegate:(id)delegate{
    AMapPOIKeywordsSearchRequest *request = [[AMapPOIKeywordsSearchRequest alloc] init];
    if (city == nil) {
        city =  [[UserInfoManager shareUserInfoManager]getValueWithKey:@"city"];
    }
    request.keywords            = key;
    request.city                = city;
    request.types               = @"";
    request.requireExtension    = YES;
    
    /*  搜索SDK 3.2.0 中新增加的功能，只搜索本城市的POI。*/
    request.cityLimit           = NO;
    request.requireSubPOIs      = YES;
    self.searchDelegate = delegate;
[self.search AMapPOIKeywordsSearch:request];
}
/* POI 搜索回调. */
- (void)onPOISearchDone:(AMapPOISearchBaseRequest *)request response:(AMapPOISearchResponse *)response
{
    if (response.pois.count == 0)
    {
        return;
    }
    NSMutableArray *addressArr = [NSMutableArray array];
    for (AMapPOI *poi in  response.pois) {
        AddressModel *address = [[AddressModel alloc]init];
        address.name = poi.name;
        address.address = poi.address;
        address.latitude = poi.location.latitude;
        address.longitude = poi.location.longitude;
        NSArray *collectArr = [self unarchiverHistoryWithFilename:collectListFilename];
         address.isCollected = NO;
        for (AddressModel *model in collectArr) {
            if ([model.address isEqualToString:address.address]) {
                 address.isCollected = YES;
            }
        }
        [addressArr addObject:address];
    }
    //解析response获取POI信息，具体解析见 Demo
    if ([self.searchDelegate respondsToSelector:@selector(keyWordSearchSuccess:)]) {
        [self.searchDelegate keyWordSearchSuccess:addressArr];
    }
    
}
#pragma mark 附近搜索
-(void)searchNearbywithKeyWord:(NSString *)key andDelegate:(id)delegate{
    AMapPOIAroundSearchRequest *request = [[AMapPOIAroundSearchRequest alloc] init];
    
    request.location = [AMapGeoPoint locationWithLatitude:self.currentLocation.latitude longitude:self.currentLocation.longitude];
    request.keywords            = key;
    /* 按照距离排序. */
    request.sortrule            = 0;
    request.requireExtension    = YES;
     self.searchDelegate = delegate;
    [self.search AMapPOIAroundSearch:request];
}
///计算距离
-(CGFloat)distanceInStart:(CLLocationCoordinate2D)start withEnd:(CLLocationCoordinate2D)end{
    MAMapPoint point1 = MAMapPointForCoordinate(CLLocationCoordinate2DMake(start.latitude,start.longitude));
    MAMapPoint point2 = MAMapPointForCoordinate(CLLocationCoordinate2DMake(end.latitude,end.longitude));
    //2.计算距离
    CLLocationDistance distance = MAMetersBetweenMapPoints(point1,point2);
    return distance;
}
#pragma mark 开始导航
-(void)startNaviWithStartPoint:(CLLocationCoordinate2D)start andEndPoint:(CLLocationCoordinate2D)end andDelegate:(id)delegate{
    
    AMapNaviPoint  *startPoint = [AMapNaviPoint locationWithLatitude:start.latitude
                                                         longitude:start.longitude];
  AMapNaviPoint  *endPoint = [AMapNaviPoint locationWithLatitude:end.latitude
                                          longitude:end.longitude];
     self.naviDelegate = delegate;
    AMapNaviDrivingStrategy config;
    NaviSettingModel *model = [NaviSettingModel unarchiverNaviSettingModel];
    NSInteger guiHua = [model.guiHua integerValue];
    switch (guiHua) {
        case 0:
            config = AMapNaviDrivingStrategySingleDefault;
            break;
        case 1:
            config = AMapNaviDrivingStrategySingleAvoidCongestion;
            break;
        case 2:
            config = AMapNaviDrivingStrategySingleAvoidHighway;
            break;
    
        default:
            config = AMapNaviDrivingStrategySingleDefault;
            break;
    }
    self.driveManager.updateCameraInfo = model.boBaoDianZiYan;
    self.driveManager.updateTrafficInfo = model.boBaoLuKuang;
    [self.naviDelegate showProgressHUBWithString:@"正在算路"];
    [self.driveManager calculateDriveRouteWithStartPoints:@[startPoint] endPoints:@[endPoint] wayPoints:nil drivingStrategy:config];

}
#pragma mark - DriveNaviView Delegate

- (void)driveNaviViewCloseButtonClicked
{
    //停止导航
    [self.driveManager stopNavi];
    [[BloothManager shareBloothManager]actionStopNavi];
    [self.driveManager removeDataRepresentative:self];

    //停止语音
    [[SpeechSynthesizer sharedSpeechSynthesizer] stopSpeak];
//    [self.naviDelegate.navigationController popViewControllerAnimated:NO];
    self.driverViewController = nil;
}

#pragma mark - AMapNaviDriveManager Delegate

- (void)driveManager:(AMapNaviDriveManager *)driveManager error:(NSError *)error
{
    NSLog(@"error:{%ld - %@}", (long)error.code, error.localizedDescription);
}
- (void)driveManagerOnCalculateRouteSuccess:(AMapNaviDriveManager *)driveManager
{
    NSLog(@"onCalculateRouteSuccess");
    if (self.driverViewController == nil) {
        self.driverViewController = [[DriveNaviViewController alloc] init];
        [self.driverViewController setDelegate:self];
    }
   
    
    //将driveView添加为导航数据的Representative，使其可以接收到导航诱导数据
//    [self.driveManager addDataRepresentative:driveVC.driveView];
    [self.naviDelegate.navigationController pushViewController:self.driverViewController animated:NO];
//    [self.driveManager startGPSNavi];
    [self.naviDelegate hideProgressHUB];
    //算路成功后进行模拟导航
    [self.driveManager startEmulatorNavi];

}

- (void)driveManager:(AMapNaviDriveManager *)driveManager onCalculateRouteFailure:(NSError *)error
{
    NSLog(@"onCalculateRouteFailure:{%ld - %@}", (long)error.code, error.localizedDescription);
}

- (void)driveManager:(AMapNaviDriveManager *)driveManager didStartNavi:(AMapNaviMode)naviMode
{
    [[BloothManager shareBloothManager]actionStartNavi];
    NSLog(@"didStartNavi");
}

- (void)driveManagerNeedRecalculateRouteForYaw:(AMapNaviDriveManager *)driveManager
{
    NSLog(@"needRecalculateRouteForYaw");
}

- (void)driveManagerNeedRecalculateRouteForTrafficJam:(AMapNaviDriveManager *)driveManager
{
    NSLog(@"needRecalculateRouteForTrafficJam");
}

- (void)driveManager:(AMapNaviDriveManager *)driveManager onArrivedWayPoint:(int)wayPointIndex
{
    NSLog(@"onArrivedWayPoint:%d", wayPointIndex);
}

- (BOOL)driveManagerIsNaviSoundPlaying:(AMapNaviDriveManager *)driveManager
{
    return [[SpeechSynthesizer sharedSpeechSynthesizer] isSpeaking];
}

- (void)driveManager:(AMapNaviDriveManager *)driveManager playNaviSoundString:(NSString *)soundString soundStringType:(AMapNaviSoundType)soundStringType
{
    
    self.tiShiKeyWord = soundString;
    NSLog(@"playNaviSoundString:{%ld:%@}", (long)soundStringType, soundString);
    
    [[SpeechSynthesizer sharedSpeechSynthesizer] speakString:soundString];
}

- (void)driveManagerDidEndEmulatorNavi:(AMapNaviDriveManager *)driveManager
{
    [[BloothManager shareBloothManager]actionStopNavi];
    [self.driveManager removeDataRepresentative:self];

    NSLog(@"didEndEmulatorNavi");
}

- (void)driveManagerOnArrivedDestination:(AMapNaviDriveManager *)driveManager
{
    [self.driveManager removeDataRepresentative:self];
    [[BloothManager shareBloothManager]actionStopNavi];
    NSLog(@"onArrivedDestination");
}
#pragma mark - AMapNaviDriveDataRepresentable

- (void)driveManager:(AMapNaviDriveManager *)driveManager updateNaviMode:(AMapNaviMode)naviMode
{
    
    NSLog(@"updateNaviMode:%ld", (long)naviMode);
}

- (void)driveManager:(AMapNaviDriveManager *)driveManager updateNaviRouteID:(NSInteger)naviRouteID
{
    NSLog(@"updateNaviRouteID:%ld", (long)naviRouteID);
}

- (void)driveManager:(AMapNaviDriveManager *)driveManager updateNaviRoute:(nullable AMapNaviRoute *)naviRoute
{
    NSLog(@"updateNaviRoute");
}
#pragma mark 转向图标  下一条路
- (void)driveManager:(AMapNaviDriveManager *)driveManager updateNaviInfo:(nullable AMapNaviInfo *)naviInfo
{
    
    //转向图标
    [[BloothManager shareBloothManager] actionTurnInfoWithIconType:naviInfo.iconType meters:naviInfo.segmentRemainDistance andAnimat:YES];
    
    //    naviInfo.iconType;
    //到达目的地
    if (naviInfo.iconType == 15) {
        [[BloothManager shareBloothManager] actionRoadName:@"到达目的地"];
    }
    //展示AMapNaviInfo类中的导航诱导信息，更多详细说明参考类 AMapNaviInfo 注释。
    
    //转向剩余距离
    //    NSString *turnStr = [NSString stringWithFormat:@"%@ 后，转向类型:%ld", [self normalizedRemainDistance:naviInfo.segmentRemainDistance], (long)naviInfo.iconType];
    //    [self.turnRemainInfoLabel setText:turnStr];
    //
    NSString *roadName = naviInfo.nextRoadName;
    if (naviInfo.nextRoadName==nil) {
        roadName = @"无名道路";
    }
    if (![self.nextRoadName isEqualToString:roadName]) {
        self.nextRoadName = roadName;
        [[BloothManager shareBloothManager] actionRoadName:roadName];
    }
    //道路信息
    
    NSString *roadStr = [NSString stringWithFormat:@"从 %@ 进入 %@", naviInfo.currentRoadName, naviInfo.nextRoadName];
    KMyLog(@"%@",roadStr);
    //    [self.roadInfoLabel setText:roadStr];
    
    //路径剩余信息
    //    NSString *routeStr = [NSString stringWithFormat:@"剩余距离:%@ 剩余时间:%@", [self normalizedRemainDistance:naviInfo.routeRemainDistance], [self normalizedRemainTime:naviInfo.routeRemainTime]];
    //    [self.routeRemainInfoLabel setText:routeStr];
}
#pragma mark 电子眼信息，限速信息；
- (void)driveManager:(AMapNaviDriveManager *)driveManager updateCameraInfos:(nullable NSArray<AMapNaviCameraInfo *> *)cameraInfos
{
    //距离最近的下个电子眼信息
    if (cameraInfos.count) {
        AMapNaviCameraInfo *camera = cameraInfos.firstObject;
        //限速
        int speed = (int) camera.cameraSpeed;
        [[BloothManager shareBloothManager] actionSpeedLimitWithSpeed:speed];
        //距离
        if (camera.distance >= 0)
        {
            int distance = (int) camera.distance;
            [[BloothManager shareBloothManager] actionCameraWithIsEnabled:YES andDistabce:distance];
        }
    }
    
}
#pragma mark 定位信息
- (void)driveManager:(AMapNaviDriveManager *)driveManager updateNaviLocation:(nullable AMapNaviLocation *)naviLocation
{
    //    NSLog(@"updateNaviLocation");
}
#pragma mark 显示路口图片；
- (void)driveManager:(AMapNaviDriveManager *)driveManager showCrossImage:(UIImage *)crossImage
{
    NSLog(@"showCrossImage");
}
#pragma mark 隐藏路口图片；
- (void)driveManagerHideCrossImage:(AMapNaviDriveManager *)driveManager
{
    NSLog(@"hideCrossImage");
}
#pragma mark 显示车道信息
- (void)driveManager:(AMapNaviDriveManager *)driveManager showLaneBackInfo:(NSString *)laneBackInfo laneSelectInfo:(NSString *)laneSelectInfo
{
    
    NSArray *allArr = [laneBackInfo componentsSeparatedByString:@"|"];
    NSMutableArray *allLaneArr = [NSMutableArray array];
    for (int i = 0; i < allArr.count; i++) {
        NSNumber *num = [NSNumber numberWithInt:LANE_HIDE];
        
        allLaneArr[i] = num;
    }
    NSArray *showArr = [laneSelectInfo componentsSeparatedByString:@"|"];
    //将不需要显示的隐藏掉
    for (int i = 0; i < showArr.count; i++) {
//        NSString *str = showArr[i];
        
        NSString *str = showArr[i];
        int strInt = [str intValue];
        int showInt;
        switch (strInt) {
            case 0:
                showInt = LANE_GO_STRAIGHT;
                break;
            case 1:
                showInt = LANE_TURN_LEFT;
                break;
            case 2:
                showInt = LANE_NO_TURN_RIGHT;
                break;
            case 3:
                showInt = LANE_TURN_RIGHT;
                break;
            case 4:
                showInt = LANE_NO_TURN_LEFT;
                break;
            case 5:
                showInt = LANE_U_TURN;
                break;
            case 6:
                showInt = LANE_NO_GO_STRAIGHT;
                break;
            case 7:
                showInt = LANE_NO_U_TURN;
                break;
            case 9:
                showInt = LANE_TURN_LEFT;
                break;
            default:
                showInt = LANE_HIDE;
                break;
        }
          NSNumber *num1 = [NSNumber numberWithInt:showInt];
         allLaneArr[i] = num1;
        if ([str isEqualToString:@"f"]) {
            NSNumber *num = [NSNumber numberWithInt:LANE_HIDE];
            allLaneArr[i] = num;
        }
    }
    [[BloothManager shareBloothManager] actionLaneWithIntArr:allLaneArr];
    //[0,1,1,0,0,0,0,0,]时没有反应
    KMyLog(@"%@",laneSelectInfo);
    NSLog(@"showLaneInfo");
}

- (void)driveManagerHideLaneInfo:(AMapNaviDriveManager *)driveManager
{
    NSNumber *num = [NSNumber numberWithInteger:LANE_HIDE];
    NSArray *arr = @[num,num,num,num,num,num,num,num];
    [[BloothManager shareBloothManager] actionLaneWithIntArr:arr];
    NSLog(@"hideLaneInfo");
}

- (void)driveManager:(AMapNaviDriveManager *)driveManager updateTrafficStatus:(nullable NSArray<AMapNaviTrafficStatus *> *)trafficStatus
{
    NSLog(@"updateTrafficStatus");
}

- (void)driveManager:(AMapNaviDriveManager *)driveManager updateServiceAreaInfos:(nullable NSArray<AMapNaviServiceAreaInfo *> *)serviceAreaInfos
{
    NSLog(@"updateServiceAreaInfos");
}

#pragma mark 存储到本地
-(void)archiverHistoryWithArr:(NSArray *)arr andFileName:(NSString *)name {
    NSString *paths = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
    KMyLog(@"Caches: %@", paths);
    NSString *personsArrPath = [paths stringByAppendingString:name];
    [NSKeyedArchiver archiveRootObject:arr toFile:personsArrPath];
}
-(NSArray *)unarchiverHistoryWithFilename:(NSString *)name{
    NSString *paths = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
    NSString *personsArrPath = [paths stringByAppendingString:name];
    NSArray *newPersonsArr = [NSKeyedUnarchiver unarchiveObjectWithFile:personsArrPath];
    return newPersonsArr;
}
 
@end
