//
//  PATapView.h
//  PAPhotoBrower
//
//  Created by Dylan on 15/12/9.
//  Copyright © 2015年 feiwa. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PATapViewDelegate;

@interface PATapView : UIView

@property (nonatomic, weak) id <PATapViewDelegate> tapDelegate;

@end

@protocol PATapViewDelegate <NSObject>

@optional

- (void)view:(UIView *)view singleTapDetected:(UITouch *)touch;
- (void)view:(UIView *)view doubleTapDetected:(UITouch *)touch;
- (void)view:(UIView *)view tripleTapDetected:(UITouch *)touch;

@end