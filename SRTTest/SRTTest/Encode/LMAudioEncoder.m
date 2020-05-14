//
//  LMAudioEncoder.m
//  SRTTest
//
//  Created by Lide on 2020/5/14.
//  Copyright © 2020 Lide. All rights reserved.
//

#import "LMAudioEncoder.h"

@interface LMAudioEncoder () {
    AudioConverterRef   _audioConverter;
}

@property (nonatomic, strong) NSDictionary *audioSettings;

@end

@implementation LMAudioEncoder

- (id)initWithAudioSettings:(NSDictionary *)audioSettings {
    self = [super init];
    if (self != nil) {
        _audioSettings = audioSettings;
        [self setupAudioConverter];
    }

    return self;
}

- (void)setupAudioConverter {
    // input
    AudioStreamBasicDescription inputDes = {0};
    inputDes.mSampleRate = [_audioSettings[AVSampleRateKey] doubleValue];
    inputDes.mFormatID = kAudioFormatLinearPCM;
    inputDes.mFormatFlags = (kAudioFormatFlagIsSignedInteger | kAudioFormatFlagsNativeEndian | kAudioFormatFlagIsPacked);
    inputDes.mChannelsPerFrame = [_audioSettings[AVNumberOfChannelsKey] intValue];
    inputDes.mFramesPerPacket = 1;
    inputDes.mBitsPerChannel = [_audioSettings[AVLinearPCMBitDepthKey] intValue];
    inputDes.mBytesPerFrame = inputDes.mBitsPerChannel / 8 * inputDes.mChannelsPerFrame;
    inputDes.mBytesPerPacket = inputDes.mBytesPerFrame * inputDes.mFramesPerPacket;
    // output
    AudioStreamBasicDescription outputDes = {0};
    outputDes.mFormatFlags = 0;
    outputDes.mSampleRate = [_audioSettings[AVSampleRateKey] doubleValue];
    outputDes.mFormatID = kAudioFormatMPEG4AAC;
    outputDes.mChannelsPerFrame = [_audioSettings[AVNumberOfChannelsKey] intValue];
    // 1024
    outputDes.mFramesPerPacket = 1024;
    AudioClassDescription des[] = {
        {
            kAudioEncoderComponentType,
            kAudioFormatMPEG4AAC,
            kAppleSoftwareAudioCodecManufacturer
        }
    };
    OSStatus status = AudioConverterNewSpecific(&inputDes, &outputDes, 2, des, &_audioConverter);
    if (status != noErr) {
        //
        NSError *error = [NSError errorWithDomain:NSOSStatusErrorDomain code:status userInfo:nil];
        NSLog(@"failed to create audio converter: %@", error.description);
    }
}

- (NSData *)encodeWithAudioBufferList:(AudioBufferList *)inputBuffer {
    NSData *data;
    uint8_t *buffer = malloc(inputBuffer->mBuffers[0].mDataByteSize);
    AudioBufferList outputBuffer;
    outputBuffer.mNumberBuffers = 1;
    outputBuffer.mBuffers[0].mNumberChannels = inputBuffer->mBuffers[0].mNumberChannels;
    outputBuffer.mBuffers[0].mDataByteSize = inputBuffer->mBuffers[0].mDataByteSize;
    outputBuffer.mBuffers[0].mData = buffer;

    UInt32 packetSize = 1;
    OSStatus status = AudioConverterFillComplexBuffer(_audioConverter, inputDataProc, inputBuffer, &packetSize, &outputBuffer, NULL);
    if (status != noErr) {
        free(buffer);
        NSError *error = [NSError errorWithDomain:NSOSStatusErrorDomain code:status userInfo:nil];
        NSLog(@"failed to encode audio buffer list: %@", error.description);
        return nil;
    }

    data = [NSData dataWithBytes:buffer length:outputBuffer.mBuffers[0].mDataByteSize];
    free(buffer);
    return data;
}

OSStatus inputDataProc (AudioConverterRef               inAudioConverter,
                        UInt32 *                        ioNumberDataPackets,
                        AudioBufferList *               ioData,
                        AudioStreamPacketDescription * __nullable * __nullable outDataPacketDescription,
                        void * __nullable               inUserData) {
    AudioBufferList inputBuffer = *(AudioBufferList *)inUserData;
    ioData->mBuffers[0].mNumberChannels = inputBuffer.mBuffers[0].mNumberChannels;
    ioData->mBuffers[0].mData = inputBuffer.mBuffers[0].mData;
    ioData->mBuffers[0].mDataByteSize = inputBuffer.mBuffers[0].mDataByteSize;
    return noErr;
}

@end
