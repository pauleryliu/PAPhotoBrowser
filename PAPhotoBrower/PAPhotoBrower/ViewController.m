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

@interface ViewController ()<PAImagePickerControllerDelegate,PAImagePickerControllerDelegate>

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

@end
