//
//  AWBluetooth.m
//  AWBluetooth
//
//  Created by chengyh on 15/11/6.
//

#import <UIKit/UIKit.h>

#import "NSString+AWHexString.h"

#import "AWBluetooth.h"
#import "AWPeripheral.h"

@interface AWBluetooth ()

@property (nonatomic) CBCentralManager *centralManager;

@property (nonatomic) BOOL needUpdate;
@property (nonatomic) int APPServiceImageVersion;

// see didDiscoverPeripheral
@property (nonatomic) BOOL isReadyForOAD;
@property (nonatomic) BOOL updateSuccess;

@end

@implementation AWBluetooth

+ (AWBluetooth *)sharedBluetooth {
    static AWBluetooth *sharedBluetooth;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        sharedBluetooth = [[AWBluetooth alloc] init];
    });
    return sharedBluetooth;
}

- (void)createCentralManager {
    self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    self.needUpdate = NO;
}

- (BOOL)isPoweredOn {
    return self.centralManager.state == CBCentralManagerStatePoweredOn;
}


#pragma mark - Scan

// TODO: test if close bluetooth after launched
- (void)scanPeripherals {
    NSLog(@"scanPeripherals self.centralManager.state: %@", @(self.centralManager.state));
    if (![self isPoweredOn]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self scanPeripherals];
        });
        return;
    }
    
    self.peripheralUUIDStringDictionary = [[NSMutableDictionary alloc] init];
    NSArray *scanServices = @[[CBUUID UUIDWithString:kNormalStateAdvertisingServiceUUIDString], [CBUUID UUIDWithString:kOADStateAdvertisingServiceUUIDString]];
    NSLog(@"1. scanForPeripheralsWithServices: %@", scanServices);
    [self.centralManager scanForPeripheralsWithServices:scanServices options:nil];
}

- (void)scanOADPeripherals {
    if (!self.isReadyForOAD) {
        return;
    }
    if (![self isPoweredOn]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self scanOADPeripherals];
        });
        return;
    }
    
    self.peripheralDictionary = [[NSMutableDictionary alloc] init];
    // TODO: try kOADServiceUUIDString ???
    NSArray *scanServices = @[[CBUUID UUIDWithString:kOADStateAdvertisingServiceUUIDString]];
    NSLog(@"1. scanForPeripheralsWithOADServices: %@", scanServices);
    [self.centralManager scanForPeripheralsWithServices:scanServices options:nil];
}

- (void)stopScan {
    [self.centralManager stopScan];
}


#pragma mark - Connect Directly

- (void)connectToPeripheralWithUUIDString:(NSString *)UUIDString {
    if (!UUIDString) {
        NSLog(@"empty UUID string!");
        return;
    }
    
    NSLog(@"connectToPeripheralWithUUIDString self.centralManager.state: %@", @(self.centralManager.state));
    if (![self isPoweredOn]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self connectToPeripheralWithUUIDString:UUIDString];
        });
        return;
    }
    
    NSLog(@"1-2. retrievePeripheralsWithIdentifiers: %@", UUIDString);
    CBPeripheral *pairedPeripheral = [self.centralManager retrievePeripheralsWithIdentifiers:@[[CBUUID UUIDWithString:UUIDString]]][0];
    [self saveAndConnectPeripheral:pairedPeripheral];
}

- (void)connectToPairedPeripheral {
    [self connectToPeripheralWithUUIDString:kPairedPeripheralUUIDString];
}

- (void)cancelPeripheralConnection {
    if ([AWPeripheral sharedPeripheral].pairedPeripheral) {
        [self.centralManager cancelPeripheralConnection:[AWPeripheral sharedPeripheral].pairedPeripheral];
        [AWPeripheral sharedPeripheral].pairedPeripheral = nil;
        // now [AWPeripheral sharedPeripheral].isConnected == NO
    }
}


#pragma mark - Update Peripheral APPServiceImage

- (void)updatePeripheralAPPServiceImage {
    NSString *binPath = [[NSBundle mainBundle] pathForResource:@"OADbin" ofType:@"bin"];
    NSLog(@"binPath: %@", binPath);
    [[AWBluetooth sharedBluetooth] updatePeripheralAPPServiceImageWithAPPServiceImageData:[NSData dataWithContentsOfFile:binPath]];
}

- (void)updatePeripheralAPPServiceImageWithAPPServiceImageData:(NSData *)APPServiceImageData {
//    if ([AWPeripheral sharedPeripheral].APPServiceImageVersion && ![self isNeedUpdate]) {
//        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"当前设备已为最新版本" message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
//        [alertView show];
//        return;
//    }
    self.needUpdate = YES;
    self.updateSuccess = NO;
    self.APPServiceImageData = APPServiceImageData;
    NSLog(@"binData.length: %@", @(self.APPServiceImageData.length));
    const Byte *bytes = self.APPServiceImageData.bytes;
    self.APPServiceImageVersion = bytes[5] << 8 | bytes[4];
    
    // 已进入OAD状态
    if (kFailedUpdateAPPServiceImage) {
        self.isReadyForOAD = YES;
        [self scanOADPeripherals];
    } else {
        self.isReadyForOAD = NO;
        [self connectToPairedPeripheral];
    }
}


