//
//  User.m
//  Crouded
//
//  Created by Scott Sirowy on 12/19/14.
//  Copyright (c) 2014 App Builders Inc. All rights reserved.
//

#import "User.h"
#import "Commute.h"
#import "Stats.h"
#import "Incentives.h"

static User* sharedUser = nil;

@interface User() <AGSLocatorDelegate>

@property (nonatomic, copy) NSString* homeAddress;
@property (nonatomic, copy) NSString* workAddress;

@property (nonatomic, strong) AGSLocator*     locator;
@property (nonatomic, strong) AGSLocatorInfo* locatorInfo;

@property (nonatomic, strong) void (^addressCompletion)(NSError*);

@end

@implementation User

- (void)setLocked:(bool)locked {
    _locked = locked;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:locked forKey:UserDefaultsLockedKey];
}

- (id)initWithEmail:(NSString *)email stats:(Stats*)stats home:(NSDictionary*)home work:(NSDictionary*)work locked:(BOOL)locked
{
    self = [super init];
    if (self) {
        _email = email;
        _locked = locked;
        _myStats = stats;
        _myIncentives = [[Incentives alloc] initWithTimes:[[NSArray alloc] init]];
        
        if (home && work) {
            _homeLocation  = [AGSPoint pointWithX:[[home objectForKey:@"longitude"] doubleValue]
                                                     y:[[home objectForKey:@"latitude"] doubleValue]
                                      spatialReference:[AGSSpatialReference wgs84SpatialReference]];
            
            _workLocation = [AGSPoint pointWithX:[[work objectForKey:@"longitude"] doubleValue]
                                                     y:[[work objectForKey:@"latitude"] doubleValue]
                                      spatialReference:[AGSSpatialReference wgs84SpatialReference]];
            
            
            _myCommute = [[Commute alloc] initWithPoint1:self.homeLocation point2:self.workLocation];
        }
        
        // Store email and locked
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:email forKey:UserDefaultsEmailKey];
        [defaults setBool:locked forKey:UserDefaultsLockedKey];
        [defaults setObject:[NSKeyedArchiver archivedDataWithRootObject:stats] forKey:UserDefaultsStatsKey];
        [defaults synchronize];
        
        sharedUser = self;
    }
    
    return self;
}

// Can return nil if there is no stored user on device
+ (User*)storedUser {
    
    if (sharedUser) {
        return sharedUser;
    }
    
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString* email = [defaults objectForKey:UserDefaultsEmailKey];
    BOOL locked = [defaults boolForKey:UserDefaultsLockedKey];
    Stats* stats = [NSKeyedUnarchiver unarchiveObjectWithData:[defaults dataForKey:UserDefaultsStatsKey]];
    
    if (email) {
        sharedUser = [[User alloc] initWithEmail:email stats:stats home:nil work:nil locked:locked];
        return sharedUser;
    }
    
    return nil;
}

+ (void)signOutStoredUser
{
    // Clear entry in defaults
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:nil forKey:UserDefaultsEmailKey];
    [defaults synchronize];
    sharedUser = nil;
}

- (BOOL)hasValidCommute {
    return (self.homeLocation && self.workLocation && self.myCommute);
}

- (void)findHomeAddress:(NSString*)homeAddress
            workAddress:(NSString*)workAddress
             completion:(void (^)(NSError*))completion
{
    _homeAddress = homeAddress;
    _workAddress = workAddress;
    _addressCompletion = completion;
    
    if (!_locator) {
        NSURL* url = [NSURL URLWithString: @"http://geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer"];
        
        _locator = [[AGSLocator alloc] initWithURL: url];
        self.locator.delegate = self;
        
        [self.locator fetchLocatorInfo];
    }
    else {
        [self fetchAddressForString:homeAddress];
    }
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
    
    if (self.homeLocation) {
        [self fetchAddressForString:self.workAddress];
    }
    else {
        [self fetchAddressForString:self.homeAddress];
    }
}

- (void)locator:(AGSLocator *)locator operation:(NSOperation*)op didFindLocationsForAddress:(NSArray *)candidates
{
    AGSAddressCandidate* ac = [candidates objectAtIndex:0];
    
    if (self.homeLocation) {
        
        _workLocation = [ac.location copy];
        
        _myCommute = [[Commute alloc] initWithPoint1:self.homeLocation point2:self.workLocation];
        
        if (self.addressCompletion) {
            self.addressCompletion(nil);
        }
        
    }
    // Working in first address
    else {
        _homeLocation = [ac.location copy];
        [self fetchAddressForString:self.workAddress];
    }
}

@end
