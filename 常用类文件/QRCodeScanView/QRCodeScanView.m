//
//  ShadowView.m
//  HFWMarchantProject
//
//  Created by Eric on 2016/12/5.
//  Copyright © 2016年 Eric. All rights reserved.
//

#import "QRCodeScanView.h"
#import <AVFoundation/AVFoundation.h>
@interface QRCodeScanView ()<AVCaptureMetadataOutputObjectsDelegate>
@property(nonatomic,retain)UIImageView *scanView;
@property (nonatomic, strong) UIImageView *lineView;
@property (nonatomic, strong) NSTimer *timer;
/** 输入数据源 */
@property (nonatomic, strong) AVCaptureDeviceInput *input;
/** 输出数据源 */
@property (nonatomic, strong) AVCaptureMetadataOutput *output;

//捕捉会话
@property (nonatomic, strong) AVCaptureSession *captureSession;
//展示layer
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *videoPreviewLayer;
/** 预览图层尺寸 */
@property (nonatomic, assign) CGSize layerViewSize;
/** 有效扫码范围 */
@property (nonatomic, assign) CGRect scanRect;
@property(nonatomic,retain)UIButton *dengButton;
@end
@implementation QRCodeScanView
{
    
    AVCaptureDevice *device;
}

-(instancetype)initWithFrame:(CGRect)frame andScanViewRect:(CGRect)scanRect{
    self = [super initWithFrame:frame];
    if (self) {
        self.scanRect = scanRect;
        
      [self startReading];
            }
    return self;
}
-(void)setUI{
    self.backgroundColor = [UIColor clearColor];
//    [self addSubview:self.botomView];
    self.scanView = [[UIImageView alloc]initWithFrame:self.scanRect];
    self.scanView.image = [UIImage imageNamed:@"扫码框"];
//    self.scanView.backgroundColor = [UIColor colorWithWhite:1 alpha:0.25];
   
    
    self.scanView.frame = self.scanRect;
    [self addSubview:self.scanView];
    self.lineView  = [[UIImageView alloc] init];
    self.lineView .frame = CGRectMake(self.scanView.frame.origin.x, self.scanView.frame.origin.y, self.scanView.frame.size.width, 2);
    self.lineView.image = [UIImage imageNamed:@"line"];
    [self addSubview:self.lineView];
    //添加打开闪光灯的button
    self.dengButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.dengButton.frame = CGRectMake((KDeviceWidth-40)*0.5,CGRectGetMaxY(self.scanView.frame)+35, 40, 40);
    [self.dengButton setImage:[UIImage imageNamed:@"关灯"] forState:UIControlStateNormal];
    [self.dengButton setImage:[UIImage imageNamed:@"开灯"] forState:UIControlStateSelected];
    [self.dengButton addTarget:self action:@selector(handleKaiDeng:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.dengButton];
//    [self startReading];
}
-(void)startReading{
    NSError *error;
    //1.初始化捕捉设备（AVCaptureDevice），类型为AVMediaTypeVideo 视频类型
    AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    //2.用captureDevice创建输入流
    self.input =[AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:&error];
    if (error) {
        NSLog(@"没有输入设备");
    }else{
        //3.创建媒体数据输出流
        self.output = [[AVCaptureMetadataOutput alloc] init];
        //AVCaptureMetadataOutput的属性,可以限制扫描区域
        
        //@property(nonatomic) CGRect rectOfInterest NS_AVAILABLE_IOS(7_0);
        
        //4.实例化捕捉会话
        _captureSession = [[AVCaptureSession alloc] init];
        
        //4.1.设置会话的输入设备
        [_captureSession addInput:_input];
        
        //4.2.设置会话的输入设备
        [_captureSession addOutput:_output];
        
        //5.创建串行队列，并加媒体输出流添加到队列当中
        dispatch_queue_t dispatchQueue;
        dispatchQueue = dispatch_queue_create("Queue", NULL);
        
        //5.1.设置代理
        [self.output setMetadataObjectsDelegate:self queue:dispatchQueue];
        
        //5.2.设置输出媒体数据类型为QRCode
        [self.output setMetadataObjectTypes:[NSArray arrayWithObject:AVMetadataObjectTypeQRCode]];
        
        //6.实例化预览图层
        _videoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_captureSession];
        //7.设置预览图层填充方式
        [_videoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
        
        //8.设置图层的frame
        [_videoPreviewLayer setFrame:self.frame];
        //9.将图层添加到预览view的图层上
        [self.layer addSublayer:_videoPreviewLayer];
        [self setUI];
        CGRect containerRect = self.scanView.frame;
        CGFloat x = containerRect.origin.y / self.frame.size.height;
        CGFloat y = containerRect.origin.x/ self.frame.size.width;
        CGFloat width = self.scanRect.size.height / self.frame.size.height;
        CGFloat height = self.scanRect.size.width / self.frame.size.width;
        self.output.rectOfInterest = CGRectMake(x, y, width,height);
        //10.开始扫描
        [_captureSession startRunning];
    }
    //    return YES;
}

#pragma mark - AVCaptureMetadataOutputObjectsDelegate

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    //判断是否有数据
    if (metadataObjects != nil && [metadataObjects count] > 0) {
        AVMetadataMachineReadableCodeObject *metadataObj = [metadataObjects objectAtIndex:0];
        //判断回传的数据是否为二维码
        if ([[metadataObj type] isEqualToString:AVMetadataObjectTypeQRCode]) {
            //在主线程执行设置_statusLabel的文本信息
            //            [_statusLabel performSelectorOnMainThread:@selector(setText:) withObject:[metadataObj stringValue] waitUntilDone:YES];
            
            NSLog(@"%@",[metadataObj stringValue]);
            //结束扫描
            [self performSelectorOnMainThread:@selector(haveReadText:) withObject:[metadataObj stringValue] waitUntilDone:NO];
//            _isReading = NO;
        }
    }
}
-(void)haveReadText:(NSString *)value{
    [self stopScan];
        if ([self.scanDelegate respondsToSelector:@selector(scanDidEnd:)]) {
        [self.scanDelegate scanDidEnd:value];
    }
}
-(void)stopScan{
    [_captureSession stopRunning];
    self.dengButton.selected = NO;
    [self stopTimer];
}
-(void)startScan{
    [_captureSession startRunning];
    [self startTimer];
}
-(void)handleKaiDeng:(UIButton *)sender{
    sender.selected = !sender.selected;
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo]; // 返回用于捕获视频数据的设备（摄像头）
        if (![device hasTorch]) {
            NSLog(@"没有闪光灯");
        }else{
            [device lockForConfiguration:nil]; // 请求独占设备的硬件性能
            if (device.torchMode == AVCaptureTorchModeOff) {
                [device setTorchMode: AVCaptureTorchModeOn]; // 打开闪光灯
            }else{
                [device setTorchMode: AVCaptureTorchModeOff]; // 关闭闪光灯
            }
        }
    }
}
-(void)playAnimation{
    
    [UIView animateWithDuration:2.4 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
         self.lineView .frame = CGRectMake(self.scanView.frame.origin.x, self.scanView.frame.size.height+self.scanView.frame.origin.y, self.scanView.frame.size.width, 2);
    } completion:^(BOOL finished) {
        self.lineView .frame = CGRectMake(self.scanView.frame.origin.x, self.scanView.frame.origin.y, self.scanView.frame.size.width, 2);
    }];
}

- (void)stopTimer
{
    [_timer invalidate];
    _timer = nil;
}
-(void)startTimer{
    if (!_timer) {
        [self playAnimation];
        /* 自动播放 */
        self.timer = [NSTimer scheduledTimerWithTimeInterval:2.5 target:self selector:@selector(playAnimation) userInfo:nil repeats:YES];
    }

}
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    [super drawRect:rect];
    [self startTimer];
   }
@end




