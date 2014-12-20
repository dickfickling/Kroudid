//
//  Incentives.h
//  Crouded
//
//  Created by Scott Sirowy on 12/19/14.
//  Copyright (c) 2014 App Builders Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#define IncentivesChangedNotification @"IncentivesChanged"

@interface Incentives : NSObject

@property (nonatomic, strong) NSArray* times;

- (id)initWithTimes:(NSArray*)times;

@end
