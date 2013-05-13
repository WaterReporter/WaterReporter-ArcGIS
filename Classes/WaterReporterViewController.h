// Copyright 2012 ESRI
//
// All rights reserved under the copyright laws of the United States
// and applicable international laws, treaties, and conventions.
//
// You may freely redistribute and use this sample code, with or
// without modification, provided you include the original copyright
// notice and use restrictions.
//
// See the use restrictions at http://help.arcgis.com/en/sdk/10.0/usageRestrictions.htm
//

#import <UIKit/UIKit.h>
#import <ArcGIS/ArcGIS.h>
#import "FeatureTemplatePickerViewController.h"
#import "TutorialViewController.h"
#import "WaterReporterFeatureLayer.h"

// OnlineOfflineDelegate


@interface WaterReporterViewController : UIViewController<AGSAttachmentManagerDelegate, AGSLayerDelegate, AGSMapViewLayerDelegate, AGSMapViewCalloutDelegate, AGSInfoTemplateDelegate, AGSCalloutDelegate, AGSMapViewTouchDelegate,AGSPopupsContainerDelegate, AGSFeatureLayerEditingDelegate, AGSWebMapDelegate, FeatureTemplatePickerDelegate, UIAlertViewDelegate, CLLocationManagerDelegate> {

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

