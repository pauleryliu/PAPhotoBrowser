//
//  PAImagePickerPreviewViewController.h
//  PAPhotoBrower
//
//  Created by paulery on 11/26/15.
//  Copyright © 2015 paulery. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PAImagePickerController.h"

@interface PAImagePickerPreviewViewController : UICollectionViewController

@property (nonatomic) NSInteger maxNumberOfPhotos;      // 最多可选
@property (nonatomic,strong) NSMutableArray *asserts;
@property (strong,nonatomic) NSMutableArray *selectedAsserts;
@property (strong,nonatomic) NSIndexPath *jumpIndexPath;
@property (nonatomic,strong) NSString *doneBtnName;
@property (nonatomic,strong) PAImagePickerController  *pickerVC;
@property (nonatomic) BOOL isSupportEditWhenSelectSinglePhoto;
@property (weak,nonatomic) id<PAImagePickerControllerDelegate> delegate;

@end
