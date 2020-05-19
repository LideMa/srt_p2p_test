//
//  LMP2PClient.h
//  SRTTest
//
//  Created by Lide on 2020/5/15.
//  Copyright © 2020 Lide. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LMP2PClient : NSObject

- (NSString *)getLocalAddress;
- (BOOL)connectWithAddress:(NSString *)address;
- (void)sendMessage:(NSString *)message;

- (void)sendFile;
- (void)receiveFile;

@end

NS_ASSUME_NONNULL_END
