//
//  PAVideoRecorderVC.m
//  PAPhotoBrower
//
//  Created by paulery on 11/26/15.
//  Copyright © 2015 paulery. All rights reserved.
//

#import "PAVideoRecorderVC.h"
#import "PAVideoRecorderHelper.h"
#import "QBImageLoadingProgressBar.h"
#import "SDAVAssetExportSession.h"
#import <POP.h>
#import "PAImagePickerController.h"
#import "PAImagePickerGroupController.h"

#define UIColorFromRGB(rgbValue) \
[UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0x00FF00) >>  8))/255.0 \
blue:((float)((rgbValue & 0x0000FF) >>  0))/255.0 \
alpha:1.0]

@interface PAVideoRecorderVC ()<PAImagePickerControllerDelegate>

@property (assign,nonatomic) PACurrentModel paCurrentModel;

// recorder
@property (strong, nonatomic) PAVideoRecorder *videoRecorder;    // video recorder
@property (strong, nonatomic) AVPlayer *player;  // video preview
@property (strong, nonatomic) AVPlayerLayer *playerLayer;
@property (strong, nonatomic) NSURL *videoOutputFileURL;
@property (strong, nonatomic) NSURL *videoEncodedFileURL;
@property (strong, nonatomic) QBImageLoadingProgressBar *progressBar;
@property (strong, nonatomic) SDAVAssetExportSession *encoder;
@property (strong, nonatomic) AVAssetExportSession *exporter;
@property (nonatomic) dispatch_queue_t sessionQueue;

// ui
@property (weak, nonatomic) IBOutlet UIButton *backBtn;
@property (weak, nonatomic) IBOutlet UIButton *torchBtn;
@property (weak, nonatomic) IBOutlet UIButton *switchBtn;
@property (weak, nonatomic) IBOutlet UIButton *videoPlayBtn;
@property (weak, nonatomic) IBOutlet UIButton *videoSwitchBtn;
@property (weak, nonatomic) IBOutlet UIView *preView;
@property (weak, nonatomic) IBOutlet UIButton *videoRecorderBtn;
@property (weak, nonatomic) IBOutlet UIImageView *videoRecorderShineImageView;
@property (weak, nonatomic) IBOutlet UIImageView *videoRecorderFocusImageView;
@property (weak, nonatomic) IBOutlet UIButton *videoDeleteBtn;
@property (retain, nonatomic) IBOutlet UIButton *videoSelectBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *videoDeleteBtnWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *videoDeleteBtnHeightConstraint;
@property (weak, nonatomic) IBOutlet UIButton *videoRecorderFinishedBtn;
@property (weak, nonatomic) IBOutlet UIImageView *videoEncodeLoadingImageView;
@property (weak, nonatomic) IBOutlet UIView *videoEncodeMaskView;
@property (weak, nonatomic) IBOutlet UILabel *videoEncodeLoadingLabel;
@property (weak, nonatomic) IBOutlet UIView *bottonLayoutView;

// gesture
@property (strong,nonatomic) UITapGestureRecognizer *tapToFocusGesture;
@property (strong,nonatomic) UITapGestureRecognizer *preViewBtnGesture;

// others
@property (nonatomic) BOOL initalized;
@property (nonatomic) BOOL isMoreThanMaxSeconds;
@property (nonatomic) CGFloat videoCurrentDuration;
@property (nonatomic) CGFloat videoDeleteBtnOriginCenterX;
@property (nonatomic) CGFloat videoRecorderFinishedBtnOriginCenterX;
@property (assign, nonatomic) CGRect disRect;

// outlet
- (IBAction)backBtnPressed:(id)sender;
- (IBAction)torchBtnPressed:(id)sender;
- (IBAction)switchBtnPressed:(id)sender;
- (IBAction)videoPlayBtnPressed:(id)sender;
- (IBAction)videoDeleteBtnPressed:(id)sender;
- (IBAction)videoRecorderFinishedBtnPressed:(id)sender;
- (IBAction)videoSelectBtn:(id)sender;
- (IBAction)videoSwitchBtnPressed:(id)sender;

@end

@implementation PAVideoRecorderVC

#pragma mark - View Life Cycle
- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.view.frame = [[UIScreen mainScreen] bounds];
    [self.view setNeedsLayout];
    [self.view layoutIfNeeded];

    if (_initalized) {
        return;
    }
    
    // add Notification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dissmissVC) name:@"dismissVideoRecorderVCWhenCropVideoFinished" object:nil];
    
    // CurrentModel
    switch (self.paMediaType) {
        case PAMediaTypePhotoAndVideo:
        {
            self.paCurrentModel = PACurrentPhotoModel;
        }
            break;
        case PAMediaTypePhoto:
        {
            self.paCurrentModel = PACurrentPhotoModel;
        }
            break;
        case PAMediaTypeVideo:
        {
            self.paCurrentModel = PACurrentVideoModel;
        }
            break;
        default:
            break;
    }
    
    // init Video Recorder
    [self initRecorder];
    
    // createViews
    [self createViews];
    
    self.initalized = YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.videoRecorder.captureSession startRunning];
    [self.navigationController setNavigationBarHidden:YES];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(subjectAreaChange) name:AVCaptureDeviceSubjectAreaDidChangeNotification object:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self setApplicationStatusBarHidden:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.player pause];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVCaptureDeviceSubjectAreaDidChangeNotification object:nil];
    [self setApplicationStatusBarHidden:NO];
    [self.navigationController setNavigationBarHidden:NO];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.videoRecorder.captureSession stopRunning];
}

