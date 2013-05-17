//
//  TutorialViewController.h
//  WaterReporter
//
//  Created by viableindustries on 5/9/13.
//
//

#import <UIKit/UIKit.h>
#import "FeatureTemplatePickerViewController.h"

@interface TutorialViewController : UIViewController <UIScrollViewDelegate, UIScrollViewAccessibilityDelegate> {
    UIScrollView* _tutorialView;
    UIPageControl* _pageControl;
    FeatureTemplatePickerViewController* _featureTemplatePickerViewController;
}

@property (nonatomic, retain) IBOutlet UIScrollView* tutorialView;
@property (nonatomic, retain) UIPageControl* pageControl;
@property (nonatomic, strong) FeatureTemplatePickerViewController* featureTemplatePickerViewController;

@end
