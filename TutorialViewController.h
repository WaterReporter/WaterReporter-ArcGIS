//
//  TutorialViewController.h
//  WaterReporter
//
//  Created by viableindustries on 5/9/13.
//
//

#import <UIKit/UIKit.h>
#import <ArcGIS/ArcGIS.h>

@class TutorialViewController;

@protocol FeatureTemplatePickerDelegate;

@interface TutorialViewController : UIViewController <UIScrollViewDelegate, UIScrollViewAccessibilityDelegate> {

    id <FeatureTemplatePickerDelegate> featureTemplatePickerDelegate;

    UIScrollView* _tutorialView;
    UIPageControl* _pageControl;
    
}

@property (retain) id featureTemplatePickerDelegate;

@property (nonatomic, retain) IBOutlet UIScrollView* tutorialView;
@property (nonatomic, retain) UIPageControl* pageControl;

-(void)presentFeatureTemplatePicker;

@end