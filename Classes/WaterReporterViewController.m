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

#import "WaterReporterViewController.h"
#import "WaterReporterFeatureLayer.h"
#import "FeatureDetailsViewController.h"
#import "CodedValueUtility.h"

#define kFeatureLayerName @"Feature Layer"
#define kSketchLayerName  @"Sketch layer"

/**
 * Define the Web Map ID that we wish to load
 */
//#define FEATURE_SERVICE_URL @"70f0fef3990a462397fcd4b9409c09cb"
#define FEATURE_SERVICE_URL @"7f587e3a53dc455f92972a15031c94f8"

/**
 * Define whether the Feature Template Picker should display
 * automatically when the 
 */
#define FEATURE_TEMPLATE_AUTODISPLAY YES
#define TUTORIAL_IS_ACTIVE YES
#define FEATURE_SERVICE_ZOOM 150000

double viUserLocationLongitude;
double viUserLocationLatitude;
NSInteger viFeatureAddButtonX = 264.0;
NSInteger viFeatureAddButtonY = 404.0;
NSString *viFeatureAddButtonURL = @"buttonNewFeature.png";
NSInteger viDefaultUserLocationZoomLevel = 150000;



@implementation WaterReporterViewController

@synthesize mapView = _mapView;
@synthesize featureLayer = _featureLayer;
@synthesize webmap = _webmap;
@synthesize featureTemplatePickerViewController = _featureTemplatePickerViewController;
@synthesize tutorialViewController = _tutorialViewController;
@synthesize locationManager = _locationManager;
@synthesize sketchLayer = _sketchLayer;


/**
 * Begin using the users geographic location
 *
 * Make these variables accessible throughout
 * entire application. Especially when editing
 * feature layers.
 *
 */
+ (double)viUserLocationLongitude {
    return viUserLocationLongitude;
}

+ (double)viUserLocationLatitude {
    return viUserLocationLatitude;
}

+ (int)viFeatureAddButtonX {
    return viFeatureAddButtonX;
}

+ (int)viFeatureAddButtonY {
    return viFeatureAddButtonY;
}

- (void)respondToGeomChanged: (NSNotification*) notification {
        
    /**
     * This allows us to see what is being fired and when
     */
    NSLog(@"WaterReporterViewController: respondToGeomChanged");
    
    /**
     * Update the interface and associated fields if the
     * user selected geometry is valid.
     */
    if([self.sketchLayer.geometry isValid] && ![self.sketchLayer.geometry isEmpty]) {
        
        // Display the "Done" button
        //self.sketchCompleteButton.enabled = YES;
        
        /***
         ** TODO: FOR NOW WE ONLY NEED POINTS, BUT IN THE FUTURE
         ** WE ARE GOING TO NEED TO ADD SUPPORT FOR POLYGONS AND
         ** LINES WITHIN OUR GEOMETRY TOOLS.
         ***/
        AGSPoint *currentSketchValue = (AGSPoint*)AGSGeometryWebMercatorToGeographic(self.sketchLayer.geometry);
        
        viUserLocationLongitude = currentSketchValue.x;
        viUserLocationLatitude = currentSketchValue.y;
        
        NSLog(@"long_push: %f; lat_push: %f;", viUserLocationLongitude, viUserLocationLatitude);

        /***
         ** WE NEED SOME TYPE OF LISTENER HERE TO UPDATE
         ** THE FIELDS FOR US PROGRAMATICALLY. WE NEED TO
         ** INSERT THE NEW GEOMETRY INTO THE APPROPRIATE
         ** FIELDS OF THE FEATURE LAYER FORM.
         **
         ** self.sketchLayer.geometry
         **
         ***/
        
        /***
         ** WE ALSO NEED TO FIGURE OUT WHETHER THE POINT
         ** IS CONTAINED WITHIN THE POLYGON OF ONE OF THE
         ** WATERSHEDS THAT IS DISPLAYED ON OUR MAP.
         **
         ** http://resources.arcgis.com/en/help/runtime-ios-sdk/apiref/interface_a_g_s_envelope.html#ad7fdaa3ec058a14c2b9c3af92585086e
         **
         ***/
        
        //
        // Iterate through all of the selected Feature Layer's
        // fields and perform the necessary pre-display actions
        // upon each field one at a time.
        //
        // These operations primarily concern the prepopulation
        // of specific fields such as the date and geolocation.
        // While others like the Attachments and associated image
        // fields depend on user interaction later in the process
        // to be updated dynamically.
        //
        
    }
    
    NSLog(@"long_push: %f; lat_push: %f;", viUserLocationLongitude, viUserLocationLatitude);

}

