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


// Notes:
//
// http://resources.arcgis.com/en/help/runtime-ios-sdk/concepts/index.html#/Working_with_JSON/00pw0000004w000000/
// http://resources.arcgis.com/en/help/runtime-ios-sdk/concepts/index.html#//00pw00000052000000
// http://resources.arcgis.com/en/help/runtime-ios-sdk/apiref/index.htm
// http://services.arcgis.com/I6k5a3a8EwvGOEs3/arcgis/rest/services/pollution_report/FeatureServer/0
// http://services.arcgis.com/I6k5a3a8EwvGOEs3/arcgis/rest/services/pollution_report/FeatureServer/0?f=pjson
// Everything we need to know about FeatureLayers http://resources.arcgis.com/en/help/runtime-ios-sdk/concepts/index.html#//00pw0000004s000000


/**
 * The primary View Controller for the Water Reporter iOS Application.
 */

#import "WaterReporterViewController.h"

@implementation WaterReporterViewController

@synthesize mapView = _mapView;
@synthesize activeFeatureLayer = _featureLayer;
@synthesize webmap = _webmap;
@synthesize popupVC = _popupVC;
@synthesize featureTemplatePickerViewController = _featureTemplatePickerViewController;
@synthesize sketchLayer = _sketchLayer;
@synthesize bannerView = _bannerView;
@synthesize alertView = _alertView;
@synthesize loadingView = _loadingView;
@synthesize sketchCompleteButton = _sketchCompleteButton;
@synthesize locationManager = _locationManager;

NSString *viWaterReporterWebMapID = @"70f0fef3990a462397fcd4b9409c09cb";
double viUserLocationLongitude;
double viUserLocationLatitude;
int viDefaultUserLocationZoomLevel = 150000;


#pragma mark - Handlers for Navigation Bar buttons


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


#pragma mark -  UIView methods

- (void)viewDidLoad {
    
    /**
     * Add the "Add report" button to the main map
     */
    UIImage *addNewFeatureImage = [UIImage imageNamed:@"addButton.png"];
    UIButton *addNewFeatureToMap = [UIButton buttonWithType:UIButtonTypeCustom];
    addNewFeatureToMap.userInteractionEnabled = YES;
    addNewFeatureToMap.frame = CGRectMake(264.0, 384.0, 36.0, 36.0);
    [addNewFeatureToMap setImage:addNewFeatureImage forState:UIControlStateNormal];
    [addNewFeatureToMap addTarget:self action:@selector(presentFeatureTemplatePicker) forControlEvents:UIControlEventTouchUpInside];

    /**
     * Add the "Legend" button to the main map
     */
    UIImage *presentLegendImage = [UIImage imageNamed:@"legendButton.png"];
    UIButton *presentLegend = [UIButton buttonWithType:UIButtonTypeCustom];
    presentLegend.userInteractionEnabled = YES;
    presentLegend.frame = CGRectMake(264.0, 384.0, 36.0, 36.0);
    [presentLegend setImage:presentLegendImage forState:UIControlStateNormal];

    /**
     * Initialize the button bar for our "Done" button
     */
    self.sketchCompleteButton = [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:self action:@selector(sketchComplete)];
    
    /**
     * Initialize the feature template picker so that we can show it later when needed
     */
    self.featureTemplatePickerViewController =  [[FeatureTemplatePickerViewController alloc] initWithNibName:@"FeatureTemplatePickerViewController" bundle:nil];
    self.featureTemplatePickerViewController.delegate = self;
    
    /**
     * Set the delegates so that they can do the job they are here for
     */
	self.mapView.layerDelegate = self;
	self.mapView.touchDelegate = self;
	self.mapView.calloutDelegate = self;
    self.mapView.callout.delegate = self;
	
    /**
     * Setup the WebMap
     */
    self.webmap = [AGSWebMap webMapWithItemId:viWaterReporterWebMapID credential:nil];
    
    /**
     * Designate a delegate to be notified as web map is opened
     */
    self.webmap.delegate = self;
    [self.webmap openIntoMapView:self.mapView];
    
    // See http://tech.pro/tutorial/926/iphone-tutorial-creating-basic-buttons
    [self.mapView addSubview:addNewFeatureToMap];
	
    [super viewDidLoad];

}


/**
 * Custom Navigation Bar for the Map View
 *
 */
