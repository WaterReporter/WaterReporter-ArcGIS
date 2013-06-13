//
//  TutorialViewController.h
//  WaterReporter
//
//  Created by viableindustries on 5/9/13.
//
//

#import <UIKit/UIKit.h>
#import <ArcGIS/ArcGIS.h>
#import "CuratedMapViewController.h"

@class TutorialViewController;

@protocol FeatureTemplatePickerDelegate;

@interface TutorialViewController : UIViewController <UIScrollViewDelegate, UIScrollViewAccessibilityDelegate> {

    id <FeatureTemplatePickerDelegate> featureTemplatePickerDelegate;

    UIScrollView* _tutorialView;
    UIPageControl* _pageControl;
    
    CuratedMapViewController *_curatedMapViewController;
    
}

@property (retain) id featureTemplatePickerDelegate;

@property (nonatomic, retain) IBOutlet UIScrollView* tutorialView;
@property (nonatomic, retain) UIPageControl* pageControl;
@property (nonatomic, strong) CuratedMapViewController* curatedMapViewController;

-(void)presentFeatureTemplatePicker;

@end