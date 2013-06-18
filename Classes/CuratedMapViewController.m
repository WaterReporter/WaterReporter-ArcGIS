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
#import "FeatureTemplatePickerViewController.h"
#import "FeatureDetailsViewController.h"
#import "PopupHelper.h"

/**
 * Define the Web Map ID that we wish to load
 */
#define FEATURE_SERVICE_URL @"a2d34296ca3a4966a924ffd7bad5149a"
#define FEATURE_SERVICE_ZOOM 150000
#define BACKGROUND_LINEN_LIGHT [UIColor colorWithPatternImage:[UIImage imageNamed:@"backgroundDefault"]]

@implementation CuratedMapViewController 

@synthesize webMap = _webMap;
@synthesize mapView = _mapView;
@synthesize webmapId = _webmapId;

@synthesize activityIndicator = _activityIndicator;
@synthesize popupVC = _popupVC;
@synthesize popupHelper = _popupHelper;

@synthesize userLocation;
@synthesize locationManager = _locationManager;
@synthesize viUserLocationLongitude = _viUserLocationLongitude;
@synthesize viUserLocationLatitude = _viUserLocationLatitude;

@synthesize cachedFeatureLayerTemplates;
@synthesize featureLayer = _featureLayer;

@synthesize featureTemplatePickerViewController;

// Do any additional setup after loading the view
- (void)viewDidLoad {

    /**
     * This allows us to see what is being fired and when
     */
    NSLog(@"CuratedMapViewController:viewDidLoad");
    NSLog(@"Value from TutorialViewController: %@", self.cachedFeatureLayerTemplates);
    
    [super viewDidLoad];
    
    /**
     * Setup the Web Map
     *
     * We are loading the appropriate web map, based on the Web Map ID defined
     * in the FEATURE_SERVICE_URL constant at the top of this document.
     *
     */
    self.webMap = [AGSWebMap webMapWithItemId:FEATURE_SERVICE_URL credential:nil];
    
    /**
     * Designate a delegate to be notified as web map is opened
     */
    self.webMap.delegate = self;
    [self.webMap openIntoMapView:self.mapView];
    
    /**
     * Set the delegates so that they can do the job they are here for
     */
    self.mapView.touchDelegate = self;
    self.mapView.calloutDelegate = self;
    self.mapView.callout.delegate = self;
    self.mapView.layerDelegate = self;
        
    /**
     * Initialize the feature template picker so that we can show it later when needed.
     *
     * As soon as we do, we need to add those templates to the FeatureTemplatePicker.
     *
     */
    self.featureTemplatePickerViewController =  [[[FeatureTemplatePickerViewController alloc] initWithNibName:@"FeatureTemplatePickerViewController" bundle:nil] autorelease];
    self.featureTemplatePickerViewController.delegate = self;

    for (AGSFeatureLayer* layer in self.cachedFeatureLayerTemplates) {
        NSLog(@"Loading layer from CuratedMap %@", layer.name);
        [self.featureTemplatePickerViewController addTemplatesFromLayer:layer];
    }
    

    /**
     * Prepare the Popup Helper for later use
     */
    self.popupHelper = [[PopupHelper alloc] init];
    self.popupHelper.delegate = self;
    
    /**
     * This is the "Commit" button when you're adding a new feature to the map
     */
    UIBarButtonItem *addReportButton = [[[UIBarButtonItem alloc]initWithTitle:@"Add Report" style:UIBarButtonItemStyleBordered target:self action:@selector(presentFeatureTemplatePicker)]autorelease];
    self.navigationItem.rightBarButtonItem = addReportButton;
    
    [self.navigationItem setHidesBackButton:YES];
    
}

#pragma mark - AGSWebMapDelegagte methods
- (void) webMapDidLoad:(AGSWebMap *)webMap {

    /**
     * This allows us to see what is being fired and when
     */
    NSLog(@"CuratedMapViewController: webMap: webMapDidLoad");

}


/**
 * Display users geolocation on map
 *
 */
