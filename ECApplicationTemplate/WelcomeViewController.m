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
#import "StartViewController.h"

@interface WelcomeViewController () <UIScrollViewDelegate>
// FIXME: in fact, you needn't add <UIScrollViewDelegate> if you set guideScrollView's delegate in storyboard

@property (nonatomic, weak) IBOutlet UIScrollView *guideScrollView;
@property (nonatomic, weak) IBOutlet UIPageControl *guidePageControl;

@property (nonatomic, weak) IBOutlet UIButton *loginButton;
@property (nonatomic, weak) IBOutlet UIButton *registerButton;

@property (nonatomic, weak) IBOutlet UIImageView *launchImageView;


@property (nonatomic) id<NSObject> findOADPeripheralObserver;
@property (nonatomic) BOOL isFoundOADPeripheral;

@end

@implementation WelcomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [UIApplication sharedApplication].statusBarHidden = YES;
    self.navigationController.navigationBar.hidden = YES;
    
    [self setScrollGuideView];
    
    self.launchImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"welcome_background_%@x%@.png", @((NSInteger) SCREEN_PIXEL_WIDTH), @((NSInteger) SCREEN_PIXEL_HEIGHT)]];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultsLoginState] isEqual:@(ECUserDefaultsLoginStateIsLogin)]) {
        self.launchImageView.hidden = NO;
        
        [self hiddenScrollView]; // Once login, scroll view doesn't show any more.
        
//        [[AWUserInfo sharedUserInfo] fetchUserInfo];
        
        [self jumpToTabBar];
    } else {
        self.launchImageView.hidden = YES;
    }
}

- (IBAction)loginButtonClicked:(UIButton *)sender {
    [self performSegueWithIdentifier:@"WelcomeToLogin" sender:self];
}


- (void)setScrollGuideView {
    // use GUIDE_PICTURE_NUMBER for multiple APPs
    for (NSUInteger i = 0; i < GUIDE_PICTURE_NUMBER; i++) {
        NSString *imageName = [NSString stringWithFormat:@"welcome_guide_%@_%@.png", @((NSInteger) (SCREEN_HEIGHT + 0.5)), @(i + 1)];
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
}

- (void)jumpToTabBar {
    self.isFoundOADPeripheral = NO;
    self.findOADPeripheralObserver = [[NSNotificationCenter defaultCenter] addObserverForName:kNotificationFindOADPeripheral object:nil queue:nil usingBlock:^(NSNotification *n) {
        [[NSNotificationCenter defaultCenter] removeObserver:self.findOADPeripheralObserver];
        
        self.isFoundOADPeripheral = YES;
        [self performSegueWithIdentifier:@"WelcomeToTabBar" sender:self];
    }];
    [[AWBluetooth sharedBluetooth] scanOADPeripherals];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (!self.isFoundOADPeripheral) {
            [[NSNotificationCenter defaultCenter] removeObserver:self.findOADPeripheralObserver];
            
            [self performSegueWithIdentifier:@"WelcomeToTabBar" sender:self];
        }
    });
}


#pragma mark - Scroll View Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat offsetx = scrollView.contentOffset.x;
    self.guidePageControl.currentPage = (NSInteger)(offsetx / SCREEN_WIDTH + 0.5);
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue destinationViewController] isKindOfClass:[TabBarController class]]) {
        TabBarController *tabBarController = [segue destinationViewController];
        tabBarController.isFoundOADPeripheral = self.isFoundOADPeripheral;
    }
}

@end
