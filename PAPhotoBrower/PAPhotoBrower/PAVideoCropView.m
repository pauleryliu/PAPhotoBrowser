//
//  PAVideoCropView.m
//  PAPhotoBrower
//
//  Created by paulery on 11/26/15.
//  Copyright © 2015 paulery. All rights reserved.
//

#import "PAVideoCropView.h"
#import "PAVideoCropHanderView.h"

#define UIColorFromRGB(rgbValue) \
[UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0x00FF00) >>  8))/255.0 \
blue:((float)((rgbValue & 0x0000FF) >>  0))/255.0 \
alpha:1.0]

@interface VideoCropView ()

@property (strong,nonatomic) AVAsset* avAsset;
@property (strong,nonatomic) UIScrollView *scrollView;

@property (strong,nonatomic) PAVideoCropHanderView *videoCropHandlerView;
@property (strong,nonatomic) UIImageView *videoCropLeftHandlerImageView;
@property (strong,nonatomic) UIView *videoCropLeftHandlerMaskView;
@property (strong,nonatomic) UIImageView *videoCropRightHandlerImageView;
@property (strong,nonatomic) UIView *videoCropRightHandlerMaskView;

@property (nonatomic) UIPanGestureRecognizer *leftPanGesture;
@property (nonatomic) UIPanGestureRecognizer *rightPanGesture;
@property (nonatomic) UIPanGestureRecognizer *leftMaskViewPanGesture;
@property (nonatomic) UIPanGestureRecognizer *rightMaskViewPanGesture;

@property (nonatomic) CGFloat videoCropLeftProcess;
@property (nonatomic) CGFloat videoCropRightProcess;
@property (nonatomic) CGFloat totalDuration;

@property (nonatomic) CGFloat totalViewCount;
@property (nonatomic) NSInteger numberOfViewsInScrollView;
@property (nonatomic) CGFloat thumbNailWidth;
@property (nonatomic) CGFloat thumbNailHeight;

@end

@implementation VideoCropView

- (id)initWithFrame:(CGRect)frame withVideoURL:(NSURL*)videoURL andVideoDuration:(CGFloat)videoDuration
{
    self = [super initWithFrame:frame];
    
    if (self) {
        self.videoInputURL = videoURL;
        self.videoDuration = videoDuration;
        self.totalDuration = 10.0f;  // self.frame.size.width represent 10 seconds
        self.backgroundColor = [UIColor clearColor];
        
        self.avAsset = [AVAsset assetWithURL:self.videoInputURL];
        int gap = 2;
        self.totalViewCount = self.videoDuration/gap;
        
        // thumb
        self.numberOfViewsInScrollView = 5;
        self.thumbNailWidth = self.frame.size.width/self.numberOfViewsInScrollView;
        self.thumbNailHeight = self.frame.size.width/self.numberOfViewsInScrollView;
        
        // time & precess
        if (self.videoDuration > 10) {
            self.videoCropRightProcess = 1.0;
            self.videoCropEndTime = 10.0f;
        }else{
            self.videoCropEndTime = self.videoDuration;
            self.videoCropRightProcess = self.videoDuration/10.0;
        }
        self.videoCropLeftProcess = 0.0f;
        self.videoCropBeginTime = 0.0f;
        self.videoCropDurationTime = self.videoCropEndTime - self.videoCropBeginTime;
        self.videoCropCurrentTime = self.videoCropBeginTime;
        self.videoCropPreCurTime = self.videoCropEndTime;
        
        // scrollView
        [self creatScrollView];
        
        // thunbNail
        [self creatThumbNail];
        
        // hanler
        [self creatHanler];
        
        // progressBar
        [self creatProgressBar];
        
        if (self.videoDuration < 10) {
            self.scrollView.layer.cornerRadius = 5;
        }
    }
    
    return self;
}
 
- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];

}

