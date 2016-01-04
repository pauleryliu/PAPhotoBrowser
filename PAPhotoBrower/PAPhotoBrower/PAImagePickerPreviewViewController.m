//
//  PAImagePickerPreviewViewController.m
//  PAPhotoBrower
//
//  Created by paulery on 11/26/15.
//  Copyright © 2015 paulery. All rights reserved.
//

#import "PAImagePickerPreviewViewController.h"
#import "PAImagePickerPreviewCell.h"

#define UIColorFromRGB(rgbValue) \
[UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0x00FF00) >>  8))/255.0 \
blue:((float)((rgbValue & 0x0000FF) >>  0))/255.0 \
alpha:1.0]

#define BottomBarHeight 45

@interface PAImagePickerPreviewViewController ()

@property (strong,nonatomic) UIButton *bottomBarRightBtn;
@property (strong,nonatomic) UILabel *bottomBarSelectedLabel;

@property (nonatomic,strong) UIButton *originSendBtn;

@property (strong,nonatomic) UIView *bottomToolBarView;
@property (strong,nonatomic) ALAsset *currentAsset;
@property (nonatomic) CGSize cellSize;
@property (nonatomic) CGFloat cellSpacing;
@property (nonatomic) CGFloat selectionSpacing;
@property (nonatomic,strong) UIButton *navLeftBtn;
@property (nonatomic,strong) UIButton *rightBarBtn;

@property (nonatomic, strong) NSString * originSizeStr;

@end

@implementation PAImagePickerPreviewViewController

static NSString * const reuseIdentifier = @"Cell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setNavigationBar];
    [self setBottomToolBar];
    
    if (!self.doneBtnName) {
        self.doneBtnName = @"完成";
    }
    
    if (!self.selectedAsserts) {
        self.selectedAsserts = [[NSMutableArray alloc] init];
    }
    self.cellSpacing = 0;
    self.selectionSpacing = 0;
    NSInteger cellNumberInSingleLine = 1;
    CGFloat cellWidth = (self.view.frame.size.width - self.cellSpacing*3 - self.selectionSpacing*2)/cellNumberInSingleLine;
    self.cellSize = CGSizeMake(cellWidth, cellWidth);
    
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.showsVerticalScrollIndicator = NO;
    
    if (self.jumpIndexPath.row >= 0) {
        
        [self.collectionView scrollToItemAtIndexPath:self.jumpIndexPath atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
    }
    self.collectionView.pagingEnabled = YES;
    [self.collectionView registerClass:[PAImagePickerPreviewCell class] forCellWithReuseIdentifier:@"identifier"];
    
    self.currentAsset = self.asserts[0];
    
    if (self.currentAsset) {
        
        CGImageRef ref = [[self.currentAsset  defaultRepresentation]fullResolutionImage];
        UIImage *img = [[UIImage alloc]initWithCGImage:ref];
        NSData * data = UIImageJPEGRepresentation(img, 1.0);
        
        [self.originSendBtn setTitle:[NSString stringWithFormat:@"原图: %.2fM", data.length / (1000 * 1.0 * 1000 * 1.0)] forState:UIControlStateNormal];
    }
}

#pragma mark -- Private Method
- (void)setNavigationBar
{
    //    if (MyDevice().isIOS7AndAbove)
    //    {
    self.navigationController.navigationBar.barTintColor = UIColorFromRGB(0x1a1a1f);
    //    }
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : UIColorFromRGB(0x8f8f95)}];
    
    // select btn
    self.rightBarBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.rightBarBtn setImage:[UIImage imageNamed:@"photo_localUnselected_tag"] forState:UIControlStateNormal];
    [self.rightBarBtn setImage:[UIImage imageNamed:@"photo_localSelected_tag"] forState:UIControlStateSelected];
    [self.rightBarBtn setTitleColor:UIColorFromRGB(0xffa015) forState:UIControlStateNormal];
    [self.rightBarBtn sizeToFit];
    [self.rightBarBtn addTarget:self action:@selector(rightBarBtnPressed) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightBarItem = [[UIBarButtonItem alloc] initWithCustomView:self.rightBarBtn];
    self.navigationItem.rightBarButtonItem = rightBarItem;
    
    UIButton *btn = [self setLeftBarItem:@"icon_back" accessibilityHint:@"点两下返回" accesssibilityLabel:@"返回"];
    [btn addTarget:self action:@selector(popVCwithAnimation) forControlEvents:UIControlEventTouchUpInside];
}

