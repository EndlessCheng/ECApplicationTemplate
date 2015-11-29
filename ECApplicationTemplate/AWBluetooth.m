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

// 取-60 ~ -69都是合适的
const float_t MIN_CONNECT_RSSI = -61.0;

typedef NS_ENUM(NSInteger, AWUpdateState) {
    AWUpdateStateNormal, // 未OAD使能下的升级
    AWUpdateStateFindOADWithConfirm, // 扫描到OAD后取消扫描，确认是否升级
    AWUpdateStateFindOADWithoutConfirm, // 扫描到OAD后立刻升级
};

@interface AWBluetooth ()

@property (nonatomic) CBCentralManager *centralManager;

@property (nonatomic) AWUpdateState updateState;

@property (nonatomic) id<NSObject> didDiscoverAllCharacteristicsObserver;

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
}

- (BOOL)isPoweredOn {
    return self.centralManager.state == CBCentralManagerStatePoweredOn;
}


#pragma mark - Scan

// TODO: test if close bluetooth after launched
- (void)scanPeripheralsWithServices:(NSArray<CBUUID *> *)services {
    NSLog(@"\nscanPeripherals self.centralManager.state: %@\n\n", @(self.centralManager.state));
    if (![self isPoweredOn]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t) (0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self scanPeripheralsWithServices:services];
        });
        return;
    }

    self.peripheralUUIDStringDictionary = [[NSMutableDictionary alloc] init];
    NSLog(@"1. scanForPeripheralsWithServices: %@", services);
    [self.centralManager scanForPeripheralsWithServices:services options:nil];
}

- (void)scanNormalPeripherals {
    [self scanPeripheralsWithServices:@[[CBUUID UUIDWithString:kNormalStateAdvertisingServiceUUIDString]]];
}

- (void)scanOADPeripherals {
    self.updateState = AWUpdateStateFindOADWithConfirm;
    [self scanPeripheralsWithServices:@[[CBUUID UUIDWithString:kOADStateAdvertisingServiceUUIDString]]];
}

- (void)scanAllPeripherals {
    [self scanPeripheralsWithServices:@[[CBUUID UUIDWithString:kNormalStateAdvertisingServiceUUIDString], [CBUUID UUIDWithString:kOADStateAdvertisingServiceUUIDString]]];
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

// if ispaired then send this message
- (void)updateNormalPeripheral {
    self.didDiscoverAllCharacteristicsObserver = [[NSNotificationCenter defaultCenter] addObserverForName:kNotificationDidDiscoverAllCharacteristics object:nil queue:nil usingBlock:^(NSNotification *n) {
        [[NSNotificationCenter defaultCenter] removeObserver:self.didDiscoverAllCharacteristicsObserver];
        
        NSLog(@"8. Disable APPServiceImage");
        [[AWPeripheral sharedPeripheral] disableAPPServiceImage];
    }];
    
    [self connectToPairedPeripheral];
}

// @see scanOADPeripherals
- (void)scanAndUpdateOADPeripheral {
    self.updateState = AWUpdateStateFindOADWithoutConfirm;
    [self scanPeripheralsWithServices:@[[CBUUID UUIDWithString:kOADStateAdvertisingServiceUUIDString]]];
}


#pragma mark - Central Manager Delegate

- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationCentralManagerDidUpdateState object:@(central.state)];
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {
    NSLog(@"2. didDiscoverPeripheral: %@(%@)", peripheral.name, peripheral.identifier.UUIDString);
    NSLog(@"kCBAdvDataManufacturerData: %@", advertisementData[@"kCBAdvDataManufacturerData"]);
    NSLog(@"RSSI: %@", RSSI);
    
    // 第一层按设备名处理比updateState更好
    if ([peripheral.name isEqualToString:kNormalStatePeripheralName]) {
        // 绑定
        // 由于信号弱的设备在连接后会由于不稳定而断开连接，所以直接不处理信号弱的设备
        if (RSSI.floatValue < MIN_CONNECT_RSSI) {
            return;
        }
        
        NSString *manufacturerString = [NSString hexStringWithData:advertisementData[@"kCBAdvDataManufacturerData"]];
        self.peripheralUUIDStringDictionary[manufacturerString] = peripheral.identifier.UUIDString;
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationFindNewPeripheral object:@{kFindNewPeripheralManufacturer : manufacturerString}];
    } else {
        // 对OAD设备不要筛选信号，因为升级中断开连接，就算是蓝牙信号弱也可以继续升级
        [self stopScan];
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationFindOADPeripheral object:nil];
        
        if (self.updateState == AWUpdateStateFindOADWithConfirm) {
            return;
        } else if (self.updateState == AWUpdateStateFindOADWithoutConfirm) {
            [self saveAndConnectPeripheral:peripheral];
        } else {
            // TODO: pair 001122334455
        }
    }
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    if (error) {
        [error handleErrorWithUUIDString:peripheral.identifier.UUIDString];
    }
    
    NSLog(@"!!!didFailToConnectPeripheral");
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    NSLog(@"3. didConnectPeripheral: %@(%@)", peripheral.name, peripheral.identifier.UUIDString);

    // 冗余
    [self stopScan];

    [AWPeripheral sharedPeripheral].peripheralState |= 1;
    
    if (([AWPeripheral sharedPeripheral].peripheralState >> 1 & 1) == 0) { // OAD 则跳过 post notification
        [[NSNotificationCenter defaultCenter] postNotificationName:(kPairedPeripheralUUIDString ? kNotificationDidConnectPairedPeripheral : kNotificationDidConnectUnpairedPeripheral) object:nil];
    }
    
    NSArray *services = [peripheral.name isEqualToString:kNormalStatePeripheralName] ? @[[CBUUID UUIDWithString:kWeCoachCoreServiceUUIDString], [CBUUID UUIDWithString:kWeCoachExtendedServiceUUIDString]] : @[[CBUUID UUIDWithString:kOADServiceUUIDString]];
    [peripheral discoverServices:services];
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    // 目前只有解除绑定这一种情况
    if (([AWPeripheral sharedPeripheral].peripheralState & 1) == 0) {
        return;
    }
    
    if (error) {
        [error handleErrorWithUUIDString:peripheral.identifier.UUIDString];
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
        // OAD即意味着升级
        [self scanAndUpdateOADPeripheral];
    } else if (kPairedPeripheralUUIDString) {
        [self connectToPairedPeripheral];
    }
    // 断开发生在确认绑定之前的就不重连了，因为确认绑定后还会再重新连接一次
}

@end
