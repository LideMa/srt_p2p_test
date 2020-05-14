//
//  LMVideoCamera.h
//  SRTTest
//
//  Created by Lide on 2020/5/13.
//  Copyright © 2020 Lide. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol LMVideoCameraDelegate;

@interface LMVideoCamera : NSObject

@property (nonatomic, weak) id<LMVideoCameraDelegate> delegate;

@property (nonatomic, strong) NSDictionary *recommendedVideoSettings;
@property (nonatomic, strong) NSDictionary *recommendedAudioSettings;

- (void)setPreviewView:(UIView *)previewView;

- (void)startCameraCapture;
- (void)stopCameraCapture;

- (void)destory;

@end

@protocol LMVideoCameraDelegate <NSObject>

- (void)videoCameraDidOutputAudioBuffer:(CMSampleBufferRef)audioBuffer;
- (void)videoCameraDidOutputVideoBuffer:(CMSampleBufferRef)videoBuffer;

@end

NS_ASSUME_NONNULL_END
