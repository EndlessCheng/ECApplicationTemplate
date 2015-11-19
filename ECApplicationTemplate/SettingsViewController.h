//
//  SettingsViewController.h
//  ECApplicationTemplate
//
//  Created by chengyh on 15/10/21.
//  Copyright © 2015年 jianyan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "PeripheralsPopupView.h"

typedef NS_ENUM(NSUInteger, SettingsAlertTag) {
    SettingsAlertTagDisPair = 1,
    SettingsAlertTagUpdate,
    SettingsAlertTagLogOut,
};

@interface SettingsViewController : UIViewController <PeripheralsPopupViewDelegate, UITableViewDelegate, UIAlertViewDelegate>

@property (nonatomic, weak) IBOutlet UITableView *settingsTableView;

@property (nonatomic, weak) IBOutlet PeripheralsPopupView *peripheralsPopupView;
- (IBAction)cancelPairPeripheral:(id)sender;

@property (nonatomic, weak) IBOutlet UIView *updateProgressBackgroundView;
@property (nonatomic, weak) IBOutlet UIProgressView *updateProgressView;
@property (nonatomic, weak) IBOutlet UILabel *progressPercentLabel;
@property (nonatomic, weak) IBOutlet UILabel *progressRateLabel;

@end
