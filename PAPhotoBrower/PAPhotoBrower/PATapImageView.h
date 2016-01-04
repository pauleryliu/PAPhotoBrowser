//
//  PATapImageView.h
//  PAPhotoBrower
//
//  Created by Dylan on 15/12/9.
//  Copyright © 2015年 feiwa. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PATapImageViewDelegate;

@interface PATapImageView : UIImageView

@property (nonatomic, weak) id <PATapImageViewDelegate> tapDelegate;

@end

@protocol PATapImageViewDelegate <NSObject>

@optional

- (void)imageView:(UIImageView *)imageView singleTapDetected:(UITouch *)touch;
- (void)imageView:(UIImageView *)imageView doubleTapDetected:(UITouch *)touch;
- (void)imageView:(UIImageView *)imageView tripleTapDetected:(UITouch *)touch;


//! @name Gesture For imageView
- (void)imageView:(UIImageView *)imageView doubleTap:(CGPoint)gestureLocation;
- (void)imageView:(UIImageView *)imageView singleTap:(CGPoint)gestureLocation;
@end