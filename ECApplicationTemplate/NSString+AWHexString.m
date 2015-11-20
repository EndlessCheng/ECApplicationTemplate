//
//  NSString+AWHexString.m
//  ECApplicationTemplate
//
//  Created by chengyh on 15/11/16.
//  Copyright © 2015年 jianyan. All rights reserved.
//

#import "NSString+AWHexString.h"

@implementation NSString (AWHexString)

+ (NSString *)hexStringWithData:(NSData *)data {
    NSMutableString *hexString = [[NSMutableString alloc] init];
    const Byte *bytes = data.bytes;
    for (NSUInteger i = 0; i < data.length; i++) {
        [hexString appendString:[NSString stringWithFormat:@"%02x", bytes[i]]];
    }
    return [NSString stringWithString:hexString];
}

@end
