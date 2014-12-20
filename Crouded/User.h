//
//  User.h
//  Crouded
//
//  Created by Scott Sirowy on 12/19/14.
//  Copyright (c) 2014 App Builders Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ArcGIS/ArcGIS.h>

#define UserDefaultsEmailKey @"UserDefaultsEmail"
#define UserDefaultsLockedKey @"UserDefaultsLocked"

@class Stats;
@class Commute;
@class Incentives;

@interface User : NSObject

@property (nonatomic, readonly) NSString* email;
@property (nonatomic) bool locked;

@property (nonatomic, strong, readonly) AGSPoint* homeLocation;
@property (nonatomic, strong, readonly) AGSPoint* workLocation;

@property (nonatomic, strong, readonly) Commute* myCommute;

@property (nonatomic, strong, readonly) Stats*    myStats;

@property (nonatomic, strong, readonly) Incentives* myIncentives;

// Will overwrite any previous user on device
- (id)initWithEmail:(NSString*)email;
- (id)initWithEmail:(NSString *)email locked:(BOOL)locked;

// Can return nil if there is no stored user on device
+ (User*)storedUser;

+ (void)signOutStoredUser;

- (void)findHomeAddress:(NSString*)homeAddress
             workAddress:(NSString*)address2
           completion:(void (^)(NSError*))completion;

- (BOOL)hasValidCommute;

@end
