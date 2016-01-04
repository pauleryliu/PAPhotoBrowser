//
//  PAPhotoBrowserHelper.m
//  PAPhotoBrower
//
//  Created by 小飞 刘 on 11/27/15.
//  Copyright © 2015 feiwa. All rights reserved.
//

#import "PAPhotoBrowserHelper.h"

#define UIColorFromRGB(rgbValue) \
[UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0x00FF00) >>  8))/255.0 \
blue:((float)((rgbValue & 0x0000FF) >>  0))/255.0 \
alpha:1.0]

@implementation PAPhotoBrowserHelper

@end
