//
//  TutorialViewController.h
//  WaterReporter
//
//  Created by viableindustries on 5/9/13.
//
//

#import <UIKit/UIKit.h>
#import "FeatureTemplatePickerViewController.h"

@interface TutorialViewController : UIViewController {
    UIScrollView* tutorialView;
    FeatureTemplatePickerViewController* _featureTemplatePickerViewController;
}

@property (nonatomic, retain) IBOutlet UIScrollView* tutorialView;
@property (nonatomic, strong) FeatureTemplatePickerViewController* featureTemplatePickerViewController;

@end
