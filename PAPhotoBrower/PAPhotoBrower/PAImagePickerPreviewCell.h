//
//  PAImagePickerPreviewCell.h
//  PAPhotoBrower
//
//  Created by paulery on 11/26/15.
//  Copyright © 2015 paulery. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface PAImagePickerPreviewCell : UICollectionViewCell

@property (nonatomic) BOOL isSelected;
- (void)bindData:(ALAsset*)asset;

@end
