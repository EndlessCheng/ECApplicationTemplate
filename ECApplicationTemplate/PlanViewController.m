//
//  PlanViewController.m
//  ECApplicationTemplate
//
//  Created by chengyh on 15/12/8.
//  Copyright © 2015年 jianyan. All rights reserved.
//

#import "PlanViewController.h"

@interface PlanViewController ()

@property (weak, nonatomic) IBOutlet UIView *nowPlan;
@property (weak, nonatomic) IBOutlet UIView *planGroups;


@property (nonatomic, copy) NSArray<UIView *> *planViews;

@end

@implementation PlanViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.planViews = @[self.nowPlan, self.planGroups];
    for (NSInteger i = 0; i < self.planViews.count; ++i) {
        self.planViews[i].hidden = (i != 0);
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (IBAction)planSegmentedControlChanged:(UISegmentedControl *)sender {
    NSInteger selectedSegment = sender.selectedSegmentIndex;
    for (NSInteger i = 0; i < self.planViews.count; ++i) {
        self.planViews[i].hidden = (i != selectedSegment);
    }
}

- (IBAction)mainPlanToAddPlan:(UIButton *)sender {
    [self performSegueWithIdentifier:@"MainPlanToAddPlan" sender:self];
}

@end
