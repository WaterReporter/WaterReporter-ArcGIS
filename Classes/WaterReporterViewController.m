/**
 * Water Reporter
 *
 * Created by Viable Industries L.L.C. in March 2013.
 * Copyright (c) 2013 Viable Industries L.L.C. All rights reserved.
 *
 */

#import "WaterReporterViewController.h"
#import "WaterReporterFeatureLayer.h"
#import "FeatureDetailsViewController.h"

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
#define FEATURE_SERVICE_ZOOM 150000

NSInteger viFeatureAddButtonX = 264.0;
NSInteger viFeatureAddButtonY = 404.0;
NSString *viFeatureAddButtonURL = @"buttonNewFeature.png";
NSInteger viDefaultUserLocationZoomLevel = 150000;

@implementation WaterReporterViewController

@synthesize userLocation;

@synthesize loadingFromFeatureDetails = _loadingFromFeatureDetails;
@synthesize viUserLocationLongitude = _viUserLocationLongitude;
@synthesize viUserLocationLatitude = _viUserLocationLatitude;

@synthesize mapView = _mapView;
@synthesize webmap = _webmap;
@synthesize featureLayer = _featureLayer;
@synthesize locationManager = _locationManager;
@synthesize featureTemplatePickerViewController = _featureTemplatePickerViewController;
@synthesize tutorialViewController = _tutorialViewController;
@synthesize sketchLayer = _sketchLayer;

-(void)viewWillAppear:(BOOL)animated{
}

-(void)viewDidLoad {
    	
    
    /**
     * This allows us to see what is being fired and when
     */
    NSLog(@"WaterReporterViewController: viewDidLoad");

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

        /**
         * Add a button to the Map View so that users can add a new
         * feature from the template picker at any time.
         */
        [self presentFeatureTemplatePickerButton];
    }
    
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
    if (TUTORIAL_IS_ACTIVE && ![[NSUserDefaults standardUserDefaults] boolForKey:@"hasSeenTutorial"]) {
        NSLog(@"This is the first time the user is using the application.");
        
        //
        // When the tutorial closes we will then need to set the BOOL to TRUE
        // so that this check is skipped in all future application launches
        //
        // We set it by calling the following:
        //
        // [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"hasSeenTutorial"];
        //
        [self presentViewController:self.tutorialViewController animated:NO completion:nil];
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
     * Load the Feature template picker, now that all of the webmap information has loaded successfully
     */
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"hasSeenTutorial"] && self.loadingFromFeatureDetails == NO) {
        [self.navigationController pushViewController:self.featureTemplatePickerViewController animated:YES];
    } else {
        [self displaySketchLayer];
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
    
    //    return self.mapView.touchDelegate != self.sketchLayer;
    return nil;
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
    
    AGSGraphic* graphic = (AGSGraphic*) callout.representedObject;

	/**
     * Prepares the selected features details for display
     */
    FeatureDetailsViewController *detailViewController = [[[FeatureDetailsViewController alloc] initWithFeatureLayer:self.featureLayer feature:graphic featureGeometry:graphic.geometry templatePrototype:nil] autorelease];

    detailViewController.viUserLocationLongitude = self.viUserLocationLongitude;
    detailViewController.viUserLocationLatitude = self.viUserLocationLatitude;
    
	/**
     * Display the details for the active or clicked on feature.
     */
    [self.navigationController pushViewController:detailViewController animated:YES];
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
        NSLog(@"[Sketch Layer] Updated: %@", self.sketchLayer.geometry);
    } else {
        NSLog(@"[Sketch Layer] Error: Something went wrong and we couldn't save your geometry;");
    }
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
        [self.mapView.locationDisplay startDataSource];
        self.mapView.locationDisplay.zoomScale = viDefaultUserLocationZoomLevel;
        self.mapView.locationDisplay.autoPanMode = AGSLocationDisplayAutoPanModeDefault;
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

-(void)presentFeatureTemplatePickerButton {
    
    /**
     * This allows us to see what is being fired and when
     */
    NSLog(@"WaterReporterViewController:presentFeatureTemplatePickerButton");
    
    /**
     * Plus/Add Button on main map view.
     *
     * We want the image to display in the bottom left of the screen regardless
     * of the users device (e.g., iPhone, iPhone 4" Retina, iPad, iPad Retina. So
     * we need to update the X, Y, and the image being used depending on what the
     * user is viewing the application on.
     *
     */
    UIImage *addNewFeatureImage = [UIImage imageNamed:viFeatureAddButtonURL];
    UIButton *addNewFeatureToMap = [UIButton buttonWithType:UIButtonTypeCustom];
    addNewFeatureToMap.frame = CGRectMake(viFeatureAddButtonX, viFeatureAddButtonY, 36.0, 36.0);
    
    addNewFeatureToMap.userInteractionEnabled = YES;
    addNewFeatureToMap.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin;
    [addNewFeatureToMap setImage:addNewFeatureImage forState:UIControlStateNormal];
    [addNewFeatureToMap addTarget:self action:@selector(presentFeatureTemplatePicker) forControlEvents:UIControlEventTouchUpInside];
    
    [self.mapView addSubview:addNewFeatureToMap];
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
 * Stop updating the Location Manager and remove the delegate
 */
- (void)stopUpdatingLocation {
    
    /**
     * This allows us to see what is being fired and when
     */
    NSLog(@"WaterReporterViewController:stopUpdatingLocation");
     
    [self.locationManager stopUpdatingLocation];
    [self.locationManager release];
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

    [super dealloc];
}

@end
