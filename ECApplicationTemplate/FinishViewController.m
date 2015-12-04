//
//  FinishViewController.m
//  ECApplicationTemplate
//
//  Created by chengyh on 15/10/21.
//  Copyright © 2015年 jianyan. All rights reserved.
//

#import "FinishViewController.h"

@interface FinishViewController ()

@property (nonatomic, copy) NSString *resultInfoString;

@end

@implementation FinishViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.leftBarButtonItem.imageInsets = UIEdgeInsetsMake(2, -2, -2, 2);
    self.navigationItem.title = NSLocalizedString(@"完成",);
    self.resultInfoString = @"70000";
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    self.resultLabel.text = self.resultInfoString;
}

- (IBAction)backToStartViewController:(UIBarButtonItem *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
@end
