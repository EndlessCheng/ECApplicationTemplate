//
//  AWBluetooth.h
//  AWBluetooth
//
//  Created by chengyh on 15/11/6.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface AWBluetooth : NSObject <CBCentralManagerDelegate>

+ (AWBluetooth *)sharedBluetooth;
- (void)createCentralManager;


@property (nonatomic) NSMutableDictionary<NSNumber *, CBPeripheral *> *peripheralDictionary;
@property (nonatomic) NSMutableDictionary<NSString *, NSString *> *peripheralUUIDStringDictionary;

- (BOOL)isPoweredOn;

- (void)scanAllPeripherals;
- (void)scanOADPeripherals;
- (void)stopScan;

- (void)connectToPeripheralWithUUIDString:(NSString *)UUIDString;
- (void)connectToPairedPeripheral;
- (void)cancelPeripheralConnection;


@property (nonatomic) BOOL needUpdate;

- (void)updatePeripheralAPPServiceImage;

@end
