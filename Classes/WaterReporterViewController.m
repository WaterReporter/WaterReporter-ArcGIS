/**
 * Water Reporter
 *
 * Created by Viable Industries L.L.C. in March 2013.
 * Copyright (c) 2013 Viable Industries L.L.C. All rights reserved.
 *
 */

#import "WaterReporterViewController.h"
#import "FeatureDetailsViewController.h"
#import "TutorialViewController.h"
#import "PopupHelper.h"

/**
 * Define the Web Map ID that we wish to load
 */
#define FEATURE_SERVICE_URL @"7f587e3a53dc455f92972a15031c94f8"

/**
 * Define whether the Feature Template Picker should display
 * automatically when the 
 */
#define FEATURE_TEMPLATE_AUTODISPLAY YES
#define TUTORIAL_IS_ACTIVE YES
#define FEATURE_SERVICE_ZOOM 3000

@implementation WaterReporterViewController

@synthesize userLocation;
@synthesize loadingFromFeatureDetails = _loadingFromFeatureDetails;
@synthesize viUserLocationLongitude = _viUserLocationLongitude;
@synthesize viUserLocationLatitude = _viUserLocationLatitude;

@synthesize mapView = _mapView;
@synthesize webmap = _webmap;
@synthesize featureLayer = _featureLayer;
@synthesize locationManager = _locationManager;
@synthesize sketchLayer = _sketchLayer;
@synthesize addNewFeatureToMap = _addNewFeatureToMap;

@synthesize featureTemplatePickerViewController = _featureTemplatePickerViewController;
@synthesize tutorialViewController = _tutorialViewController;
@synthesize popupViewController = _popupViewController;

@synthesize activityIndicator = _activityIndicator;
@synthesize popupVC = _popupVC;
@synthesize popupHelper = _popupHelper;

@synthesize manualFeatureGeometry;
@synthesize featureGeometryDelegate;

-(void)viewWillAppear:(BOOL)animated{
}

-(void)viewDidLoad {
    	
    
    /**
     * This allows us to see what is being fired and when
     */
    NSLog(@"WaterReporterViewController: viewDidLoad");
    
    if (self.webmap) {
        NSLog(@"self.webmap already loaded: %@", self.webmap.URL);
    }

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
     * If we are loading the View Controller from the Feature Details then
     * we shouldn't load the Feature Template Picker, the Feature Template
     * Picker Buton, and reload the geolocation tools.
     */
    if (self.loadingFromFeatureDetails == NO) {

        /**
         * Set the delegates so that they can do the job they are here for
         */
        self.mapView.touchDelegate = self;
        self.mapView.calloutDelegate = self;
        self.mapView.callout.delegate = self;
        self.mapView.layerDelegate = self;

        /**
         * Initialize the feature template picker so that we can show it later when needed
         */
        self.featureTemplatePickerViewController =  [[[FeatureTemplatePickerViewController alloc] initWithNibName:@"FeatureTemplatePickerViewController" bundle:nil] autorelease];
        self.featureTemplatePickerViewController.delegate = self;

    }
    
    /**
     * Prepare the Popup Helper for later use
     */
    self.popupHelper = [[PopupHelper alloc] init];
    self.popupHelper.delegate = self;

    /**
     * Locate the user via their GPS cooridnates
     */
    [self displayUsersGeolocation];
    

    /**
     * Initialize the tutorial so that we can show it later when needed
     */
    self.tutorialViewController =  [[[TutorialViewController alloc] initWithNibName:@"TutorialViewController" bundle:nil] autorelease];
    
    /**
     * If this is the first time the user is using the application we need
     * to show them the tutorial.
     */
    if (TUTORIAL_IS_ACTIVE) {
        [self.navigationController pushViewController:self.tutorialViewController animated:YES];
    }
    
    /**
     * Set our default map navigation bar background to use our
     * charcoal pattern
     */
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"toolbar-charcoal-default.png"] forBarMetrics:UIBarMetricsDefault];
    
    [super viewDidLoad];
}
 
