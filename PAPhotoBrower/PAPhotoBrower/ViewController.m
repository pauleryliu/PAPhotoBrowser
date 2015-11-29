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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)paPhotoBrowserButtonPressed:(id)sender
{
    NSLog(@"paPhotoBrowserButtonPressed");
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:nil cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照",@"视频",@"相册", nil];
    actionSheet.delegate = self;
    [actionSheet showInView:self.view];
}

#pragma mark -- 

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
        {
            NSLog(@"拍照");
        }
            break;
        case 1:
        {
            NSLog(@"录视频");
            PAVideoRecorderVC *videoRecorderVC = [[PAVideoRecorderVC alloc] initWithNibName:@"PAVideoRecorderVC" bundle:[NSBundle mainBundle]];
//            PAVideoRecorderVC.delegate = (id)self;
            [self presentViewController:videoRecorderVC animated:YES completion:^{
                
            }];
        }
            break;
        case 2:
        {
            NSUInteger maxNumberOfPhotos = 6;
            UICollectionViewFlowLayout *layout= [[UICollectionViewFlowLayout alloc]init];
            [layout setScrollDirection:UICollectionViewScrollDirectionVertical];
            PAImagePickerController *pickerVC = [[PAImagePickerController alloc] initWithCollectionViewLayout:layout];
            PAImagePickerGroupController *pickerGroupVC = [[PAImagePickerGroupController alloc] init];
            pickerVC.isSupportEditWhenSelectSinglePhoto = NO;
            pickerGroupVC.maxNumberOfPhotos = maxNumberOfPhotos;
            pickerVC.maxNumberOfPhotos = maxNumberOfPhotos;
            pickerVC.delegate = self;
            pickerGroupVC.delegate = self;
            pickerVC.doneBtnName = @"发送";
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
