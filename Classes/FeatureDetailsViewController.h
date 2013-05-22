/**
 * Water Reporter
 *
 * Created by Viable Industries L.L.C. in March 2013.
 * Copyright (c) 2013 Viable Industries L.L.C. All rights reserved.
 *
 */

#import <UIKit/UIKit.h>
#import <ArcGIS/ArcGIS.h>
#import "WaterReporterViewController.h"

@class FeatureTypeViewController;
@class WaterReporterFeatureLayer;

@interface FeatureDetailsViewController : UITableViewController <UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,AGSFeatureLayerEditingDelegate,UITextFieldDelegate,UIPickerViewDataSource,UIPickerViewDelegate> {
	

    AGSFeatureLayer *_featureLayer;
	AGSGraphic *_feature;
    int *_featureObjectId;
    NSMutableArray *allMediaAttachments;
	AGSGeometry *_featureGeometry;
    AGSPoint *_userLocation;
    NSObject *_templatePrototype;
	NSMutableArray *_attachments;			// any attachments, for not newFeature it will start filled with NSNull, then populated as we retrieve the data for the attachments (happens when they click on to view an attachment)
    NSDate *_date;							// date of when the feature was created
	NSDateFormatter *_dateFormat;			// used for displaying the date
	NSDateFormatter *_timeFormat;			// used for displaying the time
	int _objectId;							// object id of the feature passed in, or created feature
	BOOL _newFeature;						// flag that indicates whether the feature for which details are being viewed is new or existing
	NSArray *_attachmentInfos;				// when the feature is already existing, then we query for the attachment infos, store them in this var
	NSMutableArray *_operations;			// all the in-progress operations spawned by this VC, we keep them so we can cancel them if we pop the VC (dealloc cancels them)
	NSOperation *_retrieveAttachmentOp;		// keep track of the retrieve attachment op so that we only do one of these at a time

	UITextField *_dateField;
	UITextField *_eventField;
    UITextField *_reporterField;
    UITextField *_commentField;
    UITextField *_keeperField;
	UITextField *_pollutionField;
    UITextField *_emailField;
    
	UIPickerView *eventPicker;
	UIPickerView *reporterPicker;
    UIPickerView *keeperPicker;
    UIPickerView *pollutionPicker;
    NSMutableArray *eventPickerViewFieldOptions;
    NSMutableArray *reporterPickerViewFieldOptions;
    NSMutableArray *keeperPickerViewFieldOptions;
    NSMutableArray *pollutionPickerViewFieldOptions;
    
    WaterReporterViewController* _waterReporterViewController;
}

@property (nonatomic) double viUserLocationLongitude;
@property (nonatomic) double viUserLocationLatitude;
@property (nonatomic) int featureObjectId;
@property (nonatomic, retain) NSMutableArray *allMediaAttachments;

@property (nonatomic, retain) AGSGraphic *feature;
@property (nonatomic, retain) AGSGeometry *featureGeometry;
@property (nonatomic, retain) AGSPoint *userLocation;
@property (nonatomic, retain) NSObject *templatePrototype;
@property (nonatomic, retain) AGSFeatureLayer *featureLayer;
@property (nonatomic, retain) NSMutableArray *attachments;
@property (nonatomic, retain) NSDate *date;
@property (nonatomic, retain) NSDateFormatter *dateFormat;
@property (nonatomic, retain) NSDateFormatter *timeFormat;
@property (nonatomic, retain) NSArray *attachmentInfos;
@property (nonatomic, retain) NSMutableArray *operations;
@property (nonatomic, retain) NSOperation *retrieveAttachmentOp;

@property (nonatomic, retain) UITextField *dateField;
@property (nonatomic, retain) UITextField *eventField;
@property (nonatomic, retain) UITextField *reporterField;
@property (nonatomic, retain) UITextField *commentField;
@property (nonatomic, retain) UITextField *keeperField;
@property (nonatomic, retain) UITextField *pollutionField;
@property (nonatomic, retain) UITextField *emailField;

@property (nonatomic, strong) IBOutlet UIPickerView *eventPicker;
@property (nonatomic, strong) IBOutlet UIPickerView *reporterPicker;
@property (nonatomic, strong) IBOutlet UIPickerView *keeperPicker;
@property (nonatomic, strong) IBOutlet UIPickerView *pollutionPicker;
@property (nonatomic, retain) NSMutableArray *eventPickerViewFieldOptions;
@property (nonatomic, retain) NSMutableArray *reporterPickerViewFieldOptions;
@property (nonatomic, retain) NSMutableArray *keeperPickerViewFieldOptions;
@property (nonatomic, retain) NSMutableArray *pollutionPickerViewFieldOptions;

@property (nonatomic, strong) WaterReporterViewController* waterReporterViewController;

-(id)initWithFeatureLayer:(AGSFeatureLayer*)featureLayer feature:(AGSGraphic *)feature featureGeometry:(AGSGeometry*)featureGeometry templatePrototype:(NSObject*)templatePrototype;
-(void)didSelectFeatureType:(FeatureTypeViewController *)ftvc;

@end
