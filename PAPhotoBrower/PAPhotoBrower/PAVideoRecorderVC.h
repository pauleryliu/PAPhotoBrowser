//
//  PAVideoRecorderVC.h
//  PAPhotoBrower
//
//  Created by paulery on 11/26/15.
//  Copyright © 2015 paulery. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PAVideoRecorder.h"

/**
 *  用途：视频拍摄界面
 */

// recorder
#define MIN_VIDEO_DUR 3
#define MAX_VIDEO_DUR 9.9
// recorder btns animation config
#define DURATION 0.1666
#define OFFSETX_OF_INTERVAL_1 40
#define OFFSETX_OF_INTERVAL_2 30
#define SCALE_OF_INTERVAL_1 1.4
#define SCALE_OF_INTERVAL_2 1
// videoEncodeLoadingImageView animation config
#define ENCODELOADINGIMAGEVIEW_ANIMATION_DURATION 1
// videoRecorderShine
#define VIDEORECORDERSHINE_DURATION 1

@interface PAVideoRecorderVC : UIViewController<PAVideoRecorderDelegate>

typedef enum {
    PAMediaTypePhotoAndVideo = 0,   // Default
    PAMediaTypePhoto = 1,
    PAMediaTypeVideo = 2,
} PAMediaType;

@property (nonatomic,copy) void (^recordVCDismssCallback)(void);
@property (nonatomic,assign) PAMediaType paMediaType;
@property (nonatomic,assign) BOOL isSupportVideoCrop;

@end
