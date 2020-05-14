//
//  CameraDetailViewController.m
//  SRTTest
//
//  Created by Lide on 2020/5/13.
//  Copyright © 2020 Lide. All rights reserved.
//

#import "CameraDetailViewController.h"
#import "LMVideoCamera.h"
#import "LMVideoHardEncoder.h"
#import "LMAudioEncoder.h"

@interface CameraDetailViewController () <LMVideoCameraDelegate> {
    LMVideoCamera   *_videoCamera;
    UIButton        *_startButton;
    UIView          *_previewView;

    LMVideoHardEncoder   *_videoEncoder;
    LMAudioEncoder       *_audioEncoder;

    UIButton        *_connectButton;
    UIButton        *_pushButton;
}

@property (nonatomic, assign) BOOL isCapture;
@property (nonatomic, assign) BOOL isPush;

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
    _videoCamera.delegate = self;

    _startButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _startButton.frame = CGRectMake(40, 100, 100, 40);
    _startButton.backgroundColor = [UIColor blackColor];
    [_startButton setTitle:@"Start" forState:UIControlStateNormal];
    [_startButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_startButton addTarget:self action:@selector(clickStartButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_startButton];

    _connectButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _connectButton.frame = CGRectMake(160, 100, 100, 40);
    _connectButton.backgroundColor = [UIColor blackColor];
    [_connectButton setTitle:@"Connect" forState:UIControlStateNormal];
    [_connectButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_connectButton addTarget:self action:@selector(clickConnectButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_connectButton];

    _pushButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _pushButton.frame = CGRectMake(40, 160, 100, 40);
    _pushButton.backgroundColor = [UIColor blackColor];
    [_pushButton setTitle:@"Push" forState:UIControlStateNormal];
    [_pushButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_pushButton addTarget:self action:@selector(clickPushButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_pushButton];
}

- (void)clickStartButton:(id)sender {
    if (_isCapture) {
        return;
    }
    _isCapture = YES;
    [_videoCamera startCameraCapture];
}

- (void)clickConnectButton:(id)sender {
    
}

- (void)clickPushButton:(id)sender {
    if (_isPush) {
        return;
    }
    _isPush = YES;
    _audioEncoder = [[LMAudioEncoder alloc] initWithAudioSettings:_videoCamera.recommendedAudioSettings];
    _videoEncoder = [[LMVideoHardEncoder alloc] initWithVideoSettings:_videoCamera.recommendedVideoSettings];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - LMVideoCameraDelegate

- (void)videoCameraDidOutputAudioBuffer:(CMSampleBufferRef)audioBuffer {
    if (!_isPush) {
        return;
    }

    CFRetain(audioBuffer);

    AudioBufferList audioBufferList;
    CMBlockBufferRef blockBuffer;

    CMSampleBufferGetAudioBufferListWithRetainedBlockBuffer(audioBuffer, NULL, &audioBufferList, sizeof(audioBufferList), NULL, NULL, 0, &blockBuffer);

    CFRelease(blockBuffer);

    NSData *data = [_audioEncoder encodeWithAudioBufferList:&audioBufferList];
    if (data != nil) {
        // push
    }
}

- (void)videoCameraDidOutputVideoBuffer:(CMSampleBufferRef)videoBuffer {
    [_videoEncoder encodeWithVideoBuffer:videoBuffer];
}

@end
