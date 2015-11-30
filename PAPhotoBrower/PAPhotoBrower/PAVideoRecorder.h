//
//  PAVideoRecorder.h
//  PAPhotoBrower
//
//  Created by paulery on 11/26/15.
//  Copyright © 2015 paulery. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <MediaPlayer/MediaPlayer.h>
#import "SDAVAssetExportSession.h"

#define COUNT_DUR_TIMER_INTERVAL 0.1

/**
 *  用途：视频拍摄功能封装
 */

typedef enum {
    VideoRecoderStateInit = 1,              // 初始化
    VideoRecoderStateReadyToRecord = 2,     // 随时准备拍摄，。。。写文件
    VideoRecoderStateRecording = 3,         // 拍摄中，。。。写文件
}VideoRecoderState;

typedef enum
{
    PACurrentPhotoModel = 0,    // Default
    PACurrentVideoModel = 1,
}PACurrentModel;

@class PAVideoRecorder;

@protocol PAVideoRecorderDelegate <NSObject>
@optional
- (void)videoRecorder:(PAVideoRecorder*)videoRecorder didStartRecordingToOutPutFileAtURL:(NSURL*)fileURL;
- (void)videoRecorder:(PAVideoRecorder*)videoRecorder didRecordingToOutPutFileAtURL:(NSURL*)outputFileURL duration:(CGFloat)videoDuration;
- (void)videoRecorder:(PAVideoRecorder *)videoRecorder didFinishRecordingToOutPutFileAtURL:(NSURL *)outputFileURL duration:(CGFloat)videoDuration error:(NSError*)error;
@end


@interface PAVideoRecorder : NSObject<AVCaptureFileOutputRecordingDelegate>

@property (nonatomic,assign) PACurrentModel paCurrentModel;
@property (nonatomic,weak) id <PAVideoRecorderDelegate>delegate;
@property (nonatomic,strong) AVCaptureSession *captureSession;
@property (nonatomic,strong) AVCaptureMovieFileOutput *movieFileOutput;
@property (nonatomic,strong) AVCaptureVideoPreviewLayer *videoPreview;
@property (nonatomic, readonly) VideoRecoderState state;

// Device
- (void)initCaptureDevice;
- (BOOL)isCameraSupported;
- (BOOL)isFrontCameraSupported;
- (BOOL)isUsingFrontCamera;
- (BOOL)isTorchOn;
- (BOOL)isTorchSupported;

// Actions
- (void)openTorch:(BOOL)open;
- (void)switchCamera;
- (void)takePhoto;
- (CGFloat)getVideoDuration; // recorded time
- (void)startRecordingOutputFile;
- (void)stopCurrentVideoRecording;
- (void)subjectAreaDidChange;
- (void)focusAndExposeTap:(CGPoint)tapPoint;

@end