#pragma mark - Central Manager Delegate

- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {
    NSLog(@"2. didDiscoverPeripheral: %@(%@)", peripheral.name, peripheral.identifier.UUIDString);
    NSLog(@"advertisementData: %@", advertisementData);
    NSLog(@"RSSI: %@", RSSI);
    
    if (self.isReadyForOAD) {
        if ([peripheral.name isEqualToString:kOADStatePeripheralName]) {
            self.peripheralDictionary[RSSI] = peripheral;
            // 第一次扫描到目标机后，再扫描1.5秒，然后连接RSSI最大的
            if (self.peripheralDictionary.count == 1) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self stopScan];
        
                    NSNumber *maxRSSI = [[self.peripheralDictionary allKeys] valueForKeyPath:@"@max.self"];
                    NSLog(@"maxRSSI: %@", maxRSSI);
                    [self saveAndConnectPeripheral:self.peripheralDictionary[maxRSSI]];
                });
            }
        }
    } else {
        if ([peripheral.name isEqualToString:kNormalStatePeripheralName] || [peripheral.name isEqualToString:kOADStatePeripheralName]) {
            NSString *manufacturerString = [NSString hexStringWithData:advertisementData[@"kCBAdvDataManufacturerData"]];
            self.peripheralUUIDStringDictionary[manufacturerString] = peripheral.identifier.UUIDString;
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationPeripheralsPopupViewFindNewPeripheral object:@{kFindNewPeripheralManufacturer: manufacturerString}];
        }
    }
}

- (void)saveAndConnectPeripheral:(CBPeripheral *)peripheral {
    // must save peripheral before connect
    [AWPeripheral sharedPeripheral].pairedPeripheral = peripheral;
    // now [AWPeripheral sharedPeripheral].isConnected == NO
    
    [self.centralManager connectPeripheral:peripheral options:nil];
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    NSLog(@"3. didConnectPeripheral: %@(%@)", peripheral.name, peripheral.identifier.UUIDString);
    
    [AWPeripheral sharedPeripheral].isConnected = YES;
    
    if (!self.isReadyForOAD) { // OAD 则跳过 post notification
        NSString *postNotificationName = kPairedPeripheralUUIDString ? kNotificationStartViewControllerDidConnectToPairedPeripheral : kNotificationPeripheralsPopupViewDidConnectToUnpairedPeripheral;
        [[NSNotificationCenter defaultCenter] postNotificationName:postNotificationName object:nil];
    }
    
    peripheral.delegate = self;
    NSArray *services = [peripheral.name isEqualToString:kNormalStatePeripheralName] ? @[[CBUUID UUIDWithString:kAServiceUUIDString], [CBUUID UUIDWithString:kBServiceUUIDString]] : @[[CBUUID UUIDWithString:kOADServiceUUIDString]];
    [peripheral discoverServices:services];
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    // 人为cancelPeripheralConnection
    if (![AWPeripheral sharedPeripheral].isConnected) {
        return;
    }
    // 升级成功后断开重启，不处理
    if (self.updateSuccess) {
        self.updateSuccess = NO;
        return;
    }
    
    // 意外断开，如距离过远，连接到充电座等
    NSLog(@"*** didDisconnectPeripheral");
    [AWPeripheral sharedPeripheral].isConnected = NO;
    if (self.isReadyForOAD) {
        [self scanOADPeripherals];
    } else if (kPairedPeripheralUUIDString) {
        [self connectToPairedPeripheral];
    }
    // 断开发生在确认绑定之前的就不重连了
}


#pragma mark - Peripheral Delegate

// 能进入到这一步说明连接信号较强
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error{
    for (CBService *s in peripheral.services) {
        NSString *serviceUUIDString = s.UUID.UUIDString;
        NSLog(@"4. didDiscoverServices: %@", serviceUUIDString);
        [peripheral discoverCharacteristics:nil forService:s]; // discover all characteristics
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    NSLog(@"5. didDiscoverCharacteristicsForService: %@", service.UUID.UUIDString);
    for (CBCharacteristic *c in service.characteristics) {
        // 由于失活APPServiceImage前需先触发版本检测及电量检测，故将失活操作延后0.5秒执行
        if ([c.UUID.UUIDString isEqualToString:kDisableAPPServiceImageCharacteristicUUIDString]) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [[AWPeripheral sharedPeripheral] enableNotificationsForCharacteristic:c];
            });
        } else {
            [[AWPeripheral sharedPeripheral] enableNotificationsForCharacteristic:c];
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    NSLog(@"6. didUpdateNotificationStateForCharacteristic: %@", characteristic.UUID.UUIDString);
    
    [peripheral readValueForCharacteristic:characteristic];
}

