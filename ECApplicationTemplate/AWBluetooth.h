//
//  AWBluetooth.h
//  AWBluetooth
//
//  Created by chengyh on 15/11/6.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface AWBluetooth : NSObject <CBCentralManagerDelegate, CBPeripheralDelegate>

@property (nonatomic) NSMutableDictionary<NSNumber *, CBPeripheral *> *peripheralDictionary;
@property (nonatomic) NSMutableDictionary<NSString *, NSString *> *peripheralUUIDStringDictionary;

+ (AWBluetooth *)sharedBluetooth;

- (BOOL)isPoweredOn;

- (void)createCentralManager;
- (void)scanNormalPeripherals;
- (void)stopScan;

- (void)connectToPeripheralWithUUIDString:(NSString *)UUIDString;
- (void)connectToPairedPeripheral;
- (void)disconnectPeripheral;

- (void)updatePeripheralAPPServiceImageWithAPPServiceImageData:(NSData *)APPServiceImageData;

@end
