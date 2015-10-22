//
//  WelcomeViewController.h
//  ECApplicationTemplate
//
//  Created by chengyh on 15/10/21.
//  Copyright © 2015年 jianyan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WelcomeViewController : UIViewController

@property (nonatomic, weak) IBOutlet UIScrollView *guideScrollView;
@property (nonatomic, weak) IBOutlet UIPageControl *guidePageControl;

- (IBAction)jumpToTabBarViewController:(id)sender;

@end