-(void) mapViewDidLoad:(AGSMapView*)mapView {
    
    NSLog(@"Starting core location from didOpenWebMap");
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    [self.locationManager startUpdatingLocation];
    
    /**
     * If we are not already displaying the users
     * current location on the map, then we need to
     * add an indicator to the map, showing the user
     * where the application thinks they are currently.
     *
     * @see For more information on AGSLocationDisplay
     *   http://resources.arcgis.com/en/help/runtime-ios-sdk/apiref/interface_a_g_s_location_display.html
     */
    if(!self.mapView.locationDisplay.dataSourceStarted) {
        [self.mapView.locationDisplay startDataSource];
        self.mapView.locationDisplay.zoomScale = FEATURE_SERVICE_ZOOM;
        self.mapView.locationDisplay.autoPanMode = AGSLocationDisplayAutoPanModeDefault;
    }
    
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
    [self.webMap continueOpenAndSkipCurrentLayer];
}

- (void)mapView:(AGSMapView *)mapView didClickAtPoint:(CGPoint)screen mapPoint:(AGSPoint *)mappoint graphics:(NSDictionary *)graphics {
    
    //cancel any outstanding requests
    [self.popupHelper cancelOutstandingRequests];
    
    [self.popupHelper findPopupsForMapView:mapView withGraphics:graphics atPoint:mappoint andWebMap:self.webMap withQueryableLayers:nil];
}

/**
 * Implements didClickAccessoryButtonForCallout
 *
 * This is the little blue button with the arrow that appears
 * in popups to display the "Information Window" or feature
 * details about the selected feature.
 *
 * This method is fired when the user clicks that arrow button.
 *
 */
- (void)didClickAccessoryButtonForCallout:(AGSCallout *) callout {
    
    
    /**
     * This allows us to see what is being fired and when
     */
    NSLog(@"WaterReporterViewController: didClickAccessoryButtonForCallout");
    
	/**
     * Display the details for the active or clicked on feature.
     */
    [self.navigationController pushViewController:self.popupVC animated:YES];
}

/**
 * Add a new feature
 *
 * The action for the "+" button that allows
 * the user to select what kind of Feature
 * they would like to add to the map
 *
 */
-(void)presentFeatureTemplatePicker {
    
    /**
     * This allows us to see what is being fired and when
     */
    NSLog(@"CuratedMapViewController:presentFeatureTemplatePicker");
    
    // iPAD ONLY: Limit the size of the form sheet
    if([[AGSDevice currentDevice] isIPad]) {
        self.featureTemplatePickerViewController.modalPresentationStyle = UIModalPresentationFormSheet;
    }
    
    // ALL: Animate the template picker, covering vertically
    self.featureTemplatePickerViewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    
    // Display the modal ... see FeatureTemplatePickerViewController.xib for layout
    self.featureTemplatePickerViewController.curatedMapActivated = YES;
    [self.navigationController pushViewController:self.featureTemplatePickerViewController animated:YES];
    
}

- (void)foundPopups:(NSArray*) popups atMapPonit:(AGSPoint*)mapPoint withMoreToFollow:(BOOL)more {
    
    //Release the last popups vc
    self.popupVC = nil;
    
    // If we've found one or more popups
    if (popups.count > 0) {
        //Create a popupsContainer view controller with the popups
        self.popupVC = [[AGSPopupsContainerViewController alloc] initWithPopups:popups usingNavigationControllerStack:YES];
        self.popupVC.style = AGSPopupsContainerStyleBlack;
        self.popupVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        self.popupVC.delegate = self;
        [self.popupVC.view setBackgroundColor:BACKGROUND_LINEN_LIGHT];
       
    
        
        // For iPad, display popup view controller in the callout
        if ([[AGSDevice currentDevice] isIPad]) {
            self.mapView.callout.customView = self.popupVC.view;
            if(more){
                // Start the activity indicator in the upper right corner of the
                // popupsContainer view controller while we wait for the query results
                self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
                UIBarButtonItem *blankButton = [[UIBarButtonItem alloc] initWithCustomView:(UIView*)self.activityIndicator];
                self.popupVC.actionButton = blankButton;
                [self.activityIndicator startAnimating];
            }
        }
        else {
            //For iphone, display summary info in the callout
            self.mapView.callout.title = [NSString stringWithFormat:@"%d Results", popups.count];
            self.mapView.callout.accessoryButtonHidden = NO;
            if(more)
                self.mapView.callout.detail = @"loading more...";
            else
                self.mapView.callout.detail = @"";
        }
        
    }else{
        // If we did not find any popups yet, but we expect some to follow
        // show the activity indicator in the callout while we wait for results
        if(more) {
            self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
            self.mapView.callout.customView = self.activityIndicator;
            [self.activityIndicator startAnimating];
        }
        else{
            //If don't have any popups, and we don't expect any more results
            [self.activityIndicator stopAnimating];
            self.mapView.callout.customView = nil;
            self.mapView.callout.accessoryButtonHidden = YES;
            self.mapView.callout.title = @"No Results";
            self.mapView.callout.detail = @"";
        }
        
    }
    [self.mapView.callout showCalloutAt:mapPoint pixelOffset:CGPointZero animated:YES];
    
    
}

