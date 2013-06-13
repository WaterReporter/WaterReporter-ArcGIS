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

@interface CuratedMapViewController : UIViewController <AGSWebMapDelegate, AGSMapViewTouchDelegate, AGSPopupsContainerDelegate, PoupupHelperDelegate> {

    AGSMapView *_mapView;
    AGSWebMap* _webmap;
    NSString* webmapId;
    
    UIActivityIndicatorView *_activityIndicator;
    PopupHelper *_popupHelper;
    AGSPopupsContainerViewController *_popupVC;
    
}

@property (nonatomic, strong) IBOutlet AGSMapView *mapView;
@property (nonatomic, strong) AGSWebMap *webMap;
@property (nonatomic, strong) NSString* webmapId;

@property (nonatomic,strong) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) PopupHelper * popupHelper;
@property (nonatomic, strong) AGSPopupsContainerViewController* popupVC;

- (void)foundPopups:(NSArray*) popups atMapPonit:(AGSPoint*)mapPoint withMoreToFollow:(BOOL)more;
- (void)foundAdditionalPopups:(NSArray*) popups withMoreToFollow:(BOOL)more;

@end