- (void) webMap:(AGSWebMap *)webMap didLoadLayer:(AGSLayer *)layer {

    /**
     * This allows us to see what is being fired and when
     */
    NSLog(@"WaterReporterViewController: webMap: didLoadLayer");

    //The last feature layer we encounter we will use for editing features
    //If the web map contains more than one feature layer, the sample may need to be modified to handle that
    if([layer isKindOfClass:[AGSFeatureLayer class]]){
        AGSFeatureLayer* featureLayer = (AGSFeatureLayer*)layer;
        
        //set the feature layer as its infoTemplateDelegate
        //this will then automatically set the callout's title to a value
        //from the display field of the feature service
        featureLayer.infoTemplateDelegate = featureLayer;

        //Get all the fields
        featureLayer.outFields = [NSArray arrayWithObject:@"*"];
        
        //This view controller should be notified when features are edited
        featureLayer.editingDelegate = self;
        
        //Add templates from this layer to the Feature Template Picker
        [self.featureTemplatePickerViewController addTemplatesFromLayer:featureLayer];
    }
}

- (void) didOpenWebMap:(AGSWebMap *)webMap intoMapView:(AGSMapView *)mapView {
    
    /**
     * This allows us to see what is being fired and when
     */
    NSLog(@"WaterReporterViewController: webMap: intoMapView");

    /**
     * This is the "Commit" button when you're adding a new feature to the map
     */
    UIBarButtonItem *addReportButton = [[[UIBarButtonItem alloc]initWithTitle:@"Add Report" style:UIBarButtonItemStylePlain target:self action:@selector(presentFeatureTemplatePicker)]autorelease];
    self.navigationItem.rightBarButtonItem = addReportButton;

    
    /**
     * Load the Feature template picker, now that all of the webmap information has loaded successfully
     */
    if (self.loadingFromFeatureDetails == YES) {
        [self displaySketchLayer];
        self.addNewFeatureToMap.enabled = NO;
    } else {
        self.addNewFeatureToMap.enabled = YES;
    }
}

- (void) webMap:(AGSWebMap *)webMap didFailToLoadLayer:(AGSWebMapLayerInfo *)layerInfo baseLayer:(BOOL)baseLayer federated:(BOOL)federated withError:(NSError *)error {
    
    NSLog(@"Failed to load layer : %@", layerInfo.title);
    
    //continue anyway
    [self.webmap continueOpenAndSkipCurrentLayer];
}

- (BOOL)mapView:(AGSMapView *)mapView shouldShowCalloutForGraphic:(AGSGraphic *)graphic {
    
    /**
     * This allows us to see what is being fired and when
     */
    NSLog(@"WaterReporterViewController: mapView: shouldShowCalloutForGraphic");
    
    return !self.loadingFromFeatureDetails;
    //return NO;
}

- (void)mapView:(AGSMapView *)mapView didClickAtPoint:(CGPoint)screen mapPoint:(AGSPoint *)mappoint graphics:(NSDictionary *)graphics {
    
    //cancel any outstanding requests
    [self.popupHelper cancelOutstandingRequests];
    
    [self.popupHelper findPopupsForMapView:mapView withGraphics:graphics atPoint:mappoint andWebMap:self.webmap withQueryableLayers:nil ];
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
    
//    /**
//     * Prepares the selected feature to be displayed
//     * in a popup container
//     */
//    AGSGraphic* graphic = (AGSGraphic*) callout.representedObject;
//    self.popupViewController = [[PopupViewController alloc] initWithExistingFeature:graphic];
    //[self.navigationController pushViewController:self.popupViewController animated:YES];
    
	/**
     * Display the details for the active or clicked on feature.
     */
    [self.navigationController pushViewController:self.popupVC animated:YES];
}

- (NSString *)detailForGraphic:(AGSGraphic *)graphic screenPoint:(CGPoint)screen mapPoint:(AGSPoint *)map{
    
    /**
     * This allows us to see what is being fired and when
     */
    NSLog(@"WaterReporterViewController: detailForGraphic");
    
	// get the center point of the geometry
    AGSPoint *centerPoint = graphic.geometry.envelope.center;
    return [NSString stringWithFormat:@"x = %0.2f, y = %0.2f",centerPoint.x,centerPoint.y];
}

/**
 * Display sketch layer for the user to manually
 * update their report geolocation.
 */
