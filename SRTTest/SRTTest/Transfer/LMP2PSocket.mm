//
//  LMP2PSocket.m
//  SRTTest
//
//  Created by Lide on 2020/5/15.
//  Copyright © 2020 Lide. All rights reserved.
//

#import "LMP2PSocket.h"
#import "srt.h"
//#import <netdb.h>
#include <string>
#include <vector>
#include <net/if.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <ifaddrs.h>
#include <sstream>

using namespace std;

std::vector<struct in_addr> getLocalAddress() {
    std::vector<struct in_addr> result;
    struct ifaddrs* ifap;
    if(::getifaddrs(&ifap) == -1)
    {
        assert(false);
        throw;
    }
    struct ifaddrs* curr = ifap;
    while(curr != 0)
    {
        if(curr->ifa_addr && !(curr->ifa_flags & IFF_LOOPBACK))  // Exclude loopback interface
        {
            if(curr->ifa_addr->sa_family == AF_INET)
            {
                sockaddr_in *sin = (sockaddr_in *)curr->ifa_addr;
                if(sin->sin_addr.s_addr != 0)
                {
                    result.push_back(sin->sin_addr);
                }
            }
        }
        curr = curr->ifa_next;
    }
    ::freeifaddrs(ifap);
    return result;
}

struct in_addr resolveHostName(const std::string& name) {
    int retry = 5;
    struct addrinfo *info = 0;
    struct addrinfo hints = { 0 };
    hints.ai_family = PF_INET;

    int rs = 0;
    do {
        rs = ::getaddrinfo(name.c_str(), 0, &hints, &info);
    } while (info == 0 && rs == EAI_AGAIN && --retry >= 0);

    if (rs != 0) {
        //        assert(false);
        //没有获取IP地址
        in_addr ip = in_addr();
        ip.s_addr = 0;
        return ip;
    }

    sockaddr_in *sin = reinterpret_cast<sockaddr_in *>(info->ai_addr);
    in_addr ip = sin->sin_addr;
    freeaddrinfo(info);

    return ip;
}

@interface LMP2PSocket () {
    SRTSOCKET   _socket;
}

@property (nonatomic, strong) NSString *remoteAddress;

@end

@implementation LMP2PSocket

- (id)init {
    self = [super init];
    if (self != nil) {
        srt_setloglevel(srt_logging::LogLevel::debug);
        _socket = srt_create_socket();

////        bool no = false;
////        if (SRT_ERROR == srt_setsockopt(_socket, 0, SRTO_RCVSYN, &no, sizeof no)) {
////            cout << "srt_setsockopt: " << srt_getlasterror_str() << endl;
////        }
//        int yes = 1;
//        srt_setsockflag(_socket, SRTO_SENDER, &yes, sizeof yes);
////        SRT_TRANSTYPE tt = SRTT_FILE;
////        srt_setsockopt(_socket, 0, SRTO_TRANSTYPE, &tt, sizeof tt);

        // bind local address
        [self bindLocalAddress];
    }

    return self;
}

- (void)bindLocalAddress {
    std::vector<struct in_addr> localAddressArray = ::getLocalAddress();
    std::string ipAddress;
    // TODO:当前只选一个差不多能用的
    for (int i = 0; i < localAddressArray.size(); i++) {
        in_addr sin = localAddressArray[i];
        char *ip = inet_ntoa(sin);
        std::string address = std::string(ip);
        if (address.find("192.168", 0) != std::string::npos) {
            ipAddress = address;
            break;
        } else if (address.find("127.", 0) != std::string::npos) {
            continue;
        } else if (address.find("169.254", 0) != std::string::npos) {
            continue;
        } else {
            ipAddress = address;
            continue;
        }
    }

    unsigned short randomPort = 32768;
    randomPort += arc4random() % 16384;

    sockaddr_in sin;
    memset(&sin, 0, sizeof(sin));
    sin.sin_family = AF_INET;
    sin.sin_port = htons(randomPort);
    sin.sin_addr.s_addr = resolveHostName(ipAddress).s_addr;
    if (srt_bind(_socket, (struct sockaddr *)&sin, sizeof sin) == SRT_ERROR) {
        NSLog(@"failed to bind local address");
    }

    std::stringstream ss;
    ss << ipAddress << ":" << randomPort;
    std::string localIPAddress = ss.str();
    self.localIPAddress = [NSString stringWithCString:localIPAddress.c_str() encoding:NSUTF8StringEncoding];
}

