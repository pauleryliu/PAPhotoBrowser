//
//  PAVideoRecorderHelper.h
//  PAPhotoBrower
//
//  Created by paulery on 11/26/15.
//  Copyright © 2015 paulery. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <QuartzCore/QuartzCore.h>

/**
 *  用途：视频功能工具类
 */

@interface PAVideoRecorderHelper : NSObject

// videoRecorder
+ (CGFloat)getFileSize:(NSURL*)fileURL;
+ (NSString*)getFilePathByTime;
+ (NSString*)getMovFilePathByTime;
+ (NSTimeInterval)getVideoDuration:(NSURL*)fileURL;
+ (BOOL)saveToAppDocumentWithFileURL:(NSURL*)fileURL;
+ (UIImage*)getVideoPreViewImageWithFileURL:(NSURL*)fileURL;
+ (BOOL)onlyShowForTheFirstTimeForKey:(NSString*)key;

// videoHandle
+ (NSString *)convertTime:(CGFloat)second;

    
@end
