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

@property (nonatomic) NSData *APPServiceImageData;

+ (AWBluetooth *)sharedBluetooth;
- (void)createCentralManager;

- (BOOL)isPoweredOn;

- (void)scanPeripherals;
- (void)stopScan;

- (void)connectToPeripheralWithUUIDString:(NSString *)UUIDString;
- (void)connectToPairedPeripheral;
- (void)cancelPeripheralConnection;

- (void)updatePeripheralAPPServiceImage;

@end
