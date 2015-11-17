//
//  ECNotificationNames.h
//  ECApplicationTemplate
//
//  Created by chengyh on 15/11/13.
//  Copyright © 2015年 jianyan. All rights reserved.
//

#ifndef ECNotificationNames_h
#define ECNotificationNames_h

// 扫描到新外设
#define kNotificationPeripheralsPopupViewFindNewPeripheral @"peripheralsPopupViewFindNewPeripheral"
#define kFindNewPeripheralManufacturer @"findNewPeripheralManufacturer"

#define kNotificationConnectionFailed @"connectionFailed"

// 点击待绑定列表中的某个外设之后，连接上
#define kNotificationPeripheralsPopupViewDidConnectToUnpairedPeripheral @"peripheralsPopupViewDidConnectToUnpairedPeripheral"

// 绑定到所连接的外设
#define kNotificationPeripheralsPopupViewDidPairToPeripheral @"peripheralsPopupViewDidPairToUnpairedPeripheral"

// 自动连接
#define kNotificationStartViewControllerDidConnectToPairedPeripheral @"startViewControllerDidConnectToPairedPeripheral"

#define kNotificationOADServiceImageBlockNumber @"OADServiceImageBlockNumber"
#define kOADServiceImageBlockNumber @"OADServiceImageBlockNumber"

#endif /* ECNotificationNames_h */
