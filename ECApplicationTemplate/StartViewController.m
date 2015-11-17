//
//  StartViewController.m
//  ECApplicationTemplate
//
//  Created by chengyh on 15/10/21.
//  Copyright © 2015年 jianyan. All rights reserved.
//

#import "AWBluetooth.h"
#import "AWPeripheral.h"

#import "StartViewController.h"

@interface StartViewController ()

@property (nonatomic) id<NSObject> didPairToPeripheralObserver;
@property (nonatomic) id<NSObject> didConnectToPairedPeripheralObserver;

@property (nonatomic) id<NSObject> updateAPPServiceImageObserver;

@end

@implementation StartViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = NSLocalizedString(@"开始",);
    
    if (kFailedUpdateAPPServiceImage) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"固件升级" message:@"上次升级未成功，是否继续升级？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"继续", nil];
        alertView.tag = StartAlertTagUpdate;
        [alertView show];
    } else {
        [self updateActionButtonState];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (!kPairedPeripheralUUIDString) {
        self.actionButtonState = ActionButtonStatePairPeripheral;
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateActionButtonState {
    if (!kPairedPeripheralUUIDString) {
        self.actionButtonState = ActionButtonStatePairPeripheral;
    } else {
        self.actionButtonState = ActionButtonStateSearchingPairedPeripheral;
        
        self.didConnectToPairedPeripheralObserver = [[NSNotificationCenter defaultCenter] addObserverForName:kNotificationStartViewControllerDidConnectToPairedPeripheral object:nil queue:nil usingBlock:^(NSNotification *n) {
            // 已绑定设备
            self.actionButtonState = ActionButtonStateStart;
        }];
        
        [[AWBluetooth sharedBluetooth] connectToPairedPeripheral];
    }
}

- (void)setActionButtonState:(ActionButtonState)actionButtonState {
    _actionButtonState = actionButtonState;
    switch (actionButtonState) {
        case ActionButtonStatePairPeripheral:
            [self.actionButton setTitle:@"绑定设备" forState:UIControlStateNormal];
            break;
        case ActionButtonStateSearchingPairedPeripheral:
            [self.actionButton setTitle:@"请晃动WeCoach" forState:UIControlStateNormal]; // UIControlStateDisabled
            break;
        case ActionButtonStateUpdate:
            [self.actionButton setTitle:@"正在升级固件..." forState:UIControlStateNormal]; // UIControlStateDisabled
            break;
        case ActionButtonStateStart:
            [self.actionButton setTitle:@"开始！" forState:UIControlStateNormal];
            break;
    }
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

// 注意“取消绑定”和“断开绑定”是两码事
- (IBAction)cancelPairPeripheral:(id)sender {
    [[AWBluetooth sharedBluetooth] stopScan];
    self.peripheralPopupView.hidden = YES;
}

- (IBAction)clickedActionButton:(id)sender {
    switch (self.actionButtonState) {
        case ActionButtonStatePairPeripheral: {
            self.didPairToPeripheralObserver = [[NSNotificationCenter defaultCenter] addObserverForName:kNotificationPeripheralsPopupViewDidPairToPeripheral object:nil queue:nil usingBlock:^(NSNotification *n) {
                // 已绑定设备
                [[NSNotificationCenter defaultCenter] removeObserver:self.didPairToPeripheralObserver];
                
                if ([AWPeripheral sharedPeripheral].isConnected) {
                    self.actionButtonState = ActionButtonStateStart;
                } else {
                    self.actionButtonState = ActionButtonStateSearchingPairedPeripheral;
                    
                    [[AWBluetooth sharedBluetooth] connectToPairedPeripheral];
                }
            }];
            
            self.peripheralPopupView.hidden = NO;
            break;
        } case ActionButtonStateSearchingPairedPeripheral:
        case ActionButtonStateUpdate:
            break;
        case ActionButtonStateStart:
            if (kFailedUpdateAPPServiceImage) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"固件升级" message:@"请升级到最新版固件。升级耗时约2分钟，按确定开始升级。" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
                alertView.tag = StartAlertTagUpdate;
                [alertView show];
            } else {
                [self performSegueWithIdentifier:@"StartToFinish" sender:self];
            }
            break;
    }
}


#pragma mark - Alert View Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (alertView.tag) {
        case StartAlertTagUpdate:
            if (buttonIndex == 0) {
                [self updateActionButtonState];
            } else if (buttonIndex == 1) {
                self.updateProgressView.progress = 0.0;
                self.progressPercentLabel.text = @"0.0%";
                self.progressRateLabel.text = @"启动中...";
                self.updateProgressBackgroundView.hidden = NO;
                self.actionButtonState = ActionButtonStateUpdate;
                
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
                        
                        [self updateActionButtonState];
                    }
                }];
                
                [[AWBluetooth sharedBluetooth] updatePeripheralAPPServiceImage];
            }
            break;
        default:
            break;
    }
}

@end
