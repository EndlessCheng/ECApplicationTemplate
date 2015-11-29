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


// 用作PeripheralsPopupView的数据源
@property (nonatomic) NSMutableDictionary<NSNumber *, CBPeripheral *> *peripheralDictionary;
@property (nonatomic) NSMutableDictionary<NSString *, NSString *> *peripheralUUIDStringDictionary;

- (void)scanNormalPeripherals;

// 该方法扫描到OAD外设后断开连接，请求确认是否升级
- (void)scanOADPeripherals;

- (void)scanAllPeripherals;

// 取消绑定、未找到OAD外设
- (void)stopScan;


// 扫描后未绑定时的直连
- (void)connectToPeripheralWithUUIDString:(NSString *)UUIDString;

- (void)connectToPairedPeripheral;

- (void)cancelPeripheralConnection;


// TODO: change to set notify YES if isConnected else connect
@property (nonatomic) BOOL needUpdate;

- (void)updateNormalPeripheral;

// 登陆后、OAD使能后
- (void)scanAndUpdateOADPeripheral;

@end
