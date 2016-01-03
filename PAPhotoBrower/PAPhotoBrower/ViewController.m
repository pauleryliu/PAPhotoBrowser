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
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:nil cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Take Photos",@"Record Videos",@"Take Photos And Record Videos",@"Select Photos",@"Select Videos",@"Select Photos And Videos",nil];
    actionSheet.delegate = self;
    [actionSheet showInView:self.view];
}

#pragma mark -- ActionSheet

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
        {
            PAVideoRecorderVC *videoRecorderVC = [[PAVideoRecorderVC alloc] initWithNibName:@"PAVideoRecorderVC" bundle:[NSBundle mainBundle]];
            videoRecorderVC.paMediaType = PAMediaTypePhoto;
            [self presentViewController:videoRecorderVC animated:YES completion:^{
                
            }];
        }
            break;
        case 1:
        {
            PAVideoRecorderVC *videoRecorderVC = [[PAVideoRecorderVC alloc] initWithNibName:@"PAVideoRecorderVC" bundle:[NSBundle mainBundle]];
            videoRecorderVC.paMediaType = PAMediaTypeVideo;
            [self presentViewController:videoRecorderVC animated:YES completion:^{
                
            }];
        }
            break;
        case 2:
        {
            PAVideoRecorderVC *videoRecorderVC = [[PAVideoRecorderVC alloc] initWithNibName:@"PAVideoRecorderVC" bundle:[NSBundle mainBundle]];
            videoRecorderVC.paMediaType = PAMediaTypePhotoAndVideo;
            [self presentViewController:videoRecorderVC animated:YES completion:^{
                
            }];
        }
            break;
        case 3:
        {
            UICollectionViewFlowLayout *layout= [[UICollectionViewFlowLayout alloc]init];
            [layout setScrollDirection:UICollectionViewScrollDirectionVertical];
            PAImagePickerController *pickerVC = [[PAImagePickerController alloc] initWithCollectionViewLayout:layout];
            PAImagePickerGroupController *pickerGroupVC = [[PAImagePickerGroupController alloc] init];
            pickerVC.delegate = self;
            pickerGroupVC.delegate = self;
            pickerVC.isSupportRecorder = YES;
            pickerGroupVC.isSupportRecorder = YES;
            pickerVC.paMediaType = PAMediaTypePhoto;
            pickerVC.paMediaType = PAMediaTypePhoto;
            UINavigationController *pickerNavController = [[UINavigationController alloc] initWithRootViewController:pickerGroupVC];
            pickerNavController.viewControllers = @[pickerGroupVC,pickerVC];
            [self presentViewController:pickerNavController animated:YES completion:^{
                
            }];
        }
            break;
        case 4:
        {
            UICollectionViewFlowLayout *layout= [[UICollectionViewFlowLayout alloc]init];
            [layout setScrollDirection:UICollectionViewScrollDirectionVertical];
            PAImagePickerController *pickerVC = [[PAImagePickerController alloc] initWithCollectionViewLayout:layout];
            PAImagePickerGroupController *pickerGroupVC = [[PAImagePickerGroupController alloc] init];
            pickerVC.delegate = self;
            pickerGroupVC.delegate = self;
            pickerVC.isSupportRecorder = YES;
            pickerGroupVC.isSupportRecorder = YES;
            pickerVC.paMediaType = PAMediaTypeVideo;
            pickerVC.paMediaType = PAMediaTypeVideo;
            UINavigationController *pickerNavController = [[UINavigationController alloc] initWithRootViewController:pickerGroupVC];
            pickerNavController.viewControllers = @[pickerGroupVC,pickerVC];
            
            [self presentViewController:pickerNavController animated:YES completion:^{
                
            }];
        }
            break;
        case 5:
        {
            UICollectionViewFlowLayout *layout= [[UICollectionViewFlowLayout alloc]init];
            [layout setScrollDirection:UICollectionViewScrollDirectionVertical];
            PAImagePickerController *pickerVC = [[PAImagePickerController alloc] initWithCollectionViewLayout:layout];
            PAImagePickerGroupController *pickerGroupVC = [[PAImagePickerGroupController alloc] init];
            pickerVC.delegate = self;
            pickerGroupVC.delegate = self;
            pickerVC.isSupportRecorder = YES;
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
