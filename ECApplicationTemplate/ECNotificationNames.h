//
//  ECNotificationNames.h
//  ECApplicationTemplate
//
//  Created by chengyh on 15/11/13.
//  Copyright © 2015年 jianyan. All rights reserved.
//

#ifndef ECNotificationNames_h
#define ECNotificationNames_h

#pragma mark - Peripheral Service A (AA50)

#define kNotificationGetSensorData @"getSensorData" // AA51


#pragma mark - Peripheral Service B (AB50)

#define kNotificationGetAPPServiceImageVersion @"getAPPServiceImageVersion" // AB56

#define kNotificationIsReadyForOAD @"isReadyForOAD" // AB55


#pragma mark - Peripheral Service OAD (FFC0)

#define kNotificationOADServiceImageBlockNumber @"OADServiceImageBlockNumber" // FFC2
#define kOADServiceImageBlockNumber @"OADServiceImageBlockNumber"


#pragma mark - Bluetooth Scan / Connection

#define kNotificationFindNewPeripheral @"findNewPeripheral"
#define kFindNewPeripheralManufacturer @"findNewPeripheralManufacturer"

#define kNotificationConnectionFailed @"connectionFailed"

#define kNotificationDidConnectPairedPeripheral @"DidConnectPairedPeripheral"
#define kNotificationDidConnectUnpairedPeripheral @"didConnectUnpairedPeripheral"


#endif /* ECNotificationNames_h */