- (void)dissmissVC
{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)setApplicationStatusBarHidden:(BOOL)hidden
{
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= MP_IOS_3_2
    if ([UIApplication instancesRespondToSelector:@selector(setStatusBarHidden:withAnimation:)]) {
        // Hiding the status bar should use a fade effect.
        // Displaying the status bar should use no animation.
        UIStatusBarAnimation animation = UIStatusBarAnimationNone;
        [[UIApplication sharedApplication] setStatusBarHidden:hidden withAnimation:animation];
        return;
    }
#endif
    
    [[UIApplication sharedApplication] setStatusBarHidden:hidden];
}

- (void)disappearWithAnimationEndRect:(CGRect)rect image:(UIImage *)image
{
    self.disRect = rect;
    [self dismissViewControllerAnimated:NO completion:nil];
    UIView *window = [UIApplication sharedApplication].keyWindow;
    [window addSubview:self.view];
    [self doAnimationWithImage:image WhenDisappear:^{
        [self.view removeFromSuperview];
    }];
}

- (void)doAnimationWithImage:(UIImage *)image WhenDisappear:(void(^)(void))block
{
    _preView.hidden = YES;
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:_preView.frame];
    imageView.image = image;
    [self.view addSubview:imageView];
    
    UIColor *bgColor = self.view.backgroundColor;
    [UIView animateWithDuration:0.35
                          delay:0.0
                        options:UIViewAnimationOptionTransitionNone animations:^{
                            imageView.frame = self.disRect;
                            self.view.backgroundColor = UIColorFromRGB(0xededf0);
                        } completion:^(BOOL finished) {
                            if (finished)
                            {
                                self.view.backgroundColor = bgColor;
                                _preView.hidden = NO;
                                [imageView removeFromSuperview];
                                block();
                            }
                        }];
}

#pragma mark - Main method
- (void)focusTap:(UITapGestureRecognizer*)tapGesture
{
    CGPoint focusPoint = [tapGesture locationInView:[tapGesture view]];
    [self.videoRecorder focusAndExposeTap:focusPoint];
    [self.videoRecorderFocusImageView setHidden:NO];
    self.videoRecorderFocusImageView.center = focusPoint;
    [self videoRecorderFocusAnimation];
}

- (void)initRecorder
{
    // video Recorder
    if (!self.videoRecorder) {
        self.videoRecorder = [[PAVideoRecorder alloc] init];
    }
    self.videoRecorder.paCurrentModel = self.paCurrentModel;
    
    dispatch_queue_t sessionQueue = dispatch_queue_create("session queue", DISPATCH_QUEUE_SERIAL);
    [self setSessionQueue:sessionQueue];
    
    dispatch_sync(sessionQueue, ^{
        [self.videoRecorder initCaptureDevice];
    });
    
    self.videoRecorder.delegate = self;
    self.videoRecorder.videoPreview.frame = self.preView.layer.bounds;
    [self.preView.layer addSublayer:self.videoRecorder.videoPreview];
    
    // video Recorder Btn
    [self.videoRecorderBtn addTarget:self action:@selector(recorderButtonTouchBegin) forControlEvents:UIControlEventTouchDown];
    [self.videoRecorderBtn addTarget:self action:@selector(recorderButtonTouchEnd) forControlEvents:UIControlEventTouchUpInside];
}

- (void)subjectAreaChange
{
    [self.videoRecorder subjectAreaDidChange];
}

- (void)updateUI
{
    if (self.paCurrentModel == PACurrentVideoModel) {
        // progressBar
        if (!self.progressBar) {
            CGRect preViewRect = self.preView.frame;
            self.progressBar = [[QBImageLoadingProgressBar alloc] initWithFrame:CGRectMake(0,preViewRect.origin.y + CGRectGetHeight(preViewRect), CGRectGetWidth(preViewRect), 5) andBackgroundColor:[UIColor colorWithRed:32.0/255.0 green:32.0/255.0 blue:40.0/255.0 alpha:1]];
            [self.progressBar setProgress:0.0];
            [self.view addSubview:self.progressBar];
            
            // progressTagView
            UIView *progressTagView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.progressBar.frame)*0.3, 0, 1, CGRectGetHeight(self.progressBar.frame))];
            progressTagView.backgroundColor = [UIColor colorWithRed:255/255.0 green:160/255.0 blue:21/255.0 alpha:1];
            self.progressBar.layer.zPosition = -1;
            [self.progressBar addSubview:progressTagView];
        } else {
            [self.progressBar setHidden:NO];
        }
    } else {
        [self.progressBar setHidden:YES];
    }
}

