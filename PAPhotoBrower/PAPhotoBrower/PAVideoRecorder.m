//
//  PAVideoRecorder.m
//  PAPhotoBrower
//
//  Created by paulery on 11/26/15.
//  Copyright © 2015 paulery. All rights reserved.
//

#import "PAVideoRecorder.h"
#import "PAVideoRecorderHelper.h"
@interface PAVideoRecorder()

@property (nonatomic,strong) NSTimer *countDurationTimer;
@property (nonatomic) CGFloat currentVideoDuration;
@property (nonatomic,strong) NSURL *currentFileURL;

@property (nonatomic) BOOL isFrontCameraSupported;
@property (nonatomic) BOOL isCameraSupported;        // default is background Camera
@property (nonatomic) BOOL isTorchSupported;
@property (nonatomic) BOOL isTorchOn;
@property (nonatomic,assign) BOOL isUsingFrontCamera;

@property (nonatomic,strong) AVCaptureDeviceInput *videoDeviceInput;
@property (nonatomic,strong) AVCaptureDeviceInput *audioDeviceInput;
@property (nonatomic,strong) AVCaptureStillImageOutput *captureStillImageOutput;

@end

@implementation PAVideoRecorder

- (id)init{
    self = [super init];
    if (self) {
        // Capture Session
        _captureSession = [[AVCaptureSession alloc] init];
        
        // preview layer
        _videoPreview = [AVCaptureVideoPreviewLayer layerWithSession:_captureSession];
        _videoPreview.videoGravity = AVLayerVideoGravityResizeAspectFill;
        
        _state = VideoRecoderStateInit;
    }
    return self;
}

- (void)dealloc
{
    [_captureSession stopRunning];
    [_captureSession removeInput:_audioDeviceInput];
    [_captureSession removeInput:_videoDeviceInput];
    [_captureSession removeOutput:_movieFileOutput];
    _movieFileOutput = nil;
    _videoDeviceInput = nil;
    _audioDeviceInput = nil;
    _captureSession = nil;
}

- (void)initCaptureDevice{

    // position of Camera
    AVCaptureDevice *frontCamera = nil;
    AVCaptureDevice *backCamera = nil;
    for (AVCaptureDevice *camera in [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo]){
        camera.position == AVCaptureDevicePositionFront ? (frontCamera = camera) : (backCamera = camera);
    }
    
    // Camera && Torch Support
    if (!backCamera) {
        _isCameraSupported = NO;
        return;
    }else{
        _isCameraSupported = YES;
        
        if ([backCamera hasFlash]) {
            _isTorchSupported = YES;
        }else{
            _isTorchSupported = NO;
        }
    }
    
    if (!frontCamera) {
        _isFrontCameraSupported = NO;
    }else{
        _isFrontCameraSupported = YES;
    }
    [backCamera lockForConfiguration:nil];
    if ([backCamera isExposureModeSupported:AVCaptureExposureModeAutoExpose]) {
        [backCamera setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
    }
    if ([backCamera isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance]) {
        [backCamera setWhiteBalanceMode:AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance];
    }
    [backCamera unlockForConfiguration];
    
    // Add Input && Output To Session
    _videoDeviceInput  = [AVCaptureDeviceInput deviceInputWithDevice:backCamera error:nil];
    if ([_captureSession canAddInput:_videoDeviceInput]) {
        [_captureSession addInput:_videoDeviceInput];
    }
    
    if (self.paCurrentModel == PACurrentPhotoModel) {
        _captureStillImageOutput = [[AVCaptureStillImageOutput alloc] init];
        if ([_captureSession canAddOutput:_captureStillImageOutput]) {
            [_captureSession addOutput:_captureStillImageOutput];
        }
    }
    
    if (self.paCurrentModel == PACurrentVideoModel) {
        AVCaptureDevice *audioDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
        if (audioDevice) {
            NSError *error;
            _audioDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:audioDevice error:&error];
            if (!error) {
                if ([_captureSession canAddInput:_audioDeviceInput]) {
                    [_captureSession addInput:_audioDeviceInput];
                }
            }
        }
        
        _movieFileOutput = [[AVCaptureMovieFileOutput alloc] init];
        if ([_captureSession canAddOutput:_movieFileOutput]){
            [_captureSession addOutput:_movieFileOutput];
            if ([_captureSession respondsToSelector:@selector(setUsesApplicationAudioSession:)]) {
                [_captureSession setUsesApplicationAudioSession:NO];
            }
            [self setMovieFileOutput:_movieFileOutput];
        }
    }
    
    // present
    _captureSession.sessionPreset = AVCaptureSessionPreset640x480;
    [_captureSession startRunning];
    _state = VideoRecoderStateReadyToRecord;
}

