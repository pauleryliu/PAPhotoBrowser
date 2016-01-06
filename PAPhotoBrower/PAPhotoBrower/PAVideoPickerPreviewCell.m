//
//  PAVideoPickerPreviewCell.m
//  PAPhotoBrower
//
//  Created by Garry on 16/1/4.
//  Copyright © 2016年 feiwa. All rights reserved.
//

#import "PAVideoPickerPreviewCell.h"
#import <AVFoundation/AVFoundation.h>

#define UISCREEN_WIDTH      [UIScreen mainScreen].bounds.size.width

@interface PAVideoPickerPreviewCell ()
@property(nonatomic,strong)AVPlayerLayer *playerLayer;
@property(nonatomic,strong)AVPlayer *player;
@property(nonatomic,strong)UIButton *playBtn;
@end

@implementation PAVideoPickerPreviewCell
{
    AVPlayerItem *playItem;
    CGSize videoSize;
}
-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.playerLayer.player = self.player;
        [self.layer insertSublayer:self.playerLayer atIndex:0];
        [self addSubview:self.playBtn];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(videoPlayDidEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(playVideo)];
        [self addGestureRecognizer:tap];
    }
    return self;
}
-(void)videoPlayDidEnd:(NSNotification *)nofification{
    [self.player pause];
    self.playBtn.hidden = NO;
    self.playBtn.selected = NO;
    [playItem seekToTime:kCMTimeZero];
}
-(void)bindData:(ALAsset *)asset{
    [self.player pause];
    self.playBtn.selected = NO;
    self.playBtn.hidden = NO;
    ALAssetRepresentation *representation = [asset defaultRepresentation];
    videoSize = [representation dimensions];
    
    playItem = [AVPlayerItem playerItemWithURL:[representation url]];
    [self.player replaceCurrentItemWithPlayerItem:playItem];
}
-(void)layoutSubviews{
    CGRect frame = self.bounds;
    CGFloat newWidth = frame.size.width * 0.9;
    
    CGFloat zoomScale = newWidth / videoSize.width;
    
    CGFloat newHeight = zoomScale * videoSize.height;
    
    CGSize newSize = CGSizeMake(newWidth, newHeight);
    
    frame.origin.x = frame.size.width * 0.05;
    frame.origin.y = (self.bounds.size.height - newHeight) / 2;
    frame.size = newSize;
    _playerLayer.frame = frame;
    
    [_playBtn sizeToFit];
    _playBtn.center = CGPointMake(self.bounds.size.width / 2 , self.bounds.size.height / 2);
}
-(void)playVideo{
    if (self.playBtn.selected) {
        [self.player pause];
        self.playBtn.hidden = NO;
    }else{
        [self.player play];
        self.playBtn.hidden = YES;
    }
    self.playBtn.selected = !self.playBtn.selected;
}
-(AVPlayer *)player{
    if (!_player) {
        _player = [[AVPlayer alloc] init];
        _player.rate = 1.0f;
    }
    return _player;
}
-(AVPlayerLayer *)playerLayer{
    if (!_playerLayer) {
        _playerLayer = [[AVPlayerLayer alloc] init];
        _playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
        _playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    }
    return _playerLayer;
}
-(UIButton *)playBtn{
    if (!_playBtn) {
        _playBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _playBtn.frame = CGRectMake(0, 0, 30, 30);
        [_playBtn setImage:[UIImage imageNamed:@"video-player-play"] forState:UIControlStateNormal];
        [_playBtn setImage:[UIImage imageNamed:@"video-player-pause"] forState:UIControlStateSelected];
        [_playBtn addTarget:self action:@selector(playVideo) forControlEvents:UIControlEventTouchUpInside];
    }
    return _playBtn;
}

@end