-(void)displaySketchLayer {
    
    /**
     * This allows us to see what is being fired and when
     */
    NSLog(@"WaterReporterViewController: displaySketchLayer");
    
    /**
     * Load sketch layer capabilities to the map, make sure we start
     * with the geometry detected by the user, and then ensure that
     * we map the sketchLayer the touchDelegate which allows users
     * to tap the map to update their location.
     */
    self.sketchLayer = [[AGSSketchGraphicsLayer alloc] init];
    [self.mapView addMapLayer:self.sketchLayer withName:@"Sketch Layer"];
    self.mapView.touchDelegate = self.sketchLayer;
    self.sketchLayer.geometry = [[AGSMutablePoint alloc] initWithX:NAN y:NAN spatialReference:_mapView.spatialReference];
    
    /**
     * This is the "Commit" button when you're adding a new feature to the map
     */
    UIBarButtonItem *commit = [[[UIBarButtonItem alloc]initWithTitle:@"Update" style:UIBarButtonItemStylePlain target:self action:@selector(commit)]autorelease];
    self.navigationItem.rightBarButtonItem = commit;

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(respondToGeomChanged:) name:AGSSketchGraphicsLayerGeometryDidChangeNotification object:nil];
}

/**
 * Notifies the system of when the geometry has been
 * updated via the sketch layer.
 */
- (void)respondToGeomChanged: (NSNotification*) notification {
    
    /**
     * This allows us to see what is being fired and when
     */
    NSLog(@"WaterReporterViewController: respondToGeomChanged");
    

    if([self.sketchLayer.geometry isValid] && ![self.sketchLayer.geometry isEmpty]) {
        AGSGeometry *updatedSketchGeometry = (AGSEnvelope*)AGSGeometryWebMercatorToGeographic(self.sketchLayer.geometry);
        
        self.manualFeatureGeometry = updatedSketchGeometry;
        NSLog(@"[Sketch Layer] Updated manualFeatureGeometry: %@", self.manualFeatureGeometry);        
    }
}

-(void)commit {
    NSLog(@"[Saving] Updated manualFeatureGeometry: %@", self.manualFeatureGeometry);
    
    [self.featureGeometryDelegate sketchLayerUserEditingDidFinish:self.manualFeatureGeometry];

    [self.navigationController popViewControllerAnimated:YES];
}

/**
 * Display users geolocation on map
 *
 */
-(void)displayUsersGeolocation {

    /**
     * This allows us to see what is being fired and when
     */
    NSLog(@"WaterReporterViewController:displayUsersGeolocation");
    
    
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
        self.mapView.locationDisplay.zoomScale = FEATURE_SERVICE_ZOOM;
        self.mapView.locationDisplay.autoPanMode = AGSLocationDisplayAutoPanModeDefault;
        [self.mapView.locationDisplay startDataSource];
    }
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
    NSLog(@"WaterReporterViewController: presentFeatureTemplatePicker");
    
    
    // iPAD ONLY: Limit the size of the form sheet
    if([[AGSDevice currentDevice] isIPad]) {
        self.featureTemplatePickerViewController.modalPresentationStyle = UIModalPresentationFormSheet;
    }
    
    // ALL: Animate the template picker, covering vertically
    self.featureTemplatePickerViewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    
    // Display the modal ... see FeatureTemplatePickerViewController.xib for layout
    [self.navigationController pushViewController:self.featureTemplatePickerViewController animated:YES];
}

