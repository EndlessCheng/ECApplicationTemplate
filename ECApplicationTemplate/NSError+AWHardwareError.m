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
    NSLog(@"[ERROR at %@]", [[NSThread callStackSymbols][1] componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"[]"]][1]);
    D(UUIDString);
    D(self.description);
    
    // 跳过OAD的error
    if (([AWPeripheral sharedPeripheral].peripheralState >> 1 & 1) == 1) {
        return;
    }
    
    [AWPeripheral sharedPeripheral].peripheralState &= 254; // 11111110
    switch (self.code) {
        case 6: // "The connection has timed out unexpectedly."
            break;
        case 10:
            NSLog(@"[蓝牙连接失败]");
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationConnectionFailed object:nil];
            break;
        case 14: // "Unlikely error."
            NSLog(@"[Unlikely error]");
            break;
        default:
            break;
    }
}

@end
