//
//  LoginViewController.m
//  ECApplicationTemplate
//
//  Created by chengyh on 15/10/23.
//  Copyright © 2015年 jianyan. All rights reserved.
//

#import "LoginViewController.h"

@interface LoginViewController ()

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (IBAction)loginButtonClicked:(UIButton *)sender {
    if ([ECHTTPUtil loginWithUsername:TEST_USERNAME password:TEST_PASSWORD]) {
        [self.navigationController popToRootViewControllerAnimated:NO];
    }
}

@end