- (void)switchToModel:(PACurrentModel)paCurrentModel
{
    self.paCurrentModel = paCurrentModel;
    
    if (self.paCurrentModel == PACurrentPhotoModel) {
        _captureStillImageOutput = [[AVCaptureStillImageOutput alloc] init];
        if ([_captureSession canAddOutput:_captureStillImageOutput]) {
            [_captureSession addOutput:_captureStillImageOutput];
        }
    }
    
    if (self.paCurrentModel == PACurrentVideoModel) {
        AVCaptureDevice *audioDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
        if (audioDevice) {
            NSError *error;
            _audioDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:audioDevice error:&error];
            if (!error) {
                if ([_captureSession canAddInput:_audioDeviceInput]) {
                    [_captureSession addInput:_audioDeviceInput];
                }
            }
        }
        
        _movieFileOutput = [[AVCaptureMovieFileOutput alloc] init];
        if ([_captureSession canAddOutput:_movieFileOutput]){
            [_captureSession addOutput:_movieFileOutput];
            if ([_captureSession respondsToSelector:@selector(setUsesApplicationAudioSession:)]) {
                [_captureSession setUsesApplicationAudioSession:NO];
            }
            [self setMovieFileOutput:_movieFileOutput];
        }
    }
}

#pragma mark -- Photo Method

- (void)takePhoto
{
    AVCaptureConnection *captureConnection = [self.captureStillImageOutput connectionWithMediaType:AVMediaTypeVideo];
    [self.captureStillImageOutput captureStillImageAsynchronouslyFromConnection:captureConnection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
        if (imageDataSampleBuffer) {
            NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
            UIImage *image = [UIImage imageWithData:imageData];
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
        }
    }];
}

#pragma mark -- Video Recorder Method

- (void)startCountDurTimer
{
    _countDurationTimer = [NSTimer scheduledTimerWithTimeInterval:COUNT_DUR_TIMER_INTERVAL target:self selector:@selector(onTimer:) userInfo:nil repeats:YES];
}

- (void)stopCountDurTimer
{
    [_countDurationTimer invalidate];
    _countDurationTimer = nil;
}

- (void)onTimer:(NSTimer *)timer
{
    _currentVideoDuration += COUNT_DUR_TIMER_INTERVAL;
    [self videoRecording];
}

- (CGFloat)getVideoDuration
{
    return _currentVideoDuration;
}

- (void)focusAndExposeTap:(CGPoint)tapPoint
{
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    double screenWidth = screenRect.size.width;
    double screenHeight = screenRect.size.height;
    double focus_x = tapPoint.x / screenWidth;
    double focus_y = tapPoint.y / screenHeight;
    CGPoint focusPoint = CGPointMake(focus_x, focus_y);
    
    [self focusWithMode:AVCaptureFocusModeAutoFocus exposeWithMode:AVCaptureExposureModeAutoExpose atDevicePoint:focusPoint monitorSubjectAreaChange:YES];
}

- (void)subjectAreaDidChange
{
    CGPoint devicePoint = CGPointMake(.5, .5);
    [self focusWithMode:AVCaptureFocusModeContinuousAutoFocus exposeWithMode:AVCaptureExposureModeContinuousAutoExposure atDevicePoint:devicePoint monitorSubjectAreaChange:NO];
}

- (void)focusWithMode:(AVCaptureFocusMode)focusMode exposeWithMode:(AVCaptureExposureMode)exposureMode atDevicePoint:(CGPoint)point monitorSubjectAreaChange:(BOOL)monitorSubjectAreaChange
{
    AVCaptureDevice *device = [[self videoDeviceInput] device];
    NSError *error = nil;
    if ([device lockForConfiguration:&error]) {
        if ([device isFocusPointOfInterestSupported] && [device isFocusModeSupported:focusMode])
        {
            [device setFocusMode:focusMode];
            [device setFocusPointOfInterest:point];
        }
        if ([device isExposurePointOfInterestSupported] && [device isExposureModeSupported:exposureMode])
        {
            [device setExposureMode:exposureMode];
            [device setExposurePointOfInterest:point];
        }
        [device setSubjectAreaChangeMonitoringEnabled:monitorSubjectAreaChange];
        [device unlockForConfiguration];
    } else {
        NSLog(@"%@", error);
    }
}