#pragma mark UIView methods

-(void)viewWillAppear:(BOOL)animated{
}

- (void)viewDidLoad {
    
    /**
     * Plus/Add Button on main map view.
     *
     * We want the image to display in the bottom left of the screen regardless
     * of the users device (e.g., iPhone, iPhone 4" Retina, iPad, iPad Retina. So
     * we need to update the X, Y, and the image being used depending on what the
     * user is viewing the application on.
     
     */   
    UIImage *addNewFeatureImage = [UIImage imageNamed:viFeatureAddButtonURL];
    UIButton *addNewFeatureToMap = [UIButton buttonWithType:UIButtonTypeCustom];
    addNewFeatureToMap.frame = CGRectMake(viFeatureAddButtonX, viFeatureAddButtonY, 36.0, 36.0);
    
    addNewFeatureToMap.userInteractionEnabled = YES;
    addNewFeatureToMap.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin;
    [addNewFeatureToMap setImage:addNewFeatureImage forState:UIControlStateNormal];
    [addNewFeatureToMap addTarget:self action:@selector(presentFeatureTemplatePicker) forControlEvents:UIControlEventTouchUpInside];

    /**
     * Set the delegates so that they can do the job they are here for
     */
    self.mapView.touchDelegate = self;
	self.mapView.calloutDelegate = self;
    self.mapView.callout.delegate = self;
    self.mapView.showMagnifierOnTapAndHold = YES;
	self.mapView.layerDelegate = self;
	
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
     * Initialize the feature template picker so that we can show it later when needed
     */
    self.featureTemplatePickerViewController =  [[FeatureTemplatePickerViewController alloc] initWithNibName:@"FeatureTemplatePickerViewController" bundle:nil];
    self.featureTemplatePickerViewController.delegate = self;
    
    /**
     * Initialize the tutorial so that we can show it later when needed
     */
    self.tutorialViewController =  [[TutorialViewController alloc] initWithNibName:@"TutorialViewController" bundle:nil];
    
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
    
    [self.mapView addSubview:addNewFeatureToMap];

    [super viewDidLoad];
}


#pragma mark - AGSWebMapDelegate methods
 
- (void) webMap:(AGSWebMap *)webMap didLoadLayer:(AGSLayer *)layer {
    
    /**
     * This allows us to see what is being fired and when
     */
    NSLog(@"WaterReporterViewController: webMap:didLoadLayer");
    
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
     * Once all the layers in the web map are loaded
     * we will add a dormant sketch layer on top. We
     * will activate the sketch layer when the time is right.
     */
    self.sketchLayer = [[AGSSketchGraphicsLayer alloc] init];
    [self.mapView addMapLayer:self.sketchLayer withName:@"Sketch Layer"];
    
    
    /**
     * Register Notification for receiving notifications
     * from the sketch layer
     *
     * - @addObserver self
     * - @selector respondToGeomChanged
     */
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(respondToGeomChanged:) name:AGSSketchGraphicsLayerGeometryDidChangeNotification object:nil];
    
    

    /**
     * Load the Feature template picker, now that all of the webmap information has loaded successfully
     */
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"hasSeenTutorial"]) {        
        [self.navigationController pushViewController:self.featureTemplatePickerViewController animated:YES];
    }
    
    
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

