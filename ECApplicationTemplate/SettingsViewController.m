//
//  SettingsViewController.m
//  ECApplicationTemplate
//
//  Created by chengyh on 15/10/21.
//  Copyright © 2015年 jianyan. All rights reserved.
//

#import "SettingsViewController.h"
#import "SettingsTableViewCell.h"

NSString *const kCellIndetifier = @"SettingsTableViewCellIndetifier";

@interface SettingsViewController ()

@property (nonatomic, copy) NSArray<NSArray<NSString *> *> *settingTitlesGroup;

@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = NSLocalizedString(@"设置",);
    
    self.settingTitlesGroup = @[
                       @[@"清除缓存", @"消息通知"],
                       @[@"意见反馈", @"给应用评分", @"关于", @"开源许可"],
                       @[@"个人信息", @"修改密码", @"注销登录"],
                       ];
    [self.settingsTableView registerNib:[UINib nibWithNibName:@"SettingsTableViewCell" bundle:nil] forCellReuseIdentifier:kCellIndetifier];
    if ([self.settingsTableView respondsToSelector:@selector(setLayoutMargins:)]) {
        self.settingsTableView.layoutMargins = UIEdgeInsetsZero;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Table View

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 8.0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.settingTitlesGroup.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.settingTitlesGroup[section].count;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SettingsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIndetifier forIndexPath:indexPath];
    
    // round corner of cell
    // TODO: this part can refactor to parent class
    UIRectCorner rectCorner = 0UL;
    if (indexPath.row == 0) {
        rectCorner |= UIRectCornerTopLeft | UIRectCornerTopRight;
    }
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
    
    // content of cell
    cell.titleLabel.text = self.settingTitlesGroup[indexPath.section][indexPath.row];
    cell.redPoint.hidden = !(indexPath.section == 0 && indexPath.row == 1);
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 2:
            switch (indexPath.row) {
                case 2: {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"乃确定不是手滑了吗？",) message:nil delegate:self cancelButtonTitle:@"我手滑了" otherButtonTitles:@"我要退出", nil];
                    alert.tag = SettingsAlertTagLogOut;
                    [alert show];
                    break;
                } default:
                    break;
            }
            break;
        default:
            break;
    }
}


#pragma mark - Alert View Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (alertView.tag) {
        case SettingsAlertTagLogOut:
            if (buttonIndex == 1) {
                [[NSUserDefaults standardUserDefaults] setObject:@(ECUserDefaultsLoginStateNotLogin) forKey:kUserDefaultsLoginState];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                [self.navigationController dismissViewControllerAnimated:YES completion:nil];
            }
            break;
        default:
            break;
    }
}

@end
