//
//  PAVideoGroupViewController.h
//  PAPhotoBrower
//
//  Created by paulery on 11/26/15.
//  Copyright © 2015 paulery. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface PAVideoGroupViewController : UIViewController<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, weak) id postDelegate;

@end
