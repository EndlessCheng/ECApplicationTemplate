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
- (void)createCentralManager;

- (BOOL)isPoweredOn;

- (void)scanNormalPeripherals;
- (void)stopScan;

- (void)connectToPeripheralWithUUIDString:(NSString *)UUIDString;
- (void)connectToPairedPeripheral;
- (void)cancelPeripheralConnection;

- (void)updatePeripheralAPPServiceImageWithAPPServiceImageData:(NSData *)APPServiceImageData;

@end
