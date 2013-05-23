//
//  PopupViewController.h
//  WaterReporter
//
//  Created by Joshua Powell on 5/22/13.
//
//

#import <UIKit/UIKit.h>
#import <ArcGIS/ArcGIS.h>

@interface PopupViewController : UIViewController <UINavigationControllerDelegate> {

    AGSGraphic* _feature;
    AGSFeatureLayer* _featureLayer;
    
}

@property (nonatomic, strong) AGSGraphic* feature;
@property (nonatomic, strong) AGSFeatureLayer* featureLayer;

-(id)initWithExistingFeature:(AGSFeatureLayer*)featureLayer feature:(AGSGraphic *)feature;
    
@end
