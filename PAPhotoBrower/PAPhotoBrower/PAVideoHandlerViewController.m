//
//  PAVideoHandlerViewController.m
//  PAPhotoBrower
//
//  Created by paulery on 11/26/15.
//  Copyright © 2015 paulery. All rights reserved.
//

#import "PAVideoHandlerViewController.h"
#import "PAVideoCropView.h"
#import "PAVideoRecorderHelper.h"
#import "SDAVAssetExportSession.h"
//#import "UIDevice+ScreenSizeCheck.h"

#define UIColorFromRGB(rgbValue) \
[UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0x00FF00) >>  8))/255.0 \
blue:((float)((rgbValue & 0x0000FF) >>  0))/255.0 \
alpha:1.0]

@interface PAVideoHandlerViewController ()

// view should hidden in iPhone4&4S
@property (weak, nonatomic) IBOutlet UILabel *labelNeedToHidden;
@property (weak, nonatomic) IBOutlet UIImageView *imgviewNeedToHidden;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightNeedToSet35;

@property (weak, nonatomic) AVPlayer *player;  // video preview
@property (strong,nonatomic) AVPlayerItem *playerItem;
@property (strong, nonatomic) AVPlayerLayer *playerLayer;
@property (strong, nonatomic) NSURL *videoOutputFileURL;
@property (strong,nonatomic) AVAsset* avAsset;
@property (weak,nonatomic) id playerBoundaryTimeObserver;
@property (weak,nonatomic) id playerPeriodicTimeObserver;

// convert
@property (strong, nonatomic) AVAssetExportSession *exporter;
@property (strong, nonatomic) SDAVAssetExportSession *encoder;
@property (strong, nonatomic) NSURL *videoEncodedFileURL;

// ui
@property (strong, nonatomic) VideoCropView *cropView;
@property (weak, nonatomic) IBOutlet UIButton *videoPlayBtn;
@property (weak, nonatomic) IBOutlet UIView *preView;
@property (retain, nonatomic) IBOutlet UIView *middleView;
@property (weak, nonatomic) IBOutlet UIView *videoEncodeMaskView;
@property (weak, nonatomic) IBOutlet UILabel *videoEncodeLoadingLabel;
@property (weak, nonatomic) IBOutlet UIImageView *videoEncodeLoadingImageView;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (strong, nonatomic) UIScrollView *videoPreScrollView;


// tips
@property (retain, nonatomic) IBOutlet UIImageView *pointToTopArrowImageView;
@property (retain, nonatomic) IBOutlet UIImageView *pointToBottomArrowImageView;


// gesture
@property (strong,nonatomic) UITapGestureRecognizer *preViewBtnTapGesture;

// others
@property (nonatomic) BOOL initalized;
@property (assign, nonatomic) CGRect disRect;

// outlet
- (IBAction)videoBtnPressed:(id)sender;

@end

@implementation PAVideoHandlerViewController

