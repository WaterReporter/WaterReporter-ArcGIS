/**
 * Water Reporter
 *
 * Created by Viable Industries L.L.C. in March 2013.
 * Copyright (c) 2013 Viable Industries L.L.C. All rights reserved.
 *
 */

#import <QuartzCore/QuartzCore.h>
#import "WaterReporterViewController.h"
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
#define FEATURE_SERVICE_ZOOM 150000

@implementation WaterReporterViewController

@synthesize userLocation;
@synthesize loadingFromFeatureDetails = _loadingFromFeatureDetails;
@synthesize viUserLocationLongitude = _viUserLocationLongitude;
@synthesize viUserLocationLatitude = _viUserLocationLatitude;

@synthesize tutorialView = _tutorialView;
@synthesize pageControl = _pageControl;

@synthesize mapView = _mapView;
@synthesize webmap = _webmap;
@synthesize curatedMap = _curatedMap;
@synthesize featureLayer = _featureLayer;
@synthesize cachedFeatureLayers = _cachedFeatureLayers;
@synthesize locationManager = _locationManager;
@synthesize sketchLayer = _sketchLayer;
@synthesize addNewFeatureToMap = _addNewFeatureToMap;

@synthesize featureTemplatePickerViewController = _featureTemplatePickerViewController;
@synthesize curatedMapViewController = _curatedMapViewController;

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

    self.cachedFeatureLayers = [NSMutableArray new];

    /**
     * Setup the Web Map
     *
     * We are loading the appropriate web map, based on the Web Map ID defined
     * in the FEATURE_SERVICE_URL constant at the top of this document.
     *
     */
    self.webmap = [AGSWebMap webMapWithItemId:FEATURE_SERVICE_URL credential:nil];
    //self.curatedMap = [AGSWebMap webMapWithItemId:CURATED_MAP_URL credential:nil];
    
    /**
     * Designate a delegate to be notified as web map is opened
     */
    self.webmap.delegate = self;
    
    //self.curatedMap.delegate = self;
    [self.webmap openIntoMapView:self.mapView];
    
    /**
     * Change the appearance of all the buttons
     * that appear within our UI
     */
    UIImage *buttonDefaultImage = [UIImage imageNamed:@"buttonDefaultBackground"];
    UIImage *buttonDefaultImageHighlight = [UIImage imageNamed:@"buttonDefaultHighlightBackground"];
    [[UIBarButtonItem appearance] setBackgroundImage:buttonDefaultImage forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [[UIBarButtonItem appearance] setBackgroundImage:buttonDefaultImageHighlight forState:UIControlStateHighlighted barMetrics:UIBarMetricsDefault];
    
    UIImage *buttonBackImage = [UIImage imageNamed:@"buttonBackButtonBackground"];
    UIImage *buttonBackImageHighlight = [UIImage imageNamed:@"buttonBackButtonHighlightedBackground"];
    [[UIBarButtonItem appearance] setBackButtonBackgroundImage:buttonBackImage forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [[UIBarButtonItem appearance] setBackButtonBackgroundImage:buttonBackImageHighlight forState:UIControlStateHighlighted barMetrics:UIBarMetricsDefault];
    
    /**
     * Set our default map navigation bar background to use our
     * charcoal pattern
     */
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"toolbar-charcoal-default.png"] forBarMetrics:UIBarMetricsDefault];
    self.curatedMapViewController =  [[[CuratedMapViewController alloc] initWithNibName:@"CuratedMapViewController" bundle:nil] autorelease];
    [self setupScrollView];

    UIImageView *image = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    image.image = [UIImage imageNamed:[NSString stringWithFormat:@"backgroundTutorial"]];
    image.contentMode = UIViewContentModeScaleAspectFit;
    [self.mapView addSubview:image];
    [self.mapView bringSubviewToFront:image];
    
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
        
    } else {
        [self.mapView sendSubviewToBack:image];
    }
    
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
        [self.cachedFeatureLayers addObject:featureLayer];
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
    UIBarButtonItem* addReportButton = [[[UIBarButtonItem alloc]initWithTitle:@"Add Report" style:UIBarButtonItemStyleBordered target:self action:@selector(presentFeatureTemplatePicker)]autorelease];
    self.navigationItem.rightBarButtonItem = addReportButton;

    /**
     * This is the "Commit" button when you're adding a new feature to the map
     */
    UIBarButtonItem *displayCuratedMap = [[[UIBarButtonItem alloc]initWithTitle:@"Map" style:UIBarButtonItemStylePlain target:self action:@selector(presentCuratedMap)]autorelease];
    self.navigationItem.leftBarButtonItem = displayCuratedMap;

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
    //[self.curatedMap continueOpenAndSkipCurrentLayer];
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
    
    //[self displayGeoLocation];
    
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

