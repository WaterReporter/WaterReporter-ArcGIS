/**
 * Water Reporter
 *
 * Created by Viable Industries L.L.C. in March 2013.
 * Copyright (c) 2013 Viable Industries L.L.C. All rights reserved.
 *
 */

#import <UIKit/UIKit.h>
#import <ArcGIS/ArcGIS.h>
#import "FeatureTemplatePickerViewController.h"
#import "TutorialViewController.h"
#import "WaterReporterFeatureLayer.h"

@interface WaterReporterViewController : UIViewController <AGSAttachmentManagerDelegate, AGSLayerDelegate, AGSMapViewLayerDelegate, AGSMapViewCalloutDelegate, AGSInfoTemplateDelegate, AGSCalloutDelegate, AGSMapViewTouchDelegate,AGSPopupsContainerDelegate, AGSFeatureLayerEditingDelegate, AGSWebMapDelegate, FeatureTemplatePickerDelegate, UIAlertViewDelegate, CLLocationManagerDelegate> {

    AGSMapView *_mapView;
    AGSWebMap* _webmap;
	AGSFeatureLayer *_featureLayer;
    CLLocationManager *_locationManager;
    AGSGraphic *_newFeature;

    FeatureTemplatePickerViewController* _featureTemplatePickerViewController;
    TutorialViewController* _tutorialViewController;
}   

    @property (nonatomic, strong) IBOutlet AGSMapView *mapView;
    @property (nonatomic, strong) AGSWebMap* webmap;
    @property (nonatomic, retain) AGSFeatureLayer *featureLayer;
    @property (nonatomic, strong) CLLocationManager *locationManager;
    @property (nonatomic, strong) AGSGraphic* newFeature;

    @property (nonatomic, strong) FeatureTemplatePickerViewController* featureTemplatePickerViewController;
    @property (nonatomic, strong) TutorialViewController* tutorialViewController;

@end

