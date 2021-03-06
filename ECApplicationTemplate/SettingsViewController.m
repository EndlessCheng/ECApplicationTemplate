//
//  SettingsViewController.m
//  ECApplicationTemplate
//
//  Created by chengyh on 15/10/21.
//  Copyright © 2015年 jianyan. All rights reserved.
//

#import "AWBluetooth.h"
#import "AWPeripheral.h"
#import "AWTreadmill.h"

#import "AWFileUtil.h"

#import "SettingsModel.h"

#import "SettingsTableViewCell.h"
#import "PeripheralsPopupView.h"

#import "SettingsViewController.h"
#import "ShareViewController.h"

@interface SettingsViewController () <UITableViewDelegate, UIAlertViewDelegate, PeripheralsPopupViewDelegate>

@property (nonatomic, weak) IBOutlet UITableView *settingsTableView;

@property (nonatomic, weak) IBOutlet PeripheralsPopupView *peripheralsPopupView;

@property (nonatomic, weak) IBOutlet UIView *updateProgressBackgroundView;
@property (nonatomic, weak) IBOutlet UIProgressView *updateProgressView;
@property (nonatomic, weak) IBOutlet UILabel *progressPercentLabel;
@property (nonatomic, weak) IBOutlet UILabel *progressRateLabel;


@property (nonatomic) SettingsModel *settingsModel;

@property (nonatomic) id<NSObject> updateAPPServiceImageObserver;

@property (nonatomic) UIImage *sharedImage;

@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = NSLocalizedString(@"设置",);

    self.settingsModel = [[SettingsModel alloc] init];
    self.settingsTableView.dataSource = self.settingsModel;
    if ([self.settingsTableView respondsToSelector:@selector(setLayoutMargins:)]) {
        self.settingsTableView.layoutMargins = UIEdgeInsetsZero;
    }

    self.peripheralsPopupView.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [self.settingsTableView reloadData];
}

// 注意“取消绑定”和“断开绑定”是两码事
- (IBAction)cancelPairPeripheral:(UIButton *)sender {
    [[AWBluetooth sharedBluetooth] stopScan];
    self.peripheralsPopupView.hidden = YES;
    self.tabBarController.tabBar.userInteractionEnabled = YES;
}

- (IBAction)shareScrollView:(UIBarButtonItem *)sender {
    self.sharedImage = [self imageWithScrollView:self.settingsTableView];
    
    [self performSegueWithIdentifier:@"SettingsToShare" sender:self];
}


- (void)reloadPairPeripheralCell {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:1 inSection:1];
    SettingsTableViewCell *cell = (SettingsTableViewCell *) [self.settingsTableView cellForRowAtIndexPath:indexPath];
    cell.infoLabel.text = kSettingsPairPeripheralInfoLabelText;
    [self.settingsTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
}

- (void)updateUpdateProgressViewWithWrittenBytesLength:(NSUInteger)writtenBytesLength {
    self.updateProgressView.progress = (float) writtenBytesLength / [AWFileUtil getLocalAPPServiceImageData].length;
    self.progressPercentLabel.text = [NSString stringWithFormat:@"%.1f%%", self.updateProgressView.progress * 100];
    self.progressRateLabel.text = [NSString stringWithFormat:@"%@/%@", @((NSUInteger) (writtenBytesLength * UPDATE_PROGRESS_MAGIC)), @((NSUInteger) ([AWFileUtil getLocalAPPServiceImageData].length * UPDATE_PROGRESS_MAGIC))];
}

