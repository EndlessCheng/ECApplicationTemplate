//
//  StartViewController.m
//  ECApplicationTemplate
//
//  Created by chengyh on 15/10/21.
//  Copyright © 2015年 jianyan. All rights reserved.
//

#import "AWBluetooth.h"

#import "StartViewController.h"

@interface StartViewController ()

@property (nonatomic) id<NSObject> didPairToPeripheralObserver;
@property (nonatomic) id<NSObject> didConnectToPairedPeripheralObserver;

@end

@implementation StartViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = NSLocalizedString(@"开始",);
    
    if (kPairedPeripheralUUIDString) {
        self.actionButtonState = ActionButtonStateSearchingPairedPeripheral;
        
        self.didConnectToPairedPeripheralObserver = [[NSNotificationCenter defaultCenter] addObserverForName:kNotificationStartViewControllerDidConnectToPairedPeripheral object:nil queue:nil usingBlock:^(NSNotification *n) {
            // 已连接设备
            [[NSNotificationCenter defaultCenter] removeObserver:self.didConnectToPairedPeripheralObserver];
            self.actionButtonState = ActionButtonStateStart;
        }];
        
        [[AWBluetooth sharedBluetooth] connectToPairedPeripheral];
    } else {
        self.actionButtonState = ActionButtonStatePairPeripheral;
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

- (void)setActionButtonState:(ActionButtonState)actionButtonState {
    _actionButtonState = actionButtonState;
    switch (actionButtonState) {
        case ActionButtonStatePairPeripheral:
            [self.actionButton setTitle:@"绑定设备" forState:UIControlStateNormal];
            break;
        case ActionButtonStateSearchingPairedPeripheral:
            [self.actionButton setTitle:@"请晃动WeCoach-Pro" forState:UIControlStateNormal];
            break;
        case ActionButtonStateStart:
            [self.actionButton setTitle:@"开始！" forState:UIControlStateNormal];
            break;
    }
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
                // 已绑定并连接设备
                [[NSNotificationCenter defaultCenter] removeObserver:self.didPairToPeripheralObserver];
                
                self.actionButtonState = ActionButtonStateStart;
            }];
            
            self.peripheralPopupView.hidden = NO;
            break;
        } case ActionButtonStateSearchingPairedPeripheral:
            break;
        case ActionButtonStateStart:
            [self performSegueWithIdentifier:@"StartToFinish" sender:self];
            break;
    }
}

@end
