//
//  PAVideoGroupViewController.m
//  PAPhotoBrower
//
//  Created by paulery on 11/26/15.
//  Copyright © 2015 paulery. All rights reserved.
//

#import "PAVideoGroupViewController.h"
#import "PAVideoRecorderVC.h"
#import "PAVideoAssetViewController.h"

#define UIColorFromRGB(rgbValue) \
[UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0x00FF00) >>  8))/255.0 \
blue:((float)((rgbValue & 0x0000FF) >>  0))/255.0 \
alpha:1.0]

@interface PAVideoGroupViewController ()

@property(nonatomic,strong) UITableView *tableView;
@property (nonatomic, strong) ALAssetsLibrary *assetsLibrary;
@property (nonatomic, strong) NSMutableArray *groups;

@end

@implementation PAVideoGroupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"本地视频";
//    if (MyDevice().isIOS7AndAbove)
//    {
        self.navigationController.navigationBar.barTintColor = UIColorFromRGB(0x1a1a1f);
//    }
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : UIColorFromRGB(0x8f8f95)}];
//    self.navigationController.navigationBar.translucent = NO;
    
    // setup assert
    [self setupAssert];
    
    // cancel btn
    UIButton *rightBarBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    rightBarBtn.titleLabel.font = [UIFont systemFontOfSize:17.0f];
    [rightBarBtn setTitle:@"取消" forState:UIControlStateNormal];
    [rightBarBtn setTitleColor:UIColorFromRGB(0xffa015) forState:UIControlStateNormal];
    [rightBarBtn sizeToFit];
    [rightBarBtn addTarget:self action:@selector(rightBarBtnPressed) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightBarItem = [[UIBarButtonItem alloc] initWithCustomView:rightBarBtn];
    self.navigationItem.rightBarButtonItem = rightBarItem;
    
    // tableview
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

#pragma mark - outlet
- (void)rightBarBtnPressed{
    [self dismissViewControllerAnimated:YES completion:^(void){}];
}

#pragma mark - main method
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
    
    // add group that contain videos
    ALAssetsLibraryGroupsEnumerationResultsBlock groupBlock = ^(ALAssetsGroup *group,BOOL *stop){
        ALAssetsFilter *onlyVideoFilter = [ALAssetsFilter  allVideos];
        [group setAssetsFilter:onlyVideoFilter];
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

#pragma mark - datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.groups.count;
}

#pragma mark - delegate

-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    // Force your tableview margins (this may be a bad idea)
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.tableView setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Remove seperator inset
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    // Prevent the cell from inheriting the Table View's margin settings
    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        [cell setPreservesSuperviewLayoutMargins:NO];
    }
    
    // Explictly set your cell's layout margins
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        cell.layoutMargins = UIEdgeInsetsZero;
    }
    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        cell.preservesSuperviewLayoutMargins = NO;
    }
    cell.imageView.frame = (CGRect){CGPointZero,cell.imageView.frame.size};
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
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    UICollectionViewFlowLayout *layout= [[UICollectionViewFlowLayout alloc]init];
    [layout setScrollDirection:UICollectionViewScrollDirectionVertical];
    
    PAVideoAssetViewController *vc = [[PAVideoAssetViewController alloc] initWithCollectionViewLayout:layout];
    vc.postDelegate = self.postDelegate;
    vc.assertGroup = [self.groups objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
