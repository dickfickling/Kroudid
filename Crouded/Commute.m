//
//  WorkRoute.m
//  Crouded
//
//  Created by Scott Sirowy on 12/19/14.
//  Copyright (c) 2014 App Builders Inc. All rights reserved.
//

#import "Commute.h"

@implementation Commute

- (id)initWithPoint1:(AGSPoint*)p1
              point2:(AGSPoint*)p2
{
    self = [super init];
    if (self) {
        _p1 = p1;
        _p2 = p2;
    }
    
    return self;
}

- (void)startCommute
{
    NSLog(@"Start commute");
}

- (void)endCommuteAndReachedDestination:(BOOL)reached
{
    NSLog(@"End commute");
}

#define kBufferFactor 100
- (AGSGeometry*)p1Geofence
{
    if (_p1Geofence == nil) {
        AGSGeometryEngine* ge = [AGSGeometryEngine defaultGeometryEngine];
        AGSSpatialReference* sr = [AGSSpatialReference webMercatorSpatialReference];
        
        double distance = [sr convertValue:kBufferFactor fromUnit:AGSSRUnitMeter];
        AGSGeometry* projectGeometry = [ge projectGeometry:self.p1 toSpatialReference:sr];
        _p2Geofence = [ge bufferGeometry:projectGeometry byDistance:distance];
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

@end
