//
//  QBImageLoadingProgressBar.m
//  QiuBai
//
//  Created by noark on 14-4-16.
//  Copyright (c) 2014年 Less Everything. All rights reserved.
//

#import "QBImageLoadingProgressBar.h"

#define UIColorFromRGB(rgbValue) \
[UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0x00FF00) >>  8))/255.0 \
blue:((float)((rgbValue & 0x0000FF) >>  0))/255.0 \
alpha:1.0]

@interface QBImageLoadingProgressBar()
{
    CALayer *_moveLayer;
}

@end

@implementation QBImageLoadingProgressBar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _displayProgress = 0;
        _progress = 0;
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame andBackgroundColor:(UIColor*)backgroundColor
{
    self = [super initWithFrame:frame];
    if (self) {
        _displayProgress = 0;
        _progress = 0;
        self.backgroundColor = backgroundColor;
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    CGFloat p = _displayProgress;
    p = MIN(p, 1.0);
    CGRect progressRect = rect;
    progressRect.size.width = ceil(progressRect.size.width * p);
    UIBezierPath* bezierPath = [UIBezierPath bezierPathWithRect:progressRect];
    [UIColorFromRGB(0xffa015) setFill];
    [bezierPath fill];
}

- (void)starPrepareAnimation
{
    self.progress = 0;
    if (!_moveLayer)
    {
        _moveLayer = [CALayer layer];
        _moveLayer.backgroundColor = UIColorFromRGB(0xffa015).CGColor;
        _moveLayer.frame = CGRectMake(0, 0, 100, self.frame.size.height);
    }
    [self.layer addSublayer:_moveLayer];
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, -100, self.frame.size.height / 2);
    CGPathAddLineToPoint(path, NULL, 100 + self.frame.size.width, self.frame.size.height / 2);
    
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    animation.path = path;
    animation.rotationMode = kCAAnimationRotateAuto;
    animation.removedOnCompletion = NO;
    
    animation.repeatCount = HUGE_VALF;
    animation.duration = 2.50;
    [_moveLayer removeAllAnimations];
    [_moveLayer addAnimation:animation forKey:@"panguo"];
}

- (void)stopPrepareAnimation
{
    if (_moveLayer)
    {
        [_moveLayer removeAllAnimations];
        [_moveLayer removeFromSuperlayer];
    }
}

@end
