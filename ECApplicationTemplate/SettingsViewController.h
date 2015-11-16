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
    SettingsAlertTagLogOut,
};

@interface SettingsViewController : UIViewController <UITableViewDelegate, UIAlertViewDelegate>

@property (nonatomic, weak) IBOutlet UITableView *settingsTableView;

@property (nonatomic, weak) IBOutlet PeripheralsPopupView *peripheralPopupView;
- (IBAction)cancelPairPeripheral:(id)sender;

@end
