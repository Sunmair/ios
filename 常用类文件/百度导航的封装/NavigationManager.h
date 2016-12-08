//
//  NavigationManager.h
//  HFWParkingProject
//
//  Created by Eric on 2016/11/24.
//  Copyright © 2016年 Eric. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ParkingPreview.h"
#import "BNCoreServices.h"
#import "BNRoutePlanModel.h"
@interface NavigationManager : NSObject <BNNaviUIManagerDelegate,BNNaviRoutePlanDelegate>
+(NavigationManager *)shareNavigation;
-(void)startNaviWithStartPoint:(CLLocationCoordinate2D)start andEndPoint:(CLLocationCoordinate2D)end;
@end
