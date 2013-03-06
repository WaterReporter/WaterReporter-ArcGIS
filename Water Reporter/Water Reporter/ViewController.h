//
//  ViewController.h
//  Water Reporter
//
//  Created by J.I. Powell on 3/6/13.
//  Copyright (c) 2013 Developed Simple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ArcGIS/ArcGIS.h>

@interface ViewController : UIViewController <AGSWebMapDelegate, AGSMapViewLayerDelegate, AGSMapViewTouchDelegate, AGSMapViewCalloutDelegate>
@property (weak, nonatomic) IBOutlet AGSMapView *mapView;
    
@end
