//
//  WorkRoute.m
//  Crouded
//
//  Created by Scott Sirowy on 12/19/14.
//  Copyright (c) 2014 App Builders Inc. All rights reserved.
//

#import "Commute.h"

@interface Commute() <AGSLocatorDelegate>

@property (nonatomic, copy) NSString* address1;
@property (nonatomic, copy) NSString* address2;

@property (nonatomic, strong) AGSLocator*     locator;
@property (nonatomic, strong) AGSLocatorInfo* locatorInfo;

@property (nonatomic, strong) void (^completion)(NSError*);

@end

@implementation Commute

- (id)initWithAddress:(NSString*)address1 address2:(NSString*)address2 completion:(void (^)(NSError*))completion
{
    self = [super init];
    if (self) {
        _address1 = address1;
        _address2 = address2;
        _completion = completion;
        
        NSURL* url = [NSURL URLWithString: @"http://geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer"];
        
        _locator = [[AGSLocator alloc] initWithURL: url];
        _locator.delegate = self;
        
        [_locator fetchLocatorInfo];
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

- (void)fetchAddressForString:(NSString*)address
{
    AGSLocationsForAddressParameters* params = [[AGSLocationsForAddressParameters alloc] init];
    NSDictionary *addressDict = [NSDictionary dictionaryWithObjectsAndKeys:address, self.locatorInfo.singleLineAddressField.name,nil];
    
    params.address              = addressDict;
    params.outFields            = @[@"*"];
    params.outSpatialReference  = [AGSSpatialReference wgs84SpatialReference];
    [_locator locationsForAddressWithParameters:params];
}


- (void)locator:(AGSLocator *)locator operation:(NSOperation *)op didFetchLocatorInfo:(AGSLocatorInfo *)locatorInfo {
    
    self.locatorInfo = locatorInfo;
    
    if (self.point1) {
        [self fetchAddressForString:self.address2];
    }
    else {
        [self fetchAddressForString:self.address1];
    }
}

- (void)locator:(AGSLocator *)locator operation:(NSOperation*)op didFindLocationsForAddress:(NSArray *)candidates
{
    AGSAddressCandidate* ac = [candidates objectAtIndex:0];
    
    if (self.point1) {
        
        _point2 = [ac.location copy];
        
        if (self.completion) {
            self.completion(nil);
        }
        
    }
    // Working in first address
    else {
        _point1 = [ac.location copy];
        [self fetchAddressForString:self.address2];
    }
}



@end
