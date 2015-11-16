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
@property (nonatomic) NSData *APPServiceImageData;
@property (nonatomic) int APPServiceImageVersion;

// 见didDiscoverPeripheral方法
@property (nonatomic) BOOL isReadyForOAD;

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

- (BOOL)isPoweredOn {
    return self.centralManager.state == CBCentralManagerStatePoweredOn;
}

- (void)createCentralManager {
    self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    self.needUpdate = NO;
}

#pragma mark - Scan

// TODO: 精确地等待到系统响应
// TODO: close bluetooth after launched
- (void)scanNormalPeripherals {
    NSLog(@"scanNormalPeripherals self.centralManager.state: %@", @(self.centralManager.state));
    if (![self isPoweredOn]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self scanNormalPeripherals];
        });
        return;
    }
    
    self.peripheralUUIDStringDictionary = [[NSMutableDictionary alloc] init];
    NSArray *scanServices = @[[CBUUID UUIDWithString:kNormalStateAdvertisingServiceUUIDString]];
    NSLog(@"1. scanForPeripheralsWithServices: %@", scanServices);
    [self.centralManager scanForPeripheralsWithServices:scanServices options:nil];
}

- (void)stopScan {
    [self.centralManager stopScan];
}


#pragma mark - Connect Directly

// 禁止接受manufacturerString作为参数！只有UUID才能直连
- (void)connectToPeripheralWithUUIDString:(NSString *)UUIDString {
    NSLog(@"connectToPeripheralWithUUIDString self.centralManager.state: %@", @(self.centralManager.state));
    if (![self isPoweredOn]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self connectToPeripheralWithUUIDString:UUIDString];
        });
        return;
    }
    
    CBPeripheral *pairedPeripheral = [self.centralManager retrievePeripheralsWithIdentifiers:@[[CBUUID UUIDWithString:UUIDString]]][0];
    [self saveAndConnectPeripheral:pairedPeripheral];
}

- (void)connectToPairedPeripheral {
    NSLog(@"1-2. retrievePeripheralsWithIdentifiers: %@", kPairedPeripheralUUIDString);
    [self connectToPeripheralWithUUIDString:kPairedPeripheralUUIDString];
}

- (void)disconnectPeripheral {
    [AWPeripheral sharedPeripheral].pairedPeripheral = nil;
    self.centralManager = nil;
}


#pragma mark - Update Peripheral APPServiceImage

- (void)updatePeripheralAPPServiceImageWithAPPServiceImageData:(NSData *)APPServiceImageData {
    if (!self.centralManager) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"未绑定设备" message:@"请先绑定设备后再升级" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alertView show];
        return;
    }
    
    self.needUpdate = YES;
    NSString *binPath = [[NSBundle mainBundle] pathForResource:@"OADbin" ofType:@"bin"];
    NSLog(@"binPath: %@", binPath);
    self.APPServiceImageData = [NSData dataWithContentsOfFile:binPath];
    
    
    self.APPServiceImageData = APPServiceImageData;
    NSLog(@"binData.length: %@", @(self.APPServiceImageData.length));
    
    const Byte *bytes = self.APPServiceImageData.bytes;
    self.APPServiceImageVersion = bytes[5] << 8 | bytes[4];
    
    [self scanNormalPeripherals];
}

- (void)prepareForOAD {
    self.peripheralDictionary = [[NSMutableDictionary alloc] init];
    self.isReadyForOAD = YES;
}

- (void)scanOADPeripherals {
    NSLog(@"self.centralManager.state: %@", @(self.centralManager.state));
    
    if (self.centralManager.state == CBCentralManagerStatePoweredOn) {
        self.peripheralDictionary = [[NSMutableDictionary alloc] init];
        // TODO: try kOADServiceUUIDString ???
        NSArray *scanServices = @[[CBUUID UUIDWithString:kOADStateAdvertisingServiceUUIDString]];
        NSLog(@"1. scanForPeripheralsWithServices: %@", scanServices);
        [self.centralManager scanForPeripheralsWithServices:scanServices options:nil];
    }
}


#pragma mark - Central Manager Delegate

- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    if (kPairedPeripheralUUIDString) {
        [self connectToPairedPeripheral];
    }
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {
    NSLog(@"2. didDiscoverPeripheral: %@(%@)", peripheral.name, peripheral.identifier.UUIDString);
    NSLog(@"advertisementData: %@", advertisementData);
    NSData *manufacturerData = advertisementData[@"kCBAdvDataManufacturerData"];
    NSString *manufacturerString = [NSString hexStringWithData:manufacturerData];
    NSLog(@"manufacturerData: %@", manufacturerString);
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
        if ([peripheral.name isEqualToString:kNormalStatePeripheralName]) {
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
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (![AWPeripheral sharedPeripheral].isConnected) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"连接失败" message:@"请将手机靠近设备后再尝试" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
            [alertView show];
        }
    });
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    NSLog(@"3. didConnectPeripheral: %@(%@)", peripheral.name, peripheral.identifier.UUIDString);
    
    [AWPeripheral sharedPeripheral].isConnected = YES;
    
    if ([peripheral.name isEqualToString:kNormalStatePeripheralName]) {
        NSString *postNotificationName = kPairedPeripheralUUIDString ? kNotificationStartViewControllerDidConnectToPairedPeripheral : kNotificationPeripheralsPopupViewDidConnectToUnpairedPeripheral;
        [[NSNotificationCenter defaultCenter] postNotificationName:postNotificationName object:nil];
    }
    
    peripheral.delegate = self;
    NSArray *services = [peripheral.name isEqualToString:kNormalStatePeripheralName] ? @[[CBUUID UUIDWithString:kAServiceUUIDString], [CBUUID UUIDWithString:kBServiceUUIDString]] : @[[CBUUID UUIDWithString:kOADServiceUUIDString]];
    [peripheral discoverServices:services];
}

// TODO: 蓝牙非人为断开时重新连接
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    NSLog(@"*** didDisconnectPeripheral");
    [AWPeripheral sharedPeripheral].isConnected = NO;
    [self connectToPairedPeripheral];
}

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
    // TODO: OAD到一半就中断的设备版本号是多少？

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
        if (![self isNeedUpdate]) {
            self.needUpdate = NO;
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"当前设备已为最新版本" message:nil delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
            [alertView show];
            return;
        }
    } else if ([characteristicUUIDString isEqualToString:kGetSensorDataCharacteristicUUIDString]) {
        if (!self.needUpdate) {
            return;
        }
//        NSLog(@"7.2. isCharging: %d", [AWPeripheral sharedPeripheral].isCharging);
        if ([AWPeripheral sharedPeripheral].isCharging) {
            self.needUpdate = NO;
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"请勿在升级时充电" message:nil delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
            [alertView show];
            return;
        }
        int batteryPercentage = (int)[AWPeripheral sharedPeripheral].batteryPercentage;
//        NSLog(@"7.3. GetBatteryVoltage: %f", batteryVoltage);
        if (batteryPercentage <= 15) {
            self.needUpdate = NO;
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"设备电量不足%d%%", batteryPercentage] message:@"请充电后再升级" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
            [alertView show];
            return;
        }
    } else if ([characteristicUUIDString isEqualToString:kDisableAPPServiceImageCharacteristicUUIDString]) {
        if (!self.needUpdate) {
            return;
        }
        NSLog(@"8. Disable APPServiceImage");
        [[AWPeripheral sharedPeripheral] disableAPPServiceImage];
        [self prepareForOAD];
        [self scanOADPeripherals];
    } else if ([characteristicUUIDString isEqualToString:kOADServiceImageIdentifyCharacteristicUUIDString]) {
        // 准备激活OAD
        NSLog(@"9. Identify OADServiceImage");
        [[AWPeripheral sharedPeripheral] identifyOADServiceImageWithOADServiceImageData:self.APPServiceImageData];
    } else if ([characteristicUUIDString isEqualToString:kOADServiceImageBlockCharacteristicUUIDString]){
        if (error) {
            // TODO: deal NSLog(error);
            return;
        }
        
        int OADServiceImageWriteOffset = [AWPeripheral sharedPeripheral].OADServiceImageWriteOffset;
        NSLog(@"11. OADServiceImage Block offset: %d", OADServiceImageWriteOffset);
        
        [[AWPeripheral sharedPeripheral] writeOADServiceImageWithOADServiceImageData:self.APPServiceImageData];
        
        // 如果最后一个14字节块未写入的部分用0xff填充
        // 此时硬件会和蓝牙断开连接并重启，重启后OAD即完成。
        if (OADServiceImageWriteOffset == 2815) {
            self.isReadyForOAD = NO;
            self.needUpdate = NO;
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"升级成功" message:@"您的固件已升级到最新版本" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
            [alertView show];
            
            [self scanNormalPeripherals];
        }
    }
}

@end
