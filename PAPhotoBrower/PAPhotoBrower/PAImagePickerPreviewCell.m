//
//  PAImagePickerPreviewCell.m
//  PAPhotoBrower
//
//  Created by paulery on 11/26/15.
//  Copyright © 2015 paulery. All rights reserved.
//

#import "PAImagePickerPreviewCell.h"

#define UISCREEN_WIDTH      [UIScreen mainScreen].bounds.size.width
#define UISCREEN_HEIGHT     [UIScreen mainScreen].bounds.size.height

@interface PAImagePickerPreviewCell ()

@property (nonatomic,strong) UIImageView *thumbNailImageView;

@end

@implementation PAImagePickerPreviewCell

- (void)bindData:(ALAsset*)asset
{
    // thumNail
    if (!self.thumbNailImageView) {
        self.thumbNailImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        self.thumbNailImageView.userInteractionEnabled = YES;
        [self.contentView addSubview:self.thumbNailImageView];
        
        UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchView:)];
        [self.thumbNailImageView addGestureRecognizer:pinchGesture];
        
        UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panView:)];
        [panGesture setMinimumNumberOfTouches:1];
        [panGesture setMaximumNumberOfTouches:1];
        [self.thumbNailImageView addGestureRecognizer:panGesture];
        
        UIRotationGestureRecognizer *rotationGestureRecognizer = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(rotateView:)];
        [self.thumbNailImageView addGestureRecognizer:rotationGestureRecognizer];
        
        UITapGestureRecognizer *doubleTapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(doubleTap:)];
        [doubleTapGestureRecognizer setNumberOfTapsRequired:2];
        [self.thumbNailImageView addGestureRecognizer:doubleTapGestureRecognizer];
    }
    CGImageRef ref = [[asset defaultRepresentation] fullScreenImage];
    UIImage *img = [[UIImage alloc]initWithCGImage:ref];
    self.thumbNailImageView.image = img;
    self.thumbNailImageView.contentMode = UIViewContentModeScaleAspectFit;
}

- (void)doubleTap: (UITapGestureRecognizer *)gesture {
    
    
}

// Rotate
- (void) rotateView:(UIRotationGestureRecognizer *)rotationGestureRecognizer {
    
    UIView *view = rotationGestureRecognizer.view;
    if (rotationGestureRecognizer.state == UIGestureRecognizerStateBegan || rotationGestureRecognizer.state == UIGestureRecognizerStateChanged) {
        view.transform = CGAffineTransformRotate(view.transform, rotationGestureRecognizer.rotation);
        [rotationGestureRecognizer setRotation:0];
    }
}

// Scale
- (void) pinchView:(UIPinchGestureRecognizer *)pinchGestureRecognizer {
    
    UIView *view = self.thumbNailImageView;
    if (pinchGestureRecognizer.state == UIGestureRecognizerStateBegan || pinchGestureRecognizer.state == UIGestureRecognizerStateChanged) {
        view.transform = CGAffineTransformScale(view.transform, pinchGestureRecognizer.scale, pinchGestureRecognizer.scale);
        pinchGestureRecognizer.scale = 1;
    }
}

// TransLate
- (void) panView:(UIPanGestureRecognizer *)panGestureRecognizer {
    
    UIView *view = self.thumbNailImageView;
    if (panGestureRecognizer.state == UIGestureRecognizerStateBegan || panGestureRecognizer.state == UIGestureRecognizerStateChanged) {
        CGPoint translation = [panGestureRecognizer translationInView:view.superview];
        [view setCenter:(CGPoint){view.center.x + translation.x, view.center.y + translation.y}];
        [panGestureRecognizer setTranslation:CGPointZero inView:view.superview];
    }
}

@end
