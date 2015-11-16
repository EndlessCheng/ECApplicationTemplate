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
    ActionButtonStateStart,
};

@interface StartViewController : UIViewController

@property (nonatomic, weak) IBOutlet UIButton *actionButton;
@property (nonatomic) ActionButtonState actionButtonState;
- (IBAction)clickedActionButton:(id)sender;

@property (nonatomic, weak) IBOutlet PeripheralsPopupView *peripheralPopupView;
- (IBAction)cancelPairPeripheral:(id)sender;

@end
