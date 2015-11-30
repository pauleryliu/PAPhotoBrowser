//
//  PAVideoAssetViewController.m
//  PAPhotoBrower
//
//  Created by paulery on 11/26/15.
//  Copyright © 2015 paulery. All rights reserved.
//

#import "PAVideoAssetViewController.h"
#import "PAVideoHandlerViewController.h"
#import "PAVideoRecorderHelper.h"
#import <CommonCrypto/CommonDigest.h>

#define UIColorFromRGB(rgbValue) \
[UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0x00FF00) >>  8))/255.0 \
blue:((float)((rgbValue & 0x0000FF) >>  0))/255.0 \
alpha:1.0]

@interface PAVideoAssetViewController ()

@property (nonatomic,strong) NSMutableArray *asserts;
@property (nonatomic) CGSize cellSize;
@property (nonatomic) CGFloat cellSpacing;
@property (nonatomic) CGFloat selectionSpacing;

@end

@implementation PAVideoAssetViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.backgroundColor = UIColorFromRGB(0x1a1a1f);
    self.cellSpacing = 5;
    self.selectionSpacing = 3;
    CGFloat cellWidth = (self.view.frame.size.width - self.cellSpacing*3 - self.selectionSpacing*2)/4;
    self.cellSize = CGSizeMake(cellWidth, cellWidth);
    
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"identifier"];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.title = [self.assertGroup valueForProperty:ALAssetsGroupPropertyName];
    
    if (!self.asserts) {
        self.asserts = [[NSMutableArray alloc] init];
    }else{
        [self.asserts removeAllObjects];
    }
    
    ALAssetsGroupEnumerationResultsBlock assetsEnumerationBlock = ^(ALAsset *result, NSUInteger index, BOOL *stop) {
        if (result) {
            // only more than 3 seconds
            if ([[result valueForProperty:ALAssetPropertyDuration] doubleValue] >= 3.0f) {
                [self.asserts addObject:result];
            }
        }
    };
    
    ALAssetsFilter *onlyVideosFilter = [ALAssetsFilter allVideos];
    [self.assertGroup setAssetsFilter:onlyVideosFilter];
    [self.assertGroup enumerateAssetsUsingBlock:assetsEnumerationBlock];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.asserts.count;
}

- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"identifier" forIndexPath:indexPath];
    ALAsset *asset = self.asserts[indexPath.row];
    
    // thumNail
    UIImage *thumbNail = [UIImage imageWithCGImage:[asset thumbnail]];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.cellSize.width, self.cellSize.height)];
    imageView.image = thumbNail;
    
    // maskView
    UIImageView *maskView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.cellSize.width, self.cellSize.height)];
    maskView.image = [UIImage imageNamed:@"video_localSelected_mask"];
    [imageView addSubview:maskView];
    
    // time label
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, self.cellSize.height - 15, self.cellSize.width, 15)];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont systemFontOfSize:10.0f];
    label.text = [PAVideoRecorderHelper convertTime:[[asset valueForProperty:ALAssetPropertyDuration] floatValue]];
    [maskView addSubview:label];
    
    [cell.contentView addSubview:imageView];
    
    return cell;
}

#pragma mark - UICollectionViewDelegate

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
    return UIEdgeInsetsMake(9,self.selectionSpacing,0,self.selectionSpacing);//分别为上、左、下、右
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
    ALAsset *asset = self.asserts[indexPath.row];
    ALAssetRepresentation *defaultRepresentation = [asset defaultRepresentation];
    
    NSData *data;
    NSString *videoOriginHash;
    int videoOrginHashLength = 8096;   // 对本地上传视频取前4kb字节取hash值
    
    if(defaultRepresentation.size < videoOrginHashLength){
        // create a buffer to hold image data
        uint8_t *buffer = (Byte*)malloc(defaultRepresentation.size);
        NSUInteger length = [defaultRepresentation getBytes:buffer fromOffset:0.0  length:8096 error:nil];
        if (length != 0)  {
            // buffer -> NSData object; free buffer afterwards
            data = [[NSData alloc] initWithBytesNoCopy:buffer length:length freeWhenDone:YES];
            videoOriginHash = [self MD5HexDigest:data];
            NSLog(@"HashValue:%@",videoOriginHash);
        }
    }else{
        videoOriginHash = nil;
    }
    
    PAVideoHandlerViewController *vc = [[PAVideoHandlerViewController alloc] initWithNibName:@"VideoHandlerViewController" bundle:[NSBundle mainBundle]];
    vc.title = @"剪辑视频";
    vc.videoDuration = [[[self.asserts objectAtIndex:indexPath.row] valueForProperty:ALAssetPropertyDuration] doubleValue];
    vc.videoInputURL = asset.defaultRepresentation.url;
    vc.videoOriginHash = [self MD5HexDigest:data];
    [self.navigationController pushViewController:vc animated:YES];
}

- (NSString *)MD5HexDigest:(NSData *)input {
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(input.bytes, (int)input.length,result);
    NSMutableString *ret = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH*2];
    for (int i = 0; i<CC_MD5_DIGEST_LENGTH; i++) {
        [ret appendFormat:@"%02x",result[i]];
    }
    return ret;
}

#pragma mark - Rotation
// ios 6 supports
- (NSUInteger)supportedInterfaceOrientations
{
    return (1 << UIInterfaceOrientationPortrait);
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return NO;
}

/*
// Uncomment this method to specify if the specified item should be highlighted during tracking
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}
*/

/*
// Uncomment this method to specify if the specified item should be selected
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
*/

/*
// Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	return NO;
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	
}
*/

@end
