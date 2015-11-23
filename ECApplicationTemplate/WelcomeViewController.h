//
//  WelcomeViewController.h
//  ECApplicationTemplate
//
//  Created by chengyh on 15/10/21.
//  Copyright © 2015年 jianyan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WelcomeViewController : UIViewController <UIScrollViewDelegate>
// in fact, you needn't add <UIScrollViewDelegate> if you set guideScrollView's delegate in storyboard

@property (nonatomic, weak) IBOutlet UIScrollView *guideScrollView;
@property (nonatomic, weak) IBOutlet UIPageControl *guidePageControl;

@property (nonatomic, weak) IBOutlet UIButton *loginButton;
@property (nonatomic, weak) IBOutlet UIButton *registerButton;

- (IBAction)loginButtonClicked:(id)sender;

@end
