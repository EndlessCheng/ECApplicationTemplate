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
    self.sharedImageView.frame = CGRectMake(0, 0, self.sharedImage.size.width, self.sharedImage.size.height);
    self.sharedImageView.image = self.sharedImage;
}

- (IBAction)back:(UIBarButtonItem *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)updateViewConstraints {
    [super updateViewConstraints];
    
    self.sharedImageViewWidth.constant = self.sharedImage.size.width;
    self.sharedImageViewHeight.constant = self.sharedImage.size.height;
}

@end