-(void)featureTemplatePickerViewControllerWasDismissed: (FeatureTemplatePickerViewController*) featureTemplatePickerViewController{
    
    /**
     * This allows us to see what is being fired and when
     */
    NSLog(@"WaterReporterViewController: featureTemplatePickerViewControllerWasDismissed");
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)featureTemplatePickerViewController:(FeatureTemplatePickerViewController*) featureTemplatePickerViewController didSelectFeatureTemplate:(AGSFeatureTemplate*)template forFeatureLayer:(AGSFeatureLayer*)featureLayer {
    
    /**
     * This allows us to see what is being fired and when
     */
    NSLog(@"WaterReporterViewController: featureTemplatePickerViewController");   
   
    //
    // Set the active feature layer to the one we are going to edit
    //
    self.featureLayer = featureLayer;

    //create a new feature based on the template
    _newFeature = [self.featureLayer featureWithTemplate:template];
    
    //Add the new feature to the feature layer's graphic collection
    //This is important because then the popup view controller will be able to
    //find the feature layer associated with the graphic and inspect the field metadata
    //such as domains, subtypes, data type, length, etc
    //Also note, if the user cancels before saving the new feature to the server,
    //we will manually need to remove this
    //feature from the feature layer (see implementation for popupsContainer:didCancelEditingGraphicForPopup: below)
    [self.featureLayer addGraphic:_newFeature];

    //First, dismiss the Feature Template Picker
    [self dismissViewControllerAnimated:NO completion:nil];

    AGSGeometryEngine *ge = [AGSGeometryEngine defaultGeometryEngine];
    AGSGeometry *geometry = [ge projectGeometry:self.userLocation toSpatialReference:self.userLocation.spatialReference];
    
    //now create the feature details vc and display it
    FeatureDetailsViewController *detailViewController = [[[FeatureDetailsViewController alloc]initWithFeatureLayer:self.featureLayer feature:nil featureGeometry:geometry templatePrototype:template.prototype] autorelease];
    
    detailViewController.userLocation = self.userLocation;
    
    NSLog(@"userLocation: %@", userLocation);
    detailViewController.viUserLocationLatitude = self.viUserLocationLatitude;

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
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    
    /**
     * This allows us to see what is being fired and when
     */
    NSLog(@"WaterReporterViewController:locationManager:didFailWithError");
    
    // The location "unknown" error simply means the manager is currently unable to get the location.
    if ([error code] != kCLErrorLocationUnknown) {
        [self stopUpdatingLocation];
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

#pragma mark - PopupHelperDelegate methods
- (void)foundPopups:(NSArray*) popups atMapPonit:(AGSPoint*)mapPoint withMoreToFollow:(BOOL)more {
    
    //Release the last popups vc
    self.popupVC = nil;
    
    // If we've found one or more popups
    if (popups.count > 0) {
        //Create a popupsContainer view controller with the popups
        self.popupVC = [[AGSPopupsContainerViewController alloc] initWithPopups:popups usingNavigationControllerStack:true];
        self.popupVC.style = AGSPopupsContainerStyleBlack;
        self.popupVC.delegate = self;
        
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
    if ([[AGSDevice currentDevice] isIPad])
        self.mapView.callout.hidden = YES;
    else
        //dismiss the modal viewcontroller for iPhone
        [self.popupVC dismissModalViewControllerAnimated:YES];
    
}

- (void) popupsContainer:		(id< AGSPopupsContainer >) 	popupsContainer
didStartEditingGraphicForPopup:		(AGSPopup *) 	popup {
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Not Implemented"
                                                 message:@"This sample only demonstrates how to display popups. It does not allow you to edit or delete features. Please refer to the Feature Layer Editing Sample instead."
                                                delegate:self
                                       cancelButtonTitle:@"OK"
                                       otherButtonTitles:nil];
    
    [av show];
}

- (void) popupsContainer:		(id< AGSPopupsContainer >) 	popupsContainer
wantsToDeleteGraphicForPopup:		(AGSPopup *) 	popup {
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Not Implemented"
                                                 message:@"This sample only demonstrates how to display popups. It does not allow you to edit or delete features. Please refer to the Feature Layer Editing Sample instead."
                                                delegate:self
                                       cancelButtonTitle:@"OK"
                                       otherButtonTitles:nil];
    
    [av show];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
    /**
     * This allows us to see what is being fired and when
     */
    NSLog(@"WaterReporterViewController:viewDidUnload");
    
    [self.mapView release];
    [self.webmap release];
    [self.featureLayer release];
    [self.locationManager release];
    [self.featureTemplatePickerViewController release];
    [self.tutorialViewController release];
    [self.sketchLayer release];
    [self.manualFeatureGeometry release];
    [self.activityIndicator release];
    [self.popupVC release];
    [self.popupHelper release];

    [super viewDidUnload];
}

- (void)dealloc {
    
    /**
     * This allows us to see what is being fired and when
     */
    NSLog(@"WaterReporterViewController:dealloc");
    
    [self.mapView release];
    [self.webmap release];
    [self.featureLayer release];
    [self.locationManager release];
    [self.featureTemplatePickerViewController release];
    [self.tutorialViewController release];
    [self.sketchLayer release];
    [self.manualFeatureGeometry release];
    [self.activityIndicator release];
    [self.popupVC release];
    [self.popupHelper release];

    [super dealloc];
}

@end
