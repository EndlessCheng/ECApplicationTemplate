//
//  ShareViewController.m
//  ECApplicationTemplate
//
//  Created by chengyh on 15/12/7.
//  Copyright © 2015年 jianyan. All rights reserved.
//

#import "ShareViewController.h"

@interface ShareViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *sharedImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sharedImageViewWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sharedImageViewHeight;

@end

@implementation ShareViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.sharedImageView.image = self.sharedImage;
}

- (void)updateViewConstraints {
    [super updateViewConstraints];
    
    self.sharedImageViewWidth.constant = self.sharedImage.size.width;
    self.sharedImageViewHeight.constant = self.sharedImage.size.height;
}

- (IBAction)back:(UIBarButtonItem *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
