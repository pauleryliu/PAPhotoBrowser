//
//  PAVideoRecorderHelper.m
//  PAPhotoBrower
//
//  Created by paulery on 11/29/15.
//  Copyright © 2015 paulery. All rights reserved.
//

#import "PAVideoRecorderHelper.h"

@implementation PAVideoRecorderHelper

+ (CGFloat)getFileSize:(NSURL*)fileURL
{
    NSNumber *fileSizeBytes;
    NSError *error;
    NSURL *samplePath = [[NSURL alloc] initWithString:[fileURL absoluteString]];
    [samplePath getResourceValue:&fileSizeBytes forKey:NSURLFileSizeKey error:&error];
    if (error) {
        NSLog(@"error:%@",error);
        return 0;
    }else{
        CGFloat fileSize = [fileSizeBytes floatValue]/(1024);  // convert to KB
        return fileSize;
    }
}

+ (NSString*)getFilePathByTime
{
    NSString *path = NSTemporaryDirectory();
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyyMMddHHmmss";
    NSString *nowTimeStr = [formatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:0]];
    NSString *fileName = [[path stringByAppendingPathComponent:nowTimeStr] stringByAppendingString:@".mp4"];
    return fileName;
}

+ (NSString*)getMovFilePathByTime
{
    NSString *path = NSTemporaryDirectory();
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyyMMddHHmmss";
    NSString *nowTimeStr = [formatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:0]];
    NSString *fileName = [[path stringByAppendingPathComponent:nowTimeStr] stringByAppendingString:@".MOV"];
    return fileName;
}

+ (NSTimeInterval)getVideoDuration:(NSURL*)fileURL
{
    NSURL *url = fileURL;
    AVURLAsset *assert = [[AVURLAsset alloc] initWithURL:url options:nil];
    NSTimeInterval durationInSeconds = 0.0f;
    if (assert) {
        durationInSeconds = CMTimeGetSeconds(assert.duration);
    }
    return durationInSeconds;
}

+ (BOOL)saveToAppDocumentWithFileURL:(NSURL*)fileURL
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isSaveToAppDocumentSuccess;
    if ([fileManager fileExistsAtPath:[fileURL absoluteString]]) {
        NSData *data = [NSData dataWithContentsOfFile:[fileURL absoluteString]];
        isSaveToAppDocumentSuccess = [data writeToURL:fileURL atomically:YES];
    }else{
        isSaveToAppDocumentSuccess = NO;
        NSLog(@"file is not exist:%@",fileURL);
    }
    return isSaveToAppDocumentSuccess;
}

//+ (UIImage*)getVideoPreViewImageWithFileURL:(NSURL*)fileURL
//{
//    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:fileURL options:nil];
//    AVAssetImageGenerator *gen = [[AVAssetImageGenerator alloc] initWithAsset:asset];
//    gen.appliesPreferredTrackTransform = YES;
//    CMTime time = CMTimeMakeWithSeconds(0.0, 30);
//    NSError *error = nil;
//    CMTime actualTime;
//    CGImageRef image = [gen copyCGImageAtTime:time actualTime:&actualTime error:&error];
//    UIImage *img = [[UIImage alloc] initWithCGImage:image];
//    return img;
//}

+ (BOOL)onlyShowForTheFirstTimeForKey:(NSString*)key
{
    if (![[NSUserDefaults standardUserDefaults] boolForKey:key]) {
        NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
        [userDefault setBool:YES forKey:key];
        [userDefault synchronize];
        return YES;
    }else{
        return NO;
    }
    return NO;
}

+ (NSString *)convertTime:(CGFloat)second{
    NSDate *d = [NSDate dateWithTimeIntervalSince1970:second];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    if (second/3600 >= 1) {
        [formatter setDateFormat:@"HH:mm:ss"];
    } else {
        [formatter setDateFormat:@"mm:ss"];
    }
    NSString *showtimeNew = [formatter stringFromDate:d];
    return showtimeNew;
}


@end
