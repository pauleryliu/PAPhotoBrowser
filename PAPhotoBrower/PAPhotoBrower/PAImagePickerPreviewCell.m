//
//  PAImagePickerPreviewCell.m
//  PAPhotoBrower
//
//  Created by paulery on 11/26/15.
//  Copyright © 2015 paulery. All rights reserved.
//

#import "PAImagePickerPreviewCell.h"
#import "PAZoomingScrollView.h"

#define UISCREEN_WIDTH      [UIScreen mainScreen].bounds.size.width
#define UISCREEN_HEIGHT     [UIScreen mainScreen].bounds.size.height

@interface PAImagePickerPreviewCell ()

@property (nonatomic, strong) PAZoomingScrollView * scrollView;

@end

@implementation PAImagePickerPreviewCell

- (PAZoomingScrollView *)scrollView {
    
    if (!_scrollView) {
        
        _scrollView = [[PAZoomingScrollView alloc] initWithFrame:self.bounds];
    }
    
    return _scrollView;
}

- (void)bindData:(ALAsset*)asset
{
    [self addSubview:self.scrollView];
    
    CGImageRef ref = [[asset defaultRepresentation] fullScreenImage];
    UIImage *img = [[UIImage alloc]initWithCGImage:ref];
    
    [self.scrollView setImage:img];
}

@end
