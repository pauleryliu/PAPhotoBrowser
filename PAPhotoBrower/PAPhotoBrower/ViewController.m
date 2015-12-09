//
//  ViewController.m
//  PAPhotoBrower
//
//  Created by paulery on 11/26/15.
//  Copyright © 2015 paulery. All rights reserved.
//

#import "ViewController.h"
#import "PAImagePickerController.h"
#import "PAImagePickerGroupController.h"
#import "PAVideoRecorderVC.h"

@interface ViewController ()<PAImagePickerControllerDelegate,PAImagePickerControllerDelegate,UIActionSheetDelegate>

@property (weak, nonatomic) IBOutlet UIButton *paPhotoBrowserButton;

- (IBAction)paPhotoBrowserButtonPressed:(id)sender;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)paPhotoBrowserButtonPressed:(id)sender
{
    NSLog(@"paPhotoBrowserButtonPressed");
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:nil cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照",@"录视频",@"拍照和录视频",@"本地选图（默认无拍摄）",@"本地选视频（默认无拍摄）",@"本地选图和视频（默认无拍摄）",@"本地选图（含拍摄）",@"本地选视频（含拍摄）",@"本地选图和视频（含拍摄）",nil];
    actionSheet.delegate = self;
    [actionSheet showInView:self.view];
}

