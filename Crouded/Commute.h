//
//  WorkRoute.h
//  Crouded
//
//  Created by Scott Sirowy on 12/19/14.
//  Copyright (c) 2014 App Builders Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ArcGIS/ArcGIS.h>

@interface Commute : NSObject

@property (nonatomic, strong) NSDate* startDate;
@property (nonatomic, strong) NSDate* endDate;

@property (nonatomic, strong, readonly) AGSPoint* p1;
@property (nonatomic, strong, readonly) AGSPoint* p2;

- (id)initWithPoint1:(AGSPoint*)p1
              point2:(AGSPoint*)p2;

- (void)startCommute;
- (void)endCommuteAndReachedDestination:(BOOL)reached;

@end
