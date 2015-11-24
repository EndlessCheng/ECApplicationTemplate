//
//  NSError+AWHardwareError.m
//  ECApplicationTemplate
//
//  Created by chengyh on 15/11/24.
//  Copyright © 2015年 jianyan. All rights reserved.
//

#import "NSError+AWHardwareError.h"
#import "AWPeripheral.h"

@implementation NSError (AWHardwareError)

- (void)handleErrorWithUUIDString:(NSString *)UUIDString {
    // FIXME:
    // 多次断开待绑定设备后无法连接：CBErrorDomain Code=0 "Unknown error."
    // 连上设备后刚好设备没电：CBErrorDomain Code=3 "The specified device is not connected."
    NSLog(@"[ERROR] %@", UUIDString);
    [AWPeripheral sharedPeripheral].peripheralState &= 254; // 11111110
    switch (self.code) {
        case 6:
            NSLog(@"[蓝牙连接超时]");
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationConnectionTimeOut object:nil];
            break;
        case 10:
            NSLog(@"[蓝牙连接失败]");
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationConnectionFailed object:nil];
            break;
        case 14:
            NSLog(@"[Unlikely error]");
            break;
        default:
            NSLog(@"%@", self.description);
            break;
    }
}

@end