- (void)createViews
{
    // other Btns
    [self.backBtn setImage:[UIImage imageNamed:@"video_close"] forState:UIControlStateNormal];
    [self.torchBtn setImage:[UIImage imageNamed:@"video_flash"] forState:UIControlStateNormal];
    [self.torchBtn setImage:[UIImage imageNamed:@"video_flash_on"] forState:UIControlStateSelected];
    [self.switchBtn setImage:[UIImage imageNamed:@"video_camera"] forState:UIControlStateNormal];
    [self.videoRecorderBtn setImage:[UIImage imageNamed:@"video_recorder"] forState:UIControlStateNormal];
    [self.videoPlayBtn setImage:[UIImage imageNamed:@"video_play"] forState:UIControlStateNormal];
    [self.videoSwitchBtn setImage:[UIImage imageNamed:@"video_switch"] forState:UIControlStateNormal];
    [self.videoDeleteBtn setImage:[UIImage imageNamed:@"video_delete_disable"] forState:UIControlStateDisabled];
    [self.videoRecorderFinishedBtn setImage:[UIImage imageNamed:@"video_finish"] forState:UIControlStateNormal];
    [self.videoRecorderFinishedBtn setImage:[UIImage imageNamed:@"video_finish_disable"] forState:UIControlStateDisabled];
    [self.videoRecorderShineImageView setImage:[UIImage imageNamed:@"video_recorder_shine"]];
    [self.videoDeleteBtn setImage:[UIImage imageNamed:@"video_delete"] forState:UIControlStateNormal];
    
    [self.videoRecorderShineImageView setHidden:YES];
    self.videoDeleteBtnOriginCenterX = self.videoDeleteBtn.center.x;
    self.videoRecorderFinishedBtnOriginCenterX = self.videoRecorderFinishedBtn.center.x;
    [self.videoSelectBtn setImage:[UIImage imageNamed:@"video_localSelected"] forState:UIControlStateNormal];
    
    // torch btn hidden when launch on ipod touch
    if (![self.videoRecorder isTorchSupported]) {
        [self.torchBtn setHidden:YES];
    }
    
    // videoRecorderFocusImageView
    self.videoRecorderFocusImageView.layer.zPosition = 10;
    [self.videoRecorderFocusImageView setImage:[UIImage imageNamed:@"video_recorder_focus"]];
    [self.videoRecorderFocusImageView setHidden:YES];
    
    // change border when btn is highlighted
    self.videoDeleteBtn.adjustsImageWhenHighlighted = NO;
    self.videoRecorderFinishedBtn.adjustsImageWhenHighlighted = NO;
    [self.videoDeleteBtn addTarget:self action:@selector(videoDeleteBtnhighlightedBorderColor) forControlEvents:UIControlEventTouchDown];
    [self.videoDeleteBtn addTarget:self action:@selector(videoDeleteBtnunhighlightedBorderColor) forControlEvents:UIControlEventTouchUpInside];
    [self.videoDeleteBtn addTarget:self action:@selector(videoDeleteBtnunhighlightedBorderColor) forControlEvents:UIControlEventTouchUpOutside];
    [self.videoRecorderFinishedBtn addTarget:self action:@selector(videoRecorderFinishedBtnhighlightedBorderColor) forControlEvents:UIControlEventTouchDown];
    [self.videoRecorderFinishedBtn addTarget:self action:@selector(videoRecorderFinishedBtnunhighlightedBorderColor) forControlEvents:UIControlEventTouchUpInside];
    [self.videoRecorderFinishedBtn addTarget:self action:@selector(videoRecorderFinishedBtnunhighlightedBorderColor) forControlEvents:UIControlEventTouchUpOutside];

    // videoEncode
    self.videoEncodeLoadingImageView.layer.zPosition = 4;
    [self.videoEncodeLoadingImageView setHidden:YES];
    [self.videoEncodeLoadingImageView setImage:[UIImage imageNamed:@"videoEncodeLoading"]];
    self.videoEncodeLoadingLabel.layer.zPosition = 4;
    [self.videoEncodeLoadingLabel setHidden:YES];
    
    // videoEncodeMask
    self.videoEncodeMaskView.layer.zPosition = 6;
    self.videoEncodeMaskView.alpha = 0.5;
    [self.videoEncodeMaskView setBackgroundColor:[UIColor blackColor]];
    [self.videoEncodeMaskView setHidden:YES];
    
    // hide these Btns until start recorder
    self.videoPlayBtn.layer.zPosition = 4;
    [self.videoPlayBtn setHidden:YES];
    [self.videoDeleteBtn setHidden:YES];
    [self.videoRecorderFinishedBtn setHidden:YES];
    
    if (self.paMediaType == PAMediaTypePhotoAndVideo) {
        [self.videoSwitchBtn setHidden:NO];
    } else {
        [self.videoSwitchBtn setHidden:YES];
    }
    
    // gesture
    self.tapToFocusGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(focusTap:)];
    [self.preView addGestureRecognizer:self.tapToFocusGesture];
    
    // video operate Btn disabled until start recorder
    [self.videoDeleteBtn setEnabled:NO];
    [self.videoRecorderFinishedBtn setEnabled:NO];
    
    [self updateUI];
}

- (void)dismiss
{
    [self dismissViewControllerAnimated:YES completion:^{
    }];
}