- (void)creatScrollView
{
    if (self.videoDuration >= 10) {
        self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.thumbNailHeight)];
    }else{
        self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0,self.videoDuration/10*self.frame.size.width,self.thumbNailHeight)];
    }
    
    self.scrollView.delegate = self;
    self.scrollView.bounces = NO;
    self.scrollView.contentSize = CGSizeMake(self.thumbNailWidth * (self.totalViewCount), self.thumbNailHeight);
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    [self addSubview:self.scrollView];
}

- (void)creatThumbNail
{
    AVAssetImageGenerator* generator = [[AVAssetImageGenerator alloc] initWithAsset:self.avAsset];
    generator.appliesPreferredTrackTransform = YES;
    generator = [[AVAssetImageGenerator alloc] initWithAsset:self.avAsset];
    generator.appliesPreferredTrackTransform = YES;
    generator.maximumSize = CGSizeMake(120, 120);
    
    NSArray* times = [self generateThumbnailTimesForVideo:self.avAsset];
    
    __block NSInteger index = 0;
    [generator generateCGImagesAsynchronouslyForTimes:times
                                    completionHandler:^(CMTime requestedTime,
                                                        CGImageRef image,
                                                        CMTime actualTime,
                                                        AVAssetImageGeneratorResult result,
                                                        NSError* error)
     {
         if (result == AVAssetImageGeneratorSucceeded) {
            
             dispatch_sync(dispatch_get_main_queue(), ^{
                 UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.thumbNailWidth*index, 0, self.thumbNailWidth, self.thumbNailHeight)];
                 imageView.image = [UIImage imageWithCGImage:image];
                 imageView.contentMode = UIViewContentModeScaleAspectFill;
                 [self.scrollView addSubview:imageView];
                 index++;
             });
         }
     }];
}

- (void)creatHanler
{
    // crop handler view
    self.videoCropHandlerView = [[PAVideoCropHanderView alloc] initWithFrame:self.scrollView.frame];
    self.videoCropHandlerView.layer.cornerRadius = 5;
    self.videoCropHandlerView.layer.borderWidth = 1;
    self.videoCropHandlerView.layer.borderColor = UIColorFromRGB(0xffa015).CGColor;
    [self addSubview:self.videoCropHandlerView];
    
    // crop handler view frame kvo
    [self addObserver:self forKeyPath:@"videoCropHandlerView.frame" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    
    // width of handler
    CGFloat handlerScaleFactor = self.videoCropHandlerView.frame.size.height / 60.0f;
    CGFloat widthOfHandler = handlerScaleFactor * 20.0f;
    
    // leftHandler
    self.videoCropLeftHandlerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,widthOfHandler, self.videoCropHandlerView.frame.size.height)];
    self.videoCropLeftHandlerImageView.userInteractionEnabled = YES;
    [self.videoCropLeftHandlerImageView becomeFirstResponder];
    self.videoCropLeftHandlerImageView.image = [UIImage imageNamed:@"video_crop_handle_left"];
    [self.videoCropHandlerView addSubview:self.videoCropLeftHandlerImageView];
    
    self.videoCropLeftHandlerMaskView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, self.videoCropHandlerView.frame.size.height)];
    self.videoCropLeftHandlerMaskView.userInteractionEnabled = YES;
    self.videoCropLeftHandlerMaskView.backgroundColor = [UIColor blackColor];
    self.videoCropLeftHandlerMaskView.alpha = 0.7;
    [self addSubview:self.videoCropLeftHandlerMaskView];
    
    // rightHandler
    self.videoCropRightHandlerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.videoCropHandlerView.frame.size.width - widthOfHandler, 0, widthOfHandler, self.videoCropHandlerView.frame.size.height)];
    self.videoCropRightHandlerImageView.userInteractionEnabled = YES;
    [self.videoCropRightHandlerImageView becomeFirstResponder];
    self.videoCropRightHandlerImageView.image = [UIImage imageNamed:@"video_crop_handle_right"];
    [self.videoCropHandlerView addSubview:self.videoCropRightHandlerImageView];
    
    self.videoCropRightHandlerMaskView = [[UIView alloc] initWithFrame:CGRectMake(self.videoCropHandlerView.frame.size.width, 0, 0, self.videoCropHandlerView.frame.size.height)];
    self.videoCropRightHandlerMaskView.userInteractionEnabled = YES;
    self.videoCropRightHandlerMaskView.backgroundColor = [UIColor blackColor];
    self.videoCropRightHandlerMaskView.alpha = 0.7;
    [self addSubview:self.videoCropRightHandlerMaskView];
    
    // pan gesture
    self.leftPanGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(leftPan:)];
    [self.videoCropRightHandlerImageView addGestureRecognizer:self.leftPanGesture];
    
    self.leftMaskViewPanGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(leftMaskViewPan:)];
    [self.videoCropRightHandlerMaskView addGestureRecognizer:self.leftMaskViewPanGesture];
    
    
    self.rightPanGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(rightPan:)];
    [self.videoCropLeftHandlerImageView addGestureRecognizer:self.rightPanGesture];
    
    
    self.rightMaskViewPanGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(rightMaskViewPan:)];
    [self.videoCropLeftHandlerMaskView addGestureRecognizer:self.rightMaskViewPanGesture];
}

