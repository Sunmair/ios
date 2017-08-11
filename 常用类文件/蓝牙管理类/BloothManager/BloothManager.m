//
//  BloothManager.m
//  HUDAssitantProject
//
//  Created by Eric on 2017/7/18.
//  Copyright © 2017年 Eric. All rights reserved.
//

#import "BloothManager.h"
#import "GaoDeMapManager.h"

#define channelOnPeropheralView @"peripheralView"
#define BLE_SEND_MAX_LEN 20
@interface BloothManager ()
@property(nonatomic,retain)NSMutableArray *peripheralDataArray;
@property(nonatomic,assign)bloothState state;
@property(nonatomic,assign)NSInteger sendCount;
@property(nonatomic,retain)NSMutableArray *cacheArr;
@end

@implementation BloothManager
-(NSMutableArray *)cacheArr{
    if (_cacheArr == nil) {
        _cacheArr = [NSMutableArray array];
    }
    return _cacheArr;
}
+(BloothManager *)shareBloothManager{
    static BloothManager *share;
    static  dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        share = [[BloothManager alloc]init];
         share.baby = [BabyBluetooth shareBabyBluetooth];
       [share addObserver:share forKeyPath:@"cacheArr" options:NSKeyValueObservingOptionNew context:nil];
    });
    return share;
}
-(void)startScanWithBloothManagerDelegate:(id)delegate{
    [SVProgressHUD showInfoWithStatus:@"准备打开设备"];
    
    //设置蓝牙委托
    self.managerDelegate = delegate;
    self.peripheralDataArray = [[NSMutableArray alloc]init];
    
    //初始化BabyBluetooth 蓝牙库
//    [self.baby retrievePeripheralWithUUIDString:@"1111"];
     [self babyDelegate];
    //停止之前的连接
    [self.baby cancelAllPeripheralsConnection];
    //设置委托后直接可以使用，无需等待CBCentralManagerStatePoweredOn状态。
    self.baby.scanForPeripherals().begin();

   
   
}
#pragma mark 结束扫描
-(void)endScreen{
     [self.baby cancelScan];
}
#pragma mark 链接设备
-(void)connectBloothPeripheral:(CBPeripheral *)peripheral{
    
    [SVProgressHUD showInfoWithStatus:@"开始连接设备"];
    [self connectConfig];
    self.baby.having(peripheral).and.channel(channelOnPeropheralView).then.connectToPeripherals().discoverServices().discoverCharacteristics().readValueForCharacteristic().discoverDescriptorsForCharacteristic().readValueForDescriptors().begin();
}
-(void)connectConfig{
    __weak typeof(self)weakSelf = self;
    BabyRhythm *rhythm = [[BabyRhythm alloc]init];
    
    
    //设置设备连接成功的委托,同一个baby对象，使用不同的channel切换委托回调
    [self.baby setBlockOnConnectedAtChannel:channelOnPeropheralView block:^(CBCentralManager *central, CBPeripheral *peripheral) {
        [SVProgressHUD showInfoWithStatus:[NSString stringWithFormat:@"设备：%@连接成功",peripheral.name]];
        weakSelf.currentPeripheral = peripheral;
        [[NSNotificationCenter defaultCenter]postNotificationName:BLOOTH_STATE_NOTIFION object:nil userInfo:@{@"state":@"1"} ];
        NSString *UUID = peripheral.identifier.UUIDString;
        [[UserInfoManager shareUserInfoManager]saveValue:UUID WithKey:@"peripheral"];
        weakSelf.state = BloothConnected;
        [weakSelf.baby AutoReconnect:peripheral];
        if ([weakSelf.managerDelegate respondsToSelector:@selector(connectSuccess)]) {
            [weakSelf.managerDelegate connectSuccess];
        }
    }];
    
    //设置设备连接失败的委托
    [self.baby setBlockOnFailToConnectAtChannel:channelOnPeropheralView block:^(CBCentralManager *central, CBPeripheral *peripheral, NSError *error) {
//        NSLog(@"设备：%@--连接失败",peripheral.name);
        [SVProgressHUD showInfoWithStatus:[NSString stringWithFormat:@"设备：%@连接失败",peripheral.name]];
    }];
    
    //设置设备断开连接的委托
    [self.baby setBlockOnDisconnectAtChannel:channelOnPeropheralView block:^(CBCentralManager *central, CBPeripheral *peripheral, NSError *error) {
//        NSLog(@"设备：%@--断开连接",peripheral.name);
         [[NSNotificationCenter defaultCenter]postNotificationName:BLOOTH_STATE_NOTIFION object:nil userInfo:@{@"state":@"0"} ];
        [SVProgressHUD showInfoWithStatus:[NSString stringWithFormat:@"设备：%@断开",peripheral.name]];
        
    }];
    
    //设置发现设备的Services的委托
    /*
    [self.baby setBlockOnDiscoverServicesAtChannel:channelOnPeropheralView block:^(CBPeripheral *peripheral, NSError *error) {
        for (CBService *s in peripheral.services) {
            ///插入section到tableview
//            [weakSelf insertSectionToTableView:s];
        }
        
        [rhythm beats];
    }];
     */
    //设置发现设service的Characteristics的委托
    [self.baby setBlockOnDiscoverCharacteristicsAtChannel:channelOnPeropheralView block:^(CBPeripheral *peripheral, CBService *service, NSError *error) {
        NSLog(@"===service name:%@",service.UUID);
        //插入row到tableview
//        [weakSelf insertRowToTableView:service];
        
    }];
    //设置读取characteristics的委托
    [self.baby setBlockOnReadValueForCharacteristicAtChannel:channelOnPeropheralView block:^(CBPeripheral *peripheral, CBCharacteristic *characteristics, NSError *error) {
        NSLog(@"characteristic name:%@ value is:%@",characteristics.UUID,characteristics.value);
    }];
    //设置发现characteristics的descriptors的委托
    [self.baby setBlockOnDiscoverDescriptorsForCharacteristicAtChannel:channelOnPeropheralView block:^(CBPeripheral *peripheral, CBCharacteristic *characteristic, NSError *error) {
        NSLog(@"===characteristic name:%@",characteristic.service.UUID);
        if ([characteristic.UUID.UUIDString isEqualToString:bloothCharacterId]) {
            weakSelf.characteristic = characteristic;
            [weakSelf.cacheArr removeAllObjects];
        }
        if (characteristic.properties & CBCharacteristicPropertyNotify ||  characteristic.properties & CBCharacteristicPropertyIndicate) {
            [peripheral setNotifyValue:YES forCharacteristic:characteristic];
            [weakSelf.baby notify:peripheral
                   characteristic:characteristic
                            block:^(CBPeripheral *peripheral, CBCharacteristic *characteristics, NSError *error) {
                                NSLog(@"notify block");
                                NSLog(@"new value %@",characteristics.value);
                                NSString *string = [[NSString alloc] initWithData:characteristics.value encoding:NSUTF8StringEncoding];
//                                NSString *base64String = [characteristics.value base64EncodedStringWithOptions:0];

                    
                                
                                KMyLog(@"%@",string);
                            }];
        }

    }];
    //设置读取Descriptor的委托
    [self.baby setBlockOnReadValueForDescriptorsAtChannel:channelOnPeropheralView block:^(CBPeripheral *peripheral, CBDescriptor *descriptor, NSError *error) {
        NSLog(@"Descriptor name:%@ value is:%@",descriptor.characteristic.UUID, descriptor.value);
    }];
    
    //读取rssi的委托
    [self.baby setBlockOnDidReadRSSI:^(NSNumber *RSSI, NSError *error) {
        NSLog(@"setBlockOnDidReadRSSI:RSSI:%@",RSSI);
    }];
    
    
    //设置beats break委托
    [rhythm setBlockOnBeatsBreak:^(BabyRhythm *bry) {
        NSLog(@"setBlockOnBeatsBreak call");
        
        //如果完成任务，即可停止beat,返回bry可以省去使用weak rhythm的麻烦
        //        if (<#condition#>) {
        //            [bry beatsOver];
        //        }
        
    }];
    
    //设置beats over委托
    [rhythm setBlockOnBeatsOver:^(BabyRhythm *bry) {
        NSLog(@"setBlockOnBeatsOver call");
    }];
    
    //扫描选项->CBCentralManagerScanOptionAllowDuplicatesKey:忽略同一个Peripheral端的多个发现事件被聚合成一个发现事件
    NSDictionary *scanForPeripheralsWithOptions = @{CBCentralManagerScanOptionAllowDuplicatesKey:@YES};
    /*连接选项->
     CBConnectPeripheralOptionNotifyOnConnectionKey :当应用挂起时，如果有一个连接成功时，如果我们想要系统为指定的peripheral显示一个提示时，就使用这个key值。
     CBConnectPeripheralOptionNotifyOnDisconnectionKey :当应用挂起时，如果连接断开时，如果我们想要系统为指定的peripheral显示一个断开连接的提示时，就使用这个key值。
     CBConnectPeripheralOptionNotifyOnNotificationKey:
     当应用挂起时，使用该key值表示只要接收到给定peripheral端的通知就显示一个提
     */
    NSDictionary *connectOptions = @{CBConnectPeripheralOptionNotifyOnConnectionKey:@YES,
                                     CBConnectPeripheralOptionNotifyOnDisconnectionKey:@YES,
                                     CBConnectPeripheralOptionNotifyOnNotificationKey:@YES};
    
    [self.baby setBabyOptionsAtChannel:channelOnPeropheralView scanForPeripheralsWithOptions:scanForPeripheralsWithOptions connectPeripheralWithOptions:connectOptions scanForPeripheralsWithServices:nil discoverWithServices:nil discoverWithCharacteristics:nil];
}
#pragma mark -蓝牙配置和操作

