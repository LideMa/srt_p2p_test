//
//  LMP2PClient.m
//  SRTTest
//
//  Created by Lide on 2020/5/15.
//  Copyright © 2020 Lide. All rights reserved.
//

#import "LMP2PClient.h"
#import "LMP2PSocket.h"

@interface LMP2PClient () {
    LMP2PSocket     *_socket;
}

@end

@implementation LMP2PClient

- (id)init {
    self = [super init];
    if (self != nil) {
        _socket = [[LMP2PSocket alloc] init];
    }

    return self;
}

- (NSString *)getLocalAddress {
    return _socket.localIPAddress;
}

- (BOOL)connectWithAddress:(NSString *)address {
    return [_socket connectWithAddress:address];
}

@end
