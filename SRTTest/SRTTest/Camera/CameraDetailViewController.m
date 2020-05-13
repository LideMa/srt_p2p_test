//
//  CameraDetailViewController.m
//  SRTTest
//
//  Created by Lide on 2020/5/13.
//  Copyright © 2020 Lide. All rights reserved.
//

#import "CameraDetailViewController.h"
#import "LMVideoCamera.h"

@interface CameraDetailViewController () {
    LMVideoCamera   *_videoCamera;
    UIButton        *_startButton;
    UIView          *_previewView;
}

@end

@implementation CameraDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"Camera";
    self.view.backgroundColor = [UIColor whiteColor];

    _videoCamera = [[LMVideoCamera alloc] init];
    _previewView = [[UIView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:_previewView];
    [_videoCamera setPreviewView:_previewView];

    _startButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _startButton.frame = CGRectMake(40, 100, 100, 40);
    _startButton.backgroundColor = [UIColor blackColor];
    [_startButton setTitle:@"Start" forState:UIControlStateNormal];
    [_startButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_startButton addTarget:self action:@selector(clickStartButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_startButton];
}

- (void)clickStartButton:(id)sender {
    [_videoCamera startCameraCapture];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
