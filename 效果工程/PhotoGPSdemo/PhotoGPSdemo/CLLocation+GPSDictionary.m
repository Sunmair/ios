//
//  CLLocation+GPSDictionary.m
//  TravelNote
//
//  Created by liu  on 12-5-24.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "CLLocation+GPSDictionary.h"

@implementation CLLocation (GPSDictionary)

-(NSDictionary*)GPSDictionary{
    NSTimeZone    *timeZone   = [NSTimeZone timeZoneWithName:@"UTC"];
    NSDateFormatter *formatter  = [[NSDateFormatter alloc] init]; 
    [formatter setTimeZone:timeZone];
    [formatter setDateFormat:@"HH:mm:ss.SS"];
    CLLocation *location=self;
    NSDictionary *gpsDict   = [NSDictionary dictionaryWithObjectsAndKeys:
                               [NSNumber numberWithFloat:fabs(location.coordinate.latitude)], kCGImagePropertyGPSLatitude,
                               ((location.coordinate.latitude >= 0) ? @"N" : @"S"), kCGImagePropertyGPSLatitudeRef,
                               [NSNumber numberWithFloat:fabs(location.coordinate.longitude)], kCGImagePropertyGPSLongitude,
                               ((location.coordinate.longitude >= 0) ? @"E" : @"W"), kCGImagePropertyGPSLongitudeRef,
                               [formatter stringFromDate:[location timestamp]], kCGImagePropertyGPSTimeStamp,
                               nil];
    return gpsDict;
}




@end