//蓝牙网关初始化和委托方法设置
-(void)babyDelegate{
    
    __weak typeof(self) weakSelf = self;
    [self.baby setBlockOnCentralManagerDidUpdateState:^(CBCentralManager *central) {
        if (central.state == CBCentralManagerStatePoweredOn) {
            [SVProgressHUD showInfoWithStatus:@"设备打开成功，开始扫描设备"];
            
        }
    }];
    
    //设置扫描到设备的委托
    [self.baby setBlockOnDiscoverToPeripherals:^(CBCentralManager *central, CBPeripheral *peripheral, NSDictionary *advertisementData, NSNumber *RSSI) {
        NSLog(@"搜索到了设备:%@",peripheral.name);
         NSString *UUID = [[UserInfoManager shareUserInfoManager]getValueWithKey:@"peripheral"];
        if ([peripheral.identifier.UUIDString isEqualToString:UUID]) {
            [weakSelf connectBloothPeripheral:peripheral];
        }
        
        [weakSelf insertPeripheralArr:peripheral advertisementData:advertisementData RSSI:RSSI];
    }];
    //设置发现设service的Characteristics的委托
    /*
    [self.baby setBlockOnDiscoverCharacteristics:^(CBPeripheral *peripheral, CBService *service, NSError *error) {
        NSLog(@"===service name:%@",service.UUID);
        for (CBCharacteristic *c in service.characteristics) {
            NSLog(@"charateristic name is :%@",c.UUID);
        }
    }];
    //设置读取characteristics的委托
    [self.baby setBlockOnReadValueForCharacteristic:^(CBPeripheral *peripheral, CBCharacteristic *characteristics, NSError *error) {
        NSLog(@"characteristic name:%@ value is:%@",characteristics.UUID,characteristics.value);
    }];
    //设置发现characteristics的descriptors的委托
    [self.baby setBlockOnDiscoverDescriptorsForCharacteristic:^(CBPeripheral *peripheral, CBCharacteristic *characteristic, NSError *error) {
        NSLog(@"===characteristic name:%@",characteristic.service.UUID);
        for (CBDescriptor *d in characteristic.descriptors) {
            NSLog(@"CBDescriptor name is :%@",d.UUID);
        }
    }];
    //设置读取Descriptor的委托
    [self.baby setBlockOnReadValueForDescriptors:^(CBPeripheral *peripheral, CBDescriptor *descriptor, NSError *error) {
        NSLog(@"Descriptor name:%@ value is:%@",descriptor.characteristic.UUID, descriptor.value);
    }];
    
    */
    //设置查找设备的过滤器
    [self.baby setFilterOnDiscoverPeripherals:^BOOL(NSString *peripheralName, NSDictionary *advertisementData, NSNumber *RSSI) {
        //最常用的场景是查找某一个前缀开头的设备
                if ([peripheralName containsString:@"HUD"] ) {
                    return YES;
                }
                return NO;
     
        //设置查找规则是名称大于0 ， the search rule is peripheral.name length > 0
//        if (peripheralName.length >0) {
            return YES;
//        }
//        return NO;
    }];
    
    
    [self.baby setBlockOnCancelAllPeripheralsConnectionBlock:^(CBCentralManager *centralManager) {
        NSLog(@"setBlockOnCancelAllPeripheralsConnectionBlock");
    }];
    
    [self.baby setBlockOnCancelScanBlock:^(CBCentralManager *centralManager) {
        NSLog(@"setBlockOnCancelScanBlock");
    }];
    
    
    /*设置babyOptions
     
     参数分别使用在下面这几个地方，若不使用参数则传nil
     - [centralManager scanForPeripheralsWithServices:scanForPeripheralsWithServices options:scanForPeripheralsWithOptions];
     - [centralManager connectPeripheral:peripheral options:connectPeripheralWithOptions];
     - [peripheral discoverServices:discoverWithServices];
     - [peripheral discoverCharacteristics:discoverWithCharacteristics forService:service];
     
     该方法支持channel版本:
     [baby setBabyOptionsAtChannel:<#(NSString *)#> scanForPeripheralsWithOptions:<#(NSDictionary *)#> connectPeripheralWithOptions:<#(NSDictionary *)#> scanForPeripheralsWithServices:<#(NSArray *)#> discoverWithServices:<#(NSArray *)#> discoverWithCharacteristics:<#(NSArray *)#>]
     */
    
    //示例:
    //扫描选项->CBCentralManagerScanOptionAllowDuplicatesKey:忽略同一个Peripheral端的多个发现事件被聚合成一个发现事件
    NSDictionary *scanForPeripheralsWithOptions = @{CBCentralManagerScanOptionAllowDuplicatesKey:@YES};
    //连接设备->
    [self.baby setBabyOptionsWithScanForPeripheralsWithOptions:scanForPeripheralsWithOptions connectPeripheralWithOptions:nil scanForPeripheralsWithServices:nil discoverWithServices:nil discoverWithCharacteristics:nil];
    
    
}
#pragma mark 存储到蓝牙数组中；
-(void)insertPeripheralArr:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI{
    NSArray *peripherals = [_peripheralDataArray valueForKey:@"peripheral"];
    NSArray *arr = [self.baby findConnectedPeripherals];
    for (CBPeripheral *per in arr) {
        if(![peripherals containsObject:per]) {
        NSMutableDictionary *item = [[NSMutableDictionary alloc] init];
        [item setValue:per forKey:@"peripheral"];
            
       [_peripheralDataArray addObject:item];
        }
    }
    if(![peripherals containsObject:peripheral]) {
        NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:peripherals.count inSection:0];
        [indexPaths addObject:indexPath];
        
        NSMutableDictionary *item = [[NSMutableDictionary alloc] init];
        [item setValue:peripheral forKey:@"peripheral"];
        [item setValue:RSSI forKey:@"RSSI"];
        [item setValue:advertisementData forKey:@"advertisementData"];
        [_peripheralDataArray addObject:item];

        if ([self.managerDelegate respondsToSelector:@selector(findNewBlooth:)]) {
            [self.managerDelegate findNewBlooth:self.peripheralDataArray];
        }
    }
}


