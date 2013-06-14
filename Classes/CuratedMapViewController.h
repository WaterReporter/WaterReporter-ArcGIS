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
#import "PopupHelper.h"

@class FeatureTemplatePickerViewController;

@interface CuratedMapViewController : UIViewController <AGSWebMapDelegate, AGSMapViewLayerDelegate, AGSMapViewCalloutDelegate, AGSCalloutDelegate, AGSMapViewTouchDelegate, AGSPopupsContainerDelegate, PoupupHelperDelegate, CLLocationManagerDelegate> {
    
    /**
     * Map related variables
     */
    AGSMapView *_mapView;
    AGSWebMap* _webmap;
    NSString* webmapId;
    
    /**
     * Popup related variables
     */
    UIActivityIndicatorView *_activityIndicator;
    PopupHelper *_popupHelper;
    AGSPopupsContainerViewController *_popupVC;

    /**
     * Location related variables
     */
    AGSPoint *_userLocation;
    CLLocationManager *_locationManager;
    
    AGSGraphic *_newFeature;
	AGSFeatureLayer *_featureLayer;

    FeatureTemplatePickerViewController *featureTemplatePickerViewController;

}

/**
 * Pass variables along
 */
@property(nonatomic, strong) NSMutableArray* isSomethingEnabled;

/**
 * Map related variables
 */
@property (nonatomic, strong) IBOutlet AGSMapView *mapView;
@property (nonatomic, strong) AGSWebMap *webMap;
@property (nonatomic, strong) NSString* webmapId;

/**
 * Popup related variables
 */
@property (nonatomic,strong) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) PopupHelper * popupHelper;
@property (nonatomic, strong) AGSPopupsContainerViewController* popupVC;

- (void)foundPopups:(NSArray*) popups atMapPonit:(AGSPoint*)mapPoint withMoreToFollow:(BOOL)more;
- (void)foundAdditionalPopups:(NSArray*) popups withMoreToFollow:(BOOL)more;

/**
 * Location related variables
 */
@property (nonatomic, retain) AGSPoint *userLocation;
@property (nonatomic, strong) CLLocationManager *locationManager;

@property (nonatomic, retain) AGSFeatureLayer *featureLayer;

@property (nonatomic, strong) FeatureTemplatePickerViewController *featureTemplatePickerViewController;

@end
