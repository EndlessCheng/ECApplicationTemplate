//
//  FinishViewController.h
//  ECApplicationTemplate
//
//  Created by chengyh on 15/10/21.
//  Copyright © 2015年 jianyan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FinishViewController : UIViewController

@property (nonatomic, weak) IBOutlet UILabel *resultLabel;

- (IBAction)backToStartViewController:(UIBarButtonItem *)sender;

@end
