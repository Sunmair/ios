//
//  BloothManager.h
//  HUDAssitantProject
//
//  Created by Eric on 2017/7/18.
//  Copyright © 2017年 Eric. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SVProgressHUD.h"
#import "BabyBluetooth.h"

typedef enum
{
    BloothSending=0,
    BloothConnected,
    BloothDisConnect,
}bloothState;
@protocol BloothManagerDelegate <NSObject>

-(void)findNewBlooth:(NSArray *)arr;
-(void)connectSuccess;
@end

@interface BloothManager : NSObject
@property(nonatomic,retain)BabyBluetooth *baby;

+(BloothManager *)shareBloothManager;
///开始扫描
-(void)startScanWithBloothManagerDelegate:(id)delegate;
-(void)endScreen;
///连接
-(void)connectBloothPeripheral:(CBPeripheral *)peripheral;
///
@property(nonatomic,retain)CBPeripheral *currentPeripheral;
@property(nonatomic,retain)CBCharacteristic *characteristic;
@property(nonatomic,weak)id<BloothManagerDelegate>managerDelegate;
///写数据
-(void)writeNaviInfoDate:(NSData *)data;
////写导航数据
#pragma mark 开始导航时传输的数据
-(void)actionStartNavi;
///图标数据
-(void)actionTurnInfoWithIconType:(NSInteger )type  meters:(NSInteger)meters  andAnimat:(BOOL)animate;
#pragma mark 限速数据
///限速数据
-(void)actionSpeedLimitWithSpeed:(int)speedLimit;
#pragma mark 摄像头数据
///摄像头数据
-(void)actionCameraWithIsEnabled:(BOOL)isEnabled andDistabce:(int)meters;
///道路名
-(void)actionRoadName:(NSString *)roadName;
///道路信息
-(void)actionLaneWithIntArr:(NSArray *)lanes_8;
#pragma mark 结束导航时传输的数据
-(void)actionStopNavi;
@end
