//
//  StoryBoardManager.m
//  StoryBoardTest
//
//  Created by chengyh on 15/10/21.
//  Copyright © 2015年 jianyan. All rights reserved.
//

#import "StoryBoardUtil.h"

@implementation StoryBoardUtil

+ (UIViewController *)instantiateInitialViewControllerWithStoryBoardName:(NSString *)storyBoardName {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyBoardName bundle:nil];
    return [storyboard instantiateInitialViewController];
}

@end
