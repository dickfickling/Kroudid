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

@property (nonatomic, strong) AGSPoint* point1;
@property (nonatomic, strong) AGSPoint* point2;

@property (nonatomic, strong) NSDate* startDate;
@property (nonatomic, strong) NSDate* endDate;

- (id)initWithAddress:(NSString*)address1
             address2:(NSString*)address2
           completion:(void (^)(NSError*))completion;

- (void)startCommute;
- (void)endCommuteAndReachedDestination:(BOOL)reached;

@end
