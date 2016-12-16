//
//  ShadowView.h
//  HFWMarchantProject
//
//  Created by Eric on 2016/12/5.
//  Copyright © 2016年 Eric. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ScanDidEndDelegate <NSObject>

-(void)scanDidEnd:(NSString *)text;

@end

@interface QRCodeScanView : UIView
@property(nonatomic,weak)id <ScanDidEndDelegate>scanDelegate;
//@property (nonatomic, assign) CGSize showSize;
///设置相机的frame和扫描框的frame
-(instancetype)initWithFrame:(CGRect)frame andScanViewRect:(CGRect)scanRect;
-(void)stopScan;
-(void)startScan;
@end