- (void)creatProgressBar
{
    self.videoPlayProgressBar = [[UIView alloc] initWithFrame:CGRectMake(0,1, 2, self.videoCropHandlerView.frame.size.height - 2)];
    self.videoPlayProgressBar.backgroundColor = [UIColor whiteColor];
    [self.videoPlayProgressBar setHidden:YES];
    [self.videoCropHandlerView insertSubview:self.videoPlayProgressBar atIndex:0];
}

- (void)setProgressBar:(CGFloat)progress
{
    CGFloat minProgress = self.videoCropLeftHandlerImageView.frame.size.width*0.5/self.videoCropHandlerView.frame.size.width;
    CGFloat maxProgress =(self.videoCropHandlerView.frame.size.width - self.videoCropRightHandlerImageView.frame.size.width*0.5 - self.videoPlayProgressBar.frame.size.width)/self.videoCropHandlerView.frame.size.width;
    
    if (progress >= minProgress && progress <= maxProgress) {
        [self.videoPlayProgressBar setHidden:NO];
        self.videoPlayProgressBar.frame = CGRectMake(self.videoCropHandlerView.frame.size.width*progress, 0, 2, self.videoCropHandlerView.frame.size.height);
        self.videoCropCurrentTime = (self.videoCropDurationTime - self.videoCropBeginTime) * ((progress - minProgress) / (maxProgress - minProgress));
    }else{
        [self.videoPlayProgressBar setHidden:YES];
    }
}

#pragma mark - CMTimes
- (NSArray*)generateThumbnailTimesForVideo:(AVAsset*)asset
{
    CGFloat duration = CMTimeGetSeconds(asset.duration);
    int gap = 2;
    NSMutableArray *array = [[NSMutableArray alloc] init];
    
    for (int index = 0; index < duration/gap; index++) {
        CMTime time = CMTimeMake((index*gap)*asset.duration.timescale, asset.duration.timescale);
        NSValue *value = [NSValue valueWithCMTime:time];
        [array addObject:value];
    }
    
    self.totalViewCount = array.count;
//    NSLog(@"timeArray:%@",array);
    return array;
}


