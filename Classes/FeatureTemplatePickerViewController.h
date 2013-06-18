/**
 * Water Reporter
 *
 * Created by Viable Industries L.L.C. in March 2013.
 * Copyright (c) 2013 Viable Industries L.L.C. All rights reserved.
 *
 */

#import <UIKit/UIKit.h>
#import <ArcGIS/ArcGIS.h>
#import "CuratedMapViewController.h"

@class FeatureTemplatePickerViewController;

/** The delegate that will be notified by FeatureTemplatePickerViewController
 when the user dismisses the controller or picks a template from the list 
 */
@protocol FeatureTemplatePickerDelegate <NSObject>

@end


@interface FeatureTemplatePickerViewController : UITableViewController<UIActionSheetDelegate,UINavigationControllerDelegate,UITableViewDataSource,UITableViewDelegate> {

    UITableView* _featureTemplatesTableView;
    id<FeatureTemplatePickerDelegate> __weak _delegate;
	AGSGraphic *_feature;
	BOOL _newFeature;						// flag that indicates whether the feature for which details are being viewed is new or existing
    NSMutableArray* _infos;
	NSMutableArray *_operations;			// all the in-progress operations spawned by this VC, we keep them so we can cancel them if we pop the VC (dealloc cancels them)
    
    CuratedMapViewController* _curatedMapViewController;
    BOOL *_curatedMapActivated;
}


/**
 * Pass variables along
 */
@property(nonatomic, strong) NSMutableArray* cachedFeatureLayerTemplates;
@property (nonatomic) BOOL *curatedMapActivated;

/**
 * Curated Map Variables
 */
@property (nonatomic, strong) CuratedMapViewController* curatedMapViewController;

/**
 * Feature Layer Variables
 */
@property (nonatomic, retain) AGSGraphic *feature;
@property (nonatomic, weak) id<FeatureTemplatePickerDelegate> delegate;
@property (nonatomic,strong) IBOutlet UITableView* featureTemplatesTableView;
@property (nonatomic, strong) NSMutableArray* infos;
@property (nonatomic, retain) NSMutableArray *operations;

- (void) addTemplatesFromLayer:(AGSFeatureLayer*)layer;
-(void)featureTemplatePickerViewController:(FeatureTemplatePickerViewController*) featureTemplatePickerViewController didSelectFeatureTemplate:(AGSFeatureTemplate*)template forFeatureLayer:(AGSFeatureLayer*)featureLayer;

@end


/** A value object to hold information about the feature type, template and layer */
@interface FeatureTemplatePickerInfo : NSObject {
@private
    AGSFeatureType* __weak _featureType;
    AGSFeatureTemplate* __weak _featureTemplate;
    AGSFeatureLayer* __weak _featureLayer;
}

@property (nonatomic, weak) AGSFeatureType* featureType;
@property (nonatomic, weak) AGSFeatureTemplate* featureTemplate;
@property (nonatomic, weak) AGSFeatureLayer* featureLayer;

@end