- (UIButton *)setLeftBarItem:(NSString *)imageName accessibilityHint:(NSString *)hint accesssibilityLabel:(NSString *)label
{
    UIImage *image = [UIImage imageNamed:imageName];
    //    UIImage *imageHighlight = [UIHelper image:image withAlpha:PA_BARBUTTON_HIGHLIGHT_ALPHA];
    
    UIImage *imageHighlight;
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:image forState:UIControlStateNormal];
    [button setImage:imageHighlight forState:UIControlStateHighlighted];
    [button setImage:imageHighlight forState:UIControlStateSelected];
    [button setShowsTouchWhenHighlighted:NO];
    [button setAdjustsImageWhenHighlighted:NO];
    button.frame= CGRectMake(0.0, 0.0, 48, image.size.height);
    button.imageEdgeInsets = UIEdgeInsetsMake(0, -42, 0, 0);
    //    if (!MyDevice().isIOS7AndAbove) {
    //        button.imageEdgeInsets = UIEdgeInsetsMake(0, -18, 0, 0);
    //    }
    UIBarButtonItem *forward = [[UIBarButtonItem alloc] initWithCustomView:button];
    forward.accessibilityHint = hint;
    forward.accessibilityLabel = label;
    self.navigationItem.leftBarButtonItem= forward;
    self.navLeftBtn = button;
    return button;
}

- (void)popVCwithAnimation
{
    [self.pickerVC.collectionView reloadData];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)setBottomToolBar
{
    self.bottomToolBarView = [[UIView alloc] initWithFrame:CGRectMake(0, self.collectionView.frame.size.height - BottomBarHeight, [UIScreen mainScreen].bounds.size.width, BottomBarHeight)];
    self.bottomToolBarView.backgroundColor = [UIColor blackColor];
    self.bottomToolBarView.alpha = 0.8;
    [self.view addSubview:self.bottomToolBarView];
    
    self.bottomBarRightBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.bottomToolBarView.frame.size.width - 50,0, 30, self.bottomToolBarView.frame.size.height)];
    [self.bottomBarRightBtn setTitleColor:UIColorFromRGB(0xffa015) forState:UIControlStateNormal];
    
    self.bottomBarRightBtn.titleLabel.font = [UIFont systemFontOfSize:15.0f];
    self.bottomBarRightBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.bottomBarRightBtn addTarget:self action:@selector(bottomBarRightBtnPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.bottomBarRightBtn setTitle:self.doneBtnName forState:UIControlStateNormal];
    [self.bottomToolBarView addSubview:self.bottomBarRightBtn];
    
    self.bottomBarSelectedLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.bottomToolBarView.frame.size.width - 78,self.bottomToolBarView.frame.size.height / 2 - 20 / 2, 20, 20)];
    self.bottomBarSelectedLabel.textColor = [UIColor whiteColor];
    self.bottomBarSelectedLabel.backgroundColor = UIColorFromRGB(0xffa015);
    self.bottomBarSelectedLabel.font = [UIFont systemFontOfSize:13.0f];
    self.bottomBarSelectedLabel.clipsToBounds = YES;
    self.bottomBarSelectedLabel.layer.cornerRadius = self.bottomBarSelectedLabel.frame.size.width / 2;
    self.bottomBarSelectedLabel.text = [NSString stringWithFormat:@"%ld",(long)self.selectedAsserts.count];
    self.bottomBarSelectedLabel.textAlignment = NSTextAlignmentCenter;
    [self.bottomToolBarView addSubview:self.bottomBarSelectedLabel];
    
    
    //! @author Dylan - 2015-1-4
    
    self.originSendBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.originSendBtn.frame = CGRectMake(10, self.bottomToolBarView.frame.size.height / 2 - 20 / 2, 90, 20);
    [self.originSendBtn setImage:[UIImage imageNamed:@"photo_localUnselected_tag"] forState:UIControlStateNormal];
    [self.originSendBtn setImage:[UIImage imageNamed:@"photo_localSelected_tag"] forState:UIControlStateSelected];
    [self.originSendBtn setTitleColor:UIColorFromRGB(0xffa015) forState:UIControlStateNormal];
    [self.originSendBtn setTitle:@"原图 0.0M" forState:UIControlStateNormal];
    self.originSendBtn.titleLabel.font = [UIFont systemFontOfSize:12.];
    self.originSendBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 0);
    [self.originSendBtn addTarget:self action:@selector(originSendButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [self.bottomToolBarView addSubview:self.originSendBtn];
    
    if (self.selectedAsserts.count > 0) {
        [self.bottomBarSelectedLabel setHidden:NO];
    } else {
        [self.bottomBarSelectedLabel setHidden:YES];
    }
}

- (void)originSendButtonAction {
    
    if ([self.originSendBtn isSelected]) {
        
        [self.originSendBtn setSelected:NO];
        
        // 缩略图
        
        CGImageRef ref = [self.currentAsset thumbnail];
        UIImage *img = [[UIImage alloc]initWithCGImage:ref];
        
    } else {
        
        [self.originSendBtn setSelected:YES];
        
        // 原图
        
        CGImageRef ref = [[self.currentAsset  defaultRepresentation]fullResolutionImage];
        
        UIImage *img = [[UIImage alloc]initWithCGImage:ref];
        NSData * data = UIImageJPEGRepresentation(img, 1.0);
    }
    
    [UIView animateWithDuration:.1 animations:^{
        
        self.originSendBtn.transform = CGAffineTransformMakeScale(1.1, 1.1);
    } completion:^(BOOL finished) {
        
        self.originSendBtn.transform = CGAffineTransformIdentity;
    }];
}

- (void)rightBarBtnPressed
{
    if (self.selectedAsserts.count >= self.maxNumberOfPhotos && ![self.rightBarBtn isSelected]) {
        // 超过范围
        //        NSString *tip = [NSString stringWithFormat:@"最多只能选取%ld张图片哦",self.maxNumberOfPhotos];
        //        PostMsg(tip);
        return;
    }
    
    if ([self.rightBarBtn isSelected]) {
        [self.rightBarBtn setSelected:NO];
        
        ALAsset *assetNeedRemove;
        for (ALAsset *selectAsset in self.selectedAsserts) {
            if ([[selectAsset valueForProperty:ALAssetPropertyAssetURL] isEqual:[self.currentAsset valueForProperty:ALAssetPropertyAssetURL]]) {
                assetNeedRemove = selectAsset;
            }
        }
        if (assetNeedRemove) {
            [self.selectedAsserts removeObject:assetNeedRemove];
        }
        
    } else {
        [self.rightBarBtn setSelected:YES];
        [self.selectedAsserts addObject:self.currentAsset];
    }
    
    if (self.selectedAsserts.count > 0) {
        self.bottomBarSelectedLabel.text = [NSString stringWithFormat:@"%ld",(long)self.selectedAsserts.count];
        [self.bottomBarSelectedLabel setHidden:NO];
        
        //        POPSpringAnimation *sizeAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerScaleXY];
        //        sizeAnimation.fromValue = [NSValue valueWithCGSize:CGSizeMake(0.6, 0.6)];
        //        sizeAnimation.toValue = [NSValue valueWithCGSize:CGSizeMake(1,1)];
        //        sizeAnimation.springSpeed = 20.f;
        //        sizeAnimation.springBounciness = 20.0f;
        //        [self.bottomBarSelectedLabel.layer pop_addAnimation:sizeAnimation forKey:@"paulery"];
    } else {
        [self.bottomBarSelectedLabel setHidden:YES];
    }
}

- (void)bottomBarRightBtnPressed
{
    // Done Btn Pressed
    if (!self.selectedAsserts || self.selectedAsserts.count == 0) {
        // 没有选择图片自动添加当前预览图片
        [self.selectedAsserts addObject:self.currentAsset];
    }
    
    if (self.selectedAsserts.count == 1 && self.isSupportEditWhenSelectSinglePhoto) {
        // 单张图片
        ALAsset *assert = [self.selectedAsserts firstObject];
        CGImageRef  ref = [[assert defaultRepresentation] fullScreenImage];
        UIImage *img = [[UIImage alloc]initWithCGImage:ref];
        return;
    } else {
        // 单张图片(不支持单张编辑)或多张图片直接添加
        if ([_delegate respondsToSelector:@selector(PAImagePickerControllerMultiPhotosDidFinishPickingMediaInfo:)]) {
            [_delegate PAImagePickerControllerMultiPhotosDidFinishPickingMediaInfo:self.selectedAsserts];
        }
        
        [self dismissViewControllerAnimated:YES completion:^{
        }];
    }
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.asserts.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    self.currentAsset = self.asserts[indexPath.row];
    PAImagePickerPreviewCell *cell = (PAImagePickerPreviewCell*)[collectionView dequeueReusableCellWithReuseIdentifier:@"identifier" forIndexPath:indexPath];
    [cell bindData:self.asserts[indexPath.row]];
    
    BOOL isAssetExist = NO;
    for (ALAsset *asset in self.selectedAsserts) {
        if ([[asset valueForProperty:ALAssetPropertyAssetURL] isEqual:[self.currentAsset valueForProperty:ALAssetPropertyAssetURL]]) {
            isAssetExist = YES;
        }
    }
    
    if (isAssetExist) {
        [self.rightBarBtn setSelected:YES];
    } else {
        [self.rightBarBtn setSelected:NO];
    }
    
    return cell;
}

#pragma mark <UICollectionViewDelegate>

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
}

