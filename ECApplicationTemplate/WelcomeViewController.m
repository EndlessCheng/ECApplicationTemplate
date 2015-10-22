//
//  WelcomeViewController.m
//  ECApplicationTemplate
//
//  Created by chengyh on 15/10/21.
//  Copyright © 2015年 jianyan. All rights reserved.
//

#import "WelcomeViewController.h"

#import "StoryBoardUtil.h"

@interface WelcomeViewController ()

@end

@implementation WelcomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [UIApplication sharedApplication].statusBarHidden = YES;
    self.navigationController.navigationBar.hidden = YES;
    [self setScrollGuideView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setScrollGuideView {
    for (int i = 0; i < GUIDE_PICTURE_NUMBER; i++) {
        NSString *imageName = [NSString stringWithFormat:@"welcome_guide%d_%d.png", (int)SCREEN_HEIGHT, i + 1];
        UIImage *image = [UIImage imageNamed:imageName];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        imageView.frame = CGRectMake(i * SCREEN_WIDTH, 0, image.size.width, image.size.height);
        if (i == GUIDE_PICTURE_NUMBER - 1) {
            UIColor *textColor = [UIColor colorWithRed:0.0 / 255 green:122.0 / 255 blue:255.0 / 255 alpha:1.0];
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.frame = CGRectMake(0, 0, 200, 40);
            button.center = CGPointMake(SCREEN_WIDTH / 2, SCREEN_HEIGHT - 57);
            [button setTitle:NSLocalizedString(@"Let's Move!",) forState:UIControlStateNormal];
            [button.titleLabel setFont:[UIFont systemFontOfSize:18]];
            [button setTitleColor:textColor forState:UIControlStateNormal];
            [button.layer setMasksToBounds:YES];
            [button.layer setCornerRadius:10.0];
            [button.layer setBorderWidth:1.5f];
            [button.layer setBorderColor:textColor.CGColor];
            
            [imageView addSubview:button];
            [button addTarget:self action:@selector(hiddenScrollView) forControlEvents:UIControlEventTouchUpInside];
            imageView.userInteractionEnabled = YES;
        }
        
        [_guideScrollView addSubview:imageView];
    }
    
    [_guideScrollView setContentSize:CGSizeMake(4 * SCREEN_WIDTH, SCREEN_HEIGHT)];
    _guideScrollView.delegate = self;
    
    _guidePageControl.numberOfPages = GUIDE_PICTURE_NUMBER;
}

- (void)hiddenScrollView {
    _guideScrollView.hidden = YES;
    _guidePageControl.hidden = YES;
    [UIApplication sharedApplication].statusBarHidden = NO;
    self.navigationController.navigationBar.hidden = NO;
}

- (void)jumpToTabBarViewController:(id)sender {
    [self performSegueWithIdentifier:@"WelcomeToTabBar" sender:self];
}


#pragma mark - Scroll View Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat offsetx = scrollView.contentOffset.x;
    _guidePageControl.currentPage = (NSInteger)(offsetx / SCREEN_WIDTH + 0.5);
}

@end
