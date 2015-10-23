//
//  StoryBoardManager.h
//  StoryBoardTest
//
//  Created by chengyh on 15/10/21.
//  Copyright © 2015年 jianyan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface StoryBoardUtil : NSObject

+ (UIViewController *)instantiateInitialViewControllerWithStoryBoardName:(NSString *)storyBoardName;

@end