#pragma mark -- ActionSheet

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
        {
            NSLog(@"拍照");
            PAVideoRecorderVC *videoRecorderVC = [[PAVideoRecorderVC alloc] initWithNibName:@"PAVideoRecorderVC" bundle:[NSBundle mainBundle]];
            videoRecorderVC.paMediaType = PAMediaTypePhoto;
            // PAVideoRecorderVC.delegate = (id)self;
            [self presentViewController:videoRecorderVC animated:YES completion:^{
                
            }];
        }
            break;
        case 1:
        {
            NSLog(@"录视频");
            PAVideoRecorderVC *videoRecorderVC = [[PAVideoRecorderVC alloc] initWithNibName:@"PAVideoRecorderVC" bundle:[NSBundle mainBundle]];
            videoRecorderVC.paMediaType = PAMediaTypeVideo;
            // PAVideoRecorderVC.delegate = (id)self;
            [self presentViewController:videoRecorderVC animated:YES completion:^{
                
            }];
        }
            break;
        case 2:
        {
            NSLog(@"拍照和录视频");
            PAVideoRecorderVC *videoRecorderVC = [[PAVideoRecorderVC alloc] initWithNibName:@"PAVideoRecorderVC" bundle:[NSBundle mainBundle]];
            videoRecorderVC.paMediaType = PAMediaTypePhotoAndVideo;
            //  PAVideoRecorderVC.delegate = (id)self;
            [self presentViewController:videoRecorderVC animated:YES completion:^{
                
            }];
        }
            break;
        case 3:
        {
            // 本地选图（默认无拍摄）
            UICollectionViewFlowLayout *layout= [[UICollectionViewFlowLayout alloc]init];
            [layout setScrollDirection:UICollectionViewScrollDirectionVertical];
            PAImagePickerController *pickerVC = [[PAImagePickerController alloc] initWithCollectionViewLayout:layout];
            PAImagePickerGroupController *pickerGroupVC = [[PAImagePickerGroupController alloc] init];
            pickerVC.delegate = self;
            pickerGroupVC.delegate = self;
            pickerVC.paMediaType = PAMediaTypePhoto; // Default
            pickerVC.paMediaType = PAMediaTypePhoto;
            UINavigationController *pickerNavController = [[UINavigationController alloc] initWithRootViewController:pickerGroupVC];
            pickerNavController.viewControllers = @[pickerGroupVC,pickerVC];
            
            [self presentViewController:pickerNavController animated:YES completion:^{
                
            }];
        }
            break;
        case 4:
        {
            // 本地选视频（默认无拍摄）
            UICollectionViewFlowLayout *layout= [[UICollectionViewFlowLayout alloc]init];
            [layout setScrollDirection:UICollectionViewScrollDirectionVertical];
            PAImagePickerController *pickerVC = [[PAImagePickerController alloc] initWithCollectionViewLayout:layout];
            PAImagePickerGroupController *pickerGroupVC = [[PAImagePickerGroupController alloc] init];
            pickerVC.delegate = self;
            pickerGroupVC.delegate = self;
            pickerVC.paMediaType = PAMediaTypeVideo; // Default
            pickerVC.paMediaType = PAMediaTypeVideo;
            UINavigationController *pickerNavController = [[UINavigationController alloc] initWithRootViewController:pickerGroupVC];
            pickerNavController.viewControllers = @[pickerGroupVC,pickerVC];
            
            [self presentViewController:pickerNavController animated:YES completion:^{
                
            }];
        }
            break;
        case 5:
        {
            // 本地选图和视频（默认无拍摄）
            UICollectionViewFlowLayout *layout= [[UICollectionViewFlowLayout alloc]init];
            [layout setScrollDirection:UICollectionViewScrollDirectionVertical];
            PAImagePickerController *pickerVC = [[PAImagePickerController alloc] initWithCollectionViewLayout:layout];
            PAImagePickerGroupController *pickerGroupVC = [[PAImagePickerGroupController alloc] init];
            pickerVC.delegate = self;
            pickerGroupVC.delegate = self;
            UINavigationController *pickerNavController = [[UINavigationController alloc] initWithRootViewController:pickerGroupVC];
            pickerNavController.viewControllers = @[pickerGroupVC,pickerVC];
            
            [self presentViewController:pickerNavController animated:YES completion:^{
                
            }];
        }
            break;
        case 6:
        {
            // 本地选图(含拍摄)
            UICollectionViewFlowLayout *layout= [[UICollectionViewFlowLayout alloc]init];
            [layout setScrollDirection:UICollectionViewScrollDirectionVertical];
            PAImagePickerController *pickerVC = [[PAImagePickerController alloc] initWithCollectionViewLayout:layout];
            PAImagePickerGroupController *pickerGroupVC = [[PAImagePickerGroupController alloc] init];
            pickerVC.delegate = self;
            pickerGroupVC.delegate = self;
            pickerVC.isSupportRecorder = YES;
            pickerGroupVC.isSupportRecorder = YES;
            pickerVC.paMediaType = PAMediaTypePhoto; // Default
            pickerVC.paMediaType = PAMediaTypePhoto;
            UINavigationController *pickerNavController = [[UINavigationController alloc] initWithRootViewController:pickerGroupVC];
            pickerNavController.viewControllers = @[pickerGroupVC,pickerVC];
            [self presentViewController:pickerNavController animated:YES completion:^{
                
            }];
        }
            break;
        case 7:
        {
            // 本地选视频(含拍摄)
            UICollectionViewFlowLayout *layout= [[UICollectionViewFlowLayout alloc]init];
            [layout setScrollDirection:UICollectionViewScrollDirectionVertical];
            PAImagePickerController *pickerVC = [[PAImagePickerController alloc] initWithCollectionViewLayout:layout];
            PAImagePickerGroupController *pickerGroupVC = [[PAImagePickerGroupController alloc] init];
            pickerVC.delegate = self;
            pickerGroupVC.delegate = self;
            pickerVC.isSupportRecorder = YES;
            pickerGroupVC.isSupportRecorder = YES;
            pickerVC.paMediaType = PAMediaTypeVideo; // Default
            pickerVC.paMediaType = PAMediaTypeVideo;
            UINavigationController *pickerNavController = [[UINavigationController alloc] initWithRootViewController:pickerGroupVC];
            pickerNavController.viewControllers = @[pickerGroupVC,pickerVC];
            
            [self presentViewController:pickerNavController animated:YES completion:^{
                
            }];
        }
            break;
        case 8:
        {
            // 本地选图和视频(含拍摄)
            UICollectionViewFlowLayout *layout= [[UICollectionViewFlowLayout alloc]init];
            [layout setScrollDirection:UICollectionViewScrollDirectionVertical];
            PAImagePickerController *pickerVC = [[PAImagePickerController alloc] initWithCollectionViewLayout:layout];
            PAImagePickerGroupController *pickerGroupVC = [[PAImagePickerGroupController alloc] init];
            pickerVC.delegate = self;
            pickerGroupVC.delegate = self;
            pickerVC.isSupportRecorder = YES;   // Default NO
            pickerGroupVC.isSupportRecorder = YES;
            UINavigationController *pickerNavController = [[UINavigationController alloc] initWithRootViewController:pickerGroupVC];
            pickerNavController.viewControllers = @[pickerGroupVC,pickerVC];
            [self presentViewController:pickerNavController animated:YES completion:^{
                
            }];
        }
            break;
        default:
            break;
    }
}

@end
