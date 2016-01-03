//
//  PAImagePickerController.m
//  PAPhotoBrower
//
//  Created by paulery on 11/26/15.
//  Copyright © 2015 paulery. All rights reserved.
//

#import "PAImagePickerController.h"
#import "PAImagePickerGroupController.h"
#import "PAImagePickerCell.h"
#import "PAImagePickerTakePhotoCell.h"
#import "PAImagePickerPreviewViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "PAPhotoBrowserHelper.h"
#import <POP.h>

#define UIColorFromRGB(rgbValue) \
[UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0x00FF00) >>  8))/255.0 \
blue:((float)((rgbValue & 0x0000FF) >>  0))/255.0 \
alpha:1.0]

#define BottomBarHeight 45

@interface PAImagePickerController ()<UICollectionViewDelegate,UICollectionViewDataSource,UIImagePickerControllerDelegate,PAImagePickerCellDelegate>

@property (nonatomic, strong) UICollectionView *photosCollectionView;
@property (nonatomic, strong) ALAssetsLibrary *assetsLibrary;
@property (nonatomic, strong) NSMutableArray *groups;
@property (nonatomic,strong) NSMutableArray *asserts;

@property (nonatomic) CGSize cellSize;
@property (nonatomic) CGFloat cellSpacing;
@property (nonatomic) CGFloat selectionSpacing;
@property (strong,nonatomic) UIButton *bottomBarLeftBtn;
@property (strong,nonatomic) UIButton *bottomBarRightBtn;
@property (strong,nonatomic) NSMutableArray *selectedAsserts;
@property (strong,nonatomic) UIView *bottomToolBarView;

@end

@implementation PAImagePickerController

static NSString * const reuseIdentifier = @"Cell";

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // init
    if (!self.title) {
        self.title = @"Photo Stream";
    }
    if (!_doneButtonTitle) {
        _doneButtonTitle = @"Send";
    }
    
    if (_maxNumberOfPhotos == 0) {
        _maxNumberOfPhotos = 1;
    }
    if (_isSupportRecorder == NO) {
        _isSupportRecorder = YES;
    }
    if (_paMediaType == 0) {
        _paMediaType = PAMediaTypePhotoAndVideo;
    }
    
    [self setNavigationBar];
    [self setBottomToolBar];
    
    if (self.assertGroup) {
        [self setupAsserts];    // from album
    } else {
        [self setupAssert];     // from outside
    }
    
    if (!self.selectedAsserts) {
        self.selectedAsserts = [[NSMutableArray alloc] init];
    }
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.backgroundColor = UIColorFromRGB(0x1a1a1f);
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.showsVerticalScrollIndicator = NO;
    self.cellSpacing = 5;
    self.selectionSpacing = 3;
    NSInteger cellNumberInSingleLine = 4;
    if ([UIScreen mainScreen].bounds.size.width < 375) {
        cellNumberInSingleLine = 3;
    }
    CGFloat cellWidth = (self.view.frame.size.width - self.cellSpacing*3 - self.selectionSpacing*2)/cellNumberInSingleLine;
    self.cellSize = CGSizeMake(cellWidth, cellWidth);
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(userDidTakeScreenshot:)
                                                 name:UIApplicationUserDidTakeScreenshotNotification object:nil];
    
    [self.collectionView registerClass:[PAImagePickerCell class] forCellWithReuseIdentifier:@"identifier"];
    [self.collectionView registerClass:[PAImagePickerTakePhotoCell class] forCellWithReuseIdentifier:@"identifierT"];
}

#pragma mark -- Properties
// set max number asset you can select(Default is one)
- (void)setpa_MaxNumberSelected:(NSInteger)number
{
    _maxNumberOfPhotos = number;
}

// set done button title (Default is "send")
- (void)setpa_DoneButtonTitle:(NSString*)title
{
    _doneButtonTitle = title;
}

// set whether support take photo and video recorder(Default is YES)
- (void)setpa_isSupportRecorer:(BOOL)isSupport
{
    _isSupportRecorder = isSupport;
}

// set media type(Detail is PAMediaTypePhotoAndVideo)
- (void)setpa_MediaType:(PAMediaType)paMediaType
{
    _paMediaType = paMediaType;
}

