//
//  AWFileUtil.m
//  ECApplicationTemplate
//
//  Created by chengyh on 15/11/19.
//  Copyright © 2015年 jianyan. All rights reserved.
//

#import "AWFileUtil.h"

NSString *const kAPPServiceImageFileName = @"OADbin";
NSString *const kAPPServiceImageFileTypeName = @"bin";

@implementation AWFileUtil

+ (NSData *)getLocalAPPServiceImageData {
    NSString *binPath = [[NSBundle mainBundle] pathForResource:kAPPServiceImageFileName ofType:kAPPServiceImageFileTypeName];
//    D(binPath);
    NSData *data = [NSData dataWithContentsOfFile:binPath];
//    D(@(data.length));
    return data;
}

+ (NSInteger)getLocalAPPServiceImageVersion {
    const Byte *bytes = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:kAPPServiceImageFileName ofType:kAPPServiceImageFileTypeName]].bytes;

    return (bytes[5] << 8 | bytes[4]) >> 1;
}

@end
