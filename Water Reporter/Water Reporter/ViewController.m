//
//  ViewController.m
//  Water Reporter
//
//  Created by J.I. Powell on 3/6/13.
//  Copyright (c) 2013 Developed Simple. All rights reserved.
//

#import "ViewController.h"

static NSString * const kPublicWebmapId = @"70f0fef3990a462397fcd4b9409c09cb";

@interface ViewController () {
}

@property (nonatomic, strong) AGSWebMap *webMap;
@property (nonatomic, strong) NSString* webmapId;

@end

@implementation ViewController

@synthesize webMap = _webMap;
@synthesize mapView = _mapView;
@synthesize webmapId = _webmapId;

// Release any retained subviews of the main view.
- (void)viewDidUnload
{
    self.webMap = nil;
    self.mapView = nil;
    self.webmapId = nil;
    
    [super viewDidUnload];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
        self.mapView.layerDelegate = self;
        self.mapView.touchDelegate = self;
        self.mapView.calloutDelegate = self;

        //Ask the user which webmap to load : Public or Private?
        self.webmapId = kPublicWebmapId;
        //web map finished opening
        self.webMap = [[AGSWebMap alloc] initWithItemId:self.webmapId credential:nil];
        // set the delegate
        self.webMap.delegate = self;
        // open webmap into mapview
        [self.webMap openIntoMapView:self.mapView];

}

- (void) webMapDidLoad:(AGSWebMap*) webMap {
    //webmap data was retrieved successfully
    
}

- (void) webMap:(AGSWebMap *)webMap didFailToLoadWithError:(NSError *)error {
    //webmap data was not retrieved
    //alert the user
    NSLog(@"Error while loading webmap: %@",[error localizedDescription]);
}

-(void)didOpenWebMap:(AGSWebMap*)webMap intoMapView:(AGSMapView*)mapView{


}

-(void)webMap:(AGSWebMap*)wm didLoadLayer:(AGSLayer*)layer{
    //layer in web map loaded properly
}

-(void)webMap:(AGSWebMap*)wm didFailToLoadLayer:(NSString*)layerTitle url:(NSURL*)url baseLayer:(BOOL)baseLayer federated:(BOOL)federated withError:(NSError*)error{
    NSLog(@"Error while loading layer: %@",[error localizedDescription]);
    
    //you can skip loading this layer
    //[self.webMap continueOpenAndSkipCurrentLayer];
    
    //or you can try loading it with proper credentials if the error was security related
    //[self.webMap continueOpenWithCredential:credential];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return  YES;
}

@end
