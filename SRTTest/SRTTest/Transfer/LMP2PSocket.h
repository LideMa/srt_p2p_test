//
//  LMP2PSocket.h
//  SRTTest
//
//  Created by Lide on 2020/5/15.
//  Copyright © 2020 Lide. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LMP2PSocket : NSObject

@property (nonatomic, strong) NSString *localIPAddress;

- (BOOL)connectWithAddress:(NSString *)address;
- (void)sendMessage:(NSString *)message;

- (void)closeCurrentConnection;

@end

NS_ASSUME_NONNULL_END
