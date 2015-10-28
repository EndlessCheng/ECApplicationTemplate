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

@interface SettingsViewController () {
    NSArray *_settingTitlesGroup;
}

@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _settingTitlesGroup = @[
                       @[@"清除缓存", @"消息通知"],
                       @[@"意见反馈", @"给应用评分", @"关于", @"开源许可"],
                       @[@"个人信息", @"修改密码", @"注销登录"],
                       ];
    [_settingsTableView registerNib:[UINib nibWithNibName:@"SettingsTableViewCell" bundle:nil] forCellReuseIdentifier:kCellIndetifier];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    self.navigationController.navigationBar.topItem.title = NSLocalizedString(@"设置",);
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
    return section < _settingTitlesGroup.count - 1 ? 10.0 : 0.0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _settingTitlesGroup.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return ((NSArray *)_settingTitlesGroup[section]).count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SettingsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIndetifier forIndexPath:indexPath];
    
    cell.titleLabel.text = _settingTitlesGroup[indexPath.section][indexPath.row];
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
                [[NSUserDefaults standardUserDefaults] setInteger:ECUserDefaultsLoginStateNotLogin forKey:kUserDefaultsLoginState];
                [[NSUserDefaults standardUserDefaults] synchronize];
                [self.navigationController popToRootViewControllerAnimated:NO];
            }
            break;
        default:
            break;
    }
}

@end
