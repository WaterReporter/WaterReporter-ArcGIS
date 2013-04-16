//
//  TutorialViewController.h
//  WaterReporter
//
//  Created by Viable Industries on 3/25/13.
//
//
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
#import "LoadingView.h"

@interface WaterReporterViewController : UIViewController<AGSAttachmentManagerDelegate, AGSMapViewLayerDelegate, AGSMapViewCalloutDelegate, AGSCalloutDelegate, AGSMapViewTouchDelegate,AGSPopupsContainerDelegate, AGSFeatureLayerEditingDelegate, AGSWebMapDelegate, FeatureTemplatePickerDelegate, UIAlertViewDelegate, CLLocationManagerDelegate> {
    
	AGSMapView *_mapView;
    AGSWebMap* _webmap;
	AGSFeatureLayer *_featureLayer;
    AGSPopupsContainerViewController* _popupVC;
    AGSGraphic* _newFeature;
    AGSSketchGraphicsLayer* _sketchLayer;

    UIView* _bannerView;
    UIAlertView* _alertView;
    UIBarButtonItem* _sketchCompleteButton;
    CLLocationManager *_locationManager;

    LoadingView* _loadingView;
    FeatureTemplatePickerViewController* _featureTemplatePickerViewController;
    
}

-(IBAction)presentButtonPressedLogMessage:(id)sender;

@property (nonatomic, strong) IBOutlet AGSMapView *mapView;
@property (nonatomic, strong) AGSWebMap* webmap;
@property (nonatomic, strong) AGSFeatureLayer *activeFeatureLayer;
@property (nonatomic, strong) AGSPopupsContainerViewController* popupVC;
@property (nonatomic, strong) AGSSketchGraphicsLayer* sketchLayer;

@property (nonatomic, strong) IBOutlet UIView* bannerView;
@property (nonatomic, strong) UIAlertView* alertView;
@property (nonatomic, strong) UIBarButtonItem* sketchCompleteButton;
@property (nonatomic, strong) CLLocationManager *locationManager;

@property (nonatomic, strong) LoadingView* loadingView;
@property (nonatomic, strong) FeatureTemplatePickerViewController* featureTemplatePickerViewController;


@end

