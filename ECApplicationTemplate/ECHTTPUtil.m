//
//  ECHTTPUtil.m
//  ECApplicationTemplate
//
//  Created by chengyh on 15/10/28.
//  Copyright © 2015年 jianyan. All rights reserved.
//

#import "ECHTTPUtil.h"

@implementation ECHTTPUtil

+ (BOOL)requestVerificationCodeWithAccount:(NSString *)account error:(NSString **)errorString {
    return YES;
}

+ (BOOL)login {
    [[NSUserDefaults standardUserDefaults] setObject:@(ECUserDefaultsLoginStateIsLogin) forKey:kUserDefaultsLoginState];
    [[NSUserDefaults standardUserDefaults] synchronize];
    return YES;
}

+ (AWUserInfo *)fetchUserInfo {
    return [[AWUserInfo alloc] init];
}

@end