#pragma mark -- Private Method
- (void)setNavigationBar
{
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : UIColorFromRGB(0x8f8f95)}];
    self.navigationController.navigationBar.barTintColor = UIColorFromRGB(0x1a1a1f);
    
    // Back btn
    UIButton *leftBarBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    leftBarBtn.titleLabel.font = [UIFont systemFontOfSize:17.0f];
    [leftBarBtn setTitle:@"Album" forState:UIControlStateNormal];
    [leftBarBtn setTitleColor:UIColorFromRGB(0xffa015) forState:UIControlStateNormal];
    [leftBarBtn sizeToFit];
    [leftBarBtn addTarget:self action:@selector(leftBarBtnPressed) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftBarItem = [[UIBarButtonItem alloc] initWithCustomView:leftBarBtn];
    self.navigationItem.leftBarButtonItem = leftBarItem;
    
    // Cancel btn
    UIButton *rightBarBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    rightBarBtn.titleLabel.font = [UIFont systemFontOfSize:17.0f];
    [rightBarBtn setTitle:@"Cancel" forState:UIControlStateNormal];
    [rightBarBtn setTitleColor:UIColorFromRGB(0xffa015) forState:UIControlStateNormal];
    [rightBarBtn sizeToFit];
    [rightBarBtn addTarget:self action:@selector(rightBarBtnPressed) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightBarItem = [[UIBarButtonItem alloc] initWithCustomView:rightBarBtn];
    self.navigationItem.rightBarButtonItem = rightBarItem;
}

- (void)leftBarBtnPressed
{
    // Back to Ablum
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)rightBarBtnPressed
{
    [self dismissViewControllerAnimated:YES completion:^(void){}];
}

- (void)setBottomToolBar
{
    self.bottomToolBarView = [[UIView alloc] initWithFrame:CGRectMake(0, self.collectionView.frame.size.height - BottomBarHeight, [UIScreen mainScreen].bounds.size.width, BottomBarHeight)];
    self.bottomToolBarView.backgroundColor = [UIColor blackColor];
    self.bottomToolBarView.alpha = 0.8;
    [self.view addSubview:self.bottomToolBarView];

    self.bottomBarLeftBtn = [[UIButton alloc] initWithFrame:CGRectMake(0,0, 100, self.bottomToolBarView.frame.size.height)];
    [self.bottomBarLeftBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.bottomBarLeftBtn.titleLabel.font = [UIFont systemFontOfSize:15.0f];
    self.bottomBarLeftBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.bottomBarLeftBtn addTarget:self action:@selector(bottomBarLeftBtnPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.bottomBarLeftBtn setTitle:@"preview" forState:UIControlStateNormal];
    [self.bottomToolBarView addSubview:self.bottomBarLeftBtn];

    self.bottomBarRightBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.bottomToolBarView.frame.size.width - 80,0, 60, self.bottomToolBarView.frame.size.height)];
    [self.bottomBarRightBtn setTitleColor:UIColorFromRGB(0xffa015) forState:UIControlStateNormal];
    self.bottomBarRightBtn.titleLabel.font = [UIFont systemFontOfSize:15.0f];
    self.bottomBarRightBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.bottomBarRightBtn addTarget:self action:@selector(bottomBarRightBtnPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.bottomBarRightBtn setTitle:self.doneButtonTitle forState:UIControlStateNormal];
    [self.bottomToolBarView addSubview:self.bottomBarRightBtn];
    
    if (self.selectedAsserts.count > 0) {
        [self.bottomBarLeftBtn setHidden:NO];
    } else {
        [self.bottomBarLeftBtn setHidden:YES];
    }
}

