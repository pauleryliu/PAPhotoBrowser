//
//  PAZoomingScrollView.h
//  PAPhotoBrower
//
//  Created by Dylan on 15/12/9.
//  Copyright © 2015年 feiwa. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "PATapView.h"
#import "PATapImageView.h"

@interface PAZoomingScrollView : UIScrollView <UIScrollViewDelegate, PATapImageViewDelegate, PATapViewDelegate>

- (void)displayImage;
- (void)setMaxMinZoomScalesForCurrentBounds;
- (void)prepareForReuse;

@property (nonatomic, strong) UIImage * photo;

// Set photo
- (void)setImage:(UIImage *)photo;

@end
