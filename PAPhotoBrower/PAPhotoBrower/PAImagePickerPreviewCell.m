//
//  PAImagePickerPreviewCell.m
//  PAPhotoBrower
//
//  Created by paulery on 11/26/15.
//  Copyright © 2015 paulery. All rights reserved.
//

#import "PAImagePickerPreviewCell.h"
#import <QuartzCore/QuartzCore.h>
#import <ImageIO/ImageIO.h>

#define UISCREEN_WIDTH      [UIScreen mainScreen].bounds.size.width
#define UISCREEN_HEIGHT     [UIScreen mainScreen].bounds.size.height

@interface PAImagePickerPreviewCell ()

@property (nonatomic,strong) UIImageView *thumbNailImageView;
@property (nonatomic,strong)NSTimer *timer;
@end

@implementation PAImagePickerPreviewCell
{
    size_t index;
    size_t count;
    CGImageSourceRef gifRef;
}
//update by garry
- (void)bindData:(ALAsset*)asset
{
    [self stop];
    [self.contentView addSubview:self.thumbNailImageView];
    ALAssetRepresentation *rep = [asset defaultRepresentation];
    if ([self isGifWithFileName:[rep filename]]) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            Byte *imageBuffer = (Byte*)malloc(rep.size);
            NSUInteger bufferSize = [rep getBytes:imageBuffer fromOffset:0.0 length:rep.size error:nil];
            NSData *imageData = [NSData dataWithBytesNoCopy:imageBuffer length:bufferSize freeWhenDone:YES];
            gifRef = CGImageSourceCreateWithData((__bridge CFDataRef)imageData, NULL);
            count = CGImageSourceGetCount(gifRef);
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.timer fire];
            });
        });
    }else{
        CGImageRef ref = [rep fullScreenImage];
        self.thumbNailImageView.image = [UIImage imageWithCGImage:ref];
    }
}
//creat by garry
- (void)play
{
    index ++;
    index = index % count;
    CGImageRef ref = CGImageSourceCreateImageAtIndex(gifRef, index, NULL);
    self.thumbNailImageView.image = [UIImage imageWithCGImage:ref];
    CFRelease(ref);
}
//creat by garry
- (void)stop
{
    if (gifRef) {
        CFRelease(gifRef);
        gifRef = nil;
    }
    if (_timer)
    {
        [_timer invalidate];
        _timer = nil;
    }
}
//creat by garry
- (BOOL)isGifWithFileName:(NSString *)fileName
{
    NSString *extension = [[[fileName componentsSeparatedByString:@"."] lastObject] lowercaseString];
    if ([extension isEqualToString:@"gif"]) {
        return YES;
    }
    return NO;
}
//creat by garry
- (UIImageView *)thumbNailImageView
{
    if (!_thumbNailImageView) {
        _thumbNailImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        self.thumbNailImageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _thumbNailImageView;
}
//creat by garry
- (NSTimer *)timer{
    if (!_timer) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(play) userInfo:nil repeats:YES];
    }
    return _timer;
}
@end
