//
//  StartViewController.m
//  ECApplicationTemplate
//
//  Created by chengyh on 15/10/21.
//  Copyright © 2015年 jianyan. All rights reserved.
//

#import "AWFileUtil.h"
#import "AWBluetooth.h"
#import "AWPeripheral.h"

#import "PeripheralsPopupView.h"

#import "TabBarController.h"
#import "StartViewController.h"

@interface StartViewController () <PeripheralsPopupViewDelegate, UIAlertViewDelegate>

@property (nonatomic) id<NSObject> didConnectPairedPeripheralObserver;
@property (nonatomic) id<NSObject> updateAPPServiceImageObserver;

@end

@implementation StartViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = NSLocalizedString(@"开始",);
    self.peripheralsPopupView.delegate = self;
    
    if (((TabBarController *) self.tabBarController).isFoundOADPeripheral) {
        // 这句话仅出现一次
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"固件升级" message:@"上次升级未成功，按确定开始升级。" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        alertView.tag = StartAlertTagUpdateOADPeripheral;
        [alertView show];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [self updateActionButtonState];
}

// don't alert in this method!
- (void)updateActionButtonState {
    if (self.actionButtonState == ActionButtonStateRunning) {
        return;
    }
    
    if (!kPairedPeripheralUUIDString) {
        self.actionButtonState = ActionButtonStatePairPeripheral;
    } else if (([AWPeripheral sharedPeripheral].peripheralState & 1) == 0) {
        self.actionButtonState = ActionButtonStateSearchingPairedPeripheral;

        self.didConnectPairedPeripheralObserver = [[NSNotificationCenter defaultCenter] addObserverForName:kNotificationDidConnectPairedPeripheral object:nil queue:nil usingBlock:^(NSNotification *n) {
            [[NSNotificationCenter defaultCenter] removeObserver:self.didConnectPairedPeripheralObserver];

            [self updateActionButtonState];
        }];

        [[AWBluetooth sharedBluetooth] connectToPairedPeripheral];
    } else if (kPairedPeripheralAPPServiceImageVersion < [AWFileUtil getLocalAPPServiceImageVersion]) {
        self.actionButtonState = ActionButtonStatePleaseUpdate;
    } else if (YES) { // if userDefaults previous did end
        self.actionButtonState = ActionButtonStateStart;
    } else { // if userDefaults previous did not end
        self.actionButtonState = ActionButtonStateContinue;
        self.restartButton.hidden = NO;
    }
}

- (void)setActionButtonState:(ActionButtonState)actionButtonState {
    self.tabBarController.tabBar.userInteractionEnabled = YES;

    _actionButtonState = actionButtonState;
    switch (actionButtonState) {
        case ActionButtonStatePairPeripheral:
            [self.actionButton setTitle:@"点击绑定设备" forState:UIControlStateNormal];
            self.actionButton.enabled = YES;
            break;
        case ActionButtonStateSearchingPairedPeripheral:
            [self.actionButton setTitle:@"请晃动设备" forState:UIControlStateNormal];
            self.actionButton.enabled = NO;
            break;
        case ActionButtonStatePreparing:
            [self.actionButton setTitle:@"正在获取数据" forState:UIControlStateNormal];
            self.actionButton.enabled = NO;
            break;
        case ActionButtonStatePleaseUpdate:
            [self.actionButton setTitle:@"点击升级固件" forState:UIControlStateNormal];
            self.actionButton.enabled = YES;
            break;
        case ActionButtonStateStart:
            [self.actionButton setTitle:@"开始运动" forState:UIControlStateNormal];
            self.actionButton.enabled = YES;
            break;
        case ActionButtonStateContinue:
            [self.actionButton setTitle:@"继续运动" forState:UIControlStateNormal];
            self.actionButton.enabled = YES;
            break;
        case ActionButtonStateRunning:
            [self.actionButton setTitle:@"运动中，点击结束" forState:UIControlStateNormal];
            self.actionButton.enabled = YES;
            break;
    }
}

