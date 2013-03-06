//
//  ModelController.h
//  Water Reporter 2
//
//  Created by J.I. Powell on 3/6/13.
//  Copyright (c) 2013 Developed Simple. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DataViewController;

@interface ModelController : NSObject <UIPageViewControllerDataSource>

- (DataViewController *)viewControllerAtIndex:(NSUInteger)index storyboard:(UIStoryboard *)storyboard;
- (NSUInteger)indexOfViewController:(DataViewController *)viewController;

@end
