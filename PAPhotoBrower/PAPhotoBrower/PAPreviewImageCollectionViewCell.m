//
//  PAPreviewImageCollectionViewCell.m
//  PAPhotoBrower
//
//  Created by 王俊 on 15/12/1.
//  Copyright © 2015年 feiwa. All rights reserved.
//

#import "PAPreviewImageCollectionViewCell.h"
#import <AssetsLibrary/AssetsLibrary.h>

@interface PAPreviewImageCollectionViewCell ()
@property (nonatomic, strong) UIButton    *photoButton;
@property (nonatomic, strong) UIButton    *checkButton;
@end


@implementation PAPreviewImageCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame andAsset:(ALAsset *)asset
{
    self = [super initWithFrame:frame];
    
    if (self) {
        // Create a image view
        self.backgroundColor = [UIColor clearColor];
        self.autoresizesSubviews = YES;
        
    }
    
    return self;
}




@end