- (void)startRecordingOutputFile
{
    // start Recordering
    [_captureSession startRunning];
    [_movieFileOutput startRecordingToOutputFileURL:[NSURL fileURLWithPath:[PAVideoRecorderHelper getMovFilePathByTime]] recordingDelegate:self];
    _state = VideoRecoderStateRecording;
}

- (void)stopCurrentVideoRecording
{
    [self stopCountDurTimer];
    [_movieFileOutput stopRecording];
    [_captureSession stopRunning];
    _state = VideoRecoderStateReadyToRecord;
}

- (void)videoRecording
{
    if ([_delegate respondsToSelector:@selector(videoRecorder:didRecordingToOutPutFileAtURL:duration:)]) {
        // Recording...
        [_delegate videoRecorder:self didRecordingToOutPutFileAtURL:_currentFileURL duration:_currentVideoDuration];
    }
}

#pragma mark -- AVCaptureFileOutputRecording Delegate

- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didStartRecordingToOutputFileAtURL:(NSURL *)fileURL fromConnections:(NSArray *)connections
{
    _currentFileURL = fileURL;
    _currentVideoDuration = 0.0f;
    [self startCountDurTimer];
    if ([_delegate respondsToSelector:@selector(videoRecorder:didStartRecordingToOutPutFileAtURL:)]){
        [_delegate videoRecorder:self didStartRecordingToOutPutFileAtURL:fileURL];
    }
}
    
- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray *)connections error:(NSError *)error
{
    if ([_delegate respondsToSelector:@selector(videoRecorder:didFinishRecordingToOutPutFileAtURL:duration:error:)]) {
        [_delegate videoRecorder:self didFinishRecordingToOutPutFileAtURL:outputFileURL duration:_currentVideoDuration error:error];
    }
}

#pragma mark --  Method

- (AVCaptureDevice *)getCameraDevice:(BOOL)isFront
{
    NSArray *cameras = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    
    AVCaptureDevice *frontCamera;
    AVCaptureDevice *backCamera;
    
    for (AVCaptureDevice *camera in cameras) {
        if (camera.position == AVCaptureDevicePositionBack) {
            backCamera = camera;
        } else {
            frontCamera = camera;
        }
    }
    
    if (isFront) {
        return frontCamera;
    }
    
    return backCamera;
}

- (void)openTorch:(BOOL)open
{
    self.isTorchOn = open;
    if (!_isTorchSupported) {
        return;
    }
    
    AVCaptureTorchMode torchMode;
    if (open) {
        torchMode = AVCaptureTorchModeOn;
    } else {
        torchMode = AVCaptureTorchModeOff;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        [device lockForConfiguration:nil];
        [device setTorchMode:torchMode];
        [device unlockForConfiguration];
    });
}

- (void)switchCamera
{
    if (!_isFrontCameraSupported || !_isCameraSupported || !_videoDeviceInput) {
        return;
    }
    
    if (_isTorchOn) {
        [self openTorch:NO];
    }
    
    [_captureSession beginConfiguration];
    
    [_captureSession removeInput:_videoDeviceInput];
    
    self.isUsingFrontCamera = !_isUsingFrontCamera;
    AVCaptureDevice *device = [self getCameraDevice:_isUsingFrontCamera];
    
    [device lockForConfiguration:nil];
    if ([device isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure]) {
        [device setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
    }
    [device unlockForConfiguration];
    
    self.videoDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
    if ([_captureSession canAddInput:_videoDeviceInput]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:AVCaptureDeviceSubjectAreaDidChangeNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(subjectAreaDidChange) name:AVCaptureDeviceSubjectAreaDidChangeNotification object:nil];
        [_captureSession addInput:_videoDeviceInput];
    }
    [_captureSession commitConfiguration];
}

- (BOOL)isFrontCameraSupported
{
    return _isFrontCameraSupported;
}

- (BOOL)isCameraSupported
{
    return _isCameraSupported;
}

- (BOOL)isTorchSupported
{
    return _isTorchSupported;
}

- (BOOL)isTorchOn
{
    return _isTorchOn;
}

- (BOOL)isUsingFrontCamera
{
    return _isUsingFrontCamera;
}

@end