- (UINavigationItem *)navigationItem
{
    UINavigationItem *navigationItem = [super navigationItem];
    UILabel *customLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320.0, 40.0)];
    customLabel.text = @"Water Reporter";
    customLabel.textColor = [UIColor blackColor];
    customLabel.textAlignment = UITextAlignmentCenter;
    customLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size: 19.0];
    navigationItem.titleView = customLabel;
    return navigationItem;
}

#pragma mark - AGSWebMapDelegate methods

- (void) webMap:(AGSWebMap *)webMap didLoadLayer:(AGSLayer *)layer {
    
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
    [self presentModalViewController:self.featureTemplatePickerViewController animated:YES];
    
    
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



#pragma mark AGSSketchGraphicsLayer notifications

- (void)respondToGeomChanged: (NSNotification*) notification {
    
    /**
     * Update the interface and associated fields if the
     * user selected geometry is valid.
     */
    if([self.sketchLayer.geometry isValid] && ![self.sketchLayer.geometry isEmpty]) {
        
        // Display the "Done" button
        self.sketchCompleteButton.enabled = YES;
        
        /***
         ** TODO: FOR NOW WE ONLY NEED POINTS, BUT IN THE FUTURE
         ** WE ARE GOING TO NEED TO ADD SUPPORT FOR POLYGONS AND
         ** LINES WITHIN OUR GEOMETRY TOOLS.
         ***/    
        AGSPoint *currentSketchValue = (AGSPoint*)AGSGeometryWebMercatorToGeographic(self.sketchLayer.geometry);
        
        viUserLocationLongitude = currentSketchValue.x;
        viUserLocationLatitude = currentSketchValue.y;
                
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

}


#pragma mark - FeatureTemplatePickerDelegate methods

/**
 * Add a new feature
 *
 * The action for the "+" button that allows
 * the user to select what kind of Feature
 * they would like to add to the map
 *
 */
-(void)presentFeatureTemplatePicker{
    NSLog(@"presentFeatureTemplatePicker");
    
    // iPAD ONLY: Limit the size of the form sheet
    if([[AGSDevice currentDevice] isIPad])
        self.featureTemplatePickerViewController.modalPresentationStyle = UIModalPresentationFormSheet;
    
    // ALL: Animate the template picker, covering vertically
    self.featureTemplatePickerViewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    
    // Display the modal ... see FeatureTemplatePickerViewController.xib for layout
    [self presentModalViewController:self.featureTemplatePickerViewController animated:YES];
}

-(void)featureTemplatePickerViewControllerWasDismissed: (FeatureTemplatePickerViewController*) featureTemplatePickerViewController{
    NSLog(@"featureTemplatePickerViewControllerWasDismissed");
    [self dismissModalViewControllerAnimated:YES];
}

-(void)featureTemplatePickerViewController:(FeatureTemplatePickerViewController*) featureTemplatePickerViewController didSelectFeatureTemplate:(AGSFeatureTemplate*)template forFeatureLayer:(AGSFeatureLayer*)featureLayer {
    NSLog(@"featureTemplatePickerViewController:didSelectFeatureTemplate");
    
    //
    // Set the active feature layer to the one we are going to edit
    //
    self.activeFeatureLayer = featureLayer;


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
    for (AGSFeatureLayer* field in self.activeFeatureLayer.fields) {

        //
        // Prepopulate the date field for the user
        //
        if ([field.name isEqualToString:@"date"]) {
            
            //
            // Get the current date and time and auto-fill the form field
            //
            // All about date formatting in iOS https://developer.apple.com/library/mac/#documentation/Cocoa/Conceptual/DataFormatting/Articles/dfDateFormatting10_4.html
            // get the current date
            //
            NSTimeInterval theCurrentTime = [[NSDate date] timeIntervalSince1970];
            
            double theAGSCompatibleTime = theCurrentTime * 1000; // We must do this so that ArcGIS translates it appropriately
            
            [template.prototype setAttributeWithDouble:theAGSCompatibleTime forKey:@"date"];

        }

        //
        // Prepopulate the users images as they upload attachments.
        //
        // NOTE: We don't want to prepopulate the image fields. What
        //       we really want to do is fill these fields automatically
        //       later in the process when a user interacts with the
        //       form by attaching files (e.g., image, video)
        //
        //if ([field.name hasPrefix:@"image"] || [field.name hasSuffix:@"image"]) {
            // fill in the image fields as attachments are added
        //}

        //
        // Prepopulate the users location when they add a new report.
        //
        // Note: We need to not only prepopulate these fields within the
        //       Feature Layer but we also need to update the sketch layer
        //       so that the GPS uses that same location. If we update
        //       the sketch layer, we also need to come back and refill
        //       these fields as well.
        //
        if ([field.name hasPrefix:@"lat"] || [field.name hasPrefix:@"long"]) {
            
            [template.prototype setAttributeWithFloat:viUserLocationLongitude forKey:@"long_push"];
            [template.prototype setAttributeWithFloat:viUserLocationLatitude forKey:@"lat_push"];
            
            //NSLog(@"long_push: %@; lat_push: %@;", [template.prototype valueForKey:@"long_push"], [template.prototype valueForKey:@"lat_push"]);
            
        }

        //
        // Point to Polygon
        //
        // Determine what watershed a user is in when they launch the application
        // and set their default based on the results of their GPS or geolocation
        //
        // In order to implement this see if we can use the "containsPoint" method
        // provided by the AGSPolygon Class.
        //
        // For more information see http://resources.arcgis.com/en/help/runtime-ios-sdk/apiref/interface_a_g_s_polygon.html#a64a3986417a6f545d3d721827969ee55
        //
        if ([field.name hasPrefix:@"keeper"] || [field.name hasSuffix:@"keeper"]) {
            //[template.prototype setAttributeWithString:@"A keeper was found" forKey:field.name];
        }
        
    }
    
    //create a new feature based on the template
    _newFeature = [self.activeFeatureLayer featureWithTemplate:template];
    
    //Add the new feature to the feature layer's graphic collection
    //This is important because then the popup view controller will be able to 
    //find the feature layer associated with the graphic and inspect the field metadata
    //such as domains, subtypes, data type, length, etc
    //Also note, if the user cancels before saving the new feature to the server, 
    //we will manually need to remove this
    //feature from the feature layer (see implementation for popupsContainer:didCancelEditingGraphicForPopup: below)
    [self.activeFeatureLayer addGraphic:_newFeature];
        
    //Iniitalize a popup view controller
    self.popupVC = [[AGSPopupsContainerViewController alloc] initWithWebMap:self.webmap forFeature:_newFeature usingNavigationControllerStack:NO];
    self.popupVC.delegate = self;
    
    //Only for iPad, set presentation style to Form sheet 
    //We don't want it to cover the entire screen
    if([[AGSDevice currentDevice] isIPad])
        self.popupVC.modalPresentationStyle = UIModalPresentationFormSheet;
    
    //Animate by covering vertically
    self.popupVC.modalTransitionStyle =  UIModalTransitionStyleCoverVertical;
    
    //First, dismiss the Feature Template Picker
    [self dismissModalViewControllerAnimated:NO];
    
    //Next, Present the popup view controller
    [self presentModalViewController:self.popupVC animated:YES];
    [self.popupVC startEditingCurrentPopup];
    
}

#pragma mark - AGSMapViewCalloutDelegate methods

- (BOOL)mapView:(AGSMapView *) mapView shouldShowCalloutForGraphic:(AGSGraphic *) graphic {
    NSLog(@"mapView:shouldShowCalloutForGraphic");
    //Dont show callout when the sketch layer is active.
    //The user is sketching and even if he taps on a feature, 
    //we don't want to display the callout and interfere with the sketching workflow
    return self.mapView.touchDelegate != self.sketchLayer ;
}

#pragma mark - AGSCalloutDelegate methods
- (void) didClickAccessoryButtonForCallout:		(AGSCallout *) 	callout {
    NSLog(@"didClickAccessoryButtonForCallout");
    
    AGSGraphic* graphic = (AGSGraphic*)callout.representedObject;
    self.activeFeatureLayer = (AGSFeatureLayer*) graphic.layer;
    
    //Show popup for the graphic because the user tapped on the callout accessory button
    self.popupVC = [[AGSPopupsContainerViewController alloc] initWithWebMap:self.webmap forFeature:graphic usingNavigationControllerStack:NO];
    self.popupVC.delegate = self;
    self.popupVC.modalTransitionStyle =  UIModalTransitionStyleCoverVertical;
    
    //If iPad, use a modal presentation style
    if([[AGSDevice currentDevice] isIPad])
        self.popupVC.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentModalViewController:self.popupVC animated:YES];

}



#pragma mark -  AGSPopupsContainerDelegate methods

- (AGSGeometry *)popupsContainer:(id) popupsContainer wantsNewMutableGeometryForPopup:(AGSPopup *) popup {
    NSLog(@"wantsNewMutableGeometryForPopup");

    //Return an empty mutable geometry of the type that our feature layer uses
    return AGSMutableGeometryFromType( ((AGSFeatureLayer*)popup.graphic.layer).geometryType, self.mapView.spatialReference);
}

- (void)popupsContainer:(id) popupsContainer readyToEditGraphicGeometry:(AGSGeometry *) geometry forPopup:(AGSPopup *) popup{
    NSLog(@"readyToEditGraphicGeometry");

    //Dismiss the popup view controller
    [self dismissModalViewControllerAnimated:YES];
    
    
    //Prepare the current view controller for sketch mode
    self.bannerView.hidden = NO;
    self.mapView.touchDelegate = self.sketchLayer; //activate the sketch layer
    self.mapView.callout.hidden = YES;
    
    
    // Stop updating the location so the user can actually add their
    // new location to the map by touching.
    [self.locationManager stopUpdatingLocation];
    
    
    //Assign the sketch layer the geometry that is being passed to us for 
    //the active popup's graphic. This is the starting point of the sketch
    self.sketchLayer.geometry = geometry;
    
    //zoom to the existing feature's geometry
    AGSEnvelope* env = nil;
    AGSGeometryType geoType = AGSGeometryTypeForGeometry(self.sketchLayer.geometry);
    if(geoType == AGSGeometryTypePolygon){
        env = ((AGSPolygon*)self.sketchLayer.geometry).envelope;
    }else if(geoType == AGSGeometryTypePolyline){
        env = ((AGSPolyline*)self.sketchLayer.geometry).envelope ;
    }
    
    if(env!=nil){
        AGSMutableEnvelope* mutableEnv  = [env mutableCopy];
        [mutableEnv expandByFactor:1.4];
        [self.mapView zoomToEnvelope:mutableEnv animated:YES];
    }
    
    //replace the button in the navigation bar to allow a user to 
    //indicate that the sketch is done
	self.navigationItem.rightBarButtonItem = self.sketchCompleteButton;
    self.sketchCompleteButton.enabled = NO;
}

- (void)popupsContainer:(id<AGSPopupsContainer>) popupsContainer wantsToDeleteGraphicForPopup:(AGSPopup *) popup {
    NSLog(@"wantsToDeleteGraphicForPopup");

    //Call method on feature layer to delete the feature
    NSNumber* number = [NSNumber numberWithInteger: [self.activeFeatureLayer objectIdForFeature:popup.graphic]];
    NSArray* oids = [NSArray arrayWithObject: number ];
    [self.activeFeatureLayer deleteFeaturesWithObjectIds:oids ];
    self.loadingView = [LoadingView loadingViewInView:self.popupVC.view withText:@"Deleting feature..."];

}

-(void)popupsContainer:(id<AGSPopupsContainer>)popupsContainer didFinishEditingGraphicForPopup:(AGSPopup*)popup{
    NSLog(@"didFinishEditingGraphicForPopup");

	// simplify the geometry, this will take care of self intersecting polygons and
	popup.graphic.geometry = [[AGSGeometryEngine defaultGeometryEngine]simplifyGeometry:popup.graphic.geometry];
    //normalize the geometry, this will take care of geometries that extend beyone the dateline 
    //(ifwraparound was enabled on the map)
	popup.graphic.geometry = [[AGSGeometryEngine defaultGeometryEngine]normalizeCentralMeridianOfGeometry:popup.graphic.geometry];
	
	int oid = [self.activeFeatureLayer objectIdForFeature:popup.graphic];
	
	if (oid > 0){
		//feature has a valid objectid, this means it exists on the server
        //and we simply update the exisiting feature
		[self.activeFeatureLayer updateFeatures:[NSArray arrayWithObject:popup.graphic]];
	} else {
		//objectid does not exist, this means we need to add it as a new feature
		[self.activeFeatureLayer addFeatures:[NSArray arrayWithObject:popup.graphic]];
	}
    
    //Tell the user edits are being saved int the background
    self.loadingView = [LoadingView loadingViewInView:self.popupVC.view withText:@"Saving feature details..."];

    //we will wait to post attachments till when the updates succeed
}

- (void)popupsContainerDidFinishViewingPopups:(id) popupsContainer {
    NSLog(@"popupsContainerDidFinishViewingPopups");

    //dismiss the popups view controller
    [self dismissModalViewControllerAnimated:YES];
    self.popupVC = nil;
    
}

- (void)popupsContainer:(id) popupsContainer didCancelEditingGraphicForPopup:(AGSPopup *) popup {
    NSLog(@"didCancelEditingGraphicForPopup");

    //dismiss the popups view controller
    [self dismissModalViewControllerAnimated:YES];

    //if we had begun adding a new feature, remove it from the layer because the user hit cancel.
    if(_newFeature!=nil){
        [self.activeFeatureLayer removeGraphic:_newFeature];
        _newFeature = nil;
    }
    
    //reset any sketch related changes we made to our main view controller
    [self.sketchLayer clear];
    self.mapView.touchDelegate = self;
    self.mapView.calloutDelegate = self;
    self.bannerView.hidden = YES;
    self.popupVC = nil;
}

#pragma mark - 
- (void) warnUserOfErrorWithMessage:(NSString*) message {
    NSLog(@"warnUserOfErrorWithMessage");
    //Display an alert to the user
    self.alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [self.alertView show];
    
    //Restart editing the popup so that the user can attempt to save again
    [self.popupVC startEditingCurrentPopup];
}

#pragma mark - AGSFeatureLayerEditingDelegate methods

-(void)featureLayer:(AGSFeatureLayer *)featureLayer operation:(NSOperation *)op didFeatureEditsWithResults:(AGSFeatureLayerEditResults *)editResults{
    NSLog(@"featureLayer:didFeatureEditsWithResults");
    
    //Remove the activity indicator
    [self.loadingView removeView];
    
    //We will assume we have to update the attachments unless
    //1) We were adding a feature and it failed
    //2) We were updating a feature and it failed
    //3) We were deleting a feature
    BOOL _updateAttachments = YES;
    
    if([editResults.addResults count]>0){
        //we were adding a new feature
        AGSEditResult* result = (AGSEditResult*)[editResults.addResults objectAtIndex:0];
        if(!result.success){
            //Add operation failed. We will not update attachments
            _updateAttachments = NO;
            //Inform user
            [self warnUserOfErrorWithMessage:@"Could not add feature. Please try again"];
        } else {
            NSLog(@"editResults.addResults %@", result.encodeToJSON);
        }
        
    }else if([editResults.updateResults count]>0){
        //we were updating a feature
        AGSEditResult* result = (AGSEditResult*)[editResults.updateResults objectAtIndex:0];
        if(!result.success){
            //Update operation failed. We will not update attachments
            _updateAttachments = NO;
            //Inform user
            [self warnUserOfErrorWithMessage:@"Could not update feature. Please try again"];
        } else {
            NSLog(@"editResults.updateResults %@", result.encodeToJSON);
        }
    }else if([editResults.deleteResults count]>0){
        //we were deleting a feature
        _updateAttachments = NO;
        AGSEditResult* result = (AGSEditResult*)[editResults.deleteResults objectAtIndex:0];
        if(!result.success){
            //Delete operation failed. Inform user
            [self warnUserOfErrorWithMessage:@"Could not delete feature. Please try again"];
        }else{
            //Delete operation succeeded
            //Dismiss the popup view controller and hide the callout which may have been shown for
            //the deleted feature.
            self.mapView.callout.hidden = YES;
            [self dismissModalViewControllerAnimated:YES];
            self.popupVC = nil;
        }

    }
    
    //if edits pertaining to the feature were successful...
    if (_updateAttachments){
        
        [self.sketchLayer clear];

        //...we post edits to the attachments 
		AGSAttachmentManager *attMgr = [featureLayer attachmentManagerForFeature:self.popupVC.currentPopup.graphic];
		attMgr.delegate = self;
        
        if([attMgr hasLocalEdits]){
			[attMgr postLocalEditsToServer];
            self.loadingView = [LoadingView loadingViewInView:self.popupVC.view withText:@"Saving attachments..."];
        }
        
        
        
        
	}

}

-(void)featureLayer:(AGSFeatureLayer *)featureLayer operation:(NSOperation *)op didFailFeatureEditsWithError:(NSError *)error{
    NSLog(@"featureLayer:didFailFeatureEditsWithError");
    NSLog(@"Could not commit edits because: %@", [error localizedDescription]);

    [self.loadingView removeView];
    [self warnUserOfErrorWithMessage:@"Could not save edits. Please try again"];
}



#pragma mark -
#pragma mark AGSAttachmentManagerDelegate

-(void)attachmentManager:(AGSAttachmentManager *)attachmentManager didPostLocalEditsToServer:(NSArray *)attachmentsPosted{
    NSLog(@"didPostLocalEditsToServer");
    
    [self.loadingView removeView];
    
    //loop through all attachments looking for failures
    BOOL _anyFailure = NO;
    for (AGSAttachment* attachment in attachmentsPosted) {
        if(attachment.networkError!=nil || attachment.editResultError!=nil){
            _anyFailure = YES;
            NSString* reason = nil;
            if(attachment.networkError!=nil)
                reason = [attachment.networkError localizedDescription];
            else if(attachment.editResultError !=nil)
                reason = attachment.editResultError.errorDescription;
            NSLog(@"Attachment '%@' could not be synced with server because %@",attachment.attachmentInfo.name,reason);
        }
    }
    
    if(_anyFailure){
        [self warnUserOfErrorWithMessage:@"Some attachment edits could not be synced with the server. Please try again"];
    }

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    NSLog(@"shouldAutorotateToInterfaceOrientation");
    //Pass the interface orientation on to the map's gps so that
    //it can re-position the gps symbol appropriately in
    //compass navigation mode
    self.mapView.locationDisplay.interfaceOrientation = interfaceOrientation;
    return YES;
}

#pragma mark -
- (void)didReceiveMemoryWarning {
    NSLog(@"didReceiveMemoryWarning");
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    //Stop the GPS, undo the map rotation (if any)
    if([self.mapView.locationDisplay isDataSourceStarted]){
        [self.mapView.locationDisplay stopDataSource];
    }
    [self.locationManager stopUpdatingLocation];
    self.locationManager = nil;
    self.mapView = nil;
}


/*
 * We want to get and store a location measurement that meets the desired accuracy. For this example, we are
 *      going to use horizontal accuracy as the deciding factor. In other cases, you may wish to use vertical
 *      accuracy, or both together.
 */
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    
    /**
     * Ensure horizontal accuracy doesn't resolve to
     * an invalid measurement.
     */
    if (newLocation.horizontalAccuracy < 0) {
        return;
    }
    
    
    /**
     * Add the existing GPS point to the sketch layer
     */
    [self.sketchLayer insertVertex:[self.mapView.locationDisplay mapLocation] inPart:0 atIndex:-1];
    
    
    /**
     * Create an AGSLocation instance so that we can
     * fetch the X & Y coordinates and update the
     * variables for our feature layer form.
     */
    AGSLocation* agsLoc = self.mapView.locationDisplay.location;

    viUserLocationLongitude = agsLoc.point.x;
    viUserLocationLatitude = agsLoc.point.y;

    NSLog(@"Settings to be used for new map feature [x: %f; y: %f]", viUserLocationLongitude, viUserLocationLatitude);
}

/**
 * If the Location Manager fails, we need to stop it so that it doesn't start
 * looping through error after error.
 */
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    // The location "unknown" error simply means the manager is currently unable to get the location.
    if ([error code] != kCLErrorLocationUnknown) {
        [self stopUpdatingLocation];
    }
}

/**
 * Stop updating the Location Manager and remove the delegate
 */
- (void)stopUpdatingLocation {
    //stop the location manager and set the delegate to nil;
    [self.locationManager stopUpdatingLocation];
    self.locationManager.delegate = nil;
}


/**
 * Save a user's sketch properties
 *
 * Once a user has completed the "sketch" process
 * the app will save the geometry information and
 * dismiss the modal.
 *
 */
-(void)sketchComplete{    
    self.navigationItem.rightBarButtonItem = nil;
    [self presentModalViewController:self.popupVC animated:YES];
    self.mapView.touchDelegate = self;
    self.bannerView.hidden = YES;

}



@end
