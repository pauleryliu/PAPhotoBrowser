//
//  PAVideoHandlerViewController.h
//  PAPhotoBrower
//
//  Created by paulery on 11/26/15.
//  Copyright © 2015 paulery. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "PAVideoHandlerViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "PAVideoCropView.h"

// videoEncodeLoadingImageView animation config
#define ENCODELOADINGIMAGEVIEW_ANIMATION_DURATION 1

@interface PAVideoHandlerViewController : UIViewController<PAVideoCropViewDelegate>

@property (nonatomic, strong) NSURL *videoInputURL;
@property (nonatomic) CGFloat videoDuration;
@property (nonatomic, strong) NSString *videoOriginHash;

@end