-(void)writeNaviInfoDate:(NSData *)data{
    Byte  frameBeforeBase64 [5];
    frameBeforeBase64[0] = 'R';
    frameBeforeBase64[1] = 'd';
    frameBeforeBase64[2] = 0x00;
    frameBeforeBase64[3] =  0x00;
    frameBeforeBase64[4] = 0x07;
    
    NSMutableData *beforedata = [[NSData dataWithBytes:frameBeforeBase64 length:sizeof(frameBeforeBase64)]mutableCopy];
    //数据拼接
    [beforedata appendData:data];
  NSData *newData  =  [self alcChecksum:beforedata];
 
    //数据的 base64编码
    NSString *base64Encoded = [newData base64EncodedStringWithOptions:0];
    NSString *totalStr = [NSString stringWithFormat:@"^%@$",base64Encoded];
//    [totalStr dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    NSData *totalData =[totalStr dataUsingEncoding:NSUTF8StringEncoding];
    
    [[BloothManager shareBloothManager]writeDate:totalData];

}
-(NSData *)alcChecksum:(NSData *)data{
    Byte *testByte = (Byte *)[data bytes];
    if (data.length < 4) {
        return data;
    }
    testByte[2] = 0;
    testByte[3] = 0;
    int sum = 0;
    for(int i=0;i<[data length];i++){
       Byte b = testByte[i];
          sum += (b & 0xFF);
    }
//    int sum = (int)data.length;
     testByte[2] = (Byte)((sum & 0xFF00) >> 8);
    testByte[3] = (Byte)(sum &0xFF);
    NSData *newData = [NSData dataWithBytes:testByte length:data.length];
    return newData;
}
-(void)writeDate:(NSData *)data{
    [self.baby setBlockOnDidWriteValueForCharacteristicAtChannel:channelOnPeropheralView block:^(CBCharacteristic *characteristic, NSError *error) {
        //发送成功则移除 发送次数置为0， 状态置为已连接；
        if (error == nil) {
                        KMyLog(@"写完数据了");
        }else{
            
          
            KMyLog(@"写入出错");
        }
        
    }];
    if (self.characteristic == nil) {
        [SVProgressHUD showInfoWithStatus:@"未发现正确描述"];
        return;
    }
    [self sendMsgWithSubPackage:data];
//    [self.currentPeripheral writeValue:data forCharacteristic:self.characteristic type:CBCharacteristicWriteWithResponse];

    /*
    //检查数据是否已经存在缓存数组中
    if (![self.cacheArr containsObject:data]) {
        [self.cacheArr addObject:data];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW,(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            //do what you want to do
            [self repeatSend];
        });
    }
     */
}
#pragma mark  暂时不用
-(void)repeatSend{
    if (self.cacheArr.count <= 0) {
        return;
    }
    KWeakSelf(self);
    [self.baby setBlockOnDidWriteValueForCharacteristicAtChannel:channelOnPeropheralView block:^(CBCharacteristic *characteristic, NSError *error) {
        //发送成功则移除 发送次数置为0， 状态置为已连接；
        if (error == nil) {
            weakself.sendCount = 0;
            weakself.state = BloothConnected;
            if (self.cacheArr.count >0) {
                [weakself.cacheArr removeObjectAtIndex:0];
            }
            [weakself repeatSend];
            KMyLog(@"写完数据了");
        }else{
            
            [weakself repeatSend];
             KMyLog(@"写入出错");
        }
       
    }];
    //    NSData *cauce = self.cacheArr[0];
    //     [self.currentPeripheral writeValue:data forCharacteristic:self.characteristic type:CBCharacteristicWriteWithResponse];
    
    if (self.characteristic == nil) {
        [SVProgressHUD showInfoWithStatus:@"未发现正确描述"];
        return;
    }
    if (self.state == BloothSending) {
        self.sendCount += 1;
        if (self.sendCount < 3) {
            [self repeatSend];
        }else{
            self.sendCount = 0;
            [self.cacheArr removeObjectAtIndex:0];
            self.state = BloothConnected;
            [self repeatSend];
        }
    }else{
        self.sendCount = 0;
        self.state = BloothSending;
        NSData *data = self.cacheArr[0];
        [self.currentPeripheral writeValue:data forCharacteristic:self.characteristic type:CBCharacteristicWriteWithResponse];
       
    }

}
#pragma mark  分包发送蓝牙数据
-(void)sendMsgWithSubPackage:(NSData*)msgData{
    for (int i = 0; i < [msgData length]; i += BLE_SEND_MAX_LEN) {
        // 预加 最大包长度，如果依然小于总数据长度，可以取最大包数据大小
        if ((i + BLE_SEND_MAX_LEN) < [msgData length]) {
            NSString *rangeStr = [NSString stringWithFormat:@"%i,%i", i, BLE_SEND_MAX_LEN];
            NSData *subData = [msgData subdataWithRange:NSRangeFromString(rangeStr)];
            NSLog(@"%@",subData);
           [self.currentPeripheral writeValue:subData forCharacteristic:self.characteristic type:CBCharacteristicWriteWithResponse];
            //根据接收模块的处理能力做相应延时
            usleep(10 * 1000);
        }
        else {
            NSString *rangeStr = [NSString stringWithFormat:@"%i,%i", i, (int)([msgData length] - i)];
            NSData *subData = [msgData subdataWithRange:NSRangeFromString(rangeStr)];
            [self.currentPeripheral writeValue:subData forCharacteristic:self.characteristic type:CBCharacteristicWriteWithResponse];

////            [self writeCharacteristic:peripheral
//                       characteristic:character
//                                value:subData];
            usleep(10 * 1000);
        }
    }
}
#pragma mark 封装导航信息
#pragma mark 转向信息
-(void)actionTurnInfoWithIconType:(NSInteger )type  meters:(NSInteger)meters  andAnimat:(BOOL)animate{
    
//    NSString *key = [NSString stringWithFormat:@"%ld",type];
    
//    NSString *plistPath = [[NSBundle mainBundle]pathForResource:@"HUDKeyList" ofType:@"plist"];
//    NSDictionary *dic = [NSDictionary dictionaryWithContentsOfFile:plistPath];
//    NSString *value = [dic valueForKey:key];
//    int bleIconType = (int)[value integerValue];
    int bleIconType =(int) [self getYouHuaIconWithIconType:type andKeyWord:[GaoDeMapManager shareGaoDeMapManager].tiShiKeyWord];
    //    int bleIconType = (int)type;
    int  meter = (int)meters;
    Byte bytes[6];
    bytes[0] = COMMAND_TURN_INFO;
    bytes[1] =  (Byte) ((bleIconType & 0xFF00) >> 8);
    bytes[2] = (Byte) (bleIconType & 0xFF);
    bytes[3] = (Byte) ((meter & 0xFF00)>> 8 );
    bytes[4] = (Byte) (meter & 0xFF);
    
    bytes[5] = animate ? (Byte) 1 : (Byte) 0;
    NSData *data = [NSData dataWithBytes:bytes length:sizeof(bytes)];
    
    [self writeNaviInfoDate:data];
}
#pragma mark 限速数据
-(void)actionSpeedLimitWithSpeed:(int)speedLimit{
    Byte bytes[2];
    bytes[0] = COMMAND_SPEED_LIMIT;
    if (speedLimit <= 0) {
        bytes[1] = 0;
    } else if (speedLimit <= 30) {
        bytes[1] = 1;
    } else if (speedLimit <= 40) {
        bytes[1] = 2;
    } else if (speedLimit <= 50) {
        bytes[1] = 3;
    } else if (speedLimit <= 60) {
        bytes[1] = 4;
    } else if (speedLimit <= 70) {
        bytes[1] = 5;
    } else if (speedLimit <= 80) {
        bytes[1] = 6;
    } else if (speedLimit <= 90) {
        bytes[1] = 7;
    } else if (speedLimit <= 100) {
        bytes[1] = 8;
    } else if (speedLimit <= 110) {
        bytes[1] = 9;
    } else {
        bytes[1] = 10;
    }
    NSData *data = [NSData dataWithBytes:bytes length:sizeof(bytes)];
    [self writeNaviInfoDate:data];
}
#pragma mark 摄像头数据
-(void)actionCameraWithIsEnabled:(BOOL)isEnabled andDistabce:(int)meters{
    Byte bytes[4];
    bytes[0] = COMMAND_CAMERA;
    bytes[1] = isEnabled ? (Byte) 1 : (Byte) 0;
    bytes[2] =  (Byte) ((meters & 0xFF00) >> 8);
    bytes[3] =  (Byte) (meters & 0xFF);
    NSData *data = [NSData dataWithBytes:bytes length:sizeof(bytes)];
    [self writeNaviInfoDate:data];
}
#pragma mark 路口导向图
-(void)actionLaneWithIntArr:(NSArray *)lanes_8{
    int lanes_80 = [lanes_8[0] intValue];
    int lanes_81 = [lanes_8[1] intValue];
    int lanes_82 = [lanes_8[2] intValue];
    int lanes_83 = [lanes_8[3] intValue];
    int lanes_84 = [lanes_8[4] intValue];
    int lanes_85 = [lanes_8[5] intValue];
    int lanes_86 = [lanes_8[6] intValue];
    int lanes_87 = [lanes_8[7] intValue];
    //    int lanes_88 = [lanes_8[8] intValue];
    //    int lanes_89 = [lanes_8[9] intValue];
    Byte bytes[9];
    bytes[0] = COMMAND_LANE;
    bytes[1] = (lanes_80 <= 0 || lanes_80 > LANE_MAX) ? (Byte) LANE_HIDE : (Byte) lanes_80;
    bytes[2] = (lanes_81 <= 0 || lanes_81 > LANE_MAX) ? (Byte) LANE_HIDE : (Byte) lanes_81;
    bytes[3] = (lanes_82 <= 0 || lanes_82 > LANE_MAX) ? (Byte) LANE_HIDE : (Byte) lanes_82;
    bytes[4] = (lanes_83 <= 0 || lanes_83 > LANE_MAX) ? (Byte) LANE_HIDE : (Byte) lanes_83;
    bytes[5] = (lanes_84 <= 0 || lanes_84 > LANE_MAX) ? (Byte) LANE_HIDE : (Byte) lanes_84;
    bytes[6] = (lanes_85 <= 0 || lanes_85 > LANE_MAX) ? (Byte) LANE_HIDE : (Byte) lanes_85;
    bytes[7] = (lanes_86 <= 0 || lanes_86 > LANE_MAX) ? (Byte) LANE_HIDE : (Byte) lanes_86;
    bytes[8] = (lanes_87 <= 0 || lanes_87 > LANE_MAX) ? (Byte) LANE_HIDE : (Byte) lanes_87;
    NSData *data = [NSData dataWithBytes:bytes length:sizeof(bytes)];
    [[BloothManager shareBloothManager]writeNaviInfoDate:data];
}
#pragma mark 开始导航时传输的数据
-(void)actionStartNavi{
    Byte bytes[2];
    bytes[0] = COMMAND_SET_NAVI;
    bytes[1] = (Byte) 1;
    NSData *data = [NSData dataWithBytes:bytes length:sizeof(bytes)];
    [self writeNaviInfoDate:data];
}
#pragma mark 结束导航时传输的数据
-(void)actionStopNavi{
    Byte bytes[2];
    bytes[0] = COMMAND_SET_NAVI;
    bytes[1] = (Byte) 0;
    NSData *data = [NSData dataWithBytes:bytes length:sizeof(bytes)];
      [self writeNaviInfoDate:data];
}
#pragma mark 道路名称
-(void)actionRoadName:(NSString *)roadName{
    if (roadName == nil || [roadName isEqualToString:@""]) {
        Byte bytes[2];
        bytes[0] = COMMAND_ROAD_NAME;
        bytes[1] = 0;
        NSData *data = [NSData dataWithBytes:bytes length:sizeof(bytes)];
        [self writeNaviInfoDate:data];
        return;
    }
    
    //UTF8转 GBK 编码
    NSStringEncoding   gbkEncoding=CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    //    NSStringEncoding   gbkEncoding=CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGBK_95);
    NSData*data = [roadName dataUsingEncoding: gbkEncoding];
    
    Byte *bytes_gbk = (Byte *) [data bytes];
    
    int length =  (int)data.length;
    int len = MIN(length, 255);
    Byte bytes[2];
    bytes[0] = COMMAND_ROAD_NAME;
    bytes[1] = (Byte) len;
    NSMutableData *bytesData = [NSMutableData dataWithBytes:bytes length:sizeof(bytes)];
    [bytesData appendBytes:bytes_gbk length:len];
    //    [bytesData appendData:data];
    [self writeNaviInfoDate:bytesData];
    //    [[BloothManager shareBloothManager]writeNaviInfoDate:data];
}
#pragma mark  图标优化
-(NSInteger)getYouHuaIconWithIconType:(NSInteger)icon andKeyWord:(NSString *)key{
    //优化后的值
    NSInteger icontype = 0;
    switch (icon) {
        case  15:
        {
            icontype = 61;
        }
            break;
        case  13:
        {
            icontype = 58;
        }
            break;
        case  14:
        {
            icontype = 59;
        }
            break;
        case  16:
        {
            icontype = 60;
        }
            break;
        case  11:
        {
            icontype = 27;
        }
            break;
        case 2:
        {
            icontype = 5;
            if ([key containsString:@"丁字路口"]||[key containsString:@"道路尽头"]) {
                icontype = 5;
            }
            if ([key containsString:@"十字路口"]||[key containsString:@"红绿灯路口"]) {
                icontype = 37;
            }
            if ([key containsString:@"前方路口左转"]) {
                icontype = 26;
            }
        }
            break;
        case 6:
        {
            icontype = 45;
        }
            break;
        case 4:
        {
            icontype = 46;

            if ([key containsString:@"向左前方行驶"]) {
                icontype = 46;
            }
            if ([key containsString:@"靠左行驶"]&&[key containsString:@"向左前方行驶"]) {
                icontype = 13;
            }
            if ([key containsString:@"左前方靠左"]&&[key containsString:@"驶入主道"]) {
                icontype = 24;
            }
            if ([key containsString:@"靠右行驶"]&&[key containsString:@"进入辅道"]&&[key containsString:@"向左前方"]) {
                icontype = 22;
            }
          
            if ([key containsString:@"靠左行驶"]&&[key containsString:@"向左前方行驶"]&&[key containsString:@"驶入匝道"]) {
                icontype = 47;
            }
            if ([key containsString:@"向左前方行驶但不是左转"]) {
                icontype = 57;
            }
            if ([key containsString:@"三岔路口走最左边"]) {
                icontype = 31;
            }
            if ([key containsString:@"驶入左转专用道然后左转"]) {
                icontype = 41;
            }

        }
            break;
        case 8:
            icontype = 55;
            break;
            
        case 12:
        {
            icontype = 38;
        if ([key containsString:@"驶出环岛"]) {
                icontype = 38;
            }
        if ([key containsString:@"十字环岛一出口驶出环岛"]||[key containsString:@"绕环岛右转"]) {
                icontype = 34;
            }
        if ([key containsString:@"十字环岛第二出口驶出环岛"]||[key containsString:@"绕环岛直行"]) {
            icontype = 32;
        }
        if ([key containsString:@"十字环岛第三出口驶出环岛"]||[key containsString:@"绕环岛左转"]) {
                icontype = 33;
            }
        
        if ([key containsString:@"经过环岛"]&&[key containsString:@"出口"]) {
                icontype = 50;
            }
        }
            
            break;
        case 3:
        {
            icontype = 25;
            if ([key containsString:@"前方路口右转"] ) {
                icontype = 25;
            }
            if ([key containsString:@"丁字路口右转"]||[key containsString:@"道路尽头右转"]) {
                icontype = 4;
            }
            if ([key containsString:@"十字路口右转"]||[key containsString:@"红路灯路口右转"]) {
                icontype = 35;
            }
        }
            break;
        case 7:
        {
            icontype = 42;
        }
            break;
        case 5:
        {
            icontype = 43;
            if ([key containsString:@"向右前方行驶"]) {
                icontype = 43;
            }
            if ([key containsString:@"靠右行驶"]&&[key containsString:@"向右前方行驶"]) {
                icontype = 12;
            }
            if ([key containsString:@"靠右行驶"]&&[key containsString:@"进入主道"]&&[key containsString:@"向右前方"]) {
                icontype = 21;
            }
            if ([key containsString:@"靠右行驶"]&&[key containsString:@"进入辅道"]&&[key containsString:@"向右前方"]) {
                icontype = 19;
            }
            
            if ([key containsString:@"靠右行驶"]&&[key containsString:@"向右前方行驶"]&&[key containsString:@"匝道"]) {
                icontype = 47;
            }
            if ([key containsString:@"向右前方行驶但不是右转"]) {
                icontype = 1;
            }
            if ([key containsString:@"三岔路口走最右边"]) {
                icontype = 29;
            }
            if ([key containsString:@"驶入右转专用道然后右转"]) {
                icontype = 40;
            }

        }
            break;
      case 33:
        {
            icontype = 49;
        }
             break;
       case 9:
        {
            icontype = 48;
            if ([key containsString:@"沿道路直行"]) {
                icontype = 48;
            }
            
            if ([key containsString:@"三岔路口直行"]) {
                icontype = 30;
            }
            if ([key containsString:@"直行通过左三岔路口 "]) {
                icontype = 54;
            }
            if ([key containsString:@"直行通过右三岔路口 "]) {
                icontype = 52;
            }
            if ([key containsString:@"十字路口直行"] || [key containsString:@"红绿灯路口直行"]) {
                icontype = 36;
            }
            if ([key containsString:@"直行通过右岔路口"] && [key containsString:@"靠左沿道路直行"]) {
                icontype = 51;
            }
            if ([key containsString:@"直行通过左岔路口"] && [key containsString:@"靠右沿道路直行"]) {
                icontype = 53;
            }
        }
            break;
        default:
            break;
    }
    
    
    return icontype;
}
@end