#pragma mark - panGesture
- (void)leftPan:(UIPanGestureRecognizer*)sender
{
    CGPoint translation = [sender translationInView:self.videoCropRightHandlerImageView];
    CGFloat rightTobe = (self.videoCropHandlerView.frame.origin.x + self.videoCropHandlerView.frame.size.width + translation.x)/self.frame.size.width;
    CGFloat translationX = translation.x;
    
    if (self.videoDuration >= 10) {
        if (rightTobe - self.videoCropLeftProcess <= 0.3) {
            self.videoCropRightProcess = self.videoCropLeftProcess + 0.3;
            translationX = - (self.videoCropRightHandlerImageView.frame.origin.x - 0.3*self.frame.size.width + self.videoCropRightHandlerImageView.frame.size.width);
        }else if(rightTobe > 1.0){
            self.videoCropRightProcess = 1.0;
            translationX = self.frame.size.width - (self.videoCropHandlerView.frame.origin.x + self.videoCropHandlerView.frame.size.width);
        }else{
            self.videoCropRightProcess = rightTobe;
            
        }
    }else{
        if(rightTobe > self.videoDuration/10){
            self.videoCropRightProcess = self.videoDuration/10;
            translationX = self.frame.size.width*(self.videoDuration/10.0) - self.videoCropRightHandlerImageView.frame.size.width - self.videoCropRightHandlerImageView.frame.origin.x - self.videoCropHandlerView.frame.origin.x;
        }else if (rightTobe - self.videoCropLeftProcess <= 0.3) {
            self.videoCropRightProcess = self.videoCropLeftProcess + 0.3;
            translationX = - (self.videoCropRightHandlerImageView.frame.origin.x - 0.3*self.frame.size.width + self.videoCropRightHandlerImageView.frame.size.width);
        }else{
            self.videoCropRightProcess = rightTobe;
            
        }
    }
    
    sender.view.center = CGPointMake(sender.view.center.x + translationX,sender.view.center.y);
    [sender setTranslation:CGPointZero inView:self.videoCropRightHandlerImageView];
    
    // time
    self.videoCropEndTime = (self.scrollView.contentOffset.x/self.frame.size.width + self.videoCropRightProcess)*self.totalDuration;
    self.videoCropDurationTime = self.videoCropEndTime - self.videoCropBeginTime;
    self.videoCropCurrentTime = self.videoCropBeginTime;
    self.videoCropPreCurTime = self.videoCropEndTime;
    
    // update CropHandlerView
    self.videoCropHandlerView.frame = CGRectMake(self.videoCropHandlerView.frame.origin.x, self.videoCropHandlerView.frame.origin.y, self.videoCropHandlerView.frame.size.width + translationX, self.videoCropHandlerView.frame.size.height);
    
    // MaskView frame
    self.videoCropRightHandlerMaskView.frame = CGRectMake(self.videoCropHandlerView.frame.origin.x + self.videoCropHandlerView.frame.size.width, 0, self.scrollView.frame.size.width - (self.videoCropHandlerView.frame.origin.x + self.videoCropHandlerView.frame.size.width), self.videoCropRightHandlerMaskView.frame.size.height);
}

- (void)rightPan:(UIPanGestureRecognizer*)sender
{
    CGPoint translation = [sender translationInView:self.videoCropLeftHandlerImageView];
    CGFloat leftTobe = (self.videoCropHandlerView.frame.origin.x + translation.x)/self.frame.size.width;
    CGFloat translationX = translation.x;
    if (self.videoCropRightProcess - leftTobe <= 0.3) {
        self.videoCropLeftProcess = self.videoCropRightProcess - 0.3;
        translationX = self.videoCropRightHandlerImageView.frame.origin.x + self.videoCropRightHandlerImageView.frame.size.width  - 0.3*self.frame.size.width - self.videoCropLeftHandlerImageView.frame.origin.x;
    }else if(leftTobe < 0.0){
        self.videoCropLeftProcess = 0.0;
        translationX = - self.videoCropHandlerView.frame.origin.x;
    }else{
        self.videoCropLeftProcess = leftTobe;
    }
    sender.view.center = CGPointMake(sender.view.center.x + translation.x,sender.view.center.y);
    [sender setTranslation:CGPointZero inView:self.videoCropLeftHandlerImageView];

    
    // time
    self.videoCropBeginTime = (self.scrollView.contentOffset.x/self.frame.size.width + self.videoCropLeftProcess)*self.totalDuration;
    self.videoCropDurationTime = self.videoCropEndTime - self.videoCropBeginTime;
    self.videoCropPreCurTime = self.videoCropBeginTime;
    self.videoCropCurrentTime = self.videoCropBeginTime;
    
    // update CropHandlerView
    self.videoCropHandlerView.frame = CGRectMake(self.videoCropHandlerView.frame.origin.x + translationX, self.videoCropHandlerView.frame.origin.y, self.videoCropHandlerView.frame.size.width - translationX, self.videoCropHandlerView.frame.size.height);
    
    // MaskView frame
    self.videoCropLeftHandlerMaskView.frame = CGRectMake(0,0,self.videoCropHandlerView.frame.origin.x, self.videoCropLeftHandlerMaskView.frame.size.height);
}

