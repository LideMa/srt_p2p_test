//
//  LMVideoCamera.m
//  SRTTest
//
//  Created by Lide on 2020/5/13.
//  Copyright © 2020 Lide. All rights reserved.
//

#import "LMVideoCamera.h"
#import <AVFoundation/AVFoundation.h>

@interface LMVideoCamera () <AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureAudioDataOutputSampleBufferDelegate> {
    AVCaptureSession    *_captureSession;
    AVCaptureDevice     *_camera;
    AVCaptureDevice     *_microphone;

    AVCaptureDeviceInput        *_videoInput;
    AVCaptureVideoDataOutput    *_videoOutput;
    AVCaptureDeviceInput        *_audioInput;
    AVCaptureAudioDataOutput    *_audioOutput;

    dispatch_queue_t    _cameraProcessingQueue;
    dispatch_queue_t    _audioProcessingQueue;
}

@property (nonatomic, strong) AVSampleBufferDisplayLayer *displayLayer;

@end

@implementation LMVideoCamera

- (id)init {
    self = [super init];
    if (self != nil) {
        _cameraProcessingQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
        _audioProcessingQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0);

        AVCaptureDeviceDiscoverySession *videoDiscoverySession = [AVCaptureDeviceDiscoverySession discoverySessionWithDeviceTypes:@[AVCaptureDeviceTypeBuiltInDualCamera] mediaType:AVMediaTypeVideo position:AVCaptureDevicePositionBack];
        NSArray *videoDevices = videoDiscoverySession.devices;
        for (AVCaptureDevice *device in videoDevices) {
            if ([device position] == AVCaptureDevicePositionBack) {
                _camera = device;
                break;
            }
        }

        AVCaptureDeviceDiscoverySession *audioDiscoverySession = [AVCaptureDeviceDiscoverySession discoverySessionWithDeviceTypes:@[AVCaptureDeviceTypeBuiltInMicrophone] mediaType:AVMediaTypeAudio position:AVCaptureDevicePositionUnspecified];
        NSArray *audioDevices = audioDiscoverySession.devices;
        for (AVCaptureDevice *device in audioDevices) {
            _microphone = device;
            break;
        }

        // Capture Session
        _captureSession = [[AVCaptureSession alloc] init];
        [_captureSession beginConfiguration];

        // Video
        NSError *error = nil;
        _videoInput = [[AVCaptureDeviceInput alloc] initWithDevice:_camera error:&error];
        if ([_captureSession canAddInput:_videoInput]) {
            [_captureSession addInput:_videoInput];
        }
        _videoOutput = [[AVCaptureVideoDataOutput alloc] init];
        [_videoOutput setAlwaysDiscardsLateVideoFrames:NO];

        [_videoOutput setVideoSettings:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:kCVPixelFormatType_32BGRA] forKey:(id)kCVPixelBufferPixelFormatTypeKey]];
        [_videoOutput setSampleBufferDelegate:self queue:_cameraProcessingQueue];

        if ([_captureSession canAddOutput:_videoOutput]) {
            [_captureSession addOutput:_videoOutput];
        }
        [_captureSession setSessionPreset:AVCaptureSessionPreset1280x720];

        AVCaptureConnection *connection = [_videoOutput connectionWithMediaType:AVMediaTypeVideo];
        connection.videoOrientation = AVCaptureVideoOrientationPortrait;
        if ([_captureSession canAddConnection:connection]) {
            [_captureSession addConnection:connection];
        }

        // Audio
        _microphone = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
        _audioInput = [AVCaptureDeviceInput deviceInputWithDevice:_microphone error:nil];
        if ([_captureSession canAddInput:_audioInput]) {
            [_captureSession addInput:_audioInput];
        }
        _audioOutput = [[AVCaptureAudioDataOutput alloc] init];
        if ([_captureSession canAddOutput:_audioOutput]) {
            [_captureSession addOutput:_audioOutput];
        }
        [_audioOutput setSampleBufferDelegate:self queue:_audioProcessingQueue];

        [_captureSession commitConfiguration];
    }

    return self;
}

- (void)dealloc {
    [self stopCameraCapture];

    [_videoOutput setSampleBufferDelegate:nil queue:dispatch_get_main_queue()];
    [_audioOutput setSampleBufferDelegate:nil queue:dispatch_get_main_queue()];

    [self removeInputsAndOutputs];
}

- (void)removeInputsAndOutputs {
    [_captureSession beginConfiguration];
    if (_videoInput) {
        [_captureSession removeInput:_videoInput];
        [_captureSession removeOutput:_videoOutput];
        _videoInput = nil;
        _videoOutput = nil;
    }
    if (_microphone != nil) {
        [_captureSession removeInput:_audioInput];
        [_captureSession removeOutput:_audioOutput];
        _audioInput = nil;
        _audioOutput = nil;
        _microphone = nil;
    }
    [_captureSession commitConfiguration];
}

- (void)setPreviewView:(UIView *)previewView {
    AVSampleBufferDisplayLayer *avslayer = [[AVSampleBufferDisplayLayer alloc] init];

    avslayer.bounds = previewView.bounds;
    avslayer.position = CGPointMake(CGRectGetMidX(previewView.bounds), CGRectGetMidY(previewView.bounds));
    avslayer.videoGravity = AVLayerVideoGravityResizeAspect;

    CMTimebaseRef controlTimebase;
    CMTimebaseCreateWithMasterClock(CFAllocatorGetDefault(), CMClockGetHostTimeClock(), &controlTimebase);
    avslayer.controlTimebase = controlTimebase;

    CMTimebaseSetRate(avslayer.controlTimebase, 1.0);

    self.displayLayer = avslayer;

    [previewView.layer addSublayer:self.displayLayer];
}

- (void)startCameraCapture {
    if (![_captureSession isRunning]) {
        [_captureSession startRunning];
    }
}

- (void)stopCameraCapture {
    if ([_captureSession isRunning]) {
        [_captureSession stopRunning];
    }
}

#pragma mark - AVCaptureVideoDataOutputSampleBufferDelegate

- (void)captureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    if (![_captureSession isRunning]) {
        return;
    } else {
        if (output == _audioOutput) {

        } else {
            if (self.displayLayer != nil && [self.displayLayer isReadyForMoreMediaData]) {
                [self.displayLayer enqueueSampleBuffer:sampleBuffer];
            }

            [self.displayLayer flush];
        }
    }
}

@end
