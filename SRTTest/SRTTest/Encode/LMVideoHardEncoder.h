//
//  LMVideoHardEncoder.h
//  SRTTest
//
//  Created by Lide on 2020/5/13.
//  Copyright © 2020 Lide. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LMVideoHardEncoder : NSObject

- (id)initWithVideoSettings:(NSDictionary *)videoSettings;
- (void)encodeWithVideoBuffer:(CMSampleBufferRef)videoBuffer;

@end

NS_ASSUME_NONNULL_END
