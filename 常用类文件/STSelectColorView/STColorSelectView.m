//
//  STColorSelectView.m
//  ColorPicker
//
//  Created by Eric on 2018/9/13.
//  Copyright © 2018年 zws. All rights reserved.
//

#import "STColorSelectView.h"
@interface STColorSelectView ()
@property (nonatomic, retain) UIImageView *stColorView;
@property (nonatomic, retain) UIImageView *stKnobView;

@end
@implementation STColorSelectView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (instancetype)initWithFrame:(CGRect)frame andImage:(UIImage *)image
{
self = [super initWithFrame:CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, frame.size.width)];
     if (self) {
          UIImage *temp = [self imageForResizeWithImage:image resize:CGSizeMake(self.frame.size.width, self.frame.size.width)];
         UIImageView *stColor = [[UIImageView alloc] initWithImage:temp];
         stColor.userInteractionEnabled = YES;
         stColor.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
         UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapGRAct:)];
         [stColor addGestureRecognizer:tap];
         [self addSubview:stColor];
         self.stColorView = stColor;
         UIImageView *wheelKnob = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"colorPickerKnob.png"]];
         wheelKnob.center = self.stColorView.center;
         wheelKnob.userInteractionEnabled = YES;
         UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panGRAct:)];
         [wheelKnob addGestureRecognizer:pan];
         [self addSubview:wheelKnob];
         self.stKnobView = wheelKnob;
     }
    return self;
}
- (void)tapGRAct: (UITapGestureRecognizer *)recognizer{

    CGPoint location = [recognizer locationInView:self];
    [self colorChangeWithPoint:location];

}
- (void)panGRAct: (UIPanGestureRecognizer *)recognizer{
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        
    } else if (recognizer.state == UIGestureRecognizerStateChanged) {
        CGPoint location = [recognizer locationInView:self];
        [self colorChangeWithPoint:location];
    }
}
-(void)colorChangeWithPoint:(CGPoint)pointL{
    if (pow(pointL.x - self.bounds.size.width/2, 2)+pow(pointL.y-self.bounds.size.width/2, 2) <= pow(self.bounds.size.width/2, 2)) {
        self.stKnobView.center = pointL;
        UIColor *color = [self colorAtPixel:pointL];
        if (self.currentColorBlock) {
            
            self.currentColorBlock(color);
        }
    }
}
//获取图片某一点的颜色
- (UIColor *)colorAtPixel:(CGPoint)point {
    if (!CGRectContainsPoint(CGRectMake(0.0f, 0.0f, self.stColorView.image.size.width, self.stColorView.image.size.height), point)) {
        return nil;
    }
    
    NSInteger pointX = trunc(point.x);
    NSInteger pointY = trunc(point.y);
    CGImageRef cgImage = self.stColorView.image.CGImage;
    NSUInteger width = self.stColorView.image.size.width;
    NSUInteger height = self.stColorView.image.size.height;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    int bytesPerPixel = 4;
    int bytesPerRow = bytesPerPixel * 1;
    NSUInteger bitsPerComponent = 8;
    unsigned char pixelData[4] = { 0, 0, 0, 0 };
    CGContextRef context = CGBitmapContextCreate(pixelData,
                                                 1,
                                                 1,
                                                 bitsPerComponent,
                                                 bytesPerRow,
                                                 colorSpace,
                                                 kCGImageAlphaPremultipliedLast |     kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);
    CGContextSetBlendMode(context, kCGBlendModeCopy);
    
    CGContextTranslateCTM(context, -pointX, pointY-(CGFloat)height);
    CGContextDrawImage(context, CGRectMake(0.0f, 0.0f, (CGFloat)width, (CGFloat)height), cgImage);
    CGContextRelease(context);
    
    CGFloat red   = (CGFloat)pixelData[0] / 255.0f;
    CGFloat green = (CGFloat)pixelData[1] / 255.0f;
    CGFloat blue  = (CGFloat)pixelData[2] / 255.0f;
    CGFloat alpha = (CGFloat)pixelData[3] / 255.0f;
    
    NSLog(@"%f***%f***%f***%f",red,green,blue,alpha);
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}



- (UIImage *)imageForResizeWithImage:(UIImage *)picture resize:(CGSize)resize {
    CGSize imageSize = resize; //CGSizeMake(25, 25)
    UIGraphicsBeginImageContextWithOptions(imageSize, NO,0.0);
    CGRect imageRect = CGRectMake(0.0, 0.0, imageSize.width, imageSize.height);
    [picture drawInRect:imageRect];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    return image;
}
@end
