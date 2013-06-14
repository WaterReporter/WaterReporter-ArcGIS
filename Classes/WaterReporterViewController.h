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
#import "CuratedMapViewController.h"

@protocol FeatureGeometryDelegate;

@interface WaterReporterViewController : UIViewController <AGSAttachmentManagerDelegate, AGSLayerDelegate, AGSMapViewLayerDelegate, AGSMapViewCalloutDelegate, AGSInfoTemplateDelegate, AGSCalloutDelegate, AGSMapViewTouchDelegate, AGSFeatureLayerEditingDelegate, AGSWebMapDelegate, FeatureTemplatePickerDelegate, UIAlertViewDelegate, CLLocationManagerDelegate, UIScrollViewDelegate, UIScrollViewAccessibilityDelegate> {

    id <FeatureGeometryDelegate> featureGeometryDelegate;
    AGSGeometry *manualFeatureGeometry;
    
    UIScrollView* _tutorialView;
    UIPageControl* _pageControl;

    double _viUserLocationLongitude;
    double _viUserLocationLatitude;
    BOOL _loadingFromFeatureDetails;

    AGSMapView *_mapView;
    AGSWebMap* _webmap;
    AGSWebMap* _curatedMap;
	AGSFeatureLayer *_featureLayer;
    AGSPoint *_userLocation;
    CLLocationManager *_locationManager;
    AGSGraphic *_newFeature;
    AGSSketchGraphicsLayer* _sketchLayer;
    UIButton* _addNewFeatureToMap;

    FeatureTemplatePickerViewController* _featureTemplatePickerViewController;
    CuratedMapViewController* _curatedMapViewController;

}

@property (nonatomic, retain) AGSGeometry *manualFeatureGeometry;

@property (nonatomic) double viUserLocationLongitude;
@property (nonatomic) double viUserLocationLatitude;
@property (nonatomic) BOOL loadingFromFeatureDetails;

@property (nonatomic, retain) IBOutlet UIScrollView* tutorialView;
@property (nonatomic, retain) UIPageControl* pageControl;

@property (nonatomic, retain) IBOutlet AGSMapView *mapView;
@property (nonatomic, retain) AGSWebMap* webmap;
@property (nonatomic, retain) AGSWebMap* curatedMap;
@property (nonatomic, retain) AGSFeatureLayer *featureLayer;
@property (nonatomic, retain) AGSPoint *userLocation;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) AGSSketchGraphicsLayer* sketchLayer;
@property (nonatomic, strong) UIButton* addNewFeatureToMap;

@property (retain) id featureGeometryDelegate;

@property (nonatomic, strong) FeatureTemplatePickerViewController* featureTemplatePickerViewController;
@property (nonatomic, strong) CuratedMapViewController* curatedMapViewController;

-(void)featureTemplatePickerViewController:(FeatureTemplatePickerViewController*) featureTemplatePickerViewController didSelectFeatureTemplate:(AGSFeatureTemplate*)template forFeatureLayer:(AGSFeatureLayer*)featureLayer;
-(void)sketchLayerUserEditingDidFinish:(AGSGeometry *)userSelectedGeometry;

@end