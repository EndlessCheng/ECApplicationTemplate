//
//  AWFileUtil.m
//  ECApplicationTemplate
//
//  Created by chengyh on 15/11/19.
//  Copyright © 2015年 jianyan. All rights reserved.
//

#import "AWFileUtil.h"

@implementation AWFileUtil

+ (NSData *)getLocalAPPServiceImageData {
    NSString *binPath = [[NSBundle mainBundle] pathForResource:@"OADbin" ofType:@"bin"];
//    NSLog(@"binPath: %@", binPath);
    NSData *data = [NSData dataWithContentsOfFile:binPath];
//    NSLog(@"length: %@", @(data.length));
    return data;
}

+ (int)getLocalAPPServiceImageVersion {
    const Byte *bytes = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"OADbin" ofType:@"bin"]].bytes;
    
    // for test
//    return 1000;
    return (bytes[5] << 8 | bytes[4]) >> 1;
}

@end
