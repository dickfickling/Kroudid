//
//  RouteViewController.m
//  Crouded
//
//  Created by Richard Fickling on 12/19/14.
//  Copyright (c) 2014 App Builders Inc. All rights reserved.
//

#import "RouteViewController.h"
#import "Crouded-Swift.h"
#import "Commute.h"
#import "UIColor+Additions.h"
#import "MapView.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import <ArcGIS/ArcGIS.h>

// first parameter is an NSDictionary of metrics (or nil),
// subsequent parameters are variable names which are used exactly like
// the params to NSDictionaryOfVariableBindings()
#define NSDictionariesOfMetricsAndVariables(pMetricsDictionary,...) \
NSDictionary* viewsDict     = _NSDictionaryOfVariableBindings(@"" # __VA_ARGS__, __VA_ARGS__, nil);  \
NSDictionary* metrics       = pMetricsDictionary; \
NSMutableArray* constraints = [NSMutableArray arrayWithCapacity:32];        // defines "constraints" array for users

#define NSLConstraints(pFormat)    \
[NSLayoutConstraint constraintsWithVisualFormat:pFormat options:NSLayoutFormatDirectionLeftToRight metrics:metrics views:viewsDict]

#define AddConstraints(pArray)     [constraints addObjectsFromArray:pArray]

@interface RouteViewController () <AGSMapViewTouchDelegate>

@property (nonatomic, strong) UIToolbar* toolbar;
@property (nonatomic, strong) UIBarButtonItem* findButton;
@property (nonatomic, strong) UITextField* homeTextField;
@property (nonatomic, strong) UITextField* workTextField;

@property (nonatomic, strong) AGSGraphicsLayer* fencesLayer;
@property (nonatomic, strong) AGSGraphicsLayer* commuteLayer;

@end

@implementation RouteViewController

- (IBAction)okButtonPressed:(id)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    MapView* mapView = [MapView sharedMapView];
    mapView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.view addSubview:mapView];
    
    //Add a basemap tiled layer
    NSURL* url = [NSURL URLWithString:@"http://services.arcgisonline.com/arcgis/rest/services/NatGeo_World_Map/MapServer"];
    AGSTiledMapServiceLayer *tiledLayer = [AGSTiledMapServiceLayer tiledMapServiceLayerWithURL:url];
    [mapView addMapLayer:tiledLayer withName:@"Basemap Tiled Layer"];
    
    mapView.touchDelegate = self;
    
    _fencesLayer = [AGSGraphicsLayer graphicsLayer];
    [mapView addMapLayer:self.fencesLayer];
    
    _commuteLayer = [AGSGraphicsLayer graphicsLayer];
    [mapView addMapLayer:self.commuteLayer];
    
    UIToolbar* toolbar = [[UIToolbar alloc] init];
    toolbar.translatesAutoresizingMaskIntoConstraints = NO;
    toolbar.barTintColor = [UIColor crowdedBlueColor];
    
    _homeTextField = [[UITextField alloc] init];
    _homeTextField.translatesAutoresizingMaskIntoConstraints = NO;
    _homeTextField.placeholder = @"Home address";
    _homeTextField.borderStyle = UITextBorderStyleRoundedRect;
    
    _workTextField = [[UITextField alloc] init];
    _workTextField.translatesAutoresizingMaskIntoConstraints = NO;
    _workTextField.placeholder = @"Work address";
    _workTextField.borderStyle = UITextBorderStyleRoundedRect;
    
    [self.view addSubview:self.homeTextField];
    [self.view addSubview:self.workTextField];
    
    _toolbar = toolbar;
    [self.view addSubview:toolbar];
    
    NSDictionariesOfMetricsAndVariables(nil, mapView, toolbar, _homeTextField, _workTextField);
    
    AddConstraints(NSLConstraints(@"H:|[mapView]|"));
    AddConstraints(NSLConstraints(@"H:|[toolbar]|"));
    AddConstraints(NSLConstraints(@"V:|-20-[toolbar][mapView]|"));
    
    if (![[User storedUser] hasValidCommute]) {
        AddConstraints(NSLConstraints(@"H:|-5-[_homeTextField]-5-|"));
        AddConstraints(NSLConstraints(@"H:|-5-[_workTextField]-5-|"));
        AddConstraints(NSLConstraints(@"V:[toolbar]-5-[_homeTextField(35)]-5-[_workTextField(35)]"));
    }
    
    [self.view addConstraints:constraints];
    
    [self prepopulateTextFields];
    [self populateToolbar];
}

- (void)viewDidAppear:(BOOL)animated
{
    if ([[User storedUser] hasValidCommute]) {
        [self drawCommute];
    }
    else {
        [self enableGps:AGSLocationDisplayAutoPanModeDefault];
        [self prepopulateTextFields];
    }
    
    [self populateToolbar];
}

