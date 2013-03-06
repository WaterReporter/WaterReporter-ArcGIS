//
//  ViewController.m
//  Water Reporter
//
//  Created by J.I. Powell on 3/6/13.
//  Copyright (c) 2013 Developed Simple. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
        AGSTiledMapServiceLayer *tiledLayer =[AGSTiledMapServiceLayer tiledMapServiceLayerWithURL:[NSURL URLWithString:@"http://server.arcgisonline.com/ArcGIS/rest/services/ESRI_StreetMap_World_2D/MapServer"]];
        [self.mapView addMapLayer:tiledLayer withName:@"Tiled Layer"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
