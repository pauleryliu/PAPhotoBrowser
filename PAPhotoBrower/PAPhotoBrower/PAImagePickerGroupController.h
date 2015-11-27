//
//  PAImagePickerGroupController.h
//  PAPhotoBrower
//
//  Created by paulery on 11/26/15.
//  Copyright © 2015 paulery. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PAImagePickerController.h"

@interface PAImagePickerGroupController : UIViewController

@property (nonatomic) NSInteger maxNumberOfPhotos;
@property (weak,nonatomic) id<PAImagePickerControllerDelegate> delegate;

@end
