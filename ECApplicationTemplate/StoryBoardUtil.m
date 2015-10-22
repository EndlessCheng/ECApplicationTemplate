//
//  StoryBoardManager.m
//  StoryBoardTest
//
//  Created by 泽泰 舒 on 15/10/19.
//  Copyright © 2015年 杭州匠物科技. All rights reserved.
//

#import "StoryBoardUtil.h"

@implementation StoryBoardUtil

+ (UIViewController *)instantiateInitialViewControllerWithStoryBoardName:(NSString *)storyBoardName {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyBoardName bundle:nil];
    UIViewController *rootView = [storyboard instantiateInitialViewController];
    
    if ([rootView isKindOfClass:[UINavigationController class]]) {
        return ((UINavigationController *)rootView).topViewController;
    }
    return rootView;
}

@end