- (void)reset
{
    NSLog(@"%s", __func__);
    // torch && switch
    if ([self.videoRecorder isTorchSupported]) {
    [self.torchBtn setHidden:NO];
    }
    [self.switchBtn setHidden:NO];
    
    // ui
    if (self.paCurrentModel == PACurrentVideoModel) {
        [self.progressBar setProgress:0.0];
        [self.progressBar setHidden:NO];
    }
    
    // VideoRecorderBtn
    [self.videoRecorderBtn setHidden:NO];
    [self.videoRecorderBtn setEnabled:YES];
    self.videoRecorderBtn.alpha = 1.0;
    self.videoRecorderBtn.transform = CGAffineTransformMakeScale(1, 1);
    
    // videoDeleteBtn
    [self.videoDeleteBtn setHidden:YES];
    self.videoDeleteBtn.layer.borderWidth = 0;
    self.videoDeleteBtn.layer.cornerRadius = 0;
    self.videoDeleteBtn.alpha = 1.0;
    self.videoDeleteBtn.userInteractionEnabled = YES;
    self.videoDeleteBtn.center = CGPointMake(self.videoDeleteBtnOriginCenterX, self.videoDeleteBtn.center.y);
    self.videoDeleteBtn.transform = CGAffineTransformMakeScale(1, 1);
    
    // videoRecorderFinishedBtn
    [self.videoRecorderFinishedBtn setHidden:YES];
    self.videoRecorderFinishedBtn.layer.borderWidth = 0;
    self.videoRecorderFinishedBtn.layer.cornerRadius = 0;
    self.videoRecorderFinishedBtn.alpha = 1.0;
    self.videoRecorderFinishedBtn.center = CGPointMake(self.videoRecorderFinishedBtnOriginCenterX, self.videoRecorderFinishedBtn.center.y);
    self.videoRecorderFinishedBtn.userInteractionEnabled = YES;
    self.videoRecorderFinishedBtn.transform = CGAffineTransformMakeScale(1, 1);
    
    // videoSelectBtn
    [self.videoSelectBtn setHidden:NO];
    
    // videoEncodeMaskView
    [self.videoEncodeMaskView setHidden:YES];
    
    // remove Notification
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    
    // gesture
    [self.preView removeGestureRecognizer:self.preViewBtnGesture];
    self.tapToFocusGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(focusTap:)];
    [self.preView addGestureRecognizer:self.tapToFocusGesture];
    
    // release player
    [self.playerLayer removeFromSuperlayer];
    self.playerLayer = nil;
    [self.player pause];
    self.player = nil;
    [self.videoPlayBtn setHidden:YES];

    // videoRecorder
    dispatch_async(_sessionQueue, ^{
        NSLog(@"%s dispatch_async", __func__);
        [self.videoRecorder stopCurrentVideoRecording];
        [self.videoRecorder.captureSession startRunning];
    });
}

- (void)preViewPressed
{
    NSLog(@"preViewPressed");
    if (self.player.rate == 0) {
        [self.player play];
    }else{
        [self.player pause];
    }
}

- (void)preViewRecorderedVideo
{
    // player
    self.player = [AVPlayer playerWithURL:self.videoOutputFileURL];
    self.player.actionAtItemEnd = AVPlayerActionAtItemEndNone;
    self.playerLayer = [AVPlayerLayer layer];
    [self.playerLayer setPlayer:self.player];
    [self.playerLayer setFrame:self.preView.bounds];
    [self.playerLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    [self.preView.layer addSublayer:self.playerLayer];
    
    // gesture
    [self.preView removeGestureRecognizer:self.tapToFocusGesture];
    self.preViewBtnGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(preViewPressed)];
    [self.preView addGestureRecognizer:self.preViewBtnGesture];
    
    // add Notification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playItemDidReachEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    
    // play
    [self.player play];
}

- (void)videoDeleteBtnhighlightedBorderColor
{
    self.videoDeleteBtn.layer.opacity = 0.5;
}

- (void)videoDeleteBtnunhighlightedBorderColor
{
    self.videoDeleteBtn.layer.opacity = 1;
}

- (void)videoRecorderFinishedBtnhighlightedBorderColor

{
    self.videoRecorderFinishedBtn.layer.opacity = 0.5;

}

- (void)videoRecorderFinishedBtnunhighlightedBorderColor
{
    self.videoRecorderFinishedBtn.layer.opacity = 1;
}

- (UIImage*)getVideoPreViewImageWithFileURL:(NSURL*)fileURL
{
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:fileURL options:nil];
    AVAssetImageGenerator *gen = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    gen.appliesPreferredTrackTransform = YES;
    CMTime time = CMTimeMakeWithSeconds(0.0, 30);
    NSError *error = nil;
    CMTime actualTime;
    CGImageRef image = [gen copyCGImageAtTime:time actualTime:&actualTime error:&error];
    UIImage *img = [[UIImage alloc] initWithCGImage:image];
    return img;
}

