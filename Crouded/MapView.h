//
//  MapView.h
//  Crouded
//
//  Created by Scott Sirowy on 12/20/14.
//  Copyright (c) 2014 App Builders Inc. All rights reserved.
//

#import <ArcGIS/ArcGIS.h>

@interface MapView : AGSMapView

// Global singleton
+ (MapView*)sharedMapView;

@end
