//
//  PAImagePickerCell.m
//  PAPhotoBrower
//
//  Created by paulery on 11/26/15.
//  Copyright © 2015 paulery. All rights reserved.
//

#import "PAImagePickerCell.h"
#import "PAVideoRecorderHelper.h"

@interface PAImagePickerCell ()

@property (nonatomic,strong) UIImageView *thumbNailImageView;
@property (nonatomic,strong) ALAsset  *asset;

@end

@implementation PAImagePickerCell

- (void)bindData:(ALAsset*)asset
{
    self.asset = asset;
    NSString *assetType = [asset valueForProperty:ALAssetPropertyType];
    
    if ([assetType isEqual:ALAssetTypePhoto]) {
        // thumNail
        if (!self.thumbNailImageView) {
            self.thumbNailImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
            [self.contentView addSubview:self.thumbNailImageView];
        }
        
        if (!self.selectedTagBtn) {
            self.selectedTagBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            self.selectedTagBtn.frame = CGRectMake(self.frame.size.width - 15 - 5, 5, 18, 18);
            [self.selectedTagBtn setImage:[UIImage imageNamed:@"photo_localUnselected_tag"] forState:UIControlStateNormal];
            [self.selectedTagBtn setImage:[UIImage imageNamed:@"photo_localSelected_tag"] forState:UIControlStateSelected];
            [self.selectedTagBtn setSelected:NO];
            [self.selectedTagBtn addTarget:self action:@selector(selectedTagBtnPressed) forControlEvents:UIControlEventTouchUpInside];
            [self.contentView addSubview:self.selectedTagBtn];
        }
        [self.selectedTagBtn setSelected:NO];
        self.thumbNailImageView.image = [UIImage imageWithCGImage:[asset thumbnail]];
    }
    
    if ([assetType isEqual:ALAssetTypeVideo]) {
        // thumNail
        UIImage *thumbNail = [UIImage imageWithCGImage:[asset thumbnail]];
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        imageView.image = thumbNail;
    
        // maskView
        UIImageView *maskView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        maskView.image = [UIImage imageNamed:@"video_localSelected_mask"];
        [imageView addSubview:maskView];
    
        // time label
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, self.frame.size.height - 15, self.frame.size.width, 15)];
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor whiteColor];
        label.font = [UIFont systemFontOfSize:10.0f];
        label.text = [PAVideoRecorderHelper convertTime:[[asset valueForProperty:ALAssetPropertyDuration] floatValue]];
        [maskView addSubview:label];
        
        [self.contentView addSubview:imageView];
    }
}

- (void)selectedTagBtnPressed
{
    if ([_delegate respondsToSelector:@selector(selectedAsset:cell:)]) {
        [_delegate selectedAsset:self.asset cell:self];
    }
}

@end
