//
//  WelcomeViewController.m
//  ECApplicationTemplate
//
//  Created by chengyh on 15/10/21.
//  Copyright © 2015年 jianyan. All rights reserved.
//

#import "AWBluetooth.h"
#import "StoryBoardUtil.h"

#import "WelcomeViewController.h"
#import "TabBarController.h"

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

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self autoLogin];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - User Methods

- (void)setScrollGuideView {
    // use GUIDE_PICTURE_NUMBER for multiple APPs
    for (NSUInteger i = 0; i < GUIDE_PICTURE_NUMBER; i++) {
        NSString *imageName = [NSString stringWithFormat:@"welcome_guide_%@_%@.png", @((NSInteger)(SCREEN_HEIGHT + 0.5)), @(i + 1)];
        UIImage *image = [UIImage imageNamed:imageName];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        imageView.frame = CGRectMake(i * SCREEN_WIDTH, 0, image.size.width, image.size.height);
        if (i == GUIDE_PICTURE_NUMBER - 1) {
            UIColor *textColor = [UIColor colorWithRed:0.0 / 255 green:122.0 / 255 blue:255.0 / 255 alpha:1.0];
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.frame = CGRectMake(0, 0, 200, 40);
            button.center = CGPointMake(SCREEN_WIDTH / 2, SCREEN_HEIGHT - 57);
            [button setTitle:NSLocalizedString(@"开始使用",) forState:UIControlStateNormal];
            button.titleLabel.font = [UIFont systemFontOfSize:18];
            [button setTitleColor:textColor forState:UIControlStateNormal];
            button.layer.cornerRadius = 10.0;
            button.layer.borderWidth = 1.5;
            button.layer.borderColor = textColor.CGColor;
            
            [imageView addSubview:button];
            [button addTarget:self action:@selector(hiddenScrollView) forControlEvents:UIControlEventTouchUpInside];
            imageView.userInteractionEnabled = YES;
        }
        [self.guideScrollView addSubview:imageView];
    }
    [self.guideScrollView setContentSize:CGSizeMake(GUIDE_PICTURE_NUMBER * SCREEN_WIDTH, SCREEN_HEIGHT)];
    self.guidePageControl.numberOfPages = GUIDE_PICTURE_NUMBER;
}

- (void)hiddenScrollView {
    self.guideScrollView.hidden = YES;
    self.guidePageControl.hidden = YES;
    [UIApplication sharedApplication].statusBarHidden = NO;
    self.navigationController.navigationBar.hidden = NO;
}

- (void)autoLogin {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if ([[userDefaults objectForKey:kUserDefaultsLoginState] isEqual:@(ECUserDefaultsLoginStateIsLogin)]) {
        [self hiddenScrollView];

        [self setUserInfo:[ECHTTPUtil fetchUserInfo]];
        
        [self performSegueWithIdentifier:@"WelcomeToTabBar" sender:self];
    }
}

- (void)setUserInfo:(AWUserInfo *)userInfo {
    // change NSUserDefaults
}

- (IBAction)loginButtonClicked:(id)sender {
    [self performSegueWithIdentifier:@"WelcomeToLogin" sender:self];
}


#pragma mark - Scroll View Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat offsetx = scrollView.contentOffset.x;
    self.guidePageControl.currentPage = (NSInteger)(offsetx / SCREEN_WIDTH + 0.5);
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

@end
