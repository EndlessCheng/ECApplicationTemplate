//
//  StartViewController.h
//  ECApplicationTemplate
//
//  Created by chengyh on 15/10/21.
//  Copyright © 2015年 jianyan. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, ActionButtonState) {
    ActionButtonStatePairPeripheral,
    ActionButtonStateSearchingPairedPeripheral,
    ActionButtonStatePreparing,
    ActionButtonStatePleaseUpdate,
    ActionButtonStateStart,
    ActionButtonStateContinue,
    ActionButtonStateRunning,
};

typedef NS_ENUM(NSInteger, StartAlertTag) {
    StartAlertTagUpdateNormalPeripheral = 1,
    StartAlertTagUpdateOADPeripheral,
};

@class PeripheralsPopupView;

@interface StartViewController : UIViewController

@property (nonatomic, weak) IBOutlet UIButton *actionButton;
@property (nonatomic) ActionButtonState actionButtonState;

- (IBAction)clickedActionButton:(UIButton *)sender;


@property (nonatomic, weak) IBOutlet UIButton *restartButton;

- (IBAction)clickedRestartButton:(UIButton *)sender;


@property (nonatomic, weak) IBOutlet PeripheralsPopupView *peripheralsPopupView;

- (IBAction)cancelPairPeripheral:(UIButton *)sender;


@property (nonatomic, weak) IBOutlet UIView *updateProgressBackgroundView;
@property (nonatomic, weak) IBOutlet UIProgressView *updateProgressView;
@property (nonatomic, weak) IBOutlet UILabel *progressPercentLabel;
@property (nonatomic, weak) IBOutlet UILabel *progressRateLabel;

@end
