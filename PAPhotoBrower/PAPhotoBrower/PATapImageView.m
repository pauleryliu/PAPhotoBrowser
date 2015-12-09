//
//  PATapImageView.m
//  PAPhotoBrower
//
//  Created by Dylan on 15/12/9.
//  Copyright © 2015年 feiwa. All rights reserved.
//

#import "PATapImageView.h"

@implementation PATapImageView

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        self.userInteractionEnabled = YES;
        
        UITapGestureRecognizer *tapImgView = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapImgViewHandle:)];
        tapImgView.numberOfTapsRequired = 1;
        tapImgView.numberOfTouchesRequired = 1;
        [self addGestureRecognizer:tapImgView];
        
        UITapGestureRecognizer *tapImgViewTwice = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapImgViewHandleTwice:)];
        tapImgViewTwice.numberOfTapsRequired = 2;
        tapImgViewTwice.numberOfTouchesRequired = 1;
        [self addGestureRecognizer:tapImgViewTwice];
        [tapImgView requireGestureRecognizerToFail:tapImgViewTwice];
    }
    return self;
}

- (void)tapImgViewHandle: (UIGestureRecognizer *)gesture {
    
    if ([_tapDelegate respondsToSelector:@selector(imageView:singleTap:)]) {
        [_tapDelegate imageView:self singleTap:[gesture locationInView:self]];
    }
}

- (void)tapImgViewHandleTwice: (UIGestureRecognizer *)gesture {
    
    if ([_tapDelegate respondsToSelector:@selector(imageView:doubleTap:)]) {
        [_tapDelegate imageView:self doubleTap:[gesture locationInView:self]];
    }
}

- (id)initWithImage:(UIImage *)image {
    if ((self = [super initWithImage:image])) {
        self.userInteractionEnabled = YES;
    }
    return self;
}

- (id)initWithImage:(UIImage *)image highlightedImage:(UIImage *)highlightedImage {
    if ((self = [super initWithImage:image highlightedImage:highlightedImage])) {
        self.userInteractionEnabled = YES;
    }
    return self;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    NSUInteger tapCount = touch.tapCount;
    switch (tapCount) {
        case 1:
            //			[self handleSingleTap:touch];
            break;
        case 2:
            //			[self handleDoubleTap:touch];
            break;
        case 3:
            [self handleTripleTap:touch];
            break;
        default:
            break;
    }
    [[self nextResponder] touchesEnded:touches withEvent:event];
}

- (void)handleSingleTap:(UITouch *)touch {
    //	if ([_tapDelegate respondsToSelector:@selector(imageView:singleTapDetected:)])
    //		[_tapDelegate imageView:self singleTapDetected:touch];
}

- (void)handleDoubleTap:(UITouch *)touch {
    //	if ([_tapDelegate respondsToSelector:@selector(imageView:doubleTapDetected:)])
    //		[_tapDelegate imageView:self doubleTapDetected:touch];
}

- (void)handleTripleTap:(UITouch *)touch {
    if ([_tapDelegate respondsToSelector:@selector(imageView:tripleTapDetected:)])
        [_tapDelegate imageView:self tripleTapDetected:touch];
}


@end
