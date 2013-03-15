//
//  ViewController.h
//  Water Reporter
//
//  Created by Viable Industries on 3/13/13.
//  Copyright (c) 2013 Viable Industries. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ArcGIS/ArcGIS.h>

@interface ViewController : UIViewController <AGSWebMapDelegate, AGSMapViewLayerDelegate, AGSMapViewTouchDelegate, AGSMapViewCalloutDelegate>
@property (weak, nonatomic) IBOutlet AGSMapView *mapView;
    
@end
