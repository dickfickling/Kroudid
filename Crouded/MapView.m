//
//  MapView.m
//  Crouded
//
//  Created by Scott Sirowy on 12/20/14.
//  Copyright (c) 2014 App Builders Inc. All rights reserved.
//

#import "MapView.h"

static MapView* mv = nil;

@implementation MapView

+ (MapView*)sharedMapView {
    if (mv == nil) {
        mv = [[MapView alloc] init];
    }
    
    return mv;
}

@end
