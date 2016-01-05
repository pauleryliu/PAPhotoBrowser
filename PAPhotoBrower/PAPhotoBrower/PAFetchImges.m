//
//  PAFetchImges.m
//  PAPhotoBrower
//
//  Created by 王俊 on 15/12/1.
//  Copyright © 2015年 feiwa. All rights reserved.
//

#import "PAFetchImges.h"



@interface PAFetchImges ()

@property(nonatomic,strong)NSArray *groupTypes;
@property(nonatomic,strong)NSArray *selectAssetsGroup;

@property(nonatomic,strong)ALAssetsLibrary *assetsLibrary;

@end


@implementation PAFetchImges

-(ALAssetsLibrary *)assetsLibrary{

    if (!_assetsLibrary) {
        _assetsLibrary = [[ALAssetsLibrary alloc]init];
    }
    return _assetsLibrary;
}

//这个是自己写的读取照片的方法
-(void)loadAssetsElementsWithAssetsBlock:(void(^)(NSArray *assets))assetsBlock{
    
//
    __block NSMutableArray *assetsArray = [NSMutableArray array];
    //设置全选模式
    NSNumber *type = @(ALAssetsGroupLibrary);
    [self.assetsLibrary enumerateGroupsWithTypes:[type unsignedIntegerValue]
                                      usingBlock:^(ALAssetsGroup *assetsGroup, BOOL *stop) {
                                          
        NSLog(@"assetsGroup === %@",assetsGroup);
        if (assetsGroup) {
            // Filter the assets group
            ALAssetsFilter *filter = nil;
            if (self.showStyle == PASelectPhoto) {
                filter = [ALAssetsFilter allPhotos];
            }else if (self.showStyle == PASelectViedo){
                filter = [ALAssetsFilter allVideos];
            }
        //设置全选模式和默认模式
            else{
            filter = [ALAssetsFilter allAssets];
            }
        [assetsGroup setAssetsFilter:filter];
        // Add assets group
        if (assetsGroup.numberOfAssets > 0) {
            // Add assets group
//            [assetsGroups addObject:assetsGroup];
            [assetsGroup enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                if (result) {
                    
                    NSString *groupUrl = [assetsGroup valueForProperty:ALAssetsGroupPropertyURL];
                    NSString *groupId = [assetsGroup valueForProperty:ALAssetsGroupPropertyPersistentID];
                    NSString *type = [result valueForProperty:ALAssetPropertyType];
                    //获取元素生成的时间
                    NSString *dateStr = [result valueForKey:ALAssetPropertyDate];
                    //按照时间对时间和视频文件进行排序
                    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
                    [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                    NSDate *assetDate = [dateFormat dateFromString:dateStr];
//                    NSDate *nowDate = [NSDate date];
                    NSTimeInterval timeInterval = [assetDate timeIntervalSince1970];//[assetDate timeIntervalSinceDate:nowDate];
                    NSDictionary *dic = @{ASSETDATE:@(timeInterval),ASSETTYPE:type,ASSETGROUPURL:groupUrl,ASSETGROUPID:groupId};
                    [assetsArray addObject:dic];
                }
            }];
            assetsBlock(assetsArray);
        }else{
            assetsBlock(nil);
        }
        
        }else{
            assetsBlock(nil);
        }

    } failureBlock:^(NSError *error) {
                                          
    }];

}

//这个方法对获取到的图片数组进行排序 取出业务逻辑需要的照片和视频的数量
//此外需要注意的是当block'回调为空的时候 说明没有获取到图片 此时只能将显示预览的collection再重新隐藏起来
-(void)fectchAssetsCallBack:(void(^)(NSArray *assets))callBack{
    __block NSMutableArray *goldAssetsArray = [NSMutableArray array];
    [self loadAssetsElementsWithAssetsBlock:^(NSArray *assets) {
        if (assets) {
            
            NSArray *receiveArray = [assets sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
                NSInteger timeInterval1 = [obj1[ASSETDATE] integerValue];
                NSInteger timeInterval2 = [obj1[ASSETDATE] integerValue];
                //进行降序排列
                if (timeInterval1 >timeInterval2) {
                    return NSOrderedDescending;
                }else{
                
                    return NSOrderedAscending;
                }
            }];
            for (int i = 0; i < receiveArray.count; i ++) {
                if (self.selectedMaxImagesCount) {
                    if (i < self.selectedMaxImagesCount) {
                        [goldAssetsArray addObject:receiveArray[i]];
                    }
                }
                //当不限制最多取照片的数量时默认获取20张图片
                else{
                    if (i <20) {
                        [goldAssetsArray addObject:receiveArray[i]];
                    }
                }
            }
            callBack(goldAssetsArray);
            
        }else{
            callBack(nil);
        }
    }];

}

@end
