//
//  ECUserDefaults.h
//  ECApplicationTemplate
//
//  Created by chengyh on 15/10/22.
//  Copyright © 2015年 jianyan. All rights reserved.
//

#ifndef ECUserDefaults_h
#define ECUserDefaults_h

#import <Foundation/Foundation.h>

#define kUserDefaultsLoginState @"loginState"
typedef NS_ENUM(NSUInteger, ECUserDefaultsLoginState) {
    ECUserDefaultsLoginStateNotLogin,
    ECUserDefaultsLoginStateIsLogin
};

#endif /* ECUserDefaults_h */
