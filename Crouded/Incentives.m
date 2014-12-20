//
//  Incentives.m
//  Crouded
//
//  Created by Scott Sirowy on 12/19/14.
//  Copyright (c) 2014 App Builders Inc. All rights reserved.
//

#import "Incentives.h"


@implementation Incentives

- (id)initWithTimes:(NSArray *)times {
    self = [super init];
    
    if (self) {
        _times = times;
    }
    
    return self;
}

@end
