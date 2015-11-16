//
//  PeripheralsPopupView.m
//  ECApplicationTemplate
//
//  Created by chengyh on 15/11/13.
//  Copyright © 2015年 jianyan. All rights reserved.
//

#import "AWBluetooth.h"

#import "PeripheralsPopupView.h"
#import "PeripheralsTableViewCell.h"

@interface PeripheralsPopupView ()

@property (nonatomic) NSMutableArray<NSString *> *manufacturerStrings;

@property (nonatomic) id<NSObject> findNewPeripheralObserver;
@property (nonatomic) id<NSObject> didConnectToUnpairedPeripheralObserver;

@property (nonatomic) NSString *pairedPeripheralUUIDString;

@end

@implementation PeripheralsPopupView

- (void)awakeFromNib {
    [super awakeFromNib];
    self.manufacturerStrings = [[NSMutableArray alloc] init];
}

- (void)clearTableView {
    [self.manufacturerStrings removeAllObjects];
    [self.peripheralsTableView reloadData];
}

- (void)setHidden:(BOOL)hidden {
    [super setHidden:hidden];
    
    if (hidden) {
        [[NSNotificationCenter defaultCenter] removeObserver:self.findNewPeripheralObserver];
        [self clearTableView];
    } else {
        self.findNewPeripheralObserver = [[NSNotificationCenter defaultCenter] addObserverForName:kNotificationPeripheralsPopupViewFindNewPeripheral object:nil queue:nil usingBlock:^(NSNotification *n) {
            NSDictionary *dict = (NSDictionary *)n.object;
            NSString *manufacturerString = dict[kFindNewPeripheralManufacturer];
            if (![self.manufacturerStrings containsObject:manufacturerString]) {
                [self.manufacturerStrings addObject:manufacturerString];
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.manufacturerStrings.count - 1 inSection:0];
                [self.peripheralsTableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationMiddle];
            }
        }];
        
        [[AWBluetooth sharedBluetooth] scanNormalPeripherals];
    }
}


#pragma mark - Table View

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 13.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.manufacturerStrings.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PeripheralsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PeripheralsTableViewCellIdentifier" forIndexPath:indexPath];
    
    cell.manufacturerLabel.text = self.manufacturerStrings[indexPath.row];
    cell.pairingPeripheralIndicatorView.hidden = YES;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.didConnectToUnpairedPeripheralObserver = [[NSNotificationCenter defaultCenter] addObserverForName:kNotificationPeripheralsPopupViewDidConnectToUnpairedPeripheral object:nil queue:nil usingBlock:^(NSNotification *n) {
        [[NSNotificationCenter defaultCenter] removeObserver:self.didConnectToUnpairedPeripheralObserver];
        
        self.pairedPeripheralUUIDString = [AWBluetooth sharedBluetooth].peripheralUUIDStringDictionary[self.manufacturerStrings[indexPath.row]];
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"连接成功" message:@"是否绑定该设备" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        alertView.tag = PeripheralsPopupViewAlertTagPairPeripheral;
        [alertView show];
    }];
    
    PeripheralsTableViewCell *cell = (PeripheralsTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    cell.pairingPeripheralIndicatorView.hidden = NO;
    [cell.pairingPeripheralIndicatorView startAnimating];
    
    NSString *manufacturerString = cell.manufacturerLabel.text;
    [[AWBluetooth sharedBluetooth] connectToPeripheralWithUUIDString:[AWBluetooth sharedBluetooth].peripheralUUIDStringDictionary[manufacturerString]];
}


#pragma mark - Alert View Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (alertView.tag) {
        case PeripheralsPopupViewAlertTagPairPeripheral:
            if (buttonIndex == 0) {
                [[AWBluetooth sharedBluetooth] disconnectPeripheral];
                [self clearTableView];
                
                [[AWBluetooth sharedBluetooth] createCentralManager];
                [[AWBluetooth sharedBluetooth] scanNormalPeripherals];
            } else if (buttonIndex == 1) {
                
                
                NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                [userDefaults setObject:self.pairedPeripheralUUIDString forKey:kUserDefaultsPairedPeripheralUUIDString];
                [userDefaults synchronize];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationPeripheralsPopupViewDidPairToPeripheral object:nil];
                
                self.hidden = YES;
            }
            break;
        default:
            break;
    }
}

@end
