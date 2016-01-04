//
//  PAVideoCropView.h
//  PAPhotoBrower
//
//  Created by paulery on 11/26/15.
//  Copyright © 2015 paulery. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <AVFoundation/AVFoundation.h>

@protocol PAVideoCropViewDelegate <NSObject>
@optional
- (void)updateVideoPreImage;

@end


@interface VideoCropView : UIView <UIScrollViewDelegate>

@property (strong, nonatomic) NSURL *videoInputURL;
@property (nonatomic) CGFloat videoDuration;

@property (nonatomic, weak) id<PAVideoCropViewDelegate> delegate;
@property (strong,nonatomic) UIImage *videoPreImage;
@property (strong,nonatomic) UIView *videoPlayProgressBar;

@property (nonatomic) CGFloat videoCropCurrentTime;// 当前播放的时间
@property (nonatomic) CGFloat videoCropPreCurTime;  // 左右拖动，预览界面的时候的time
@property (nonatomic) CGFloat videoCropBeginTime;// 当前截取视频开始的时间
@property (nonatomic) CGFloat videoCropEndTime;
@property (nonatomic) CGFloat videoCropDurationTime;

- (id)initWithFrame:(CGRect)frame withVideoURL:(NSURL*)videoURL andVideoDuration:(CGFloat)videoDuration;
- (void)setProgressBar:(CGFloat)progress;

@end



