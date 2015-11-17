//
//  StartViewController.h
//  ECApplicationTemplate
//
//  Created by chengyh on 15/10/21.
//  Copyright © 2015年 jianyan. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "PeripheralsPopupView.h"

typedef NS_ENUM(NSUInteger, ActionButtonState) {
    ActionButtonStatePairPeripheral,
    ActionButtonStateSearchingPairedPeripheral,
    ActionButtonStateUpdate,
    ActionButtonStateStart,
};

typedef NS_ENUM(NSUInteger, StartAlertTag) {
    StartAlertTagUpdate = 1,
};

@interface StartViewController : UIViewController <UIAlertViewDelegate>

@property (nonatomic, weak) IBOutlet UIButton *actionButton;
@property (nonatomic) ActionButtonState actionButtonState;
- (IBAction)clickedActionButton:(id)sender;

@property (nonatomic, weak) IBOutlet PeripheralsPopupView *peripheralPopupView;
- (IBAction)cancelPairPeripheral:(id)sender;

@property (nonatomic, weak) IBOutlet UIView *updateProgressBackgroundView;
@property (nonatomic, weak) IBOutlet UIProgressView *updateProgressView;
@property (nonatomic, weak) IBOutlet UILabel *progressPercentLabel;
@property (nonatomic, weak) IBOutlet UILabel *progressRateLabel;

@end