- (void)convertVideoToLowQuailtyWithInputURL:(NSURL*)inputURL outputURL:(NSURL*)outputURL{
    AVAsset *asset = [AVURLAsset assetWithURL:inputURL];
    self.encoder = [[SDAVAssetExportSession alloc] initWithAsset:asset];
    self.encoder.outputFileType = AVFileTypeMPEG4;
    self.encoder.outputURL = outputURL;
    
    NSString *level = AVVideoProfileLevelH264Baseline31;
//    if (MyDevice().isIOS7AndAbove)
//    {
        level = AVVideoProfileLevelH264BaselineAutoLevel;
//    }
    // video Setting
    self.encoder.videoSettings = @{
                                   AVVideoCodecKey:AVVideoCodecH264,
                                   AVVideoWidthKey:@480, // frame
                                   AVVideoHeightKey:@480,
                                   AVVideoScalingModeKey:AVVideoScalingModeResizeAspectFill, // resize
                                   AVVideoCompressionPropertiesKey:@{
                                           AVVideoAverageBitRateKey:@(500*1024),  // Bit rate
                                           AVVideoProfileLevelKey: level,
                                           },
                                   };
    
    // audio Setting
    self.encoder.audioSettings = @{
                                   AVFormatIDKey:@(kAudioFormatMPEG4AAC),  // ;
                                   AVNumberOfChannelsKey:@1,
                                   AVSampleRateKey:@44100,   // hz?
                                   AVEncoderBitRateKey:@128000, // bitrate?
                                   };
    
    // video crop
    
    //create an avassetrack with our asset
    AVAssetTrack *clipVideoTrack = [[asset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    
    //create a video composition and preset some settings
    AVMutableVideoComposition* videoComposition = [AVMutableVideoComposition videoComposition];
    videoComposition.frameDuration = CMTimeMake(1, 30);
    //here we are setting its render size to its height x height (Square)
    videoComposition.renderSize = CGSizeMake(clipVideoTrack.naturalSize.height, clipVideoTrack.naturalSize.height);

    CGFloat scale = 1.5f;
    
    //create a video instruction
    AVMutableVideoCompositionInstruction *instruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    instruction.timeRange = CMTimeRangeMake(kCMTimeZero, CMTimeMakeWithSeconds(60, 30));
    AVMutableVideoCompositionLayerInstruction* transformer = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:clipVideoTrack];
    
    CGAffineTransform originalTransform = clipVideoTrack.preferredTransform;
    CGAffineTransform finalTransform = CGAffineTransformTranslate(originalTransform, - self.preView.frame.origin.y * scale, 0);
    [transformer setTransform:finalTransform atTime:kCMTimeZero];
    
    //add the transformer layer instructions, then add to video composition
    instruction.layerInstructions = [NSArray arrayWithObject:transformer];
    videoComposition.instructions = [NSArray arrayWithObject: instruction];
    
    [self.encoder setVideoComposition:videoComposition];
    
    // call back
    [self.encoder exportAsynchronouslyWithCompletionHandler:^{
        if (self.encoder.status == AVAssetExportSessionStatusCompleted) {
            NSLog(@"AVAssetExportSessionStatusCompleted");
            
            if ([[NSFileManager defaultManager] fileExistsAtPath:_videoOutputFileURL.path]) {
                NSLog(@"AVAssetExportSessionStatusCompleted YES");
            } else {
                NSLog(@"AVAssetExportSessionStatusCompleted NO");
            }
        }else if(self.encoder.status == AVAssetExportSessionStatusFailed){
            NSLog(@"AVAssetExportSessionStatusFailed");
        }else if(self.encoder.status == AVAssetExportSessionStatusExporting){
            NSLog(@"AVAssetExportSessionStatusExporting....");
            
        }else if(self.encoder.status == AVAssetExportSessionStatusCancelled){
            NSLog(@"AVAssetExportSessionStatusCancelled");
            
        }
    }];
}

#pragma mark - Outlet
- (void)recorderButtonTouchBegin
{
    if (self.paCurrentModel == PACurrentPhotoModel) {
        return;
    }
    
    if (self.videoRecorder.state == VideoRecoderStateInit)
    {
        NSLog(@"%s videoRecorder.state == VideoRecoderStateInit", __func__);
        return;
    }
    NSLog(@"%s", __func__);
    [self.videoSwitchBtn setHidden:YES];
    [self.videoSelectBtn setHidden:YES];
    [self videoRecorderShineAnimationStart];
    
    __weak typeof(self) weakSelf = self;
    dispatch_async(_sessionQueue, ^{
        [weakSelf.videoRecorder startRecordingOutputFile];
    });
}

- (void)recorderButtonTouchLessThanOneSecond
{
    self.videoRecorderBtn.hidden = NO;
    self.videoRecorderBtn.userInteractionEnabled = YES;
}

- (void)recorderButtonTouchEnd
{
    if (self.paCurrentModel == PACurrentPhotoModel) {
        [self.videoRecorder takePhoto];
        return;
    }
    
    if (self.videoRecorder.state != VideoRecoderStateRecording)
    {
        NSLog(@"%s videoRecorder.state != VideoRecoderStateRecording", __func__);
        return;
    }

    self.videoRecorderBtn.userInteractionEnabled = NO;
    [self performSelector:@selector(recorderButtonTouchLessThanOneSecond) withObject:nil afterDelay:1.0f];
    
    if (!self.isMoreThanMaxSeconds) {
        [self.videoRecorderBtn setEnabled:NO];
        [self videoRecorderShineAnimationStop];
    __weak typeof(self) weakSelf = self;
        dispatch_async(_sessionQueue, ^{
            [weakSelf.videoRecorder stopCurrentVideoRecording];
            [weakSelf videoRecorderBtnsAnimation];
        });
    }
}

- (IBAction)backBtnPressed:(id)sender
{
    [self.player pause];
    [self.videoRecorder stopCurrentVideoRecording];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (_recordVCDismssCallback)
        {
            _recordVCDismssCallback();
        }
        else
        {
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    });
}

- (IBAction)torchBtnPressed:(id)sender
{
    NSLog(@"%s", __func__);
    if ([self.videoRecorder isTorchOn]) {
        NSLog(@"%s isTorchOn", __func__);
        [self.torchBtn setSelected:NO];
        [self.videoRecorder openTorch:NO];
    }else{
        NSLog(@"%s else", __func__);
        [self.torchBtn setSelected:YES];
        [self.videoRecorder openTorch:YES];
    }
}

- (IBAction)switchBtnPressed:(id)sender
{
    [self.videoRecorder switchCamera];
    // close Torch when open front carmera
    if ([self.videoRecorder isTorchSupported]) {
        NSLog(@"%s isTorchSupported", __func__);
        if ([self.videoRecorder isUsingFrontCamera]) {
            [self.torchBtn setHidden:YES];
        }else{
        NSLog(@"%s else", __func__);
            [self.torchBtn setHidden:NO];
        }
    }
}

- (IBAction)videoPlayBtnPressed:(id)sender
{
    [self preViewPressed];
}

- (IBAction)videoDeleteBtnPressed:(id)sender
{
    [self.player pause];
    [self reset];
}

