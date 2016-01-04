//
//  PAVideoCropHanderView.m
//  PAPhotoBrower
//
//  Created by paulery on 11/26/15.
//  Copyright © 2015 paulery. All rights reserved.
//

#import "PAVideoCropHanderView.h"

@implementation PAVideoCropHanderView

- (id)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView *hitView = [super hitTest:point withEvent:event];
    if (hitView == self){
        return nil;
    }else {
        return hitView;
    }
}

@end
