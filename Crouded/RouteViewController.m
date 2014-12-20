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
@property (nonatomic, strong) AGSGraphicsLayer* commuteLayer;
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
    
    _commuteLayer = [AGSGraphicsLayer graphicsLayer];
    [self.mapView addMapLayer:self.commuteLayer];
    
    [self findTypicalCommute];
    
}

- (void)findTypicalCommute
{
    NSString* address1 = @"1020 W. Fern Ave Redlands, CA 92373";
    NSString* address2 = @"5015 La Mart Riverside, CA 92507";
    
    __weak RouteViewController* weakSelf = self;
    _commute = [[Commute alloc] initWithAddress:address1
                                       address2:address2
                                     completion:^(NSError* e) {
                                         [weakSelf drawCommute];
                                     }];
}

- (void)drawCommute
{
    if (!self.commute || !self.commute.point1 || !self.commute.point2) {
        [self findTypicalCommute];
    }
    
    AGSGeometryEngine * ge = [AGSGeometryEngine defaultGeometryEngine];
    AGSPoint* p1 = (AGSPoint*)[ge projectGeometry:self.commute.point1 toSpatialReference:self.mapView.spatialReference];
    AGSPoint* p2 = (AGSPoint*)[ge projectGeometry:self.commute.point2 toSpatialReference:self.mapView.spatialReference];
    
    AGSSimpleMarkerSymbol* sms1 = [AGSSimpleMarkerSymbol simpleMarkerSymbol];
    sms1.color = [UIColor redColor];
    
    AGSSimpleMarkerSymbol* sms2 = [AGSSimpleMarkerSymbol simpleMarkerSymbol];
    sms2.color = [UIColor greenColor];
    
    AGSGraphic* p1Graphic = [AGSGraphic graphicWithGeometry:p1
                                                     symbol:sms1 attributes:nil];
    
    
    AGSGraphic* p2Graphic = [AGSGraphic graphicWithGeometry:p2
                                                     symbol:sms2 attributes:nil];
    
    [self.commuteLayer addGraphics:@[p1Graphic, p2Graphic]];
    
    AGSMutablePolyline* line = [[AGSMutablePolyline alloc] init];
    [line addPathToPolyline];
    [line addPoint:p1 toPath:0];
    [line addPoint:p2 toPath:0];
    
    AGSMutableEnvelope* env = [p1.envelope mutableCopy];
    [env unionWithPoint:p2];
    [env expandByFactor:1.5];
    
    [self.mapView zoomToEnvelope:env animated:YES];
}

#define kGPSScale 12000

- (void)enableGps:(AGSLocationDisplayAutoPanMode)mode
{
    AGSLocationDisplay* gps = self.mapView.locationDisplay;
    gps.autoPanMode = mode;
    [gps startDataSource];
}

@end
