//
//  PAActionSheet.m
//  PAPhotoBrower
//
//  Created by 王俊 on 15/11/30.
//  Copyright © 2015年 feiwa. All rights reserved.
//

#import "PAActionSheet.h"
#import <AssetsLibrary/AssetsLibrary.h>
#define RGBA(R,G,B,A)  [UIColor colorWithRed:R/255.0 green:G/255.0 blue:B/255.0 alpha:A]
#define s_width [UIScreen mainScreen].bounds.size.width
#define s_height [UIScreen mainScreen].bounds.size.height

#define PREVIEWHEIGHT 150
#define BUTTONHEIGHT 45
#define SPACE 2

@interface PAActionSheet ()<UICollectionViewDataSource,UICollectionViewDelegate>

@property (nonatomic, strong) ALAssetsLibrary *assetsLibrary;

@property(nonatomic,strong)UICollectionView *collectionView;

@property(nonatomic,strong)NSArray *fetchedPreviewImagesArray;

//这里设计3个数组 分别为
//1.预览的图片和视频的数组
//2.预览的图片的数组
//3.预览的视频的数组
@property(nonatomic,strong)NSArray *previewAllArray;
@property(nonatomic,strong)NSArray *previewPhotoView;
@property(nonatomic,strong)NSArray *previewVideoView;

@end

@implementation PAActionSheet


-(instancetype)init{

   self = [super init];
    self.backgroundColor = RGBA(10, 10, 10, 0.3);
    self.frame = [UIScreen mainScreen].bounds;
    UIView *containView = [[UIView alloc]init];
    containView.tag = 600;
    
    if (self.isShowPreviewImages) {
        containView.frame =CGRectMake(0, s_height, s_width, PREVIEWHEIGHT + 3*BUTTONHEIGHT + SPACE *2);
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc]init];
        [flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
        self.collectionView=[[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, s_width ,PREVIEWHEIGHT) collectionViewLayout:flowLayout];
        self.collectionView.dataSource=self;
        self.collectionView.delegate=self;
        [self.collectionView setBackgroundColor:[UIColor whiteColor]];
        [containView addSubview:self.collectionView];
        [self creatImageTypeSelectedButtonInView:containView];
    }else{
        containView.frame =CGRectMake(0, s_height, s_width, PREVIEWHEIGHT + 3*BUTTONHEIGHT + SPACE *2);
        [self creatImageTypeSelectedButtonInView:containView];
    }
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapView)];
    [self addGestureRecognizer:tap];
    [self addSubview:containView];
    return self;
}


-(void)ShowInView:(UIView *)view{
    
    UIView *containView = (UIView *)[self viewWithTag:600];
    [UIView animateWithDuration:0.5 animations:^{
        if (self.isShowPreviewImages) {
           containView.frame =CGRectMake(0, s_height - PREVIEWHEIGHT - BUTTONHEIGHT *3 - SPACE *2, s_width, PREVIEWHEIGHT + 3*BUTTONHEIGHT + SPACE *2);
        }else{
            containView.frame =CGRectMake(0, s_height - BUTTONHEIGHT *3 - SPACE *2, s_width, PREVIEWHEIGHT + 3*BUTTONHEIGHT + SPACE *2);
        }
    }];
    
    [view insertSubview:self aboveSubview:view];
}

-(void)creatImageTypeSelectedButtonInView:(UIView *)view{

    NSArray *buttonTitleArr = @[@"拍照",@"相册",@"取消"];
    NSInteger previewHeight = 0;
    if (self.isShowPreviewImages) {
        previewHeight = PREVIEWHEIGHT + SPACE *2;
    }
    for (int i = 0; i < 3; i++) {
        UILabel *separateLine = [[UILabel alloc]initWithFrame:CGRectMake(0, previewHeight + BUTTONHEIGHT * i + 1, s_width, 1)];
        separateLine.text = @"";
        separateLine.backgroundColor = [UIColor lightGrayColor];
        UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(0, previewHeight + i * BUTTONHEIGHT - 1, s_width, BUTTONHEIGHT - 1)];
        [button setTitle:buttonTitleArr[i] forState:UIControlStateNormal];
        [button setBackgroundColor:[UIColor whiteColor]];
        button.tag = 555 + i;
        [button addTarget:self action:@selector(ImageTypeSelecteButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:button];
    }
}

-(void)ImageTypeSelecteButtonClicked:(UIButton *)sender{

//    if (_delegate && [_delegate respondsToSelector:@selector(PAActionSheet:clickedButtonAtIndex:)]) {
//        [_delegate PAActionSheet:self clickedButtonAtIndex:sender.tag - 555];
//    }
}

-(void)tapView{
    self.hidden = YES;
    [self removeFromSuperview];
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return [self.fetchedPreviewImagesArray count];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    

    return nil;
}

//返回的每一个item的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(0,0);
}

//定义每个UICollectionView 的 margin
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(2,2,2,2);
}

//UICollectionView被选中时调用的方法
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    //点击被选中的图片可以选择被选中的图片
    
    //点击未被选中的图片可以展示未被选中的图片
    
    //点击图片要做类型区分（不同类型不能同时选择）
    
    
}




@end