- (BOOL)isNeedUpdate {
    NSLog(@"7.1 GetDeviceVersion: %d", [AWPeripheral sharedPeripheral].APPServiceImageVersion);
    return [AWPeripheral sharedPeripheral].APPServiceImageVersion < (self.APPServiceImageVersion >> 1);
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    NSString *characteristicUUIDString = characteristic.UUID.UUIDString;
    NSData *readData = characteristic.value;
    [[AWPeripheral sharedPeripheral] setData:readData fromCharacteristicUUIDString:characteristicUUIDString];
    
//    if ([characteristicUUIDString isEqualToString:kSensorWorkModelCharacteristicUUIDString]) {
//        NSLog(@".SensorWorkModel, write 0X03");
//        Byte writeBytes[] = {0X03}; // 写入0X03，建立完全连接
//        NSData *writeData = [NSData dataWithBytes:writeBytes length:sizeof(writeBytes)];
//        [peripheral writeValue:writeData forCharacteristic:characteristic type:CBCharacteristicWriteWithResponse];
//    } else
    if ([characteristicUUIDString isEqualToString:kProtectConnectionCharacteristicUUIDString]) {
        [[AWPeripheral sharedPeripheral] protectConnection];
    } else if ([characteristicUUIDString isEqualToString:kGetAPPServiceImageVersionCharacteristicUUIDString]) {
        if (!self.needUpdate) {
            return;
        }
//        if (![self isNeedUpdate]) {
//            self.needUpdate = NO;
//            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"当前设备已为最新版本" message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
//            [alertView show];
//            return;
//        }
    } else if ([characteristicUUIDString isEqualToString:kGetSensorDataCharacteristicUUIDString]) {
        if (!self.needUpdate) {
            return;
        }
        if ([AWPeripheral sharedPeripheral].isCharging) {
            self.needUpdate = NO;
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"请勿在升级时充电" message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
            [alertView show];
            return;
        }
        int batteryPercentage = (int)[AWPeripheral sharedPeripheral].batteryPercentage;
        NSLog(@"7.3. GetBatteryVoltage: %d", batteryPercentage);
        if (batteryPercentage <= 15) {
            self.needUpdate = NO;
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"设备电量不足%d%%", batteryPercentage] message:@"请充电后再升级" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
            [alertView show];
            return;
        }
    } else if ([characteristicUUIDString isEqualToString:kDisableAPPServiceImageCharacteristicUUIDString]) {
        if (!self.needUpdate) {
            return;
        }
        NSLog(@"8. Disable APPServiceImage");
        [[AWPeripheral sharedPeripheral] disableAPPServiceImage];
        // 由于断开后连上很快，并且为防止意外的bug，这里不设置pairedPeripheral = nil;
        self.isReadyForOAD = YES;
        
        // 更新后UUID会变吗？
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:@(NO) forKey:kUserDefaultsDidUpdateAPPServiceImage];
        [userDefaults synchronize];
        
        [self scanOADPeripherals];
    } else if ([characteristicUUIDString isEqualToString:kOADServiceImageIdentifyCharacteristicUUIDString]) {
        if (!self.isReadyForOAD) {
            return;
        }
        // 准备激活OAD
        NSLog(@"9. Identify OADServiceImage");
        [[AWPeripheral sharedPeripheral] identifyOADServiceImageWithOADServiceImageData:self.APPServiceImageData];
    } else if ([characteristicUUIDString isEqualToString:kOADServiceImageBlockCharacteristicUUIDString]){
        if (error) {
            NSLog(@"[error description]: %@", [error description]);
            // TODO: deal NSLog(error);
            return;
        }
        
        int OADServiceImageWriteBlockNumber = [AWPeripheral sharedPeripheral].OADServiceImageWriteBlockNumber;
        NSLog(@"10. OADServiceImage Block offset: %d", OADServiceImageWriteBlockNumber);
        
        [[AWPeripheral sharedPeripheral] writeOADServiceImageWithOADServiceImageData:self.APPServiceImageData];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationOADServiceImageBlockNumber object:@{kOADServiceImageBlockNumber : @(OADServiceImageWriteBlockNumber)}];
        
        // 如果最后一个14字节块未写入的部分用0xff填充
        // 此时硬件会和蓝牙断开连接并重启，重启后OAD即完成。
        if ((OADServiceImageWriteBlockNumber + 1) << 4 == self.APPServiceImageData.length) {
            self.updateSuccess = YES;
            self.isReadyForOAD = NO;
            self.needUpdate = NO;
            
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            [userDefaults setObject:@(YES) forKey:kUserDefaultsDidUpdateAPPServiceImage];
            [userDefaults synchronize];
        }
    }
}

@end
