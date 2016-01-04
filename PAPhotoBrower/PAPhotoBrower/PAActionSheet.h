//
//  PAActionSheet.h
//  PAPhotoBrower
//
//  Created by 王俊 on 15/11/30.
//  Copyright © 2015年 feiwa. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PAActionSheet;
@protocol PAActionSheetDelegate <NSObject>

@optional
////当buttonIndex为0时执行拍照 1时执行相册
//- (void)PAActionSheet:(PAActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex;
@end

@interface PAActionSheet : UIView
//是否显示预览图片
@property(nonatomic,assign)BOOL isShowPreviewImages;
//设置预览图片数量(默认情况下最多可以预览20张图片或者视频)
@property(nonatomic,assign)NSInteger previewMaxCount;
//设置预览图片最多可选的数量(在不设置的情况下都可选)
@property(nonatomic,assign)NSInteger previewSelectedMaxCount;

@property(nonatomic,weak)id<PAActionSheetDelegate>delegate;
//默认情况下上传保存原图(1的时候为原图 越小压缩的越大)
@property(nonatomic,assign)CGFloat compressImageScale;

//需要设计一个接口  点击第一个按钮选择照片的快捷按钮(返回视频或者照片)



@end
