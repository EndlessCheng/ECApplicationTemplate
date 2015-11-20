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

#import "StartViewController.h"

@interface StartViewController ()

@property (nonatomic) id<NSObject> didConnectPairedPeripheral;
@property (nonatomic) id<NSObject> getAPPServiceImageVersionObserver;
@property (nonatomic) id<NSObject> updateAPPServiceImageObserver;

@end

@implementation StartViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = NSLocalizedString(@"开始",);
    self.peripheralsPopupView.delegate = self;
    
    if (kFailedUpdateAPPServiceImage) {
        // 默认为OAD状态
        // 这句话仅出现一次
        self.actionButtonState = ActionButtonStatePleaseUpdate;
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"固件升级" message:@"上次升级未成功，按确定开始升级。" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        alertView.tag = StartAlertTagUpdate;
        [alertView show];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self updateActionButtonState];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// don't alert in this method!
- (void)updateActionButtonState {
    if (!kPairedPeripheralUUIDString) {
        self.actionButtonState = ActionButtonStatePairPeripheral;
    } else if (([AWPeripheral sharedPeripheral].peripheralState & 1) == 0) {
        self.actionButtonState = ActionButtonStateSearchingPairedPeripheral;
        
        self.didConnectPairedPeripheral = [[NSNotificationCenter defaultCenter] addObserverForName:kNotificationDidConnectPairedPeripheral object:nil queue:nil usingBlock:^(NSNotification *n) {
            [[NSNotificationCenter defaultCenter] removeObserver:self.didConnectPairedPeripheral];
            
            // 注意，在这里得知绑定了设备，等同于（马上）获取到了APPServiceImageVersion
            [self updateActionButtonState];
        }];
        
        [[AWBluetooth sharedBluetooth] connectToPairedPeripheral];
    } else if (kPairedPeripheralAPPServiceImageVersion < [AWFileUtil getLocalAPPServiceImageVersion]) {
        self.actionButtonState = ActionButtonStatePleaseUpdate;
    } else {
        self.actionButtonState = ActionButtonStateStart;
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
            [self.actionButton setTitle:@"请晃动WeCoach" forState:UIControlStateNormal];
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
    }
}

- (void)updateUpdateProgressViewWithWrittenBytesLength:(long)writtenBytesLength {
    self.updateProgressView.progress = (float)writtenBytesLength / [AWFileUtil getLocalAPPServiceImageData].length;
    self.progressPercentLabel.text = [NSString stringWithFormat:@"%.1f%%", self.updateProgressView.progress * 100];
    self.progressRateLabel.text = [NSString stringWithFormat:@"%@/%@", @((NSUInteger)(writtenBytesLength * UPDATE_PROGRESS_MAGIC)), @((NSUInteger)([AWFileUtil getLocalAPPServiceImageData].length * UPDATE_PROGRESS_MAGIC))];
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
    self.peripheralsPopupView.hidden = YES;
    self.tabBarController.tabBar.userInteractionEnabled = YES;
}

- (IBAction)clickedActionButton:(id)sender {
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
            alertView.tag = StartAlertTagUpdate;
            [alertView show];
            break;
        } case ActionButtonStateStart:
            [self performSegueWithIdentifier:@"StartToFinish" sender:self];
            break;
    }
}


#pragma mark - Peripherals Popup View Delegate

- (void)peripheralsPopupView:(PeripheralsPopupView *)peripheralsPopupView didPairPeripheralWithUUIDString:(NSString *)UUIDString {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:UUIDString forKey:kUserDefaultsPairedPeripheralUUIDString];
    [userDefaults synchronize];
    
    self.actionButtonState = ActionButtonStatePreparing;
    
    // 在用户绑定后还会等待一会表示“准备数据”
    self.getAPPServiceImageVersionObserver = [[NSNotificationCenter defaultCenter] addObserverForName:kNotificationGetAPPServiceImageVersion object:nil queue:nil usingBlock:^(NSNotification *n) {
        [[NSNotificationCenter defaultCenter] removeObserver:self.getAPPServiceImageVersionObserver];
        
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:n.object forKey:kUserDefaultsPairedPeripheralAPPServiceImageVersion];
        [userDefaults synchronize];
        
        [self updateActionButtonState];
        
        peripheralsPopupView.hidden = YES;
        self.tabBarController.tabBar.userInteractionEnabled = YES;
    }];
}


#pragma mark - Alert View Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (alertView.tag) {
        case StartAlertTagUpdate:
            if (buttonIndex == 1) {
                // TODO: 提取模块+delegate
                self.tabBarController.tabBar.userInteractionEnabled = NO;
                self.updateProgressView.progress = 0.0;
                self.progressPercentLabel.text = @"0.0%";
                self.progressRateLabel.text = @"加载数据...";
                self.updateProgressBackgroundView.hidden = NO;
                
                self.updateAPPServiceImageObserver = [[NSNotificationCenter defaultCenter] addObserverForName:kNotificationOADServiceImageBlockNumber object:nil queue:nil usingBlock:^(NSNotification *n) {
                    NSDictionary *dict = (NSDictionary *)n.object;
                    NSNumber *OADServiceImageBlockNumber = dict[kOADServiceImageBlockNumber];
                    NSUInteger writtenBytesLength = (OADServiceImageBlockNumber.integerValue + 1) << 4;
                    
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
                    }
                }];
                
                [AWPeripheral sharedPeripheral].needUpdate = YES;
                [[AWBluetooth sharedBluetooth] updatePeripheralAPPServiceImage];
            }
            break;
        default:
            break;
    }
}

@end
