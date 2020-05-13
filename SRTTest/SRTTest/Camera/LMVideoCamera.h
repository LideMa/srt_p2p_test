//
//  LMVideoCamera.h
//  SRTTest
//
//  Created by Lide on 2020/5/13.
//  Copyright © 2020 Lide. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LMVideoCamera : NSObject

- (void)setPreviewView:(UIView *)previewView;

- (void)startCameraCapture;
- (void)stopCameraCapture;

@end

NS_ASSUME_NONNULL_END
