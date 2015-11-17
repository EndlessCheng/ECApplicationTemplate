//
//  PeripheralsPopupView.m
//  ECApplicationTemplate
//
//  Created by chengyh on 15/11/13.
//  Copyright © 2015年 jianyan. All rights reserved.
//

#import "AWBluetooth.h"
#import "AWPeripheral.h"

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
    
    if ([self.peripheralsTableView respondsToSelector:@selector(setLayoutMargins:)]) {
        self.peripheralsTableView.layoutMargins = UIEdgeInsetsZero;
    }
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
                
                [self.peripheralsTableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.manufacturerStrings.count - 1 inSection:0]] withRowAnimation:UITableViewRowAnimationMiddle];
            }
        }];
        
        [[AWBluetooth sharedBluetooth] scanPeripherals];
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
    
    cell.manufacturerLabel.text = [self.manufacturerStrings[indexPath.row] isEqualToString:kOADManufacturerString] ? @"固件升级" : self.manufacturerStrings[indexPath.row];
    cell.pairingPeripheralIndicatorView.hidden = YES;
    cell.manufacturerString = self.manufacturerStrings[indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *manufacturerString = self.manufacturerStrings[indexPath.row];
    if ([manufacturerString isEqualToString:kOADManufacturerString]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"固件升级" message:@"上次升级未成功，是否继续升级？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"继续", nil];
        alertView.tag = PeripheralsPopupViewAlertTagUpdate;
        [alertView show];
    } else {
        PeripheralsTableViewCell *cell = (PeripheralsTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
        cell.pairingPeripheralIndicatorView.hidden = NO;
        
        self.didConnectToUnpairedPeripheralObserver = [[NSNotificationCenter defaultCenter] addObserverForName:kNotificationPeripheralsPopupViewDidConnectToUnpairedPeripheral object:nil queue:nil usingBlock:^(NSNotification *n) {
            [[NSNotificationCenter defaultCenter] removeObserver:self.didConnectToUnpairedPeripheralObserver];
            
            // ???如果响应很慢，直接return，该次连接失败
            if (indexPath.row >= self.manufacturerStrings.count) {
                return;
            }
            
            self.pairedPeripheralUUIDString = [AWBluetooth sharedBluetooth].peripheralUUIDStringDictionary[manufacturerString];
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"连接成功" message:@"是否绑定该设备" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
            alertView.tag = PeripheralsPopupViewAlertTagPairPeripheral;
            [alertView show];
        }];
        
        [[AWBluetooth sharedBluetooth] connectToPeripheralWithUUIDString:[AWBluetooth sharedBluetooth].peripheralUUIDStringDictionary[cell.manufacturerString]];
    }
}


#pragma mark - Alert View Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (alertView.tag) {
        case PeripheralsPopupViewAlertTagPairPeripheral:
            if (buttonIndex == 0) {
                [[AWBluetooth sharedBluetooth] cancelPeripheralConnection];
                [self clearTableView];
                
                [[AWBluetooth sharedBluetooth] scanPeripherals];
            } else if (buttonIndex == 1) {
                NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                [userDefaults setObject:self.pairedPeripheralUUIDString forKey:kUserDefaultsPairedPeripheralUUIDString];
                [userDefaults synchronize];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationPeripheralsPopupViewDidPairToPeripheral object:nil];
                
                self.hidden = YES;
            }
            break;
        case PeripheralsPopupViewAlertTagUpdate:
            if (buttonIndex == 1) {
                [[AWBluetooth sharedBluetooth] updatePeripheralAPPServiceImage];
            }
            break;
        default:
            break;
    }
}

@end
