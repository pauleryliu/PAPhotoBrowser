//
//  PAVideoPickerPreviewCell.h
//  PAPhotoBrower
//
//  Created by 郭锐 on 16/1/4.
//  Copyright © 2016年 feiwa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface PAVideoPickerPreviewCell : UICollectionViewCell
- (void)bindData:(ALAsset*)asset;
@end