- (void)updateUpdateProgressViewWithWrittenBytesLength:(NSUInteger)writtenBytesLength {
    self.updateProgressView.progress = (float) writtenBytesLength / [AWFileUtil getLocalAPPServiceImageData].length;
    self.progressPercentLabel.text = [NSString stringWithFormat:@"%.1f%%", self.updateProgressView.progress * 100];
    self.progressRateLabel.text = [NSString stringWithFormat:@"%@/%@", @((NSUInteger) (writtenBytesLength * UPDATE_PROGRESS_MAGIC)), @((NSUInteger) ([AWFileUtil getLocalAPPServiceImageData].length * UPDATE_PROGRESS_MAGIC))];
}

- (void)prepareForUpdatePeripheral {
    // TODO: 提取模块+delegate
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
            
            // 若未连接会扫描
            [self updateActionButtonState];
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"升级成功" message:@"您的固件已升级到最新版本，赶快运动吧" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
            [alertView show];
            
            self.updateProgressBackgroundView.hidden = YES;
            self.tabBarController.tabBar.userInteractionEnabled = YES;
            
            [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
        }
    }];
}

// 注意“取消绑定”和“断开绑定”是两码事
- (IBAction)cancelPairPeripheral:(UIButton *)sender {
    [[AWBluetooth sharedBluetooth] stopScan];
    self.peripheralsPopupView.hidden = YES;
    self.tabBarController.tabBar.userInteractionEnabled = YES;
}

- (IBAction)clickedActionButton:(UIButton *)sender {
    switch (self.actionButtonState) {
        case ActionButtonStatePairPeripheral: {
            self.tabBarController.tabBar.userInteractionEnabled = NO;
            self.peripheralsPopupView.hidden = NO;
            break;
        } case ActionButtonStateSearchingPairedPeripheral:
        case ActionButtonStatePreparing:
            break;
        case ActionButtonStatePleaseUpdate: {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"固件升级" message:kPleaseUpdateAPPServiceImageMessage delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
            alertView.tag = StartAlertTagUpdateNormalPeripheral;
            [alertView show];
            break;
        } case ActionButtonStateStart:
            // TODO: if isConnected [change] else wait notification [change]
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [[AWPeripheral sharedPeripheral] writeSwimAlgorithmState:AWSwimAlgorithmStateRunning];
            });
            // notice there not break
        case ActionButtonStateContinue:
            self.restartButton.hidden = YES;
            self.actionButtonState = ActionButtonStateRunning;
            break;
        case ActionButtonStateRunning:
            [[AWBluetooth sharedBluetooth] connectToPairedPeripheral];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                // 先停止算法运行，再读数据
                [[AWPeripheral sharedPeripheral] writeSwimAlgorithmState:AWSwimAlgorithmStateStop];
                [[AWPeripheral sharedPeripheral] readSwimDataBlock];
            });
            
            [self performSegueWithIdentifier:@"StartToFinish" sender:self];
            
            self.actionButtonState = ActionButtonStateStart;
            break;
    }
}

- (IBAction)clickedRestartButton:(UIButton *)sender {
    self.restartButton.hidden = YES;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[AWPeripheral sharedPeripheral] writeSwimAlgorithmState:AWSwimAlgorithmStateRunning];
    });
    
    self.actionButtonState = ActionButtonStateRunning;
}


#pragma mark - Peripherals Popup View Delegate

- (void)peripheralsPopupView:(PeripheralsPopupView *)peripheralsPopupView didGetAPPServiceImageVersion:(NSInteger)APPServiceImageVersion {
    [self updateActionButtonState];
    self.tabBarController.tabBar.userInteractionEnabled = YES;
}


#pragma mark - Alert View Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (alertView.tag) {
        case StartAlertTagUpdateNormalPeripheral:
            if (buttonIndex == 1) {
                [self prepareForUpdatePeripheral];
                [[AWBluetooth sharedBluetooth] updateNormalPeripheral];
            }
            break;
        case StartAlertTagUpdateOADPeripheral:
            if (buttonIndex == 1) {
                [self prepareForUpdatePeripheral];
                [[AWBluetooth sharedBluetooth] scanAndUpdateOADPeripheral];
            }
        default:
            break;
    }
}

@end
