//
//  LMVideoHardEncoder.m
//  SRTTest
//
//  Created by Lide on 2020/5/13.
//  Copyright © 2020 Lide. All rights reserved.
//

#import "LMVideoHardEncoder.h"
#import <VideoToolbox/VideoToolbox.h>

@interface LMVideoHardEncoder () {
    VTCompressionSessionRef _compressionSession;
}

@property (nonatomic, strong) NSDictionary *videoSettings;
@property (nonatomic, assign) int width;
@property (nonatomic, assign) int height;
@property (nonatomic, assign) CMVideoCodecType codecType;

@end

@implementation LMVideoHardEncoder

- (id)initWithVideoSettings:(NSDictionary *)videoSettings {
    self = [super init];
    if (self != nil) {
        _videoSettings = videoSettings;
        [self setupVideoConverter];
    }

    return self;
}

- (void)setupVideoConverter {
    self.width = [_videoSettings[AVVideoWidthKey] intValue];
    self.height = [_videoSettings[AVVideoHeightKey] intValue];
    NSString *string = _videoSettings[AVVideoCodecKey];
    const uint8_t *st = (uint8_t *)[string UTF8String];
    UInt32 value = ((UInt32)st[0] << 24) | ((UInt32)st[1] << 16) | (UInt32)(st[2] << 8) | st[3];
    self.codecType = value;
    OSStatus status = VTCompressionSessionCreate(NULL, self.width, self.height, self.codecType, NULL, NULL, NULL, videoCompressionCallBack, (__bridge void *)self, &_compressionSession);
    if (status != noErr) {
        NSError *error = [NSError errorWithDomain:NSOSStatusErrorDomain code:status userInfo:nil];
        NSLog(@"failed to create video converter: %@", error.description);
        return;
    }

    NSDictionary *properties = _videoSettings[AVVideoCompressionPropertiesKey];
    [properties enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        OSStatus status = VTSessionSetProperty(self->_compressionSession, (__bridge CFStringRef _Nullable)(key), (__bridge CFTypeRef _Nullable)(obj));
        if (status != noErr) {
            NSError *error = [NSError errorWithDomain:NSOSStatusErrorDomain code:status userInfo:nil];
            NSLog(@"failed to set video converter property: %@", error.description);
        }
    }];
}

static void videoCompressionCallBack(void * CM_NULLABLE outputCallbackRefCon,
                                     void * CM_NULLABLE sourceFrameRefCon,
                                     OSStatus status,
                                     VTEncodeInfoFlags infoFlags,
                                     CM_NULLABLE CMSampleBufferRef sampleBuffer) {
    if (status != noErr) {
        NSError *error = [NSError errorWithDomain:NSOSStatusErrorDomain code:status userInfo:nil];
        NSLog(@"failed to encode video buffer: %@", error.description);
        return;
    }

    if (!CMSampleBufferDataIsReady(sampleBuffer)) {
        NSLog(@"sample buffer is not ready");
        return;
    }

    if (infoFlags == kVTEncodeInfo_FrameDropped) {
        NSLog(@"frame dropped");
        return;
    }

    CMBlockBufferRef block = CMSampleBufferGetDataBuffer(sampleBuffer);
    BOOL isKeyframe = false;

    CFArrayRef attachments = CMSampleBufferGetSampleAttachmentsArray(sampleBuffer, false);

    if(attachments != NULL) {
        CFDictionaryRef attachment =(CFDictionaryRef)CFArrayGetValueAtIndex(attachments, 0);
        CFBooleanRef dependsOnOthers = (CFBooleanRef)CFDictionaryGetValue(attachment, kCMSampleAttachmentKey_DependsOnOthers);
        isKeyframe = (dependsOnOthers == kCFBooleanFalse);
    }

    if (isKeyframe) {
        // sps pps
    }

    // IDR
}

- (void)encodeWithVideoBuffer:(CMSampleBufferRef)videoBuffer {
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(videoBuffer);
    CMTime duration = CMSampleBufferGetOutputDuration(videoBuffer);
    CMTime presentationTimeStamp = CMSampleBufferGetPresentationTimeStamp(videoBuffer);
    VTEncodeInfoFlags flags;
    OSStatus status = VTCompressionSessionEncodeFrame(_compressionSession, imageBuffer, presentationTimeStamp, duration, NULL, imageBuffer, &flags);
    if (status != noErr) {
        NSError *error = [NSError errorWithDomain:NSOSStatusErrorDomain code:status userInfo:nil];
        NSLog(@"failed to encode video buffer: %@", error.description);

        VTCompressionSessionCompleteFrames(_compressionSession, kCMTimeInvalid);
        VTCompressionSessionInvalidate(_compressionSession);
        CFRelease(_compressionSession);
        _compressionSession = NULL;
    }
}

@end
