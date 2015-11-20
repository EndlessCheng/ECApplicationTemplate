//
//  StartViewController.h
//  ECApplicationTemplate
//
//  Created by chengyh on 15/10/21.
//  Copyright © 2015年 jianyan. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "PeripheralsPopupView.h"

typedef NS_ENUM(NSInteger, ActionButtonState) {
    ActionButtonStatePairPeripheral,
    ActionButtonStateSearchingPairedPeripheral,
    ActionButtonStatePreparing,
    ActionButtonStatePleaseUpdate,
    ActionButtonStateStart,
};

typedef NS_ENUM(NSInteger, StartAlertTag) {
    StartAlertTagUpdate = 1,
};

@interface StartViewController : UIViewController <PeripheralsPopupViewDelegate, UIAlertViewDelegate>

@property (nonatomic, weak) IBOutlet UIButton *actionButton;
@property (nonatomic) ActionButtonState actionButtonState;

- (IBAction)clickedActionButton:(id)sender;

@property (nonatomic, weak) IBOutlet PeripheralsPopupView *peripheralsPopupView;

- (IBAction)cancelPairPeripheral:(id)sender;

@property (nonatomic, weak) IBOutlet UIView *updateProgressBackgroundView;
@property (nonatomic, weak) IBOutlet UIProgressView *updateProgressView;
@property (nonatomic, weak) IBOutlet UILabel *progressPercentLabel;
@property (nonatomic, weak) IBOutlet UILabel *progressRateLabel;

@end
