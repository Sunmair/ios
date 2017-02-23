//
//  ViewController.h
//  PhotoGPSdemo
//
//  Created by Alex on 12-12-20.
//  Copyright (c) 2012年 Alex. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <ImageIO/ImageIO.h>
#import "CLLocation+GPSDictionary.h"
#import "NSDictionary+CLLocation.h"
#import <AssetsLibrary/AssetsLibrary.h>

@interface ViewController : UIViewController<UINavigationControllerDelegate,UIImagePickerControllerDelegate,CLLocationManagerDelegate>

@property(nonatomic,unsafe_unretained)IBOutlet UIImageView* imgView;
@property(nonatomic,unsafe_unretained)IBOutlet UILabel* lab;
@property(nonatomic,strong)CLLocationManager* locationManager;
@property(nonatomic,strong)NSMutableDictionary* mediaInfo;//当前照片的mediaInfo
@property(nonatomic,strong)UIImage* image;//当前照片

-(IBAction)takePhoto:(id)sender;
- (IBAction)showAlbum;

@end
