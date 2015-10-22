//
//  StoryBoardManager.h
//  StoryBoardTest
//
//  Created by 泽泰 舒 on 15/10/19.
//  Copyright © 2015年 杭州匠物科技. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface StoryBoardUtil : NSObject

+ (UIViewController *)instantiateInitialViewControllerWithStoryBoardName:(NSString *)storyBoardName;

@end
