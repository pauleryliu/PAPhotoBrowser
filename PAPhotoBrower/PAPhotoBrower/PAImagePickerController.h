//
//  PAImagePickerController.h
//  PAPhotoBrower
//
//  Created by paulery on 11/26/15.
//  Copyright © 2015 paulery. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "PAVideoRecorderVC.h"

@protocol PAImagePickerControllerDelegate <NSObject>

@optional
- (void)PAImagePickerControllerMultiPhotosDidFinishPickingMediaInfo:(NSMutableArray*)info;
- (void)PAImagePickerControllerSinglePhotoDidFinishEdit:(UIImage*)image;

@end

@interface PAImagePickerController : UICollectionViewController

@property (nonatomic,assign) PAMediaType paMediaType;
@property (nonatomic,assign) BOOL isSupportRecorder;
@property (weak,nonatomic) id<PAImagePickerControllerDelegate> delegate;
@property (nonatomic,strong) ALAssetsGroup *assertGroup;
@property (nonatomic) NSInteger maxNumberOfPhotos;
@property (nonatomic,strong) NSString *doneButtonTitle;

// set max number asset you can select(Default is one)
- (void)setpa_MaxNumberSelected:(NSInteger)number;

// set done button title(Default is "send")
- (void)setpa_DoneButtonTitle:(NSString*)title;

// set whether support take photo and video recorder(Default is YES)
- (void)setpa_isSupportRecorer:(BOOL)isSupport;

// set media type (Detail is PAMediaTypePhotoAndVideo)
- (void)setpa_MediaType:(PAMediaType)paMediaType;

@end
