//
//  ECHTTPUtil.m
//  ECApplicationTemplate
//
//  Created by chengyh on 15/10/28.
//  Copyright © 2015年 jianyan. All rights reserved.
//

#import <SystemConfiguration/SystemConfiguration.h>

#import "ECHTTPUtil.h"

@implementation ECHTTPUtil

+ (BOOL)isNetworkAvailable {
    struct sockaddr_storage zeroAddress;
    bzero(&zeroAddress, sizeof(zeroAddress));
    zeroAddress.ss_len = sizeof(zeroAddress);
    zeroAddress.ss_family = AF_INET;
    
    // 0.0.0.0表示网络中的所有主机，它的作用是帮助路由器发送路由表中无法查询的包。如果设置了全零网络的路由，路由表中无法查询的包都将送到全零网络的路由中去。
    SCNetworkReachabilityRef defaultRouteReachability = SCNetworkReachabilityCreateWithAddress(NULL, (struct sockaddr *)&zeroAddress);
    SCNetworkReachabilityFlags flags;
    BOOL didRetrieveFlags = SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags);
    CFRelease(defaultRouteReachability);
    
    if (!didRetrieveFlags){
        return NO;
    }
    
    BOOL isReachable = flags & kSCNetworkFlagsReachable;
    BOOL needsConnection = flags & kSCNetworkFlagsConnectionRequired;
    return isReachable && !needsConnection;
}

+ (NSData *)fetchDataWithURLString:(NSString *)URLString postDictionary:(NSDictionary *)dictionary {
    if (![self isNetworkAvailable]) {
        NSLog(@"网络连接失败");
        return nil;
    }
    
    NSMutableURLRequest *q = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:URLString]];
    q.HTTPMethod = @"POST";
    q.HTTPBody = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:nil]; // @{@"syn_time" : @(0)}
    q.timeoutInterval = 10.0;
    return nil;
}

+ (BOOL)requestVerificationCodeWithAccount:(NSString *)account error:(NSString **)errorString {
    return YES;
}

+ (BOOL)loginWithUsername:(NSString *)username password:(NSString *)password {
    [[NSUserDefaults standardUserDefaults] setObject:@(ECUserDefaultsLoginStateIsLogin) forKey:kUserDefaultsLoginState];
    [[NSUserDefaults standardUserDefaults] synchronize];
    return YES;
}

+ (AWUserInfo *)fetchUserInfo {
    return [[AWUserInfo alloc] init];
}

@end