/**
 * Display users geolocation on map
 *
 */
-(void) displayGeoLocation {
    
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

-(void) setupScrollView {
    
    NSLog(@"setupScrollView");
    
    //add the scrollview to the view
    self.tutorialView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, -45, self.view.frame.size.width, (self.view.frame.size.height - 145))];
    self.tutorialView.contentSize = CGSizeMake(self.tutorialView.contentSize.width,self.tutorialView.frame.size.height);
    self.tutorialView.pagingEnabled = YES;
    self.tutorialView.delegate = self;
    [self.tutorialView setAlwaysBounceVertical:NO];
    
    //setup internal views
    NSInteger numberOfViews = 6;
    for (int i = 0; i < numberOfViews; i++) {
        CGFloat xOrigin = i * self.view.frame.size.width;
        UIImageView *image = [[UIImageView alloc] initWithFrame:CGRectMake(xOrigin, 0, self.view.frame.size.width, self.view.frame.size.height)];
        image.image = [UIImage imageNamed:[NSString stringWithFormat:@"slide_%d", i+1]];
        image.contentMode = UIViewContentModeScaleAspectFit;
        [self.tutorialView addSubview:image];
    }
    //set the scroll view content size
    self.tutorialView.contentSize = CGSizeMake(self.view.frame.size.width * numberOfViews, self.view.frame.size.height);
    [self.tutorialView setShowsHorizontalScrollIndicator:NO];
    [self.tutorialView setShowsVerticalScrollIndicator:NO];
    
    //add the scrollview to this view
    [self.view addSubview:self.tutorialView];
    
    [self.view insertSubview:self.tutorialView belowSubview:self.pageControl];
    
    self.pageControl = [[[UIPageControl alloc] init] autorelease];
    self.pageControl.frame = CGRectMake(((self.view.frame.size.width-100)/2),(self.view.frame.size.height-185),100,50);
    self.pageControl.numberOfPages = 6;
    self.pageControl.currentPage = 0;
    
    [self.view addSubview:self.pageControl];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat pageWidth = self.tutorialView.frame.size.width;
    float fractionalPage = self.tutorialView.contentOffset.x / pageWidth;
    NSInteger page = lround(fractionalPage);
    self.pageControl.currentPage = page;
}


/**
 * Add a new feature
 *
 * The action for the "+" button that allows
 * the user to select what kind of Feature
 * they would like to add to the map
 *
 */
-(void)presentCuratedMap {
    
    /**
     * This allows us to see what is being fired and when
     */
    NSLog(@"TutorialViewController:presentCuratedMap");
    
    self.curatedMapViewController.isSomethingEnabled = self.cachedFeatureLayers;
    
    // Display the modal ... see FeatureTemplatePickerViewController.xib for layout
    [self.navigationController pushViewController:self.curatedMapViewController animated:NO];
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
    [self.tutorialView release];
    [self.pageControl release];
    [self.curatedMap release];
    [self.featureLayer release];
    [self.locationManager release];
    [self.featureTemplatePickerViewController release];
    //[self.tutorialViewController release];
    [self.sketchLayer release];
    [self.manualFeatureGeometry release];

    [super viewDidUnload];
}

- (void)dealloc {
    
    /**
     * This allows us to see what is being fired and when
     */
    NSLog(@"WaterReporterViewController:dealloc");
    
    [self.webmap release];
    [self.curatedMap release];
    [self.featureLayer release];
    [self.locationManager release];
    [self.featureTemplatePickerViewController release];
    //[self.tutorialViewController release];
    [self.sketchLayer release];
    [self.manualFeatureGeometry release];

    [super dealloc];
}

@end
