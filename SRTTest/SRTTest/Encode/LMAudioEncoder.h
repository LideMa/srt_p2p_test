//
//  LMAudioEncoder.h
//  SRTTest
//
//  Created by Lide on 2020/5/14.
//  Copyright © 2020 Lide. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LMAudioEncoder : NSObject

- (id)initWithAudioSettings:(NSDictionary *)audioSettings;
- (NSData *)encodeWithAudioBufferList:(AudioBufferList *)inputBuffer;

@end

NS_ASSUME_NONNULL_END