-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(-64,0,0,0);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(self.collectionView.frame.size.width, self.collectionView.frame.size.width);
}

-(BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.bottomToolBarView.isHidden) {
        [self.bottomToolBarView setHidden:NO];
        self.navigationController.navigationBar.alpha = 1.0;
        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
        
    } else {
        [self.bottomToolBarView setHidden:YES];
        self.navigationController.navigationBar.alpha = 0.0;
        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    NSInteger index = scrollView.contentOffset.x / [UIScreen mainScreen].bounds.size.width;
    
    self.currentAsset = self.asserts[index];
    
    if (self.currentAsset) {
        
        //  获取缩略图：
        
        //        CGImageRef ref = [self.currentAsset thumbnail];
        //        
        //        UIImage *img = [[UIImage alloc]initWithCGImage:ref];
        
        // 获取高清相片：
        
        CGImageRef ref = [[self.currentAsset  defaultRepresentation]fullResolutionImage];
        UIImage *img = [[UIImage alloc]initWithCGImage:ref];
        NSData * data = UIImageJPEGRepresentation(img, 1.0);
        
        [self.originSendBtn setTitle:[NSString stringWithFormat:@"原图: %.2fM", data.length / (1000 * 1.0 * 1000 * 1.0)] forState:UIControlStateNormal];
    }
}

@end
