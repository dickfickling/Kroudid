//
//  WorkRoute.m
//  Crouded
//
//  Created by Scott Sirowy on 12/19/14.
//  Copyright (c) 2014 App Builders Inc. All rights reserved.
//

typedef enum{
    CommuteStateUnknown = 0,
    CommuteStateNotCommuting,
    CommuteStateAtP1,
    CommuteStateLeftP1,
    CommuteStateAwayP1,
    CommuteStateArrivedP1,
    CommuteStateAtP2,
    CommuteStateLeftP2,
    CommuteStateAwayP2,
    CommuteStateArrivedP2
} CommuteState;

#import "Commute.h"
#import "MapView.h"

@interface Commute()

@property (nonatomic, assign) CommuteState commuteState;

@property (nonatomic, strong) NSDate* startDate;
@property (nonatomic, strong) NSDate* endDate;
@property (nonatomic, strong) AGSMutablePolyline* currentCommute;

@end

@implementation Commute

- (id)initWithPoint1:(AGSPoint*)p1
              point2:(AGSPoint*)p2
{
    self = [super init];
    if (self) {
        _p1 = p1;
        _p2 = p2;
        
        _commuteState = CommuteStateUnknown;
    }
    
    return self;
}

#define kLocationPath @"location"
- (void)startCommute
{
    self.commuteState = CommuteStateUnknown;
    
    AGSLocationDisplay* gps = [[MapView sharedMapView] locationDisplay];
    [gps startDataSource];
    [[MapView sharedMapView].locationDisplay addObserver:self
                                              forKeyPath:kLocationPath
                                                 options:0
                                                 context:nil];
}

- (void)endCommute
{
    AGSLocationDisplay* gps = [[MapView sharedMapView] locationDisplay];
    [gps removeObserver:self forKeyPath:kLocationPath];
    self.commuteState = CommuteStateNotCommuting;
    [gps stopDataSource];
}

- (BOOL)atHomeOrAtWork
{
    return ((self.commuteState == CommuteStateAtP1) || (self.commuteState == CommuteStateAtP2));
}

#define kBufferFactor 200
- (AGSGeometry*)p1Geofence
{
    if (_p1Geofence == nil) {
        AGSGeometryEngine* ge = [AGSGeometryEngine defaultGeometryEngine];
        AGSSpatialReference* sr = [AGSSpatialReference webMercatorSpatialReference];
        
        double distance = [sr convertValue:kBufferFactor fromUnit:AGSSRUnitMeter];
        AGSGeometry* projectGeometry = [ge projectGeometry:self.p1 toSpatialReference:sr];
        _p1Geofence = [ge bufferGeometry:projectGeometry byDistance:distance];
    }
    
    return _p1Geofence;
}

- (AGSGeometry*)p2Geofence
{
    if (_p2Geofence == nil) {
        AGSGeometryEngine* ge = [AGSGeometryEngine defaultGeometryEngine];
        AGSSpatialReference* sr = [AGSSpatialReference webMercatorSpatialReference];
        AGSGeometry* projectGeometry = [ge projectGeometry:self.p2 toSpatialReference:sr];
        
        double distance = [sr convertValue:kBufferFactor fromUnit:AGSSRUnitMeter];
        _p2Geofence = [ge bufferGeometry:projectGeometry byDistance:distance];
    }
    
    return _p2Geofence;
}

- (void)calculateCommuteState
{
    AGSGeometryEngine* ge = [AGSGeometryEngine defaultGeometryEngine];
    AGSLocationDisplay* gps = [[MapView sharedMapView] locationDisplay];
    AGSPoint* location = (AGSPoint*)[ge projectGeometry:gps.location.point
                          toSpatialReference:[AGSSpatialReference webMercatorSpatialReference]];
    
    
    AGSPoint* intersectionP1 = (AGSPoint*)[ge intersectionOfGeometry:self.p1Geofence andGeometry:location];
    AGSPoint* intersectionP2 = (AGSPoint*)[ge intersectionOfGeometry:self.p2Geofence andGeometry:location];
    
    BOOL p1 = !(isnan(intersectionP1.x) && isnan(intersectionP1.y));
    BOOL p2 = !(isnan(intersectionP2.x) && isnan(intersectionP2.y));
    
    // Actions
    switch (self.commuteState) {
        case CommuteStateUnknown:
            break;
        case CommuteStateAtP1:
            break;
        case CommuteStateLeftP1:
            [self startWritingNewCommute];
            break;
        case CommuteStateArrivedP1:
            break;
        case CommuteStateAtP2:
            break;
        case CommuteStateLeftP2:
            [self startWritingNewCommute];
            break;
        case CommuteStateArrivedP2:
            break;
        default:
            break;
    }
    
    // Transitions
    switch (self.commuteState) {
        case CommuteStateUnknown:
            if (p1) {
                self.commuteState = CommuteStateAtP1;
            }
            else if (p2) {
                self.commuteState = CommuteStateAtP2;
            }
            break;
        case CommuteStateAtP1:
            if (!p1) {
                self.commuteState = CommuteStateLeftP1;
            }
            break;
        case CommuteStateLeftP1:
            self.commuteState = CommuteStateAwayP1;
            break;
        case CommuteStateAwayP1:
            if (p1) {
                self.commuteState = CommuteStateAtP1;
            }
            else if (p2) {
                self.commuteState = CommuteStateArrivedP2;
            }
            break;
        case CommuteStateArrivedP1:
            self.commuteState = CommuteStateAtP1;
            break;
        case CommuteStateAtP2:
            if (!p2) {
                self.commuteState = CommuteStateLeftP2;
            }
            break;
        case CommuteStateLeftP2:
            self.commuteState = CommuteStateAwayP2;
            break;
        case CommuteStateAwayP2:
            if (p2) {
                self.commuteState = CommuteStateAtP2;
            }
            else if (p1) {
                self.commuteState = CommuteStateArrivedP1;
            }
            break;
        case CommuteStateArrivedP2:
            self.commuteState= CommuteStateAtP2;
            break;
        default:
            break;
    }
    
    NSLog(@"%@", [self stringFromState:self.commuteState]);
}

- (void)startWritingNewCommute
{
    _currentCommute = [[AGSMutablePolyline alloc] init];
    [_currentCommute addPathToPolyline];
    
    _startDate = [NSDate date];
}

- (void)writeToCommute
{
    
}

- (void)completeCommuteAndWrite:(BOOL)write
{
    _endDate = [NSDate date];
}

- (NSString*)stringFromState:(CommuteState)state
{
    NSString* s;
    switch (self.commuteState) {
        case CommuteStateUnknown:
            s = @"Unknown";
        case CommuteStateAtP1:
            s = @"At P1";
            break;
        case CommuteStateLeftP1:
            s = @"Left P1";
            break;
        case CommuteStateAwayP1:
            s = @"Away";
            break;
        case CommuteStateArrivedP1:
            s = @"Arrived P1";
            break;
        case CommuteStateAtP2:
            s = @"At P2";
            break;
        case CommuteStateLeftP2:
            s = @"Left P2";
            break;
        case CommuteStateAwayP2:
            s = @"Away";
            break;
        case CommuteStateArrivedP2:
            s = @"Arrived P2";
            break;
        default:
            break;
    }

    return s;
}

#pragma mark -
#pragma mark Key-Value Observing
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if ([keyPath isEqualToString:kLocationPath]) {
        [self calculateCommuteState];
    }
}

@end
