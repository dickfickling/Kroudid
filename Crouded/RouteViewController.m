//
//  RouteViewController.m
//  Crouded
//
//  Created by Richard Fickling on 12/19/14.
//  Copyright (c) 2014 App Builders Inc. All rights reserved.
//

#import "RouteViewController.h"
#import "User.h"
#import <ArcGIS/ArcGIS.h>

@interface RouteViewController ()

@property (nonatomic, strong) AGSMapView* mapView;
@property (nonatomic, strong) User* user;


@end

@implementation RouteViewController

- (IBAction)okButtonPressed:(id)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _mapView = [[AGSMapView alloc] initWithFrame:self.view.bounds];
    
    [self.view addSubview:_mapView];
    
    //Add a basemap tiled layer
    NSURL* url = [NSURL URLWithString:@"http://services.arcgisonline.com/arcgis/rest/services/NatGeo_World_Map/MapServer"];
    AGSTiledMapServiceLayer *tiledLayer = [AGSTiledMapServiceLayer tiledMapServiceLayerWithURL:url];
    [self.mapView addMapLayer:tiledLayer withName:@"Basemap Tiled Layer"];
    
    [self enableGps:AGSLocationDisplayAutoPanModeDefault];
    
    _user = [User storedUser];
    if (!self.user) {
        NSLog(@"No user stored");
        _user = [[User alloc] initWithEmail:@"sampleuser@gmail.com"];
    }
    else {
        NSLog(@"Found user: %@", self.user.email);
    }
    
}

#define kGPSScale 12000

- (void)enableGps:(AGSLocationDisplayAutoPanMode)mode
{
    AGSLocationDisplay* gps = self.mapView.locationDisplay;
    gps.autoPanMode = mode;
    [gps startDataSource];
}

@end