- (void)bottomBarLeftBtnPressed
{
    // PreView
    UICollectionViewFlowLayout *layout= [[UICollectionViewFlowLayout alloc]init];
    [layout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    PAImagePickerPreviewViewController *preViewController = [[PAImagePickerPreviewViewController alloc] initWithCollectionViewLayout:layout];
    preViewController.hidesBottomBarWhenPushed = YES;
    preViewController.title = @"PreView";
    preViewController.maxNumberOfPhotos = self.maxNumberOfPhotos;
    preViewController.selectedAsserts = self.selectedAsserts;
    preViewController.asserts = [self.selectedAsserts mutableCopy];
    preViewController.delegate = self.delegate;
    preViewController.pickerVC = self;
    preViewController.doneBtnName = self.doneButtonTitle;
    [self.navigationController pushViewController:preViewController animated:YES];
}

- (void)bottomBarRightBtnPressed
{
    // Done Button Pressed
    if (!self.selectedAsserts || self.selectedAsserts.count == 0) {
        [self dismissViewControllerAnimated:YES completion:^{
        }];
        return;
    }
    
    if (self.selectedAsserts.count == 1) {
        // just one photo
        ALAsset *assert = [self.selectedAsserts firstObject];
        CGImageRef  ref = [[assert defaultRepresentation] fullScreenImage];
        UIImage *img = [[UIImage alloc]initWithCGImage:ref];
        if ([_delegate respondsToSelector:@selector(PAImagePickerControllerSinglePhotoDidFinishEdit:)]) {
            [_delegate PAImagePickerControllerSinglePhotoDidFinishEdit:img];
        }
        
        return;
    } else {
        // over one photo
        if ([_delegate respondsToSelector:@selector(PAImagePickerControllerMultiPhotosDidFinishPickingMediaInfo:)]) {
            [_delegate PAImagePickerControllerMultiPhotosDidFinishPickingMediaInfo:self.selectedAsserts];
        }
        
        [self dismissViewControllerAnimated:YES completion:^{
        }];
    }
}

- (void)setupAssert
{
    // Init
    if (self.assetsLibrary == nil) {
        self.assetsLibrary = [[ALAssetsLibrary alloc] init];
    }
    if (self.groups == nil) {
        self.groups = [[NSMutableArray alloc] init];
    }else{
        [self.groups removeAllObjects];
    }
    
    // In case enumerateGroupsWithTypes fails
    ALAssetsLibraryAccessFailureBlock failureBlock = ^(NSError *error){
        // failure view controller
    };
    
    // Add group
    ALAssetsFilter *assetsfilter;
    if (self.paMediaType == PAMediaTypePhoto) {
        assetsfilter = [ALAssetsFilter  allPhotos];
    } else if (self.paMediaType == PAMediaTypeVideo) {
        assetsfilter = [ALAssetsFilter allVideos];
    } else {
        assetsfilter = [ALAssetsFilter allAssets];
    }
    ALAssetsLibraryGroupsEnumerationResultsBlock groupBlock = ^(ALAssetsGroup *group,BOOL *stop){
        [group setAssetsFilter:assetsfilter];
        if ([group numberOfAssets] > 0) {
            [self.groups addObject:group];
        }
        else
        {
            self.assertGroup = [self.groups lastObject];
            [self setupAsserts];
        }
    };
    
    // Enumerate
    NSInteger groupTypes = ALAssetsGroupSavedPhotos | ALAssetsGroupAlbum | ALAssetsGroupEvent | ALAssetsGroupFaces;
    [self.assetsLibrary enumerateGroupsWithTypes:groupTypes usingBlock:groupBlock failureBlock:failureBlock];
    
}

- (void)setupAsserts
{
    if (!self.asserts) {
        self.asserts = [[NSMutableArray alloc] init];
    }else{
        [self.asserts removeAllObjects];
    }
    
    ALAssetsGroupEnumerationResultsBlock assetsEnumerationBlock = ^(ALAsset *result, NSUInteger index, BOOL *stop) {
        if (result) {
            [self.asserts addObject:result];
            
        }
        
        if (stop) {
            [self.collectionView reloadData];
        }
    };
    
    ALAssetsFilter *assetsfilter;
    
    if (self.paMediaType == PAMediaTypePhoto) {
        assetsfilter = [ALAssetsFilter  allPhotos];
    } else if (self.paMediaType == PAMediaTypeVideo) {
        assetsfilter = [ALAssetsFilter allVideos];
    } else {
        assetsfilter = [ALAssetsFilter allAssets];
    }
    
    [self.assertGroup setAssetsFilter:assetsfilter];
    [self.assertGroup enumerateAssetsWithOptions:NSEnumerationReverse usingBlock:assetsEnumerationBlock];
}

#pragma mark <UICollectionViewDataSource>
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (self.isSupportRecorder) {
        return self.asserts.count + 1;
    } else {
        return self.asserts.count;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.isSupportRecorder && indexPath.row == 0) {
        // take photo        
        PAImagePickerTakePhotoCell *cell = (PAImagePickerTakePhotoCell*)[collectionView dequeueReusableCellWithReuseIdentifier:@"identifierT" forIndexPath:indexPath];
        return cell;
    }
    
    NSInteger assertIndex = 0;
    if (self.isSupportRecorder) {
        assertIndex = indexPath.row - 1;
    } else {
        assertIndex = indexPath.row;
    }
    
    PAImagePickerCell *cell = (PAImagePickerCell*)[collectionView dequeueReusableCellWithReuseIdentifier:@"identifier" forIndexPath:indexPath];
    [cell bindData:self.asserts[assertIndex]];
    cell.delegate = self;

    BOOL isAssetExist = NO;
    for (ALAsset *selectAsset in self.selectedAsserts) {
        if ([[selectAsset valueForProperty:ALAssetPropertyAssetURL] isEqual:[self.asserts[assertIndex] valueForProperty:ALAssetPropertyAssetURL]]) {
            isAssetExist = YES;
        }
    }
    
    if (isAssetExist) {
        [cell.selectedTagBtn setSelected:YES];
    } else {
        [cell.selectedTagBtn setSelected:NO];
    }

    return cell;
}

