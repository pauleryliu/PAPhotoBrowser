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

@required
- (void)PAImagePickerControllerMultiPhotosDidFinishPickingMediaInfo:(NSMutableArray*)info;
- (void)PAImagePickerControllerSinglePhotoDidFinishEdit:(UIImage*)image;

@end

@interface PAImagePickerController : UICollectionViewController

@property (nonatomic,assign) PAMediaType paMediaType;
@property (nonatomic,assign) BOOL isSupportRecorder;
@property (weak,nonatomic) id<PAImagePickerControllerDelegate> delegate;
@property (nonatomic,strong) ALAssetsGroup *assertGroup;
@property (nonatomic) BOOL isSupportEditWhenSelectSinglePhoto;
@property (nonatomic) NSInteger maxNumberOfPhotos;      // 最多可选
@property (nonatomic,strong) NSString *doneBtnName;

@end
