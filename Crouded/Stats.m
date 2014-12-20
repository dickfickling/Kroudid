//
//  Stats.m
//  Crouded
//
//  Created by Scott Sirowy on 12/19/14.
//  Copyright (c) 2014 App Builders Inc. All rights reserved.
//

#import "Stats.h"

@implementation Stats

- (id)initWithPoints:(NSUInteger)points timeSaved:(NSUInteger)timeSaved totalTimeSaved:(NSUInteger)totalTimeSaved registrationDate:(NSDate *)registrationDate {
    self = [super init];
    
    if (self) {
        _points = points;
        _timeSaved = timeSaved;
        _totalTimeSaved = totalTimeSaved;
        _registrationDate = registrationDate;
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    if (self) {
        _points = [(NSNumber *)[coder decodeObjectForKey:@"StatsPoints"] unsignedIntegerValue];
        _timeSaved = [(NSNumber *)[coder decodeObjectForKey:@"StatsTimeSaved"] unsignedIntegerValue];
        _totalTimeSaved = [(NSNumber *)[coder decodeObjectForKey:@"StatsTotalTimeSaved"] unsignedIntegerValue];
        _registrationDate = (NSDate *)[coder decodeObjectForKey:@"StatsRegistrationDate"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:[NSNumber numberWithUnsignedInteger:self.points] forKey:@"StatsPoints"];
    [coder encodeObject:[NSNumber numberWithUnsignedInteger:self.timeSaved] forKey:@"StatsTimeSaved"];
    [coder encodeObject:[NSNumber numberWithUnsignedInteger:self.totalTimeSaved] forKey:@"StatsTotalTimeSaved"];
    [coder encodeObject:self.registrationDate forKey:@"StatsRegistrationDate"];
}

@end
