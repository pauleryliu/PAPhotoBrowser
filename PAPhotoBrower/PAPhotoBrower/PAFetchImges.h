//
//  PAFetchImges.h
//  PAPhotoBrower
//
//  Created by 王俊 on 15/12/1.
//  Copyright © 2015年 feiwa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>

#define ASSETDATE @"assetDate"
#define ASSETTYPE @"assetType"
#define ASSETGROUPURL @"groupUrl"
#define ASSETGROUPID @"groupId"

//设置获取到的类型 分别为获取到视频和图片 图片 照片
typedef enum : NSInteger {
    PASelectPhotoAndViedo = 0,
    PASelectPhoto,
    PASelectViedo
    
} PASelectedStyle;

@interface PAFetchImges : NSObject

@property(nonatomic,strong)NSArray *selectedAssetArray;

@property(nonatomic,assign)NSInteger selectedMaxImagesCount;

@property(nonatomic,assign)PASelectedStyle showStyle;

@end
