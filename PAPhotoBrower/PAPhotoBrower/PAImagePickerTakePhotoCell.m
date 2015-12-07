//
//  PAImagePickerTakePhotoCell.m
//  PAPhotoBrower
//
//  Created by paulery on 11/26/15.
//  Copyright © 2015 paulery. All rights reserved.
//

#import "PAImagePickerTakePhotoCell.h"

#define UIColorFromRGB(rgbValue) \
[UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0x00FF00) >>  8))/255.0 \
blue:((float)((rgbValue & 0x0000FF) >>  0))/255.0 \
alpha:1.0]

@interface PAImagePickerTakePhotoCell()

@property (nonatomic,strong) UIImageView *takePhotoImageView;

@end

@implementation PAImagePickerTakePhotoCell

- (void)layoutSubviews
{
    self.backgroundColor = UIColorFromRGB(0x444444);
    if (!self.takePhotoImageView) {
        NSInteger width = 23;
        NSInteger height = 23;
        self.takePhotoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.contentView.frame.size.width / 2 - width / 2, self.contentView.frame.size.height / 2 - height / 2, width, height)];
        self.takePhotoImageView.image = [UIImage imageNamed:@"photo_localSelected_camera"];
        [self.contentView addSubview:self.takePhotoImageView];
    }
}

@end