- (void)foundAdditionalPopups:(NSArray*) popups withMoreToFollow:(BOOL)more{
    
    if(popups.count>0){
        if (self.popupVC) {
            [self.popupVC showAdditionalPopups:popups];
            
            // If these are the results of the final query stop the activityIndicator
            if (!more) {
                [self.activityIndicator stopAnimating];
                
                // If we are on iPhone display the number of results returned
                if (![[AGSDevice currentDevice] isIPad]) {
                    self.mapView.callout.customView = nil;
                    NSString *results = self.popupVC.popups.count == 1 ? @"Result" : @"Results";
                    self.mapView.callout.title = [NSString stringWithFormat:@"%d %@", self.popupVC.popups.count, results];
                    self.mapView.callout.detail = @"";
                }
            }
        } else {
            
            self.popupVC = [[AGSPopupsContainerViewController alloc] initWithPopups:popups];
            self.popupVC.delegate = self;
            self.popupVC.style = AGSPopupsContainerStyleBlack;
            
            // If we are on iPad set the popupsContainerViewController to be the callout's customView
            if ([[AGSDevice currentDevice] isIPad]) {
                self.mapView.callout.customView = self.popupVC.view;
            }
            
            // If we have more popups coming, start the indicator on the popupVC
            if (more) {
                if ([[AGSDevice currentDevice] isIPad] ) {
                    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
                    UIBarButtonItem *blankButton = [[UIBarButtonItem alloc] initWithCustomView:(UIView*)self.activityIndicator];
                    self.popupVC.actionButton = blankButton;
                    [self.activityIndicator startAnimating];
                }
                
            }
            // Otherwise if we are on iPhone display the number of results returned in the callout
            else if (![[AGSDevice currentDevice] isIPad]) {
                self.mapView.callout.customView = nil;
                NSString *results = self.popupVC.popups.count == 1 ? @"Result" : @"Results";
                self.mapView.callout.title = [NSString stringWithFormat:@"%d %@", self.popupVC.popups.count, results];
                self.mapView.callout.detail = @"";
            }
        }
    }else{
        // If these are the results of the last query stop the activityIndicator
        if (!more) {
            [self.activityIndicator stopAnimating];
            
            // If no query returned results
            if (!self.popupVC) {
                self.mapView.callout.customView = nil;
                self.mapView.callout.accessoryButtonHidden = YES;
                self.mapView.callout.title = @"No Results";
                self.mapView.callout.detail = @"";
            }
            // Otherwise if we are on iPhone display the number of results returned in the callout
            else if (![[AGSDevice currentDevice] isIPad]) {
                self.mapView.callout.customView = nil;
                NSString *results = self.popupVC.popups.count == 1 ? @"Result" : @"Results";
                self.mapView.callout.title = [NSString stringWithFormat:@"%d %@", self.popupVC.popups.count, results];
                self.mapView.callout.detail = @"";
            }
        }
        
    }
    
}

#pragma mark - AGSPopupsContainerDelegate methods
- (void)popupsContainerDidFinishViewingPopups:(id<AGSPopupsContainer>)popupsContainer {
    
    //cancel any outstanding requests
    [self.popupHelper cancelOutstandingRequests];
    
    // If we are on iPad dismiss the callout
    if ([[AGSDevice currentDevice] isIPad]) {
        self.mapView.callout.hidden = YES;
    } else {
        //dismiss the modal viewcontroller for iPhone
        [self.popupVC dismissViewControllerAnimated:YES completion:nil];
    }
}

