//
//  QBImageLoadingProgressBar.h
//  QiuBai
//
//  Created by noark on 14-4-16.
//  Copyright (c) 2014年 Less Everything. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TKProgressBarView.h"

@interface QBImageLoadingProgressBar : TKProgressBarView

- (id)initWithFrame:(CGRect)frame andBackgroundColor:(UIColor*)backgroundColor;

- (void)starPrepareAnimation;

- (void)stopPrepareAnimation;

@end
