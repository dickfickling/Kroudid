//
//  Stats.h
//  Crouded
//
//  Created by Scott Sirowy on 12/19/14.
//  Copyright (c) 2014 App Builders Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#define UserDefaultsStatsKey @"UserDefaultsStats"

@interface Stats : NSObject <NSCoding>

@property (nonatomic) NSUInteger points;
@property (nonatomic) NSUInteger timeSaved;
@property (nonatomic) NSUInteger totalTimeSaved;
@property (nonatomic) NSDate* registrationDate;

- (id)initWithPoints:(NSUInteger)points timeSaved:(NSUInteger)timeSaved totalTimeSaved:(NSUInteger)totalTimeSaved registrationDate:(NSDate*)registrationDate;

@end
