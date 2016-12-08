//
//  UploadImageHelp.h
//  HFWParkingProject
//
//  Created by Eric on 2016/12/8.
//  Copyright © 2016年 Eric. All rights reserved.
//

#import <Foundation/Foundation.h>
@protocol UploadImageDelegate <NSObject>
-(void)selectImage:(UIImage *)image;
-(void)uploading:(CGFloat)progress;
-(void)uploadSuccess:(NSDictionary *)dic;
-(void)uploadFail;
@end
@interface UploadImageHelp : NSObject<UIImagePickerControllerDelegate,UINavigationControllerDelegate>
@property(nonatomic,weak)UIViewController <UploadImageDelegate> *UploadDelegate;
@property(nonatomic,assign)BOOL upload;
+(UploadImageHelp *)shareUploadHelp;
/*
 name:上传到后台的图片名字
 pathNanme：上传到后台的路径名
 */
-(void)uploadImageWithImageName:(NSString *)name andPath:(NSString *)pathName;
@end
