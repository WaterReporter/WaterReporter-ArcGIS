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

#import "CuratedMapViewController.h"

/**
 * Define the Web Map ID that we wish to load
 */
#define FEATURE_SERVICE_URL @"a2d34296ca3a4966a924ffd7bad5149a"

@implementation CuratedMapViewController 

@synthesize webMap = _webMap;
@synthesize mapView = _mapView;
@synthesize webmapId = _webmapId;

// Do any additional setup after loading the view
- (void)viewDidLoad {

    /**
     * This allows us to see what is being fired and when
     */
    NSLog(@"CuratedMapViewController:viewDidLoad");
    
    [super viewDidLoad];
    
    /**
     * Setup the Web Map
     *
     * We are loading the appropriate web map, based on the Web Map ID defined
     * in the FEATURE_SERVICE_URL constant at the top of this document.
     *
     */
    self.webmap = [AGSWebMap webMapWithItemId:FEATURE_SERVICE_URL credential:nil];
    
    /**
     * Designate a delegate to be notified as web map is opened
     */
    self.webmap.delegate = self;
    [self.webmap openIntoMapView:self.mapView];
    
    /**
     * Set the delegates so that they can do the job they are here for
     */
    self.mapView.touchDelegate = self;
    self.mapView.calloutDelegate = self;
    self.mapView.callout.delegate = self;
    self.mapView.layerDelegate = self;
        
    /**
     * Prepare the Popup Helper for later use
     */
//    self.popupHelper = [[PopupHelper alloc] init];
//    self.popupHelper.delegate = self;
    
    /**
     * Locate the user via their GPS cooridnates
     */
    //[self displayUsersGeolocation];
    
    /**
     * Set our default map navigation bar background to use our
     * charcoal pattern
     */
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"toolbar-charcoal-default.png"] forBarMetrics:UIBarMetricsDefault];
}

#pragma mark - AGSWebMapDelegagte methods
- (void) webMapDidLoad:(AGSWebMap *)webMap {

    /**
     * This allows us to see what is being fired and when
     */
    NSLog(@"CuratedMapViewController: webMap: webMapDidLoad");

}


- (void) webMap:(AGSWebMap *)webMap didLoadLayer:(AGSLayer *)layer {
    
    /**
     * This allows us to see what is being fired and when
     */
    NSLog(@"CuratedMapViewController: webMap: didLoadLayer");
    
}

- (void) webMap:(AGSWebMap *)webMap didFailToLoadLayer:(AGSWebMapLayerInfo *)layerInfo baseLayer:(BOOL)baseLayer federated:(BOOL)federated withError:(NSError *)error {
    
    NSLog(@"CuratedMapViewController: Failed to load layer : %@", layerInfo.title);
    
    //continue anyway
    [self.webmap continueOpenAndSkipCurrentLayer];
}

// Release any retained subviews of the main view.
- (void)viewDidUnload
{
    [self.webMap release];
    [self.mapView release];
    [self.webmapId release];
    [super viewDidUnload];
}

// Release any retained subviews of the main view.
- (void)dealloc
{
    [self.webMap release];
    [self.mapView release];
    [self.webmapId release];
    [super dealloc];
}



@end
