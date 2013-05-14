/**
 * Water Reporter
 *
 * Created by Viable Industries L.L.C. in March 2013.
 * Copyright (c) 2013 Viable Industries L.L.C. All rights reserved.
 *
 */

#import <UIKit/UIKit.h>
#import <ArcGIS/ArcGIS.h>

@interface FeatureTypeViewController : UITableViewController {
	AGSFeatureLayer *_featureLayer;
	AGSGraphic *_feature;
    
    id  _completedDelegate;
}

@property (nonatomic, retain) AGSFeatureLayer *featureLayer;
@property (nonatomic, retain) AGSGraphic *feature;
@property (nonatomic, assign) id completedDelegate;

@end
