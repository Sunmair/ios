//
//  UserInfoManager.h
//  VKu
//
//  Created by Eric on 16/5/25.
//  Copyright © 2016年 Eric. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserInfoManager : NSObject
+(UserInfoManager *)shareUserInfoManager;
//是否第一次登陆
-(BOOL)getFirstRun;
//存账号存密码
-(void)saveUserName:(NSString *)userName passWord:(NSString *)password;
//取账号
-(NSString *)getUserName;
//取密码
-(NSString *)getPassword;
//存用户信息
-(void)saveUidWith:(NSString *)Uid;
//获取用户信息
-(NSString *)getuserUid;
@end
