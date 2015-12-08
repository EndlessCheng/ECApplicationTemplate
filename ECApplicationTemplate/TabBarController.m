//
//  TabBarController.m
//  ECApplicationTemplate
//
//  Created by chengyh on 15/10/21.
//  Copyright © 2015年 jianyan. All rights reserved.
//

#import "StoryBoardUtil.h"

#import "StartViewController.h"
#import "PlanViewController.h"
#import "SettingsViewController.h"

#import "TabBarController.h"

@interface TabBarController ()

@end

@implementation TabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    StartViewController *startViewController = (StartViewController *)[StoryBoardUtil instantiateInitialViewControllerWithStoryBoardName:@"Start"];
    PlanViewController *planViewController = (PlanViewController *)[StoryBoardUtil instantiateInitialViewControllerWithStoryBoardName:@"Plan"];
    SettingsViewController *settingsViewController = (SettingsViewController *)[StoryBoardUtil instantiateInitialViewControllerWithStoryBoardName:@"Settings"];
    self.viewControllers = @[startViewController, planViewController, settingsViewController];
    
    NSArray *imageName = @[@"tabbar_start.png", @"tabbar_user.png", @"tabbar_user.png"];
    NSArray *selectedImageName = @[@"tabbar_start_selected.png", @"tabbar_user_selected.png", @"tabbar_user_selected.png"];
    for (NSUInteger i = 0; i < TAB_BAR_NUMBER; i++) {
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

@end
