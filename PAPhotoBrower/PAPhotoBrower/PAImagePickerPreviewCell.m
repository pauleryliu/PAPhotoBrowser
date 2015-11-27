//
//  PAImagePickerPreviewCell.m
//  PAPhotoBrower
//
//  Created by paulery on 11/26/15.
//  Copyright © 2015 paulery. All rights reserved.
//

#import "PAImagePickerPreviewCell.h"

#define UISCREEN_WIDTH      [UIScreen mainScreen].bounds.size.width
#define UISCREEN_HEIGHT     [UIScreen mainScreen].bounds.size.height

@interface PAImagePickerPreviewCell ()

@property (nonatomic,strong) UIImageView *thumbNailImageView;

@end

@implementation PAImagePickerPreviewCell

- (void)bindData:(ALAsset*)asset
{
    // thumNail
    if (!self.thumbNailImageView) {
        self.thumbNailImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        [self.contentView addSubview:self.thumbNailImageView];
    }
    CGImageRef ref = [[asset defaultRepresentation] fullScreenImage];
    UIImage *img = [[UIImage alloc]initWithCGImage:ref];
    self.thumbNailImageView.image = img;
    self.thumbNailImageView.contentMode = UIViewContentModeScaleAspectFit;
}


@end
