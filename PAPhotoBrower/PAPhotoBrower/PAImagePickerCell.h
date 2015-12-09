//
//  PAImagePickerCell.h
//  PAPhotoBrower
//
//  Created by paulery on 11/26/15.
//  Copyright © 2015 paulery. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
@class PAImagePickerCell;

@protocol PAImagePickerCellDelegate <NSObject>

- (void)selectedAsset:(ALAsset*)asset cell:(PAImagePickerCell*)cell;

@end

@interface PAImagePickerCell : UICollectionViewCell

@property (nonatomic,strong) UIButton *selectedTagBtn;
@property (nonatomic,weak) id<PAImagePickerCellDelegate> delegate;

- (void)bindData:(ALAsset*)asset;

@end