- (UIImage *)imageWithScrollView:(UIScrollView *)view {
    UIImage *image = nil;
    
    UIGraphicsBeginImageContextWithOptions(view.contentSize, view.opaque, 0.0); {
        CGPoint savedContentOffset = view.contentOffset;
        CGRect savedFrame = view.frame;
        CGFloat savedCornerRadius = view.layer.cornerRadius;
        
        view.contentOffset = CGPointZero;
        view.frame = CGRectMake(0, 0, view.contentSize.width, view.contentSize.height);
        view.layer.cornerRadius = 0.0;
        
        // this method is really slow, but where is the different?
        //        [view.layer renderInContext:UIGraphicsGetCurrentContext()];
        [view drawViewHierarchyInRect:view.frame afterScreenUpdates:YES];
        
        image = UIGraphicsGetImageFromCurrentImageContext();
        
        D(@(image.size.width));
        D(@(image.size.height));
        
        view.contentOffset = savedContentOffset;
        view.frame = savedFrame;
        view.layer.cornerRadius = savedCornerRadius;
    } UIGraphicsEndImageContext();
    
    return image;
}


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
                        self.tabBarController.tabBar.userInteractionEnabled = NO;
                        self.peripheralsPopupView.hidden = NO;
                    }
                    break;
                }
                case 2: {
                    UIAlertView *alertView;
                    if (!kPairedPeripheralUUIDString) {
                        alertView = [[UIAlertView alloc] initWithTitle:@"未绑定设备" message:@"请先绑定设备后再升级" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
                    } else if (kPairedPeripheralAPPServiceImageVersion < [AWFileUtil getLocalAPPServiceImageVersion]) {
                        alertView = [[UIAlertView alloc] initWithTitle:@"固件升级" message:@"升级耗时约2分钟，按确定开始升级" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
                        alertView.tag = SettingsAlertTagUpdate;
                    } else {
                        alertView = [[UIAlertView alloc] initWithTitle:@"固件升级" message:@"固件已升级到最新版本，赶快运动吧" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
                    }
                    [alertView show];
                    break;
                }
                case 3:
                    [[AWBluetooth sharedBluetooth] scanTreadmills];
                    
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [[AWPeripheral sharedPeripheral] notifySensor];
                        [[AWPeripheral sharedPeripheral] notifyMagneticCompassAndHeartRate];
                    });
                    break;
                default:
                    break;
            }
            break;
        case 2:
            switch (indexPath.row) {
                case 2:
                    [self performSegueWithIdentifier:@"SettingsToAbout" sender:self];
                    break;
                default:
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
                if ([AWPeripheral sharedPeripheral].batteryPowerLevel == AWBatteryPowerLevelLow) {
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"电量不足" message:@"请充电后再升级" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
                    [alertView show];
                    return;
                }
                // TODO: 提取模块
                self.tabBarController.tabBar.userInteractionEnabled = NO;

                [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
                
                self.updateProgressView.progress = 0.0;
                self.progressPercentLabel.text = @"0.0%";
                self.progressRateLabel.text = @"加载数据...";
                self.updateProgressBackgroundView.hidden = NO;

                self.updateAPPServiceImageObserver = [[NSNotificationCenter defaultCenter] addObserverForName:kNotificationOADServiceImageBlockNumber object:nil queue:nil usingBlock:^(NSNotification *n) {
                    NSDictionary *dict = (NSDictionary *) n.object;
                    NSNumber *OADServiceImageBlockNumber = dict[kOADServiceImageBlockNumber];
                    NSUInteger writtenBytesLength = (OADServiceImageBlockNumber.unsignedIntegerValue + 1) << 4;

                    [self updateUpdateProgressViewWithWrittenBytesLength:writtenBytesLength];

                    if (writtenBytesLength == [AWFileUtil getLocalAPPServiceImageData].length) {
                        [[NSNotificationCenter defaultCenter] removeObserver:self.updateAPPServiceImageObserver];

                        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                        [userDefaults setObject:@([AWFileUtil getLocalAPPServiceImageVersion]) forKey:kUserDefaultsPairedPeripheralAPPServiceImageVersion];
                        [userDefaults synchronize];

                        [[AWBluetooth sharedBluetooth] scanAllPeripherals];

                        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"升级成功" message:@"您的固件已升级到最新版本，赶快运动吧" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
                        [alertView show];

                        self.updateProgressBackgroundView.hidden = YES;
                        self.tabBarController.tabBar.userInteractionEnabled = YES;
                        
                        [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
                    }
                }];

                [[AWBluetooth sharedBluetooth] updateNormalPeripheral];
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


#pragma mark - Peripherals Popup View Delegate

- (void)peripheralsPopupView:(PeripheralsPopupView *)peripheralsPopupView didGetAPPServiceImageVersion:(NSInteger)APPServiceImageVersion {
    [self reloadPairPeripheralCell];
    self.tabBarController.tabBar.userInteractionEnabled = YES;
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.destinationViewController isKindOfClass:[ShareViewController class]]) {
        ShareViewController *vc = segue.destinationViewController;
        vc.sharedImage = self.sharedImage;
    }
}

@end
