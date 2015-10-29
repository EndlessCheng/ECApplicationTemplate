//
//  ECHTTPUtils.h
//  ECApplicationTemplate
//
//  Created by chengyh on 15/10/28.
//  Copyright © 2015年 jianyan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ECHTTPUtils : NSObject

+ (BOOL)requestVerificationCodeWithAccount:(NSString *)account error:(NSString **)errorString;

@end
