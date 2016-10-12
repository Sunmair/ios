//
//  UserInfoManager.m
//  VKu
//
//  Created by Eric on 16/5/25.
//  Copyright © 2016年 Eric. All rights reserved.
//

#import "UserInfoManager.h"

@implementation UserInfoManager
+(UserInfoManager *)shareUserInfoManager{
    static  UserInfoManager *share ;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        share = [[UserInfoManager alloc]init];
    });
    return share;
}
//是否第一次登陆
-(BOOL)getFirstRun{
    //从本地提取
    BOOL isFirstRun = [[NSUserDefaults standardUserDefaults]objectForKey:@"isFirstRun"];
    if (!isFirstRun) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isFirstRun"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        return YES;
    }else{
        return NO;
    }
}
//存账号存密码
-(void)saveUserName:(NSString *)userName passWord:(NSString *)password{
    [[NSUserDefaults standardUserDefaults] setValue:userName forKey:@"userName"];
     [[NSUserDefaults standardUserDefaults] setValue:password forKey:@"passWord"];
    //及时保存
    [[NSUserDefaults standardUserDefaults]synchronize];
}
//取账号
-(NSString *)getUserName{
    NSString *user = [[NSUserDefaults standardUserDefaults]valueForKey:@"userName"];
    return user;
}
//取密码
-(NSString *)getPassword{
    NSString *pass=[[NSUserDefaults standardUserDefaults]valueForKey:@"passWord"];
    return pass;
}
//存用户信息
-(void)saveUidWith:(NSString *)Uid{
    [[NSUserDefaults standardUserDefaults] setValue:Uid forKey:@"uid"];
    [[NSUserDefaults standardUserDefaults]synchronize];
}
//获取用户信息
-(NSString *)getuserUid{
    return [[NSUserDefaults standardUserDefaults]valueForKey:@"uid"];
}
@end
