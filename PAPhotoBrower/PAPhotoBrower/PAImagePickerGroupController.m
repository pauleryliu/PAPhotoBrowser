//
//  PAImagePickerGroupController.m
//  PAPhotoBrower
//
//  Created by paulery on 11/26/15.
//  Copyright © 2015 paulery. All rights reserved.
//

#import "PAImagePickerGroupController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "PAImagePickerController.h"

#define UIColorFromRGB(rgbValue) \
[UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0x00FF00) >>  8))/255.0 \
blue:((float)((rgbValue & 0x0000FF) >>  0))/255.0 \
alpha:1.0]

@interface PAImagePickerGroupController ()<UITableViewDelegate,UITableViewDataSource>

@property(nonatomic,strong) UITableView *tableView;
@property (nonatomic, strong) ALAssetsLibrary *assetsLibrary;
@property (nonatomic, strong) NSMutableArray *groups;

@end

@implementation PAImagePickerGroupController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"本地照片";
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : UIColorFromRGB(0x8f8f95)}];

    [self setupAssert];
    [self setNavigationBar];
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds
                                                  style:UITableViewStylePlain];
    self.tableView.backgroundColor = UIColorFromRGB(0x1a1a1f);
    self.tableView.separatorColor = UIColorFromRGB(0x313136);
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableFooterView = [[UIView alloc] init];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.tableView];
    self.tableView.contentInset = UIEdgeInsetsMake(0, -15, 0, 0);
    self.tableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, -15);
}

#pragma mark - Private Method
- (void)setNavigationBar
{
    // cancel btn
    UIButton *rightBarBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    rightBarBtn.titleLabel.font = [UIFont systemFontOfSize:17.0f];
    [rightBarBtn setTitle:@"取消" forState:UIControlStateNormal];
    [rightBarBtn setTitleColor:UIColorFromRGB(0xffa015) forState:UIControlStateNormal];
    [rightBarBtn sizeToFit];
    [rightBarBtn addTarget:self action:@selector(rightBarBtnPressed) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightBarBtnItem = [[UIBarButtonItem alloc] initWithCustomView:rightBarBtn];
    self.navigationItem.rightBarButtonItem = rightBarBtnItem;
}

- (void)rightBarBtnPressed
{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)setupAssert
{
    // init
    if (self.assetsLibrary == nil) {
        self.assetsLibrary = [[ALAssetsLibrary alloc] init];
    }
    if (self.groups == nil) {
        self.groups = [[NSMutableArray alloc] init];
    }else{
        [self.groups removeAllObjects];
    }
    
    // in case enumerateGroupsWithTypes fails
    ALAssetsLibraryAccessFailureBlock failureBlock = ^(NSError *error){
        // failure view controller
    };
    
    // add group
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
            [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
        }
    };
    
    // enumerate only videos
    NSInteger groupTypes = ALAssetsGroupSavedPhotos | ALAssetsGroupAlbum | ALAssetsGroupEvent | ALAssetsGroupFaces;
    [self.assetsLibrary enumerateGroupsWithTypes:groupTypes usingBlock:groupBlock failureBlock:failureBlock];
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static  NSString *indextifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:indextifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:indextifier];
        ALAssetsGroup *groupForCell = [self.groups objectAtIndex:indexPath.row];
        cell.imageView.image = [UIImage imageWithCGImage:[groupForCell posterImage]];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.text = [groupForCell valueForProperty:ALAssetsGroupPropertyName];
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.backgroundColor = UIColorFromRGB(0x1a1a1f);
        cell.detailTextLabel.text = [@(groupForCell.numberOfAssets) stringValue];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 66;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ALAssetsGroup *group = self.groups[indexPath.row];
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    UICollectionViewFlowLayout *layout= [[UICollectionViewFlowLayout alloc]init];
    [layout setScrollDirection:UICollectionViewScrollDirectionVertical];
    
    PAImagePickerController *vc = [[PAImagePickerController alloc] initWithCollectionViewLayout:layout];
    vc.maxNumberOfPhotos = self.maxNumberOfPhotos;
    vc.delegate = self.delegate;
    vc.paMediaType = self.paMediaType;
    vc.isSupportRecorder = self.isSupportRecorder;
    vc.title = [group  valueForProperty:ALAssetsGroupPropertyName];
    vc.assertGroup = [self.groups objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.groups.count;
}

@end
