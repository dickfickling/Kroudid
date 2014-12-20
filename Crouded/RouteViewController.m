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

@interface RouteViewController () <AGSMapViewTouchDelegate>

@property (nonatomic, strong) AGSMapView* mapView;

@property (nonatomic, strong) AGSGraphicsLayer* fencesLayer;
@property (nonatomic, strong) AGSGraphicsLayer* commuteLayer;


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
    
    self.mapView.touchDelegate = self;
    
    [self enableGps:AGSLocationDisplayAutoPanModeDefault];
    
    _fencesLayer = [AGSGraphicsLayer graphicsLayer];
    [self.mapView addMapLayer:self.fencesLayer];
    
    _commuteLayer = [AGSGraphicsLayer graphicsLayer];
    [self.mapView addMapLayer:self.commuteLayer];
    
    _user = [User storedUser];
    if (!self.user) {
        _user = [[User alloc] initWithEmail:@"sample1234@gmail.com"];
    }
    
    [self findTypicalCommute];
    
}

- (void)findTypicalCommute
{
    NSString* address1 = @"10889 N DE ANZA BLVD Cupertino, CA, 95014";
    
    NSString* address2 = @"10715 GRAPNEL PL Cupertino, CA 95014";
    //NSString* address2 = @"10711 BAXTER AVE LOS ALTOS, CA 94024";
    
    __weak RouteViewController* weakSelf = self;
    [self.user findHomeAddress:address1 workAddress:address2 completion:^(NSError* e) {
        
        if (!e) {
            weakSelf.user.myCommute.gps = weakSelf.mapView.locationDisplay;
        }
        
        [weakSelf drawCommute];
    }];
}

- (void)drawCommute
{
    if (![self.user hasValidCommute]){
        return;
    }
    
    AGSSimpleLineSymbol* sls1 = [AGSSimpleLineSymbol simpleLineSymbol];
    sls1.color = [UIColor redColor];
    
    AGSSimpleLineSymbol* sls2 = [AGSSimpleLineSymbol simpleLineSymbol];
    sls2.color = [UIColor greenColor];
    
    
    // Add geofences to map
    AGSSimpleFillSymbol* sfs1 = [AGSSimpleFillSymbol simpleFillSymbol];
    sfs1.color = [[UIColor redColor] colorWithAlphaComponent:0.5];
    sfs1.outline = sls1;
    
    AGSSimpleFillSymbol* sfs2 = [AGSSimpleFillSymbol simpleFillSymbol];
    sfs2.color = [[UIColor greenColor] colorWithAlphaComponent:0.5];
    sfs2.outline = sls2;
    
    AGSGraphic* fence1 = [AGSGraphic graphicWithGeometry:self.user.myCommute.p1Geofence
                                                  symbol:sfs1
                                              attributes:nil];
    
    AGSGraphic* fence2 = [AGSGraphic graphicWithGeometry:self.user.myCommute.p2Geofence
                                                  symbol:sfs2
                                              attributes:nil];
    
    [self.fencesLayer addGraphics:@[fence1, fence2]];
    
    //  Add home and work locations to maps
    AGSGeometryEngine * ge = [AGSGeometryEngine defaultGeometryEngine];
    AGSPoint* p1 = (AGSPoint*)[ge projectGeometry:self.user.homeLocation toSpatialReference:self.mapView.spatialReference];
    AGSPoint* p2 = (AGSPoint*)[ge projectGeometry:self.user.workLocation toSpatialReference:self.mapView.spatialReference];
    
    AGSSimpleMarkerSymbol* sms1 = [AGSSimpleMarkerSymbol simpleMarkerSymbol];
    sms1.color = [UIColor redColor];
    
    AGSSimpleMarkerSymbol* sms2 = [AGSSimpleMarkerSymbol simpleMarkerSymbol];
    sms2.color = [UIColor greenColor];
    
    AGSGraphic* p1Graphic = [AGSGraphic graphicWithGeometry:p1
                                                     symbol:sms1
                                                 attributes:nil];
    
    
    AGSGraphic* p2Graphic = [AGSGraphic graphicWithGeometry:p2
                                                     symbol:sms2
                                                 attributes:nil];
    
    [self.commuteLayer addGraphics:@[p1Graphic, p2Graphic]];
    
    // Zoom to show commute
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

- (void)mapView:(AGSMapView *)mapView didClickAtPoint:(CGPoint)screen mapPoint:(AGSPoint *)mappoint features:(NSDictionary *)features
{
    AGSGeometryEngine* ge = [AGSGeometryEngine defaultGeometryEngine];
    AGSPoint* p = (AGSPoint*)[ge projectGeometry:mappoint toSpatialReference:[AGSSpatialReference wgs84SpatialReference]];
    NSLog(@"x:  %f  y:  %f", p.x, p.y);
}

@end