- (BOOL)connectWithAddress:(NSString *)address {
//    if (address == nil || [address isEqualToString:@""]) {
//        NSLog(@"failed to get ip address");
//        return NO;
//    }
//    NSArray *array = [address componentsSeparatedByString:@":"];
//    if ([array count] < 2) {
//        NSLog(@"failed to get ip address");
//        return NO;
//    }
//    NSString *remoteIPAddress = [array firstObject];
//    unsigned short port = [[array lastObject] intValue];
//
//    sockaddr_in sin;
//    memset(&sin, 0, sizeof(sin));
//    sin.sin_family = AF_INET;
//    sin.sin_port = htons(port);
//    sin.sin_addr.s_addr = resolveHostName(std::string([remoteIPAddress UTF8String])).s_addr;
//
//    int result = srt_connect(_socket, (struct sockaddr *)&sin, sizeof sin);
//    if (result == SRT_ERROR) {
//        NSLog(@"failed to connect");
//        cout << "srt_setsockopt: " << srt_getrejectreason(_socket) << endl;
//        return NO;
//    }
//
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        [self startListen];
//    });
    self.remoteAddress = address;

    return YES;
}

- (void)startListen {

}

- (void)sendMessage:(NSString *)message {
    int result = srt_send(_socket, [message UTF8String], int([message length]));
    if (result == SRT_ERROR) {
        NSLog(@"failed to connect");
        cout << "srt_setsockopt: " << srt_getlasterror_str() << endl;
    }
}

- (void)sendFile {
    SRT_TRANSTYPE tt = SRTT_FILE;
    srt_setsockopt(_socket, 0, SRTO_TRANSTYPE, &tt, sizeof tt);

    srt_listen(_socket, 10);

    sockaddr_storage clientaddr;
    int addrlen = sizeof(clientaddr);

    SRTSOCKET fhandle;

    while (true)
    {
       if (SRT_INVALID_SOCK == (fhandle = srt_accept(_socket, (sockaddr*)&clientaddr, &addrlen)))
       {
          cout << "accept: " << srt_getlasterror_str() << endl;
       }

       char clienthost[NI_MAXHOST];
       char clientservice[NI_MAXSERV];
       getnameinfo((sockaddr *)&clientaddr, addrlen, clienthost, sizeof(clienthost), clientservice, sizeof(clientservice), NI_NUMERICHOST|NI_NUMERICSERV);
       cout << "new connection: " << clienthost << ":" << clientservice << endl;

//        CreateThread(NULL, 0, sendfile, new SRTSOCKET(fhandle), 0, NULL);
    }
}

- (void)receiveFile {
    NSString *address = self.remoteAddress;
    if (address == nil || [address isEqualToString:@""]) {
        NSLog(@"failed to get ip address");
    }
    NSArray *array = [address componentsSeparatedByString:@":"];
    if ([array count] < 2) {
        NSLog(@"failed to get ip address");
    }
    NSString *remoteIPAddress = [array firstObject];
    unsigned short port = [[array lastObject] intValue];

    sockaddr_in sin;
    memset(&sin, 0, sizeof(sin));
    sin.sin_family = AF_INET;
    sin.sin_port = htons(port);
    sin.sin_addr.s_addr = resolveHostName(std::string([remoteIPAddress UTF8String])).s_addr;

    SRT_TRANSTYPE tt = SRTT_FILE;
    srt_setsockopt(_socket, 0, SRTO_TRANSTYPE, &tt, sizeof tt);

    int result = srt_connect(_socket, (struct sockaddr *)&sin, sizeof sin);
    if (result == SRT_ERROR) {
        NSLog(@"failed to connect");
        cout << "srt_setsockopt: " << srt_getrejectreason(_socket) << endl;
    }
}

@end
