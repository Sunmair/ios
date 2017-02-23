//
//  ViewController.m
//  PhotoGPSdemo
//
//  Created by Alex on 12-12-20.
//  Copyright (c) 2012年 Alex. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController
@synthesize imgView=_imgView;
@synthesize locationManager=_locationManager;
@synthesize mediaInfo=_mediaInfo;
@synthesize image=_image;
@synthesize lab=_lab;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    self.imgView=nil;
    self.locationManager=nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

#pragma mark custom
-(IBAction)takePhoto:(id)sender{
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
        UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
        imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
        imagePickerController.showsCameraControls = YES;
        imagePickerController.allowsEditing = NO;
        //imagePickerController.cameraOverlayView = [self pickerAttachView];
        imagePickerController.delegate = self;
        self.wantsFullScreenLayout =YES;
        [self presentModalViewController:imagePickerController animated:NO];
    }else{
        NSLog(@"无法拍照！");
    }
}

- (IBAction)showAlbum;
{
	UIImagePickerController *albumPicker = [[UIImagePickerController alloc] init];
	albumPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
	albumPicker.delegate = self;
	//albumPicker.allowsEditing = NO;
    [self presentModalViewController:albumPicker animated:YES];
}

/*
 保存图片到相册
 */
- (void)writeCGImage:(UIImage*)image metadata:(NSDictionary *)metadata{
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    ALAssetsLibraryWriteImageCompletionBlock imageWriteCompletionBlock =
    ^(NSURL *newURL, NSError *error) {
        if (error) {
            NSLog( @"Error writing image with metadata to Photo Library: %@", error );
        } else {
            NSLog( @"Wrote image with metadata to Photo Library");
        }
    };
    
    //保存相片到相册 注意:必须使用[image CGImage]不能使用强制转换: (__bridge CGImageRef)image,否则保存照片将会报错
    [library writeImageToSavedPhotosAlbum:[image CGImage]
                                 metadata:metadata
                          completionBlock:imageWriteCompletionBlock];
}

#pragma mark UIImagePickerControlleDelegates
- (void) imagePickerController: (UIImagePickerController *) picker didFinishPickingMediaWithInfo: (NSDictionary *) info {
    
    if(picker.sourceType == UIImagePickerControllerSourceTypeCamera)
    {
        //图片
        UIImage *image= [info objectForKey:UIImagePickerControllerOriginalImage];
        self.image=image;
        self.imgView.image=image;
        
        //照片mediaInfo
        self.mediaInfo=[NSMutableDictionary dictionaryWithDictionary:info];
        
        if (!_locationManager) {
            _locationManager = [[CLLocationManager alloc]init];
            [_locationManager setDelegate:self];
            [_locationManager setDistanceFilter:kCLDistanceFilterNone];
            [_locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
        }
        [_locationManager startUpdatingLocation];
    } else if(picker.sourceType == UIImagePickerControllerSourceTypePhotoLibrary){
        __block UIImage *image= [info objectForKey:UIImagePickerControllerOriginalImage];
        self.imgView.image=image;
        self.image=image;
        
        NSLog(@"info:%@",info);
        __block NSMutableDictionary *imageMetadata = nil;
        NSURL *assetURL = [info objectForKey:UIImagePickerControllerReferenceURL];
        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        [library assetForURL:assetURL
                 resultBlock:^(ALAsset *asset)  {
                     imageMetadata = [[NSMutableDictionary alloc] initWithDictionary:asset.defaultRepresentation.metadata];
                     //控制台输出查看照片的metadata
                     NSLog(@"%@",imageMetadata);
                     
                     //GPS数据
                     NSDictionary *GPSDict=[imageMetadata objectForKey:(NSString*)kCGImagePropertyGPSDictionary];
                     if (GPSDict!=nil) {
                         CLLocation *loc=[GPSDict locationFromGPSDictionary];
                         
                         self.lab.text=[NSString stringWithFormat:@"latitude:%f,longitude:%f",loc.coordinate.latitude,loc.coordinate.longitude];
                     }
                     else{
                         self.lab.text=@"此照片没有GPS信息";
                     }
                     
                     //EXIF数据
                     NSMutableDictionary *EXIFDictionary =[[imageMetadata objectForKey:(NSString *)kCGImagePropertyExifDictionary]mutableCopy];
                     NSString * dateTimeOriginal=[[EXIFDictionary objectForKey:(NSString*)kCGImagePropertyExifDateTimeOriginal] mutableCopy];
                     NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                     [dateFormatter setDateFormat:@"yyyy:MM:dd HH:mm:ss"];//yyyy-MM-dd HH:mm:ss
                     NSDate *date = [dateFormatter dateFromString:dateTimeOriginal];                     
                 }
                failureBlock:^(NSError *error) {
                }];
    }

    [picker dismissModalViewControllerAnimated: NO];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
	[picker dismissModalViewControllerAnimated:NO];
}

#pragma mark CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation{
    NSLog(@"定位成功！");
    [manager stopUpdatingLocation];
    self.lab.text=[NSString stringWithFormat:@"latitude:%f,longitude:%f",newLocation.coordinate.latitude,newLocation.coordinate.longitude];

    //获取照片元数据
    NSDictionary *dict = [_mediaInfo objectForKey:UIImagePickerControllerMediaMetadata];
    NSMutableDictionary *metadata = [NSMutableDictionary dictionaryWithDictionary:dict];
    
    //将GPS数据写入图片并保存到相册
    NSDictionary * gpsDict=[newLocation GPSDictionary];//CLLocation对象转换为NSDictionary
    if (metadata&& gpsDict) {
        [metadata setValue:gpsDict forKey:(NSString*)kCGImagePropertyGPSDictionary];
    }    
    [self writeCGImage:_image metadata:metadata];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    NSLog(@"定位失败！");
}

@end
