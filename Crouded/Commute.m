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

@end