- (void)prepopulateTextFields
{
    self.homeTextField.text = @"10889 N DE ANZA BLVD Cupertino, CA, 95014";
    self.workTextField.text = @"10715 GRAPNEL PL Cupertino, CA 95014";
    //NSString* address2 = @"10711 BAXTER AVE LOS ALTOS, CA 94024";
}

- (void)findButtonClicked
{
    if ([[User storedUser] hasValidCommute]) {
        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    }
    else {
        [self findTypicalCommute];
    }
}

- (void)populateToolbar
{
    UIBarButtonItem* flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                   target:nil
                                                                                   action:nil];
    
    NSString* title = [[User storedUser] hasValidCommute] ? @"Your commute" : @"Create your commute";
    UIBarButtonItem* titleButton = [[UIBarButtonItem alloc] initWithTitle:title
                                                                    style:UIBarButtonItemStylePlain
                                                                   target:nil
                                                                   action:nil];

    titleButton.tintColor = [UIColor whiteColor];
    
    NSString* findTitle = [[User storedUser] hasValidCommute] ? @"OK": @"Find";
    _findButton = [[UIBarButtonItem alloc] initWithTitle:findTitle
                                                   style:UIBarButtonItemStyleDone
                                                  target:self
                                                  action:@selector(findButtonClicked)];
    self.findButton.tintColor = [UIColor whiteColor];
    
    self.toolbar.items = @[titleButton, flexibleSpace, self.findButton];
}

- (void)findTypicalCommute
{
    MBProgressHUD* v = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    v.color = [UIColor crowdedBlueColor];
    NSString* address1 = self.homeTextField.text;
    NSString* address2 = self.workTextField.text;
    
    __weak RouteViewController* weakSelf = self;
    [[User storedUser] findHomeAddress:address1 workAddress:address2 completion:^(NSError* e) {
        
        [MBProgressHUD hideAllHUDsForView:weakSelf.view animated:YES];
        
        if (!e) {
            [User storedUser].myCommute.gps = [MapView sharedMapView].locationDisplay;
        }
        
        [weakSelf drawCommute];
        [weakSelf populateToolbar];
    }];
}

- (void)drawCommute
{
    if (![[User storedUser] hasValidCommute]){
        return;
    }
    
    AGSSimpleLineSymbol* sls1 = [AGSSimpleLineSymbol simpleLineSymbol];
    sls1.color = [UIColor crowdedBlueColor];
    
    AGSSimpleLineSymbol* sls2 = [AGSSimpleLineSymbol simpleLineSymbol];
    sls2.color = [UIColor crowdedBlueColor];
    
    
    // Add geofences to map
    AGSSimpleFillSymbol* sfs1 = [AGSSimpleFillSymbol simpleFillSymbol];
    sfs1.color = [[UIColor crowdedBlueColor] colorWithAlphaComponent:0.5];
    sfs1.outline = sls1;
    
    AGSSimpleFillSymbol* sfs2 = [AGSSimpleFillSymbol simpleFillSymbol];
    sfs2.color = [[UIColor crowdedBlueColor] colorWithAlphaComponent:0.5];
    sfs2.outline = sls2;
    
    User* user = [User storedUser];
    AGSGraphic* fence1 = [AGSGraphic graphicWithGeometry:user.myCommute.p1Geofence
                                                  symbol:sfs1
                                              attributes:nil];
    
    AGSGraphic* fence2 = [AGSGraphic graphicWithGeometry:user.myCommute.p2Geofence
                                                  symbol:sfs2
                                              attributes:nil];
    
    [self.fencesLayer addGraphics:@[fence1, fence2]];
    
    MapView* mv = [MapView sharedMapView];
    //  Add home and work locations to maps
    AGSGeometryEngine * ge = [AGSGeometryEngine defaultGeometryEngine];
    AGSPoint* p1 = (AGSPoint*)[ge projectGeometry:user.homeLocation
                               toSpatialReference:mv.spatialReference];
    AGSPoint* p2 = (AGSPoint*)[ge projectGeometry:user.workLocation toSpatialReference:mv.spatialReference];
    
    AGSSimpleMarkerSymbol* sms1 = [AGSSimpleMarkerSymbol simpleMarkerSymbol];
    sms1.color = [UIColor crowdedBlueColor];
    
    AGSSimpleMarkerSymbol* sms2 = [AGSSimpleMarkerSymbol simpleMarkerSymbol];
    sms2.color = [UIColor crowdedBlueColor];
    
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
    [mv zoomToEnvelope:env animated:YES];
}

#define kGPSScale 12000

- (void)enableGps:(AGSLocationDisplayAutoPanMode)mode
{
    AGSLocationDisplay* gps = [MapView sharedMapView].locationDisplay;
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
