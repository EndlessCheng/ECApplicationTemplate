//
//  SettingsModel.m
//  ECApplicationTemplate
//
//  Created by chengyh on 15/11/13.
//  Copyright © 2015年 jianyan. All rights reserved.
//

#import "SettingsModel.h"
#import "SettingsTableViewCell.h"

@interface SettingsModel ()

@property (nonatomic, copy) NSArray<NSArray<NSString *> *> *settingTitlesGroup;

@end

@implementation SettingsModel

- (id)init {
    self = [super init];
    if (self) {
        self.settingTitlesGroup = @[
                @[@"个人信息", @"修改密码"],
                @[@"消息通知", @"设备绑定", @"固件升级"],
                @[@"意见反馈", @"给应用评分", @"关于", @"开源许可"],
                @[@"注销登录"],
        ];
    }
    return self;
}


#pragma mark - Table View Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.settingTitlesGroup.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.settingTitlesGroup[section].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SettingsTableViewCell *cell = (SettingsTableViewCell *) [tableView dequeueReusableCellWithIdentifier:@"SettingsTableViewCellIndetifier" forIndexPath:indexPath];

    // round corner of group
    // TODO: this part can refactor to parent class
    UIRectCorner rectCorner = 0UL;
    if (indexPath.row == 0) {
        rectCorner |= UIRectCornerTopLeft | UIRectCornerTopRight;
    }
    
    // sometimes unexpected cornor drawed
//    NSLog(@"[tableView numberOfRowsInSection:indexPath.section] - 1: %@", @([tableView numberOfRowsInSection:indexPath.section] - 1));
    if (indexPath.row == [tableView numberOfRowsInSection:indexPath.section] - 1) {
        rectCorner |= UIRectCornerBottomLeft | UIRectCornerBottomRight;
    }
    if (rectCorner != 0UL) {
        CGFloat cornerRadius = 10.0;
        UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:cell.bounds byRoundingCorners:rectCorner cornerRadii:CGSizeMake(cornerRadius, cornerRadius)];
        CAShapeLayer *maskLayer = [CAShapeLayer layer];
        maskLayer.frame = cell.bounds;
        maskLayer.path = maskPath.CGPath;
        cell.layer.mask = maskLayer;
    }

    cell.titleLabel.text = self.settingTitlesGroup[indexPath.section][indexPath.row];
    cell.redPoint.hidden = YES;
    cell.infoLabel.hidden = YES;

    switch (indexPath.section) {
        case 1:
            switch (indexPath.row) {
                case 0:
                    cell.redPoint.hidden = NO;
                    break;
                case 1: {
                    cell.infoLabel.text = kSettingsPairPeripheralInfoLabelText;
                    cell.infoLabel.hidden = NO;
                    break;
                }
                case 2:
//                    cell.infoLabel.text = @"检测到新固件";
//                    cell.infoLabel.hidden = NO;
                    break;
            }
            break;
        default:
            break;
    }

    return cell;
}

@end
