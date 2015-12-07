//
//  ShareViewController.h
//  ECApplicationTemplate
//
//  Created by chengyh on 15/12/7.
//  Copyright © 2015年 jianyan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ShareViewController : UIViewController

@property (nonatomic) UIImage *sharedImage;
@property (weak, nonatomic) IBOutlet UIImageView *sharedImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sharedImageViewWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sharedImageViewHeight;


- (IBAction)back:(UIBarButtonItem *)sender;

@end
