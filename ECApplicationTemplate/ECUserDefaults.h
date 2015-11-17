//
//  ECUserDefaults.h
//  ECApplicationTemplate
//
//  Created by chengyh on 15/10/22.
//  Copyright © 2015年 jianyan. All rights reserved.
//

#ifndef ECUserDefaults_h
#define ECUserDefaults_h

#define kUserDefaultsLoginState @"loginState"
typedef NS_ENUM(NSUInteger, ECUserDefaultsLoginState) {
    ECUserDefaultsLoginStateNotLogin,
    ECUserDefaultsLoginStateIsLogin
};

#define kUserDefaultsPairedPeripheralUUIDString @"pairedPeripheralUUIDString"
#define kPairedPeripheralUUIDString [[NSUserDefaults standardUserDefaults] stringForKey:kUserDefaultsPairedPeripheralUUIDString]

#define kUserDefaultsDidUpdateAPPServiceImage @"didUpdateAPPServiceImage"
#define kFailedUpdateAPPServiceImage ([[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultsDidUpdateAPPServiceImage] && !((NSNumber *)[[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultsDidUpdateAPPServiceImage]).boolValue)

#endif /* ECUserDefaults_h */