#pragma mark -- UICollectionViewDelegate
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return self.cellSpacing;
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return self.cellSpacing;
}

-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(9,self.selectionSpacing,BottomBarHeight,self.selectionSpacing);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return self.cellSize;
}

-(BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.isSupportRecorder && indexPath.row == 0) {
        
        if (self.selectedAsserts.count == self.maxNumberOfPhotos) {
            NSString *tip = [NSString stringWithFormat:@"you can choose just %ld number of photos",(long)self.maxNumberOfPhotos];
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:tip delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
            [alertView show];
            return;
        } else {
            // take photo
            [self onTakePictureFromSource:UIImagePickerControllerSourceTypeCamera];
            return;
        }
    } else {
        // preview
        UICollectionViewFlowLayout *layout= [[UICollectionViewFlowLayout alloc]init];
        [layout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
        PAImagePickerPreviewViewController *preViewController = [[PAImagePickerPreviewViewController alloc] initWithCollectionViewLayout:layout];
        preViewController.hidesBottomBarWhenPushed = YES;
        preViewController.title = @"PreView";
        preViewController.maxNumberOfPhotos = self.maxNumberOfPhotos;
        preViewController.selectedAsserts = self.selectedAsserts;
        preViewController.asserts = self.asserts;
        preViewController.jumpIndexPath = [NSIndexPath indexPathForRow:indexPath.row - 1 inSection:0];
        preViewController.delegate = self.delegate;
        preViewController.pickerVC = self;
        preViewController.doneBtnName = self.doneButtonTitle;
        [self.navigationController pushViewController:preViewController animated:YES];
    }
}

- (void)onTakePictureFromSource:(UIImagePickerControllerSourceType)type
{
    [self onTakePhotos:type];
}

- (void)onTakePhotos:(UIImagePickerControllerSourceType)type
{
    PAVideoRecorderVC *videoRecorderVC = [[PAVideoRecorderVC alloc] initWithNibName:@"PAVideoRecorderVC" bundle:[NSBundle mainBundle]];
    videoRecorderVC.paMediaType = PAMediaTypePhotoAndVideo;
    [self presentViewController:videoRecorderVC animated:YES completion:^{
    }];
}

#pragma mark -- Cell Delegate
- (void)selectedAsset:(ALAsset*)asset cell:(PAImagePickerCell*)cell;
{
    if (self.selectedAsserts.count == self.maxNumberOfPhotos && (!cell.selectedTagBtn.isSelected)) {
        NSString *tip = [NSString stringWithFormat:@"you can choose just %ld number of photos",(long)(long)self.maxNumberOfPhotos];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:tip delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
        [alertView show];
        return;
    }

    BOOL isAssetExist = NO;
    ALAsset *assetNeedRemove;
    for (ALAsset *selectAsset in self.selectedAsserts) {
        if ([[selectAsset valueForProperty:ALAssetPropertyAssetURL] isEqual:[asset valueForProperty:ALAssetPropertyAssetURL]]) {
            isAssetExist = YES;
            assetNeedRemove = selectAsset;
            [self.selectedAsserts removeObject:selectAsset];
            break;
        }
    }
    
    if (assetNeedRemove) {
        [self.selectedAsserts removeObject:assetNeedRemove];
    }
    
    if (isAssetExist) {
        
        [cell.selectedTagBtn setSelected:NO];
    } else {
        [self.selectedAsserts addObject:asset];
        [cell.selectedTagBtn setSelected:YES];
        
        POPSpringAnimation *sizeAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerScaleXY];
        sizeAnimation.fromValue = [NSValue valueWithCGSize:CGSizeMake(0.6, 0.6)];
        sizeAnimation.toValue = [NSValue valueWithCGSize:CGSizeMake(1,1)];
        sizeAnimation.springSpeed = 20.f;
        sizeAnimation.springBounciness = 20.0f;
        [cell.selectedTagBtn.layer pop_addAnimation:sizeAnimation forKey:@"paulery"];
    }

    if (self.selectedAsserts.count > 0) {
        [self.bottomBarLeftBtn setHidden:NO];
    } else {
        [self.bottomBarLeftBtn setHidden:YES];
    }
}

#pragma mark -- Notification
- (void)userDidTakeScreenshot:(NSNotification *)notification
{
    [self setupAssert];
    [self.collectionView reloadData];
}

@end
