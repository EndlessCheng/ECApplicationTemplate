//
//  SettingsViewController.m
//  ECApplicationTemplate
//
//  Created by chengyh on 15/10/21.
//  Copyright © 2015年 jianyan. All rights reserved.
//

#import "AWBluetooth.h"

#import "SettingsViewController.h"
#import "SettingsTableViewCell.h"
#import "SettingsModel.h"

@interface SettingsViewController ()

@property (nonatomic) SettingsModel *settingsModel;

@property (nonatomic) id<NSObject> didPairToPeripheralObserver;
@property (nonatomic) id<NSObject> updateAPPServiceImageObserver;

@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.settingsModel = [[SettingsModel alloc] init];
    self.settingsTableView.dataSource = self.settingsModel;
    
    self.navigationItem.title = NSLocalizedString(@"设置",);
    
    if ([self.settingsTableView respondsToSelector:@selector(setLayoutMargins:)]) {
        self.settingsTableView.layoutMargins = UIEdgeInsetsZero;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.settingsTableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)reloadPairPeripheralCell {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:1 inSection:1];
    SettingsTableViewCell *cell = (SettingsTableViewCell *)[self.settingsTableView cellForRowAtIndexPath:indexPath];
    cell.infoLabel.text = kSettingsPairPeripheralInfoLabelText;
    [self.settingsTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
}

- (void)updateUpdateProgressViewWithWrittenBytesLength:(long)writtenBytesLength {
    self.updateProgressView.progress = (float)writtenBytesLength / [AWBluetooth sharedBluetooth].APPServiceImageData.length;
    self.progressPercentLabel.text = [NSString stringWithFormat:@"%.1f%%", self.updateProgressView.progress * 100];
    self.progressRateLabel.text = [NSString stringWithFormat:@"%ld/%ld", (long)(writtenBytesLength * UPDATE_PROGRESS_MAGIC), (long)([AWBluetooth sharedBluetooth].APPServiceImageData.length * UPDATE_PROGRESS_MAGIC)];
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

#pragma mark - Table View Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 8.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 1:
            switch (indexPath.row) {
                case 1: {
                    if (kPairedPeripheralUUIDString) {
                        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"解除绑定" message:@"解绑后蓝牙将会断开" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
                        alertView.tag = SettingsAlertTagDisPair;
                        [alertView show];
                    } else {
                        self.didPairToPeripheralObserver = [[NSNotificationCenter defaultCenter] addObserverForName:kNotificationPeripheralsPopupViewDidPairToPeripheral object:nil queue:nil usingBlock:^(NSNotification *n) {
                            // 已绑定并连接设备
                            [[NSNotificationCenter defaultCenter] removeObserver:self.didPairToPeripheralObserver];
                            
                            [self reloadPairPeripheralCell];
                        }];
                        
                        self.peripheralPopupView.hidden = NO;
                    }
                    break;
                } case 2: {
                    if (kFailedUpdateAPPServiceImage) {
                        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"固件升级" message:@"上次升级未成功，按确定开始升级。" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
                        alertView.tag = SettingsAlertTagUpdate;
                        [alertView show];
                        break;
                    }
                    if (!kPairedPeripheralUUIDString) {
                        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"未绑定设备" message:@"请先绑定设备后再升级" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
                        [alertView show];
                        break;
                    }
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"固件升级" message:@"升级耗时约2分钟，按确定开始升级。" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
                    alertView.tag = SettingsAlertTagUpdate;
                    [alertView show];
                    break;
                } default:
                    break;
            }
            break;
        case 3:
            switch (indexPath.row) {
                case 0: {
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"乃确定不是手滑了吗？",) message:nil delegate:self cancelButtonTitle:@"我手滑了" otherButtonTitles:@"我要退出", nil];
                    alertView.tag = SettingsAlertTagLogOut;
                    [alertView show];
                    break;
                }
                default:
                    break;
            }
            break;
        default:
            break;
    }
}


#pragma mark - Alert View Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    switch (alertView.tag) {
        case SettingsAlertTagDisPair:
            if (buttonIndex == 1) {
                [[AWBluetooth sharedBluetooth] cancelPeripheralConnection];
                [userDefaults removeObjectForKey:kUserDefaultsPairedPeripheralUUIDString];
                [userDefaults synchronize];
                
                [self reloadPairPeripheralCell];
            }
            break;
        case SettingsAlertTagUpdate:
            if (buttonIndex == 1) {
                self.updateProgressView.progress = 0.0;
                self.progressPercentLabel.text = @"0.0%";
                self.progressRateLabel.text = @"启动中...";
                self.updateProgressBackgroundView.hidden = NO;
                
                self.updateAPPServiceImageObserver = [[NSNotificationCenter defaultCenter] addObserverForName:kNotificationOADServiceImageBlockNumber object:nil queue:nil usingBlock:^(NSNotification *n) {
                    NSDictionary *dict = (NSDictionary *)n.object;
                    NSNumber *OADServiceImageBlockNumber = dict[kOADServiceImageBlockNumber];
                    long writtenBytesLength = (OADServiceImageBlockNumber.integerValue + 1) << 4;
                    
                    [self updateUpdateProgressViewWithWrittenBytesLength:writtenBytesLength];
                    
                    if (writtenBytesLength == [AWBluetooth sharedBluetooth].APPServiceImageData.length) {
                        [[NSNotificationCenter defaultCenter] removeObserver:self.updateAPPServiceImageObserver];
                        
                        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"升级成功" message:@"您的固件已升级到最新版本，赶快运动吧" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
                        [alertView show];
                        self.updateProgressBackgroundView.hidden = YES;
                    }
                }];
                
                [[AWBluetooth sharedBluetooth] updatePeripheralAPPServiceImage];
            }
            break;
        case SettingsAlertTagLogOut:
            if (buttonIndex == 1) {
                [[AWBluetooth sharedBluetooth] cancelPeripheralConnection];
                
                [userDefaults setObject:@(ECUserDefaultsLoginStateNotLogin) forKey:kUserDefaultsLoginState];
                [userDefaults synchronize];
                
                [self.navigationController dismissViewControllerAnimated:YES completion:nil];
            }
            break;
        default:
            break;
    }
}


#pragma mark - IBAction

// 注意“取消绑定”和“断开绑定”是两码事
- (IBAction)cancelPairPeripheral:(id)sender {
    [[AWBluetooth sharedBluetooth] stopScan];
    self.peripheralPopupView.hidden = YES;
}

@end