- (IBAction)videoRecorderFinishedBtnPressed:(id)sender
{
    // ui
    [self.player pause];
    [self.videoPlayBtn setHidden:YES];
    
    [self.videoEncodeMaskView setHidden:NO];
    self.videoDeleteBtn.userInteractionEnabled = NO;
    self.videoRecorderFinishedBtn.userInteractionEnabled = NO;

    [self.videoEncodeLoadingImageView setHidden:NO];
    [self.videoEncodeLoadingLabel setHidden:NO];
    
    // encode loading animation
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    animation.duration = ENCODELOADINGIMAGEVIEW_ANIMATION_DURATION;
    animation.fromValue = [NSNumber numberWithFloat:0.0];
    animation.toValue = [NSNumber numberWithFloat:2*M_PI];
    animation.repeatCount = HUGE;
    [self.videoEncodeLoadingImageView.layer addAnimation:animation forKey:@"paulery"];
    
    // encode
    self.videoEncodedFileURL = [NSURL fileURLWithPath:[PAVideoRecorderHelper getFilePathByTime]];
    [self convertVideoToLowQuailtyWithInputURL:self.videoOutputFileURL outputURL:self.videoEncodedFileURL];
}

- (IBAction)videoSelectBtn:(id)sender
{
    // select photos locally
    NSUInteger maxNumberOfPhotos = 6;
    UICollectionViewFlowLayout *layout= [[UICollectionViewFlowLayout alloc]init];
    [layout setScrollDirection:UICollectionViewScrollDirectionVertical];
    PAImagePickerController *pickerVC = [[PAImagePickerController alloc] initWithCollectionViewLayout:layout];
    PAImagePickerGroupController *pickerGroupVC = [[PAImagePickerGroupController alloc] init];
    pickerGroupVC.maxNumberOfPhotos = maxNumberOfPhotos;
    pickerVC.maxNumberOfPhotos = maxNumberOfPhotos;
    pickerVC.delegate = self;
    pickerGroupVC.delegate = self;
    pickerVC.doneButtonTitle = @"Send";
    pickerVC.paMediaType = self.paMediaType;
    pickerGroupVC.paMediaType = self.paMediaType;
    UINavigationController *pickerNavController = [[UINavigationController alloc] initWithRootViewController:pickerGroupVC];
    pickerNavController.viewControllers = @[pickerGroupVC,pickerVC];
    
    [self presentViewController:pickerNavController animated:YES completion:^{
        
    }];
    
}

- (IBAction)videoSwitchBtnPressed:(id)sender
{
    if (self.paCurrentModel == PACurrentPhotoModel) {
        self.paCurrentModel = PACurrentVideoModel;
    } else {
        self.paCurrentModel = PACurrentPhotoModel;
    }
    
    [self.videoRecorder switchToModel:self.paCurrentModel];
    [self reset];
    [self updateUI];
}

#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (((PAVideoRecorderVC *)object).player != self.player) {
        return;
    }
    
    if(change[@"old"] != [NSNull null] && change[@"new"] != [NSNull null]){
        if ([change[@"old"] integerValue] == 0 && [change[@"new"] integerValue] == 0) {
            return;
        }
    }
    
    if (self.player.rate == 0) {
        [self.videoPlayBtn setHidden:NO];
    }else{
        [self.videoPlayBtn setHidden:YES];
    }
}

#pragma mark - Delegate
- (void)videoRecorder:(PAVideoRecorder*)videoRecorder didStartRecordingToOutPutFileAtURL:(NSURL*)fileURL
{
    self.videoCurrentDuration = 0.0f;
    self.isMoreThanMaxSeconds = NO;
    [self.videoDeleteBtn setHidden:NO];
    [self.videoDeleteBtn setEnabled:NO];
    [self.videoRecorderFinishedBtn setHidden:NO];
    [self.videoRecorderFinishedBtn setEnabled:NO];
    
    if ([self.videoRecorder isTorchSupported]) {
        [self.torchBtn setHidden:YES];
    }
    
    [self.switchBtn setHidden:YES];
}

- (void)videoRecorder:(PAVideoRecorder*)videoRecorder didRecordingToOutPutFileAtURL:(NSURL*)outputFileURL duration:(CGFloat)videoDuration
{
    self.videoCurrentDuration = videoDuration;
    NSLog(@"videoDuration:%f",videoDuration);
    
    // update progress UI
    [self.progressBar setProgress:videoDuration/MAX_VIDEO_DUR];
    
    if (videoDuration >= MIN_VIDEO_DUR) {
        [self.videoDeleteBtn setEnabled:YES];
        [self.videoRecorderFinishedBtn setEnabled:YES];
    }
    
    if (videoDuration >= MAX_VIDEO_DUR) {
        self.isMoreThanMaxSeconds = YES;
        [self.videoRecorderBtn setEnabled:NO];
        [self videoRecorderShineAnimationStop];
        
        dispatch_async(_sessionQueue, ^{
            NSLog(@"%s dispatch_async", __func__);
            [self.videoRecorder stopCurrentVideoRecording];
            [self videoRecorderBtnsAnimation];
        });
    }
}

- (void)videoRecorder:(PAVideoRecorder *)videoRecorder didFinishRecordingToOutPutFileAtURL:(NSURL *)outputFileURL duration:(CGFloat)videoDuration error:(NSError*)error
{
    if ([self.videoRecorder isTorchSupported]) {
        [self.torchBtn setHidden:NO];
    }
    
    [self.switchBtn setHidden:NO];
    
    if (videoDuration < MIN_VIDEO_DUR) {
        [self reset];
    } else {
        [self videoRecorderBtnAnimation];
        [self.progressBar setHidden:YES];
        
        if ([self.videoRecorder isTorchSupported]) {
            [self.torchBtn setHidden:YES];
        }
        
        [self.switchBtn setHidden:YES];
        
        // preView
        self.videoOutputFileURL = outputFileURL;
        [self preViewRecorderedVideo];
    }
}

