//
//  AddPlanViewController.m
//  ECApplicationTemplate
//
//  Created by chengyh on 15/12/8.
//  Copyright © 2015年 jianyan. All rights reserved.
//

#import "AddPlanViewController.h"

@interface AddPlanViewController ()

@end

@implementation AddPlanViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.leftBarButtonItem.imageInsets = UIEdgeInsetsMake(2, -2, -2, 2);
}

- (IBAction)back:(UIBarButtonItem *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