-(void)featureTemplatePickerViewController:(FeatureTemplatePickerViewController*) featureTemplatePickerViewController didSelectFeatureTemplate:(AGSFeatureTemplate*)template forFeatureLayer:(AGSFeatureLayer*)featureLayer {
    
    /**
     * This allows us to see what is being fired and when
     */
    NSLog(@"CuratedMapViewController:featureTemplatePickerViewController:didSelectFeatureTemplate");
    
    //
    // Set the active feature layer to the one we are going to edit
    //
    self.featureLayer = featureLayer;
    
    //create a new feature based on the template
    _newFeature = [self.featureLayer featureWithTemplate:template];
    
    //Add the new feature to the feature layer's graphic collection
    [self.featureLayer addGraphic:_newFeature];
    
    //First, dismiss the Feature Template Picker
    [self dismissViewControllerAnimated:NO completion:nil];
    
    AGSGeometryEngine *ge = [AGSGeometryEngine defaultGeometryEngine];
    AGSGeometry *geometry = [ge projectGeometry:self.userLocation toSpatialReference:self.userLocation.spatialReference];
    
    //now create the feature details vc and display it
    FeatureDetailsViewController *detailViewController = [[[FeatureDetailsViewController alloc]initWithFeatureLayer:self.featureLayer feature:nil featureGeometry:geometry templatePrototype:template.prototype] autorelease];
    
    detailViewController.userLocation = self.userLocation;
    
	/**
     * Prepares the details for the new feature.
     */
    [self.navigationController pushViewController:detailViewController animated:YES];
}

/*
 * We want to get and store a location measurement that meets the desired accuracy. For this example, we are
 *      going to use horizontal accuracy as the deciding factor. In other cases, you may wish to use vertical
 *      accuracy, or both together.
 */
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    
    /**
     * This allows us to see what is being fired and when
     */
    NSLog(@"WaterReporterViewController:locationManager:didUpdateToLocation");
    
    /**
     * Ensure horizontal accuracy doesn't resolve to
     * an invalid measurement.
     */
    if (newLocation.horizontalAccuracy < 0) {
        return;
    }
    
    /**
     * Create an AGSLocation instance so that we can
     * fetch the X & Y coordinates and update the
     * variables for our feature layer form.
     */
    AGSLocation* agsLoc = self.mapView.locationDisplay.location;
    
    /**
     * Check to see if the Longitude or Latitude has changed
     * since the last update. If it hasn't then don't change
     * it repeatedly.
     */
    if (self.viUserLocationLongitude != agsLoc.point.x && self.viUserLocationLatitude != agsLoc.point.y) {
        
        self.userLocation = (AGSMutablePoint *)agsLoc.point;
        
        self.viUserLocationLongitude = agsLoc.point.x;
        self.viUserLocationLatitude = agsLoc.point.y;
        
        NSLog(@"GEOLOCATION [x: %f; y: %f]", self.viUserLocationLongitude, self.viUserLocationLatitude);
        
        [self.locationManager stopUpdatingLocation];
    }
    
    return;
}

/**
 * If the Location Manager fails, we need to stop it so that it doesn't start
 * looping through error after error.
 */
- (void)locationManager: (CLLocationManager *)manager didFailWithError: (NSError *)error {
    
    [manager stopUpdatingLocation];
    
    NSLog(@"error%@",error);
    switch([error code]) {
        case kCLErrorNetwork: {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"please check your network connection or that you are not in airplane mode" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alert show];
            [alert release];
        }
            break;
        case kCLErrorDenied:{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"user has denied to use current Location " delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alert show];
            [alert release];
        }
            break;
        default: {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"unknown network error" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alert show];
            [alert release];
        }
            break;
    }
}

/**
 * Stop updating the Location Manager
 */
- (void)stopUpdatingLocation {
    
    /**
     * This allows us to see what is being fired and when
     */
    NSLog(@"WaterReporterViewController:stopUpdatingLocation");
    
    [self.locationManager stopUpdatingLocation];
    [self.locationManager release];
}

// Release any retained subviews of the main view.
- (void)viewDidUnload
{
    [self.webMap release];
    [self.mapView release];
    [self.webmapId release];
    
    [self.activityIndicator release];
    [self.popupVC release];
    [self.popupHelper release];
    
    [self.userLocation release];
    [self.locationManager release];
    
    [self.cachedFeatureLayerTemplates release];
    [self.featureLayer release];
    [self.featureTemplatePickerViewController release];

    [super viewDidUnload];
}

// Release any retained subviews of the main view.
- (void)dealloc
{
    [self.webMap release];
    [self.mapView release];
    [self.webmapId release];
    
    [self.activityIndicator release];
    [self.popupVC release];
    [self.popupHelper release];
    
    [self.userLocation release];
    [self.locationManager release];
    
    [self.cachedFeatureLayerTemplates release];
    [self.featureLayer release];
    [self.featureTemplatePickerViewController release];

    [super dealloc];
}



@end
