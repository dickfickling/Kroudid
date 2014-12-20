//
//  RouteViewController.m
//  Crouded
//
//  Created by Richard Fickling on 12/19/14.
//  Copyright (c) 2014 App Builders Inc. All rights reserved.
//

#import "RouteViewController.h"
#import "User.h"
#import "Commute.h"
#import <ArcGIS/ArcGIS.h>

@interface RouteViewController ()

@property (nonatomic, strong) AGSMapView* mapView;
@property (nonatomic, strong) User* user;

@property (nonatomic, strong) Commute* commute;


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
    
    NSString* address1 = @"1020 W. Fern Ave Redlands, CA 92373";
    NSString* address2 = @"3663 Canyon Crest Ave Riverside, CA 92507";
    
    _commute = [[Commute alloc] initWithAddress:address1
                                                 address2:address2
                                               completion:^(NSError* e) {
                                                   NSLog(@"Something!");
                                               }];
    
    
}

#define kGPSScale 12000

- (void)enableGps:(AGSLocationDisplayAutoPanMode)mode
{
    AGSLocationDisplay* gps = self.mapView.locationDisplay;
    gps.autoPanMode = mode;
    [gps startDataSource];
}

@end
