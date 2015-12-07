//
//  ECHTTPUtil.h
//  ECApplicationTemplate
//
//  Created by chengyh on 15/10/28.
//  Copyright © 2015年 jianyan. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AWUserInfo;

@interface ECHTTPUtil : NSObject

+ (BOOL)requestVerificationCodeWithAccount:(NSString *)account error:(NSString **)errorString;

+ (BOOL)loginWithUsername:(NSString *)username password:(NSString *)password;

+ (AWUserInfo *)fetchUserInfo;

@end
