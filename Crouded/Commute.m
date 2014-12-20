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

@property (nonatomic, strong) AGSLocator* locator;

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
        
        NSURL* url = [NSURL URLWithString: @"http://sampleserver1.arcgisonline.com/ArcGIS/rest/services/Locators/ESRI_Geocode_USA/GeocodeServer"];
        
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


#pragma mark -
#pragma mark AGSLocatorDelegate
- (void)locator:(AGSLocator*)locator operation:(NSOperation*)op didFetchLocatorInfo:(AGSLocatorInfo*)locatorInfo
{
    AGSLocationsForAddressParameters* params = [[AGSLocationsForAddressParameters alloc] init];
    NSString *currentLocaleString = [[NSLocale currentLocale] objectForKey:NSLocaleLanguageCode];
    NSDictionary *address = [NSDictionary dictionaryWithObjectsAndKeys:self.address1, @"address",
                             currentLocaleString, @"localeCode", nil];
    
    params.address              = address;
    params.outFields            = @[@"*"];
    params.outSpatialReference  = [AGSSpatialReference wgs84SpatialReference];
    [locator locationsForAddressWithParameters:params];
}

- (void)locator:(AGSLocator *)locator operation:(NSOperation*)op didFindLocationsForAddress:(NSArray *)candidates
{
    NSLog(@"HERE!");
}

- (void)locator:(AGSLocator *)locator operation:(NSOperation *)op didFailLocationsForAddress:(NSError *)error
{
    NSLog(@"HERE");
}


@end
