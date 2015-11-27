//
//  PAImagePickerCell.m
//  PAPhotoBrower
//
//  Created by paulery on 11/26/15.
//  Copyright © 2015 paulery. All rights reserved.
//

#import "PAImagePickerCell.h"

@interface PAImagePickerCell ()

@property (nonatomic,strong) UIImageView *thumbNailImageView;
@property (nonatomic,strong) ALAsset  *asset;

@end

@implementation PAImagePickerCell

- (void)bindData:(ALAsset*)asset
{
    self.asset = asset;
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

- (void)selectedTagBtnPressed
{
    if ([_delegate respondsToSelector:@selector(selectedAsset:cell:)]) {
        [_delegate selectedAsset:self.asset cell:self];
    }
}

@end
