//
//  PeripheralsPopupView.h
//  ECApplicationTemplate
//
//  Created by chengyh on 15/11/13.
//  Copyright © 2015年 jianyan. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, PeripheralsPopupViewAlertTag) {
    PeripheralsPopupViewAlertTagPairPeripheral = 1,
};

@interface PeripheralsPopupView : UIView <UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate>

@property (nonatomic, weak) IBOutlet UITableView *peripheralsTableView;

@end
