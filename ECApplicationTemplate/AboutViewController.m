//
//  AboutViewController.m
//  ECApplicationTemplate
//
//  Created by chengyh on 15/12/4.
//  Copyright © 2015年 jianyan. All rights reserved.
//

#import "AboutViewController.h"

@interface AboutViewController ()

@end

@implementation AboutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.leftBarButtonItem.imageInsets = UIEdgeInsetsMake(2, -2, -2, 2);
}

- (IBAction)backToSettingsViewController:(UIBarButtonItem *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