- (void)leftMaskViewPan:(UIPanGestureRecognizer*)sender
{
    CGPoint translation = [sender translationInView:self.videoCropRightHandlerMaskView];
    CGFloat rightTobe = (self.videoCropHandlerView.frame.origin.x + self.videoCropHandlerView.frame.size.width + translation.x)/self.frame.size.width;
    CGFloat translationX = translation.x;
    
    if (self.videoDuration >= 10) {
        if (rightTobe - self.videoCropLeftProcess <= 0.3) {
            self.videoCropRightProcess = self.videoCropLeftProcess + 0.3;
            translationX = - (self.videoCropRightHandlerImageView.frame.origin.x - 0.3*self.frame.size.width + self.videoCropRightHandlerImageView.frame.size.width);
        }else if(rightTobe > 1.0){
            self.videoCropRightProcess = 1.0;
            translationX = self.frame.size.width - (self.videoCropHandlerView.frame.origin.x + self.videoCropHandlerView.frame.size.width);
        }else{
            self.videoCropRightProcess = rightTobe;
            
        }
    }else{
        if(rightTobe > self.videoDuration/10){
            self.videoCropRightProcess = self.videoDuration/10;
            translationX = self.frame.size.width*(self.videoDuration/10.0) - self.videoCropRightHandlerImageView.frame.size.width - self.videoCropRightHandlerImageView.frame.origin.x - self.videoCropHandlerView.frame.origin.x;
        }else if (rightTobe - self.videoCropLeftProcess <= 0.3) {
            self.videoCropRightProcess = self.videoCropLeftProcess + 0.3;
            translationX = - (self.videoCropRightHandlerImageView.frame.origin.x - 0.3*self.frame.size.width + self.videoCropRightHandlerImageView.frame.size.width);
        }else{
            self.videoCropRightProcess = rightTobe;
            
        }
    }
    
    sender.view.center = CGPointMake(sender.view.center.x + translationX,sender.view.center.y);
    [sender setTranslation:CGPointZero inView:self.videoCropRightHandlerMaskView];
    
    // time
    self.videoCropEndTime = (self.scrollView.contentOffset.x/self.frame.size.width + self.videoCropRightProcess)*self.totalDuration;
    self.videoCropDurationTime = self.videoCropEndTime - self.videoCropBeginTime;
    self.videoCropPreCurTime = self.videoCropEndTime;
    self.videoCropCurrentTime = self.videoCropBeginTime;
    
    // update CropHandlerView
    self.videoCropHandlerView.frame = CGRectMake(self.videoCropHandlerView.frame.origin.x, self.videoCropHandlerView.frame.origin.y, self.videoCropHandlerView.frame.size.width + translationX, self.videoCropHandlerView.frame.size.height);
    
    // MaskView frame
    self.videoCropRightHandlerMaskView.frame = CGRectMake(self.videoCropHandlerView.frame.origin.x + self.videoCropHandlerView.frame.size.width, 0, self.scrollView.frame.size.width - (self.videoCropHandlerView.frame.origin.x + self.videoCropHandlerView.frame.size.width), self.videoCropRightHandlerMaskView.frame.size.height);
}

