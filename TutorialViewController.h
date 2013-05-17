//
//  TutorialViewController.h
//  WaterReporter
//
//  Created by viableindustries on 5/9/13.
//
//

#import <UIKit/UIKit.h>

@class TutorialViewController;

@interface TutorialViewController : UIViewController <UIScrollViewDelegate, UIScrollViewAccessibilityDelegate> {
    UIScrollView* _tutorialView;
    UIPageControl* _pageControl;
}

@property (nonatomic, retain) IBOutlet UIScrollView* tutorialView;
@property (nonatomic, retain) UIPageControl* pageControl;

@end