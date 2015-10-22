//
//  TabBarController.m
//  ECApplicationTemplate
//
//  Created by chengyh on 15/10/21.
//  Copyright © 2015年 jianyan. All rights reserved.
//

#import "TabBarController.h"

#import "StartViewController.h"
#import "SettingsViewController.h"

#import "StoryBoardUtil.h"

@interface TabBarController ()

@end

@implementation TabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    StartViewController *startViewController = (StartViewController *)[StoryBoardUtil instantiateInitialViewControllerWithStoryBoardName:@"Start"];
    startViewController.tabBarItem.title = @"开始";
    SettingsViewController *settingsViewController = (SettingsViewController *)[StoryBoardUtil instantiateInitialViewControllerWithStoryBoardName:@"Settings"];
    settingsViewController.tabBarItem.title = @"设置";
    self.viewControllers = @[startViewController, settingsViewController];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navigationItem.hidesBackButton = YES;
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

@end
