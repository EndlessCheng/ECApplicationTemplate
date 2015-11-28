//
//  ECNotificationNames.h
//  ECApplicationTemplate
//
//  Created by chengyh on 15/11/13.
//  Copyright © 2015年 jianyan. All rights reserved.
//

#ifndef ECNotificationNames_h
#define ECNotificationNames_h

#define kNotificationDidDiscoverAllCharacteristics @"didDiscoverAllCharacteristics"


#pragma mark - Peripheral Core Service (AA50)

#define kNotificationGetSensorData @"getSensorData" // AA51


#pragma mark - Peripheral Extended Service (AB50)

#define kNotificationGetSwimData @"getSwimData" // AB51
#define kNotificationIsReadyForOAD @"isReadyForOAD" // AB55
#define kNotificationGetAPPServiceImageVersion @"getAPPServiceImageVersion" // AB56


#pragma mark - Peripheral OAD Service (FFC0)

#define kNotificationOADServiceImageBlockNumber @"OADServiceImageBlockNumber" // FFC2
#define kOADServiceImageBlockNumber @"OADServiceImageBlockNumber"


#pragma mark - Bluetooth Scan / Connection

#define kNotificationCentralManagerDidUpdateState @"centralManagerDidUpdateState"

#define kNotificationFindNewPeripheral @"findNewPeripheral"
#define kFindNewPeripheralManufacturer @"findNewPeripheralManufacturer"

#define kNotificationConnectionTimeOut @"connectionTimeOut"
#define kNotificationConnectionFailed @"connectionFailed"

#define kNotificationDidConnectPairedPeripheral @"DidConnectPairedPeripheral"
#define kNotificationDidConnectUnpairedPeripheral @"didConnectUnpairedPeripheral"


#endif /* ECNotificationNames_h */
