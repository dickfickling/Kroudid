//
//  WorkRoute.h
//  Crouded
//
//  Created by Scott Sirowy on 12/19/14.
//  Copyright (c) 2014 App Builders Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ArcGIS/ArcGIS.h>

@interface WorkRoute : NSObject

@property (nonatomic, strong) AGSPoint* point1;
@property (nonatomic, strong) AGSPoint* point2;

@end
