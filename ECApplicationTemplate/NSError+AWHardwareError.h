//
//  NSError+AWHardwareError.h
//  ECApplicationTemplate
//
//  Created by chengyh on 15/11/24.
//  Copyright © 2015年 jianyan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSError (AWHardwareError)

- (void)handleErrorWithUUIDString:(NSString *)UUIDString;

@end
