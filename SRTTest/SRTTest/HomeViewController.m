//
//  HomeViewController.m
//  SRTTest
//
//  Created by Lide on 2020/5/13.
//  Copyright © 2020 Lide. All rights reserved.
//

#import "HomeViewController.h"
#import "CameraDetailViewController.h"

@interface HomeViewController () {
    UIButton    *_createButton;
}

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"Home";
    self.view.backgroundColor = [UIColor whiteColor];

    _createButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _createButton.frame = CGRectMake(40, 100, 100, 40);
    _createButton.backgroundColor = [UIColor blackColor];
    [_createButton setTitle:@"Create" forState:UIControlStateNormal];
    [_createButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_createButton addTarget:self action:@selector(clickCreateButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_createButton];
}

- (void)clickCreateButton:(id)sender {
    CameraDetailViewController *cameraDetailVC = [[CameraDetailViewController alloc] init];
    [self.navigationController pushViewController:cameraDetailVC animated:YES];
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
