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
    NSLog(@"scanPeripherals self.centralManager.state: %@", @(self.centralManager.state));
    if (![self isPoweredOn]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self scanAllPeripherals];
        });
        return;
    }
    
    self.peripheralUUIDStringDictionary = [[NSMutableDictionary alloc] init];
    NSArray *scanServices = @[[CBUUID UUIDWithString:kNormalStateAdvertisingServiceUUIDString], [CBUUID UUIDWithString:kOADStateAdvertisingServiceUUIDString]]; // and scan FFC0 ???
    NSLog(@"1. scanForPeripheralsWithServices: %@", scanServices);
    [self.centralManager scanForPeripheralsWithServices:scanServices options:nil];
}

- (void)scanOADPeripherals {
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


#pragma mark - Connection

// UUIDString来自 1. 点击的设备 2. 绑定的设备
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
        // now [AWPeripheral sharedPeripheral].isConnected == NO
    }
}


#pragma mark - Update Peripheral APPServiceImage

- (void)updatePeripheralAPPServiceImage {
    if (kFailedUpdateAPPServiceImage) {
        // 默认是OAD状态
        [AWPeripheral sharedPeripheral].peripheralState = AWPeripheralStateOADDisconnection;
        [self scanOADPeripherals];
    } else {
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
    
    if ([AWPeripheral sharedPeripheral].peripheralState == AWPeripheralStateOADDisconnection) {
        if ([peripheral.name isEqualToString:kOADStatePeripheralName]) {
            self.peripheralDictionary[RSSI] = peripheral;
            // 第一次扫描到目标机后，再扫描1.5秒，然后连接RSSI最大的
            // must test if you wanna change this seconds!
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
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationFindNewPeripheral object:@{kFindNewPeripheralManufacturer: manufacturerString}];
        }
    }
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    NSLog(@"3. didConnectPeripheral: %@(%@)", peripheral.name, peripheral.identifier.UUIDString);
    
    [self stopScan];
    
    [AWPeripheral sharedPeripheral].peripheralState |= 1;
    
    if (([AWPeripheral sharedPeripheral].peripheralState >> 1 & 1) == 0) { // OAD 则跳过 post notification
        [[NSNotificationCenter defaultCenter] postNotificationName:(kPairedPeripheralUUIDString ? kNotificationDidConnectPairedPeripheral : kNotificationDidConnectUnpairedPeripheral) object:nil];
    }

    NSArray *services = [peripheral.name isEqualToString:kNormalStatePeripheralName] ? @[[CBUUID UUIDWithString:kAServiceUUIDString], [CBUUID UUIDWithString:kBServiceUUIDString]] : @[[CBUUID UUIDWithString:kOADServiceUUIDString]];
    [peripheral discoverServices:services];
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    // 人为cancelPeripheralConnection
    if (([AWPeripheral sharedPeripheral].peripheralState & 1) == 0) {
        return;
    }
    
    // 重启（含连接充电座）或距离过远
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