#pragma mark - Notification
- (void)playItemDidReachEnd:(NSNotification*)notification
{
    AVPlayerItem *item = [notification object];
    [item seekToTime:kCMTimeZero];
    [self.player play];
}

#pragma mark - Animations
- (POPBasicAnimation*)getVideoRecorderBtnsPOPBasicAnimationWithKeyPath:(NSString*)keyPath toValue:(id)tovalue beginTime:(CFTimeInterval)beginTime duration:(CFTimeInterval)duration
{
    POPBasicAnimation *videoRecorderBtnsPOPBasicAnimation = [POPBasicAnimation animationWithPropertyNamed:keyPath];
    videoRecorderBtnsPOPBasicAnimation.toValue = tovalue;
    videoRecorderBtnsPOPBasicAnimation.beginTime = beginTime;
    videoRecorderBtnsPOPBasicAnimation.duration = duration;
    return videoRecorderBtnsPOPBasicAnimation;
}

- (void)videoRecorderBtnAnimation
{
    POPBasicAnimation *videoRecorderBtnAni1 = [self getVideoRecorderBtnsPOPBasicAnimationWithKeyPath:kPOPViewAlpha toValue:@(0.0) beginTime:0 duration:DURATION];
    [self.videoRecorderBtn pop_addAnimation:videoRecorderBtnAni1 forKey:@"videoRecorderBtnAni1"];
    
    POPBasicAnimation *videoRecorderBtnAni2 = [self getVideoRecorderBtnsPOPBasicAnimationWithKeyPath:kPOPViewScaleXY toValue:[NSValue valueWithCGSize:CGSizeMake(0, 0)] beginTime:0 duration:DURATION];
    [self.videoRecorderBtn pop_addAnimation:videoRecorderBtnAni2 forKey:@"videoRecorderBtnAni2"];
}

- (void)videoRecorderBtnsAnimation{
    
    if (self.videoCurrentDuration >= MIN_VIDEO_DUR) {
        // set BorderView
        self.videoDeleteBtn.layer.borderWidth = 1;
        self.videoDeleteBtn.layer.borderColor = [UIColor colorWithRed:204/255.0 green:70/255.0 blue:70/255.0 alpha:1].CGColor;
        self.videoDeleteBtn.layer.cornerRadius = self.videoDeleteBtn.frame.size.width/2;
        
        self.videoRecorderFinishedBtn.layer.borderWidth = 1;
        self.videoRecorderFinishedBtn.layer.borderColor = [UIColor colorWithRed:57/255.0 green:205/255.0 blue:120/255.0 alpha:1].CGColor;
        self.videoRecorderFinishedBtn.layer.cornerRadius = self.videoDeleteBtn.frame.size.width/2;
        
        // videoDeleteBtnAnimation
        POPBasicAnimation *videoDeleteBtnAni1 = [self getVideoRecorderBtnsPOPBasicAnimationWithKeyPath:kPOPViewCenter toValue:[NSValue valueWithCGPoint:CGPointMake(self.videoDeleteBtn.center.x + 60, self.videoDeleteBtn.center.y)] beginTime:0 duration:DURATION];
        [self.videoDeleteBtn pop_addAnimation:videoDeleteBtnAni1 forKey:@"videoDeleteBtnAni1"];
        
        POPBasicAnimation *videoDeleteBtnAni2 = [self getVideoRecorderBtnsPOPBasicAnimationWithKeyPath:kPOPViewScaleXY toValue:[NSValue valueWithCGSize:CGSizeMake(SCALE_OF_INTERVAL_1, SCALE_OF_INTERVAL_1)] beginTime:0 duration:DURATION];
        [self.videoDeleteBtn pop_addAnimation:videoDeleteBtnAni2 forKey:@"videoDeleteBtnAni2"];
        
        POPBasicAnimation *videoDeleteBtnAni3 = [self getVideoRecorderBtnsPOPBasicAnimationWithKeyPath:kPOPViewCenter toValue:[NSValue valueWithCGPoint:CGPointMake(self.videoDeleteBtn.center.x + 30, self.videoDeleteBtn.center.y)] beginTime:CACurrentMediaTime() + DURATION duration:DURATION];
        [self.videoDeleteBtn pop_addAnimation:videoDeleteBtnAni3 forKey:@"videoDeleteBtnAni3"];
        
        POPBasicAnimation *videoDeleteBtnAni4 = [self getVideoRecorderBtnsPOPBasicAnimationWithKeyPath:kPOPViewScaleXY toValue:[NSValue valueWithCGSize:CGSizeMake(SCALE_OF_INTERVAL_2,SCALE_OF_INTERVAL_2)] beginTime:CACurrentMediaTime() + DURATION duration:DURATION];
        [self.videoDeleteBtn pop_addAnimation:videoDeleteBtnAni4 forKey:@"videoDeleteBtnAni4"];
        
        // videoRecorderFinishBtnAnimation
        POPBasicAnimation *videoRecorderFinishBtnAni1 = [self getVideoRecorderBtnsPOPBasicAnimationWithKeyPath:kPOPViewCenter toValue:[NSValue valueWithCGPoint:CGPointMake(self.videoRecorderFinishedBtn.center.x - OFFSETX_OF_INTERVAL_1, self.videoRecorderFinishedBtn.center.y)] beginTime:0 duration:DURATION];
        [self.videoRecorderFinishedBtn pop_addAnimation:videoRecorderFinishBtnAni1 forKey:@"videoRecorderFinishBtnAni1"];
        
        POPBasicAnimation *videoRecorderFinishBtnAni2 = [self getVideoRecorderBtnsPOPBasicAnimationWithKeyPath:kPOPViewScaleXY toValue:[NSValue valueWithCGSize:CGSizeMake(SCALE_OF_INTERVAL_1, SCALE_OF_INTERVAL_1)] beginTime:0 duration:DURATION];
        [self.videoRecorderFinishedBtn pop_addAnimation:videoRecorderFinishBtnAni2 forKey:@"videoRecorderFinishBtnAni2"];
        
        POPBasicAnimation *videoRecorderFinishBtnAni3 = [self getVideoRecorderBtnsPOPBasicAnimationWithKeyPath:kPOPViewCenter toValue:[NSValue valueWithCGPoint:CGPointMake(self.videoRecorderFinishedBtn.center.x - OFFSETX_OF_INTERVAL_2, self.videoRecorderFinishedBtn.center.y)] beginTime:CACurrentMediaTime() + DURATION duration:DURATION];
        [self.videoRecorderFinishedBtn pop_addAnimation:videoRecorderFinishBtnAni3 forKey:@"videoRecorderFinishBtnAni3"];
        
        POPBasicAnimation *videoRecorderFinishBtnAni4 = [self getVideoRecorderBtnsPOPBasicAnimationWithKeyPath:kPOPViewScaleXY toValue:[NSValue valueWithCGSize:CGSizeMake(SCALE_OF_INTERVAL_2,SCALE_OF_INTERVAL_2)] beginTime:CACurrentMediaTime() + DURATION duration:DURATION];
        [self.videoRecorderFinishedBtn pop_addAnimation:videoRecorderFinishBtnAni4 forKey:@"videoRecorderFinishBtnAni4"];
    }
}

