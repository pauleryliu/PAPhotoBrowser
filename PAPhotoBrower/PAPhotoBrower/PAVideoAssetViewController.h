//
//  PAVideoAssetViewController.h
//  QiuBai
//
//  Created by 小飞 刘 on 15/1/22.
//  Copyright (c) 2015年 Less Everything. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface PAVideoAssetViewController : UICollectionViewController<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>

@property (nonatomic,strong) ALAssetsGroup *assertGroup;
@property (nonatomic, weak) id postDelegate;

@end
