//
//  ViewController.m
//  SRTTest
//
//  Created by Lide on 2020/5/11.
//  Copyright © 2020 Lide. All rights reserved.
//

#import "ViewController.h"
#import "srt.h"

@interface ViewController () {
    UILabel     *_titleLabel;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 40)];
    _titleLabel.center = CGPointMake(self.view.bounds.size.width / 2, self.view.bounds.size.height / 2);
    _titleLabel.textColor = [UIColor blackColor];
    _titleLabel.text = @"SRT_TEST";
    [self.view addSubview:_titleLabel];

    srt_startup();
}


@end