- (void)videoRecorderShineAnimationStart
{
    [self.videoRecorderShineImageView setHidden:NO];
    CABasicAnimation *shineAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    shineAnimation.duration = VIDEORECORDERSHINE_DURATION;
    shineAnimation.fromValue = @(0.0);
    shineAnimation.toValue = @(1.0);
    shineAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    shineAnimation.autoreverses = YES;
    shineAnimation.repeatCount = HUGE;
    shineAnimation.removedOnCompletion = NO;
    shineAnimation.beginTime = 0;
    shineAnimation.fillMode = kCAFillModeForwards;
    [self.videoRecorderShineImageView.layer addAnimation:shineAnimation forKey:@"paulery"];
}

- (void)videoRecorderFocusAnimation
{
    // remove original animation
    [self.videoRecorderFocusImageView.layer removeAllAnimations];
    
    // interactive for 3 times
    CGFloat videoRecorderFocusScale = 1.2;
    CGFloat videoRecorderFocusDuration = 0.18f;
    
    CABasicAnimation *scaleAnimation1 = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    scaleAnimation1.duration = videoRecorderFocusDuration;
    scaleAnimation1.beginTime = 0;
    scaleAnimation1.fromValue = [NSNumber numberWithFloat:videoRecorderFocusScale];
    scaleAnimation1.toValue =  [NSNumber numberWithFloat:1.0f];
    scaleAnimation1.autoreverses = YES;
    scaleAnimation1.repeatCount = 6;
    scaleAnimation1.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    scaleAnimation1.removedOnCompletion = NO;
    scaleAnimation1.fillMode = kCAFillModeForwards;
    [self.videoRecorderFocusImageView.layer addAnimation:scaleAnimation1 forKey:@"scaleAnimation1"];
    
    // scale 1 -> 0
    CABasicAnimation *scaleAnimation2 = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    scaleAnimation2.duration = videoRecorderFocusDuration;
    scaleAnimation2.beginTime = videoRecorderFocusDuration * 6;
    scaleAnimation2.fromValue = [NSNumber numberWithFloat:1.0f];
    scaleAnimation2.toValue =  [NSNumber numberWithFloat:0.0f];
    scaleAnimation2.autoreverses = NO;
    scaleAnimation2.repeatCount = 1;
    scaleAnimation2.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    scaleAnimation2.removedOnCompletion = YES;
    scaleAnimation2.fillMode = kCAFillModeForwards;
    [self.videoRecorderFocusImageView.layer addAnimation:scaleAnimation2 forKey:@"scaleAnimation2"];
    
    CABasicAnimation *fadeAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    fadeAnimation.duration = videoRecorderFocusDuration;
    fadeAnimation.beginTime = videoRecorderFocusDuration * 6;
    fadeAnimation.fromValue = [NSNumber numberWithFloat:1.0f];
    fadeAnimation.toValue =  [NSNumber numberWithFloat:0.0f];
    fadeAnimation.autoreverses = NO;
    fadeAnimation.repeatCount = 1;
    fadeAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    fadeAnimation.removedOnCompletion = YES;
    fadeAnimation.fillMode = kCAFillModeForwards;
    [self.videoRecorderFocusImageView.layer addAnimation:fadeAnimation forKey:@"fadeAnimation"];
    
    CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
    animationGroup.duration = videoRecorderFocusDuration * 7;
    animationGroup.removedOnCompletion = NO;
    animationGroup.fillMode = kCAFillModeForwards;
    animationGroup.animations = [NSArray arrayWithObjects:scaleAnimation1,scaleAnimation2,fadeAnimation,nil];
    [self.videoRecorderFocusImageView.layer addAnimation:animationGroup forKey:@"paulery"];
}

- (void)videoRecorderShineAnimationStop
{
    [self.videoRecorderShineImageView.layer removeAllAnimations];
    [self.videoRecorderShineImageView setHidden:YES];
}

- (void)dealloc
{
    self.player = nil;
    self.videoRecorder = nil;
}

@end
