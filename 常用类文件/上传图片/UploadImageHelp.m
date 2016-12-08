//
//  UploadImageHelp.m
//  HFWParkingProject
//
//  Created by Eric on 2016/12/8.
//  Copyright © 2016年 Eric. All rights reserved.
//

#import "UploadImageHelp.h"

@interface UploadImageHelp ()
@property(nonatomic,retain)UIImage *selectImage;
@property(nonatomic,retain)NSString *imageName;
@property(nonatomic,retain)NSString *filePath;

@end

@implementation UploadImageHelp
+(UploadImageHelp *)shareUploadHelp{
    static  UploadImageHelp *share ;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        share = [[UploadImageHelp alloc]init];
        share.upload = NO;
    });
    return share;
}
-(void)uploadImageWithImageName:(NSString *)name andPath:(NSString *)pathName{
    self.imageName = name;
    self.filePath = pathName;
    if (self.UploadDelegate == nil) {
        KMyLog(@"请设置代理");
        return;
    }
    [self handleClickCamera];
}
-(void)handleClickCamera{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"友情提示" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"拍照" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"打开系统照相机");
        //判断是否有摄像头
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            UIImagePickerController *picker = [[UIImagePickerController alloc] init];
            picker.delegate = self;//设置UIImagePickerController的代理，同时要遵循UIImagePickerControllerDelegate，UINavigationControllerDelegate协议
            picker.allowsEditing = NO;//设置拍照之后图片是否可编辑，如果设置成可编辑的话会在代理方法返回的字典里面多一些键值。PS：如果在调用相机的时候允许照片可编辑，那么用户能编辑的照片的位置并不包括边角。
            picker.sourceType = UIImagePickerControllerSourceTypeCamera;//UIImagePicker选择器的类型，UIImagePickerControllerSourceTypeCamera调用系统相机
            [self.UploadDelegate presentViewController:picker animated:YES completion:nil];
        }
        else{
            //如果当前设备没有摄像头
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"友情提示" message:@"摄像头或以损坏" preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"返回" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {}]];
            [self.UploadDelegate presentViewController:alert animated:YES completion:nil];
            
        }
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"图库" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"打开系统图片库");
        //判断相册是否可用
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
            UIImagePickerController * picker = [[UIImagePickerController alloc]init];
            picker.delegate = self;
            //是否可以对原图进行编辑
            picker.allowsEditing = NO;
            
            //打开相册选择照片
            picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            [self.UploadDelegate presentViewController:picker animated:YES completion:nil];
        }
        else{
            //相册不可用
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"友情提示" message:@"相册不存在" preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"返回" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                
            }]];
            [self.UploadDelegate presentViewController:alert animated:YES completion:nil];
        }
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"取消");
    }]];
    [self.UploadDelegate presentViewController:alert animated:YES completion:nil];
}
#pragma mark 照片的代理
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    [self.UploadDelegate dismissViewControllerAnimated:YES completion:nil];
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];//原始图片
    
    //     UIImage *editImage = [info objectForKey:UIImagePickerControllerEditedImage];//编辑后的图片
    UIImage *scaleImage = [self scaleImage:image toScale:0.3];
    self.selectImage = scaleImage;
    [self.UploadDelegate selectImage:scaleImage];
    if (self.upload) {
    [self uploadImage];
    }
}
-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [self.UploadDelegate dismissViewControllerAnimated:YES completion:nil];
}

-(void)uploadImage{
    [self uploadImageWithImage:self.selectImage title:self.imageName progress:^(CGFloat progress) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.UploadDelegate uploading:progress];
        });
    } scuss:^(id (respondObject)){
        [self.UploadDelegate uploadSuccess:respondObject];
    } failt:^{
        [self.UploadDelegate uploadFail];
    }];
}
-(void)uploadImageWithImage:(UIImage *)image title:(NSString *)title progress:(void (^)(CGFloat))progrsee scuss:(void (^)(id))scuss failt:(void (^)())failt{
    /*方式一：使用NSData数据流传图片*/
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc]init];
    //    NSString *imageURl = @"";
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    //    manager.responseSerializer.acceptableContentTypes =[NSSet setWithObject:@"text/html"];
    [NSSet setWithObjects:@"application/json",@"text/html",@"image/jpeg",@"image/png",@"application/octet-stream",@"text/json",nil];
    NSString *sid = [[UserInfoManager shareUserInfoManager] getValueWithKey:@"sid"];
    [manager POST:uploadImageUrl parameters:@{@"sid":sid,@"folder":@"xingShiZheng"} constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        //        [formData appendPartWithFileURL:filePath name:@"xingShiZheng" fileName:@"text.jpeg" mimeType:@"image/jpg" error:nil];
        [formData appendPartWithFileData:UIImageJPEGRepresentation(image, 1.0) name:@"xingShiZheng" fileName:title mimeType:@"image/jpg"];
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        CGFloat prog = 1.0 * uploadProgress.completedUnitCount/uploadProgress.totalUnitCount;
        progrsee(prog);
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil];
        scuss(dic);
        //        KMyLog(@"上传成功");
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failt();
    }];
    //
}

//缩放照片
-(UIImage *)scaleImage:(UIImage *)image toScale:(float)scaleSize{
    UIGraphicsBeginImageContext(CGSizeMake(image.size.width*scaleSize,image.size.height*scaleSize));
    [image drawInRect:CGRectMake(0, 0, image.size.width * scaleSize, image.size.height *scaleSize)];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    NSLog(@"%@",NSStringFromCGSize(scaledImage.size));
    return scaledImage;
}
@end