- (void)dealloc
{
    [self removeObserver:self forKeyPath:@"player.rate"];
    if (self.playerBoundaryTimeObserver) {
        [self.player removeTimeObserver:self.playerBoundaryTimeObserver];
    }
    
    if (self.playerPeriodicTimeObserver) {
        [self.player removeTimeObserver:self.playerPeriodicTimeObserver];
    }
    [self.playerLayer removeFromSuperlayer];
    self.playerItem = nil;
    self.playerLayer = nil;
    [self.player pause];
    self.player = nil;
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVCaptureDeviceSubjectAreaDidChangeNotification object:nil];
    self.player = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.frame = [[UIScreen mainScreen] bounds];
    [self.view setNeedsLayout];
    [self.view layoutIfNeeded];
    
    if (_initalized) {
        return;
    }
    
    // add player Oberver
    [self addObserver:self forKeyPath:@"player.rate" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
 
    // cropView
    [self createCropView];

    // next btn
    UIButton *rightBarBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    rightBarBtn.titleLabel.font = [UIFont systemFontOfSize:17.0f];
    [rightBarBtn setTitle:@"下一步" forState:UIControlStateNormal];
    [rightBarBtn setTitleColor:UIColorFromRGB(0xffa015) forState:UIControlStateNormal];
    [rightBarBtn sizeToFit];
    [rightBarBtn addTarget:self action:@selector(rightBarBtnPressed) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightBarItem = [[UIBarButtonItem alloc] initWithCustomView:rightBarBtn];
    self.navigationItem.rightBarButtonItem = rightBarItem;
    
    // createViews
    [self createViews];
    
    self.view.backgroundColor = [UIColor colorWithRed:26/255.0 green:26/255.0 blue:31/255.0 alpha:1];
    
//    if (MyDevice().isIOS7AndAbove)
//    {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
//    }
    
    self.initalized = YES;
}

- (void)updateViewConstraints
{
//    if (![UIDevice isWideScreenIPhone])
//    {
        self.imgviewNeedToHidden.hidden = YES;
        self.labelNeedToHidden.hidden = YES;
        [self.heightNeedToSet35 setConstant:35.0];
//    }
    [super updateViewConstraints];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    [self setApplicationStatusBarHidden:NO];
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

// confirm 之后的调用
- (void)disappearWithAnimationEndRect:(CGRect)rect image:(UIImage *)image
{
    self.disRect = rect;
    
    [self dismissViewControllerAnimated:NO completion:^(void){
        // dismiss VideoRecorderVC
        [[NSNotificationCenter defaultCenter] postNotificationName:@"dismissVideoRecorderVCWhenCropVideoFinished" object:nil];
    }];

    UIView *window = [UIApplication sharedApplication].keyWindow;
    [window addSubview:self.view];
    __weak typeof(self) weakSelf = self;
    [self doAnimationWithImage:image WhenDisappear:^{
        [weakSelf.view removeFromSuperview];
    }];
     
}

#pragma mark - main method
- (void)createViews
{
    // videoPlayBtn
    [self.videoPlayBtn setImage:[UIImage imageNamed:@"video_play"] forState:UIControlStateNormal];
    self.videoPlayBtn.layer.zPosition = 4;
    
    // videoTips
    [self.pointToTopArrowImageView setImage:[UIImage imageNamed:@"video_pointToTopArrow"]];
    [self.pointToBottomArrowImageView setImage:[UIImage imageNamed:@"video_pointToBottomArrow"]];
    
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
    
    self.avAsset = [[AVURLAsset alloc] initWithURL:self.videoInputURL options:nil];
    
    [self preViewRecorderedVideo];
}

- (void)createCropView
{
    NSLog(@"createCropView");
    self.cropView = [[VideoCropView alloc] initWithFrame:CGRectMake(0, 0, self.bottomView.frame.size.width, self.bottomView.frame.size.width/5) withVideoURL:self.videoInputURL andVideoDuration:self.videoDuration];
    self.cropView.delegate = self;
    [self.bottomView addSubview:self.cropView];
}

- (void)preViewRecorderedVideo
{
    // player
    self.playerItem = [[AVPlayerItem alloc] initWithURL:self.videoInputURL];
    self.player = [AVPlayer playerWithPlayerItem:self.playerItem];
    self.player.actionAtItemEnd = AVPlayerActionAtItemEndNone;
    self.playerLayer = [AVPlayerLayer layer];
    [self.playerLayer setPlayer:self.player];
    [self.playerLayer setFrame:self.view.bounds];
    [self.playerLayer setVideoGravity:AVLayerVideoGravityResize];

    // videoPreScrollView
    self.videoPreScrollView = [[UIScrollView alloc] initWithFrame:self.preView.bounds];
    
    AVAssetTrack *videoTrack = [[self.playerItem.asset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    
    CGAffineTransform transform = videoTrack.preferredTransform;
    CGSize sizeOfVideo = videoTrack.naturalSize;
    CGRect rectOfVideo = CGRectZero;
    rectOfVideo.size = sizeOfVideo;
    CGSize resultSize = self.preView.bounds.size;
    rectOfVideo = CGRectApplyAffineTransform(rectOfVideo, transform);
    sizeOfVideo = rectOfVideo.size;
    
    if (sizeOfVideo.width > sizeOfVideo.height) {
        resultSize.width = resultSize.height * sizeOfVideo.width / sizeOfVideo.height;
    } else if (sizeOfVideo.width < sizeOfVideo.height) {
        resultSize.height = resultSize.width * sizeOfVideo.height / sizeOfVideo.width;
    }
    
    CGRect boundsOfPreviewLayer = CGRectZero;
    boundsOfPreviewLayer.size = resultSize;
    self.playerLayer.frame = boundsOfPreviewLayer;
    
    self.videoPreScrollView.contentSize = resultSize;
    self.videoPreScrollView.bounces = NO;
    [self.videoPreScrollView.layer addSublayer:self.playerLayer];
    [self.preView addSubview:self.videoPreScrollView];

    // gesture
    self.preViewBtnTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(preViewPressed)];
    [self.preView addGestureRecognizer:self.preViewBtnTapGesture];
    
    if (self.playerPeriodicTimeObserver) {
        
    }
    __weak typeof(self) weakSelf = self;
    self.playerPeriodicTimeObserver = [self.player addPeriodicTimeObserverForInterval:CMTimeMake(0.01*self.avAsset.duration.timescale, self.avAsset.duration.timescale) queue:NULL usingBlock:^(CMTime time){
        [weakSelf updateVideoProgressBar];
    }];
    
    // observer
    [self addTimeObserver];
    
    // add Notification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playItemDidReachEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    
}

- (void)preViewPressed
{// 点击视频预览区域
    if (self.player.rate == 0) {
        NSLog(@"videoCropCurrentTime = %f  videoCropBeginTime = %f", self.cropView.videoCropCurrentTime, self.cropView.videoCropBeginTime);
        if(self.cropView.videoCropCurrentTime >= self.cropView.videoCropBeginTime){
            NSLog(@"self.timescale = %d (self.cropView.videoCropCurrentTime)*self.avAsset.duration.timescale = %f", self.avAsset.duration.timescale, (self.cropView.videoCropCurrentTime)*self.avAsset.duration.timescale);
            
            __weak PAVideoHandlerViewController *weakSelf = self;
            [self.player seekToTime:CMTimeMake((self.cropView.videoCropCurrentTime)*self.avAsset.duration.timescale, self.avAsset.duration.timescale) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:^(BOOL finished) {
                NSLog(@"player finished weakSelf.cropView.videoCropCurrentTime = weakSelf.cropView.videoCropBeginTime;");
                weakSelf.cropView.videoCropCurrentTime = weakSelf.cropView.videoCropBeginTime;
            }];
        }
        [self.player play];
    }else{
        [self.player pause];
    }
}

- (void)rightBarBtnPressed
{
    [self.player pause];
    [self.player seekToTime:CMTimeMake((self.cropView.videoCropBeginTime)*self.avAsset.duration.timescale, self.avAsset.duration.timescale) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
    [self.videoPlayBtn setHidden:YES];
    
    NSLog(@"Crop_startTime:%f,endTime:%f,square:%@",self.cropView.videoCropBeginTime,self.cropView.videoCropEndTime,NSStringFromCGRect(CGRectOffset(self.videoPreScrollView.frame, self.videoPreScrollView.contentOffset.x, self.videoPreScrollView.contentOffset.y)));
    
    
    [self.videoEncodeMaskView setHidden:NO];
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
    [self convertVideoToLowQuailtyWithInputURL:self.videoInputURL outputURL:self.videoEncodedFileURL];
}

#pragma mark - video convert
- (void)convertVideoToLowQuailtyWithInputURL:(NSURL*)inputURL outputURL:(NSURL*)outputURL{
    AVURLAsset *asset = [AVURLAsset assetWithURL:inputURL];
    
    // video track
//    NSError *error = nil;
    AVAssetTrack *clipVideoTrack = [[asset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    
    // insert timeRange
//    CMTimeRange range = CMTimeRangeMake(CMTimeMake(self.cropView.videoCropBeginTime*self.avAsset.duration.timescale, self.avAsset.duration.timescale),CMTimeMake(self.cropView.videoCropDurationTime*self.avAsset.duration.timescale, self.avAsset.duration.timescale));
    AVMutableComposition *composition = [AVMutableComposition composition];
//    BOOL insertTrackSuccessed = [composition insertTimeRange:range ofAsset:asset atTime:kCMTimeZero error:&error];
    
    // encoder
    self.encoder = [[SDAVAssetExportSession alloc] initWithAsset:composition];
//    self.encoder.timeRange = range;
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
    
    
    // 创建视频截取区域
    AVMutableVideoComposition* videoComposition = [AVMutableVideoComposition videoComposition];
    videoComposition.frameDuration = CMTimeMake(1, 30);
    
    // 只需要取短的边作为视频截取的大小即可，因为我们是矩形
    CGFloat smallerSide = clipVideoTrack.naturalSize.width < clipVideoTrack.naturalSize.height ? clipVideoTrack.naturalSize.width : clipVideoTrack.naturalSize.height;
    videoComposition.renderSize = CGSizeMake(smallerSide, smallerSide);
    
    AVMutableVideoCompositionLayerInstruction* transformer = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:clipVideoTrack];
    
    // 计算缩放的因子，因为要放到scrollview里面肯定缩放了，但是只需要根据小的边计算就可以了
    // 因为缩放的时候是把小的边缩放到和scrollview的宽度或是高度那么大，然后等比缩放另一条边
    CGFloat scaleFactor = smallerSide / self.videoPreScrollView.frame.size.width;
    // 根据缩放因子计算x，y的偏移量
    CGFloat xOffset = self.videoPreScrollView.contentOffset.x * scaleFactor;
    CGFloat yOffset = self.videoPreScrollView.contentOffset.y * scaleFactor;
    
    CGAffineTransform finalTransform = clipVideoTrack.preferredTransform;
    // 如果视频的宽高相同，那么就不用做移动了，因为我们的就是矩形的视频
    if (clipVideoTrack.naturalSize.width == clipVideoTrack.naturalSize.height) {
        xOffset = 0;
        yOffset = 0;
    }
    // 根据视频的仿射变换的矩阵计算x，y的实际偏移量
    CGFloat xTranslate = finalTransform.a * xOffset + finalTransform.c * yOffset;
    CGFloat yTranslate = finalTransform.b * xOffset + finalTransform.d * yOffset;
    // 横屏的话，x方向的偏移量是反的
    if (self.videoPreScrollView.contentSize.width > self.videoPreScrollView.contentSize.height) {
        xTranslate = -xTranslate;
    }
    finalTransform = CGAffineTransformTranslate(finalTransform, xTranslate, yTranslate);
    [transformer setTransform:finalTransform atTime:kCMTimeZero];
    
    // create instruction
    AVMutableVideoCompositionInstruction *instruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    instruction.timeRange = CMTimeRangeMake(kCMTimeZero, CMTimeMakeWithSeconds(60, 30));
//    instruction.timeRange = range;
    videoComposition.instructions = [NSArray arrayWithObject:instruction];
    instruction.layerInstructions = [NSArray arrayWithObject:transformer];
    
    
    /*
     // water Mask
     // logo ImageLayer
     UIImage *logoImage = [UIImage imageNamed:@"logo"];
     CALayer *logoLayer = [CALayer layer];
     logoLayer.contents = (id)logoImage.CGImage;
     logoLayer.frame = CGRectMake(5, 5, 111/2, 56/2);
     logoLayer.opacity = 0.65;
     
     // add ImagerLayer & VideoLayer to ParentLayer
     CGSize videoSize = [asset naturalSize];
     CALayer *parentLayer = [CALayer layer];
     CALayer *videoLayer = [CALayer layer];
     parentLayer.frame = CGRectMake(0, 0, videoSize.width, videoSize.height);
     videoLayer.frame = CGRectMake(0, 0,videoSize.width, videoSize.height);
     [parentLayer addSublayer:videoLayer];
     [parentLayer addSublayer:logoLayer];
     
     //incorporate by animate tool
     AVVideoCompositionCoreAnimationTool *animationTool = [AVVideoCompositionCoreAnimationTool videoCompositionCoreAnimationToolWithPostProcessingAsVideoLayer:videoLayer inLayer:parentLayer];
     videoComposition.animationTool = animationTool;
     */
    
    [self.encoder setVideoComposition:videoComposition];
    
    // call back
    __weak typeof(self) weakSelf = self;
    [self.encoder exportAsynchronouslyWithCompletionHandler:^{
        if (weakSelf.encoder.status == AVAssetExportSessionStatusCompleted) {
            
            NSLog(@"AVAssetExportSessionStatusCompleted");

//            UIImage *videoPreViewImage = [weakSelf getVideoPreViewImageWithFileURL:outputURL];
            // TODO：转码后的视频URL：outputURL，处理后的视频URL；videoPreViewImage 视频预览图
//            dispatch_async(dispatch_get_main_queue(), ^{
//                if ([_delegate respondsToSelector:@selector(onImageEdited:)])
//                {
//                    [_delegate onVideoSelectedWithPath:outputURL firstImg:videoPreViewImage videoOriginHash:self.videoOriginHash];
//                }
//                CGRect rect = CGRectZero;
//                if ([_delegate respondsToSelector:@selector(animateEndRect)])
//                {
//                    rect = [_delegate animateEndRect];
//                }
//                [weakSelf disappearWithAnimationEndRect:rect image:videoPreViewImage];
//            });
            
        }else if(weakSelf.encoder.status == AVAssetExportSessionStatusFailed){
            NSLog(@"AVAssetExportSessionStatusFailed");
        }else if(weakSelf.encoder.status == AVAssetExportSessionStatusExporting){
            NSLog(@"AVAssetExportSessionStatusExporting....");
            
        }else if(weakSelf.encoder.status == AVAssetExportSessionStatusCancelled){
            NSLog(@"AVAssetExportSessionStatusCancelled");
            
        }
    }];
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

- (void)doAnimationWithImage:(UIImage *)image WhenDisappear:(void(^)(void))block
{
    _preView.hidden = YES;
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:_preView.frame];
    imageView.image = image;
    [self.view addSubview:imageView];
    
    UIColor *bgColor = self.view.backgroundColor;
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.35
                          delay:0.0
                        options:UIViewAnimationOptionTransitionNone animations:^{
                            imageView.frame = weakSelf.disRect;
                            weakSelf.view.backgroundColor = UIColorFromRGB(0x8f8f8f);
                        } completion:^(BOOL finished) {
                            if (finished)
                            {
                                weakSelf.view.backgroundColor = bgColor;
                                _preView.hidden = NO;
                                [imageView removeFromSuperview];
                                block();
                            }
                        }];
}

#pragma mark - Outlet
- (IBAction)videoBtnPressed:(id)sender
{
    [self.player play];
}

#pragma mark - Notification
- (void)playItemDidReachEnd:(NSNotification*)notification
{
    [self.player pause];
    [self.player seekToTime:CMTimeMake((self.cropView.videoCropBeginTime)*self.avAsset.duration.timescale, self.avAsset.duration.timescale) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
    
    [self.videoPlayBtn setHidden:NO];
}

#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (((PAVideoHandlerViewController *)object).player != self.player) {
        return;
    }
    if (change[@"old"] == [NSNull null] || change[@"new"] == [NSNull null]) {
        return;
    }
    if ([change[@"old"] integerValue] == 0 && [change[@"new"] integerValue] == 0) {
        return;
    }
    
    if (self.player.rate == 0) {
        [self.videoPlayBtn setHidden:NO];
        
    }else{
        [self.videoPlayBtn setHidden:YES];
        
    }
}

#pragma mark - VideoCropView delegate
- (void)updateVideoPreImage
{
    [self.player pause];

    // TODO: 这个地方需要修改
    [self.player seekToTime:CMTimeMake((self.cropView.videoCropPreCurTime)*self.avAsset.duration.timescale, self.avAsset.duration.timescale) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
    
    NSLog(@"start:%f,end:%f,current:%f,duration:%f",self.cropView.videoCropBeginTime,self.cropView.videoCropEndTime,self.cropView.videoCropPreCurTime,self.cropView.videoCropDurationTime);
    
    [self addTimeObserver];
}

#pragma mark - TimeObserver
- (void)addTimeObserver
{
    if (self.playerBoundaryTimeObserver) {
        [self.player removeTimeObserver:self.playerBoundaryTimeObserver];
    }
    
    if (self.playerPeriodicTimeObserver) {
        [self.player removeTimeObserver:self.playerPeriodicTimeObserver];
    }
    
    __weak typeof(self) weakSelf = self;
    self.playerBoundaryTimeObserver = [self.player addBoundaryTimeObserverForTimes:[NSArray arrayWithObject:[NSValue valueWithCMTime:CMTimeMake(self.cropView.videoCropEndTime*self.avAsset.duration.timescale, self.avAsset.duration.timescale)]] queue:NULL usingBlock:^(void){
        [weakSelf.player seekToTime:CMTimeMake((weakSelf.cropView.videoCropBeginTime)*weakSelf.avAsset.duration.timescale, weakSelf.avAsset.duration.timescale) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
        [weakSelf.player pause];
    }];
    
    self.playerPeriodicTimeObserver = [self.player addPeriodicTimeObserverForInterval:CMTimeMake(0.01*self.avAsset.duration.timescale, self.avAsset.duration.timescale) queue:NULL usingBlock:^(CMTime time){
        [weakSelf updateVideoProgressBar];
    }];
}

- (void)updateVideoProgressBar
{
    CGFloat currentTime = CMTimeGetSeconds([self.player currentTime]);
    CGFloat currentProgress = (currentTime - self.cropView.videoCropBeginTime)/self.cropView.videoCropDurationTime;
    [self.cropView setProgressBar:currentProgress];
}

@end