- (void) webMap:(AGSWebMap *)webMap didFailToLoadLayer:(AGSWebMapLayerInfo *)layerInfo baseLayer:(BOOL)baseLayer federated:(BOOL)federated withError:(NSError *)error {
    
    NSLog(@"Failed to load layer : %@", layerInfo.title);
    
    //continue anyway
    [self.webmap continueOpenAndSkipCurrentLayer];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
}

- (BOOL)mapView:(AGSMapView *)mapView shouldShowCalloutForGraphic:(AGSGraphic *)graphic {
    
    /**
     * This allows us to see what is being fired and when
     */
    NSLog(@"WaterReporterViewController:mapView:shouldShowCalloutForGraphic [We aren't in editing mode, so therefore this should be a read only Feature Detail window]");
    
    //only show callout if we're not editing
    return !_editingMode;
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
    NSLog(@"didClickAccessoryButtonForCallout");

    AGSGraphic* graphic = (AGSGraphic*) callout.representedObject;

	/**
     * Prepares the selected features details for display
     */
    FeatureDetailsViewController *detailViewController = [[[FeatureDetailsViewController alloc] initWithFeatureLayer:self.featureLayer feature:graphic featureGeometry:graphic.geometry] autorelease];

	/**
     * Display the details for the active or clicked on feature.
     */
    [self.navigationController pushViewController:detailViewController animated:YES];
}

- (NSString *)titleForGraphic:(AGSGraphic *)graphic screenPoint:(CGPoint)screen mapPoint:(AGSPoint *) map{
    
    /**
     * This allows us to see what is being fired and when
     */
    NSLog(@"WaterReporterViewController: titleForGraphic");
    

	NSString *val = [CodedValueUtility getCodedValueFromFeature:graphic forField:@"trailtype" inFeatureLayer:self.featureLayer];
	
	if ((NSNull*)val == [NSNull null]){
		return nil;
	}
	
	return val;
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

#pragma mark -
#pragma mark Editing

-(void)commitGeometry:(id)sender {
    
    /**
     * This allows us to see what is being fired and when
     */
    NSLog(@"WaterReporterViewController: commitGeometry");
    
    //get sketchLayer from the mapView
    AGSSketchGraphicsLayer *sketchLayer = (AGSSketchGraphicsLayer *)[self.mapView mapLayerForName:kSketchLayerName];
        
    //get the sketch layer geometry
    AGSGeometry *geometry = sketchLayer.geometry;
    
    //now create the feature details vc and display it
    FeatureDetailsViewController *detailViewController = [[[FeatureDetailsViewController alloc]initWithFeatureLayer:self.featureLayer feature:nil featureGeometry:geometry] autorelease];
    
	/**
     * Prepares the details for the new feature.
     */
    [self.navigationController pushViewController:detailViewController animated:YES];
}

/**
 * Add a new feature
 *
 * The action for the "+" button that allows
 * the user to select what kind of Feature
 * they would like to add to the map
 *
 */
-(void)presentFeatureTemplatePicker{
    
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
    //[self presentViewController:self.featureTemplatePickerViewController animated:YES completion:nil];
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
    
    //get sketchLayer from the mapView
    AGSSketchGraphicsLayer *sketchLayer = (AGSSketchGraphicsLayer *)[self.mapView mapLayerForName:kSketchLayerName];
    
    //get the sketch layer geometry
    AGSGeometry *geometry = sketchLayer.geometry;
    
    //now create the feature details vc and display it
    FeatureDetailsViewController *detailViewController = [[[FeatureDetailsViewController alloc]initWithFeatureLayer:self.featureLayer feature:nil featureGeometry:geometry] autorelease];
    
	/**
     * Prepares the details for the new feature.
     */
    [self.navigationController pushViewController:detailViewController animated:YES];

    NSLog(@"GEOMETRY: %@", geometry);
}

#pragma mark dealloc

- (void)dealloc {
    
    /**
     * This allows us to see what is being fired and when
     */
    NSLog(@"WaterReporterViewController: dealloc");
    
	self.mapView = nil;
	self.featureLayer = nil;
    
    self.commitGeometryButton = nil;

    [super dealloc];
}

@end
