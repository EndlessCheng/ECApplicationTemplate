//
//  NSString+AWHexString.h
//  ECApplicationTemplate
//
//  Created by chengyh on 15/11/16.
//  Copyright © 2015年 jianyan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (AWHexString)

+ (NSString *)hexStringWithData:(NSData *)data;

@end