- (void)rightMaskViewPan:(UIPanGestureRecognizer*)sender
{
    CGPoint translation = [sender translationInView:self.videoCropLeftHandlerMaskView];
    CGFloat leftTobe = (self.videoCropHandlerView.frame.origin.x + translation.x)/self.frame.size.width;
    CGFloat translationX = translation.x;
    if (self.videoCropRightProcess - leftTobe <= 0.3) {
        self.videoCropLeftProcess = self.videoCropRightProcess - 0.3;
        translationX = self.videoCropRightHandlerImageView.frame.origin.x + self.videoCropRightHandlerImageView.frame.size.width  - 0.3*self.frame.size.width - self.videoCropLeftHandlerImageView.frame.origin.x;
    }else if(leftTobe < 0.0){
        self.videoCropLeftProcess = 0.0;
        translationX = - self.videoCropHandlerView.frame.origin.x;
    }else{
        self.videoCropLeftProcess = leftTobe;
    }
    sender.view.center = CGPointMake(sender.view.center.x + translation.x,sender.view.center.y);
    [sender setTranslation:CGPointZero inView:self.videoCropLeftHandlerMaskView];
    
    
    // time
    self.videoCropBeginTime = (self.scrollView.contentOffset.x/self.frame.size.width + self.videoCropLeftProcess)*self.totalDuration;
    self.videoCropDurationTime = self.videoCropEndTime - self.videoCropBeginTime;
    self.videoCropPreCurTime = self.videoCropBeginTime;
    self.videoCropCurrentTime = self.videoCropBeginTime;
    
    // update CropHandlerView
    self.videoCropHandlerView.frame = CGRectMake(self.videoCropHandlerView.frame.origin.x + translationX, self.videoCropHandlerView.frame.origin.y, self.videoCropHandlerView.frame.size.width - translationX, self.videoCropHandlerView.frame.size.height);
    
    // MaskView frame
    self.videoCropLeftHandlerMaskView.frame = CGRectMake(0,0,self.videoCropHandlerView.frame.origin.x, self.videoCropLeftHandlerMaskView.frame.size.height);
}

#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (((VideoCropView *)object).videoCropHandlerView != self.videoCropHandlerView) {
        return;
    }
    
    // width of handler
    CGFloat handlerScaleFactor = self.videoCropHandlerView.frame.size.height / 60.0f;
    CGFloat widthOfHandler = handlerScaleFactor * 20.0f;
    
    // 修正由于滑动手势修改背景frame导致的子view's frame的位置问题
    self.videoCropLeftHandlerImageView.frame = CGRectMake(0,0,widthOfHandler, self.videoCropHandlerView.frame.size.height);
    self.videoCropRightHandlerImageView.frame = CGRectMake(self.videoCropHandlerView.frame.size.width - widthOfHandler, 0, widthOfHandler, self.videoCropHandlerView.frame.size.height);
    
    // update VideoPreImage
    if ([_delegate respondsToSelector:@selector(updateVideoPreImage)]) {
        [self.videoPlayProgressBar setHidden:YES];
        [_delegate updateVideoPreImage];
    }
}

#pragma mark - UIScrollView delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    // update VideoPreImage
    self.videoCropBeginTime = (self.scrollView.contentOffset.x/self.frame.size.width + self.videoCropLeftProcess)*self.totalDuration;
    self.videoCropEndTime = (self.scrollView.contentOffset.x/self.frame.size.width + self.videoCropRightProcess)*self.totalDuration;
    self.videoCropDurationTime = self.videoCropEndTime - self.videoCropBeginTime;
    self.videoCropCurrentTime = self.videoCropBeginTime;
    if ([_delegate respondsToSelector:@selector(updateVideoPreImage)]) {
        [_delegate updateVideoPreImage];
    }
}

- (void)dealloc
{
    [self removeObserver:self forKeyPath:@"videoCropHandlerView.frame"];
}

@end
