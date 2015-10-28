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
    SettingsViewController *settingsViewController = (SettingsViewController *)[StoryBoardUtil instantiateInitialViewControllerWithStoryBoardName:@"Settings"];
    self.viewControllers = @[startViewController, settingsViewController];
    
    NSArray *imageName = @[@"tabbar_start.png", @"tabbar_user.png"];
    NSArray *selectedImageName = @[@"tabbar_start_selected.png", @"tabbar_user_selected.png"];
    for (int i = 0; i < TAB_BAR_NUMBER; i++) {
        UITabBarItem *tabBarItem = self.viewControllers[i].tabBarItem;
        tabBarItem.image = [[UIImage imageNamed:imageName[i]] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        tabBarItem.selectedImage = [[UIImage imageNamed:selectedImageName[i]] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        tabBarItem.imageInsets = UIEdgeInsetsMake(5.5, 0, -5.5, 0);
    }
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
