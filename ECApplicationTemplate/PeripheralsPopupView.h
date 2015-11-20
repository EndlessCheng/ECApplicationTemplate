//
//  PeripheralsPopupView.h
//  ECApplicationTemplate
//
//  Created by chengyh on 15/11/13.
//  Copyright © 2015年 jianyan. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, PeripheralsPopupViewAlertTag) {
    PeripheralsPopupViewAlertTagPairPeripheral = 1,
};

@class PeripheralsPopupView;

@protocol PeripheralsPopupViewDelegate <NSObject>

@required

- (void)peripheralsPopupView:(PeripheralsPopupView *)peripheralsPopupView didPairPeripheralWithUUIDString:(NSString *)UUIDString;

@end


@interface PeripheralsPopupView : UIView <UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate>

@property (assign, nonatomic, nullable) id <PeripheralsPopupViewDelegate> delegate;

@property (nonatomic, weak) IBOutlet UITableView *peripheralsTableView;

@end
