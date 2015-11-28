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
- (void)scanAllPeripherals {
    NSLog(@"\nscanPeripherals self.centralManager.state: %@\n\n", @(self.centralManager.state));
    if (![self isPoweredOn]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t) (0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self scanAllPeripherals];
        });
        return;
    }

    self.peripheralUUIDStringDictionary = [[NSMutableDictionary alloc] init];
    // TODO: try scan FFC0 ???
    NSArray *scanServices = @[[CBUUID UUIDWithString:kNormalStateAdvertisingServiceUUIDString], [CBUUID UUIDWithString:kOADStateAdvertisingServiceUUIDString]];
    NSLog(@"1. scanForPeripheralsWithServices: %@", scanServices);
    [self.centralManager scanForPeripheralsWithServices:scanServices options:nil];
}

- (void)scanOADPeripherals {
    if (![self isPoweredOn]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t) (0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self scanOADPeripherals];
        });
        return;
    }

    self.peripheralDictionary = [[NSMutableDictionary alloc] init];
    // TODO: try scan FFC0 ???
    NSArray *scanServices = @[[CBUUID UUIDWithString:kOADStateAdvertisingServiceUUIDString]];
    NSLog(@"1. scanForPeripheralsWithOADServices: %@", scanServices);
    [self.centralManager scanForPeripheralsWithServices:scanServices options:nil];
}

- (void)stopScan {
    [self.centralManager stopScan];
}


#pragma mark - Connection

// UUIDString来自 1. 点击的设备 2. 绑定的设备
- (void)connectToPeripheralWithUUIDString:(NSString *)UUIDString {
    if (!UUIDString) {
        NSLog(@"empty UUID string!");
        return;
    }

    NSLog(@"\nconnectToPeripheralWithUUIDString self.centralManager.state: %@\n\n", @(self.centralManager.state));
    if (![self isPoweredOn]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t) (0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
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

- (void)saveAndConnectPeripheral:(CBPeripheral *)peripheral {
    // must save peripheral before connect
    [AWPeripheral sharedPeripheral].pairedPeripheral = peripheral;
    // now [AWPeripheral sharedPeripheral].peripheralState is disconnection

    [self.centralManager connectPeripheral:peripheral options:nil];
}

- (void)cancelPeripheralConnection {
    if ([AWPeripheral sharedPeripheral].pairedPeripheral) {
        // 一定要先断开再释放
        [self.centralManager cancelPeripheralConnection:[AWPeripheral sharedPeripheral].pairedPeripheral];
        [AWPeripheral sharedPeripheral].pairedPeripheral = nil;
        // now [AWPeripheral sharedPeripheral].isConnected is NO
    }
}


#pragma mark - Update Peripheral APPServiceImage

- (void)updatePeripheralAPPServiceImage {
    if (kFailedUpdateAPPServiceImage) {
        // 默认是OAD状态
        [AWPeripheral sharedPeripheral].peripheralState = AWPeripheralStateOADDisconnection;
        [self scanOADPeripherals];
    } else {
        // TODO: change to set notify YES if isConnected else connect
        [self connectToPairedPeripheral];
        [AWPeripheral sharedPeripheral].needUpdate = YES;
        // HACK: may error when update just after connect
    }
}


#pragma mark - Central Manager Delegate

- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationCentralManagerDidUpdateState object:@(central.state)];
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {
    NSLog(@"2. didDiscoverPeripheral: %@(%@)", peripheral.name, peripheral.identifier.UUIDString);
    NSLog(@"advertisementData: %@", advertisementData);
    NSLog(@"RSSI: %@", RSSI);

    if ([AWPeripheral sharedPeripheral].peripheralState == AWPeripheralStateOADDisconnection) {
        // 此时设备已OAD
        if ([peripheral.name isEqualToString:kOADStatePeripheralName]) {
            self.peripheralDictionary[RSSI] = peripheral;
            // 第一次扫描到目标机后，再扫描1.5秒，然后连接RSSI最大的
            // must test if you wanna change this seconds!
            if (self.peripheralDictionary.count == 1) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t) (1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self stopScan];

                    NSNumber *maxRSSI = [[self.peripheralDictionary allKeys] valueForKeyPath:@"@max.self"];
                    NSLog(@"maxRSSI: %@", maxRSSI);
                    [self saveAndConnectPeripheral:self.peripheralDictionary[maxRSSI]];
                    [AWPeripheral sharedPeripheral].needUpdate = YES;
                });
            }
        }
    } else {
        // 绑定
        if ([peripheral.name isEqualToString:kNormalStatePeripheralName] || [peripheral.name isEqualToString:kOADStatePeripheralName]) {
            NSString *manufacturerString = [NSString hexStringWithData:advertisementData[@"kCBAdvDataManufacturerData"]];
            self.peripheralUUIDStringDictionary[manufacturerString] = peripheral.identifier.UUIDString;
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationFindNewPeripheral object:@{kFindNewPeripheralManufacturer : manufacturerString}];
        }
    }
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    if (error) {
        [error handleErrorWithUUIDString:peripheral.identifier.UUIDString];
//        return;
    }
    
    NSLog(@"!!!didFailToConnectPeripheral");
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    NSLog(@"3. didConnectPeripheral: %@(%@)", peripheral.name, peripheral.identifier.UUIDString);

    [self stopScan];

    [AWPeripheral sharedPeripheral].peripheralState |= 1;
    // 蓝牙可能马上断开，等待0.6秒再连
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (([AWPeripheral sharedPeripheral].peripheralState & 1) == 0) {
            return;
        }
        
        if (([AWPeripheral sharedPeripheral].peripheralState >> 1 & 1) == 0) { // OAD 则跳过 post notification
            [[NSNotificationCenter defaultCenter] postNotificationName:(kPairedPeripheralUUIDString ? kNotificationDidConnectPairedPeripheral : kNotificationDidConnectUnpairedPeripheral) object:nil];
        }
        
        NSArray *services = [peripheral.name isEqualToString:kNormalStatePeripheralName] ? @[[CBUUID UUIDWithString:kWeCoachCoreServiceUUIDString], [CBUUID UUIDWithString:kWeCoachExtendedServiceUUIDString]] : @[[CBUUID UUIDWithString:kOADServiceUUIDString]];
        [peripheral discoverServices:services];
    });
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    // 目前只有解除绑定这一种情况
    if (([AWPeripheral sharedPeripheral].peripheralState & 1) == 0) {
        return;
    }
    
    if (error) {
        [error handleErrorWithUUIDString:peripheral.identifier.UUIDString];
        if (error.code != 6) {
            return;
        }
    }

    /*
     1. 自动重启，如OAD化，OAD结束
     2. 手动重启，如连接充电座
     3. 距离过远
     4. 没电
     */
    NSLog(@"*** didDisconnectPeripheral");
    [AWPeripheral sharedPeripheral].peripheralState &= 254; // 11111110
    if (([AWPeripheral sharedPeripheral].peripheralState >> 1 & 1) == 1) {
        [self scanOADPeripherals];
    } else if (kPairedPeripheralUUIDString) {
        [self connectToPairedPeripheral];
    }
    // 断开发生在确认绑定之前的就不重连了
}

@end
