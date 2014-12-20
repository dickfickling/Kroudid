//
//  User.h
//  Crouded
//
//  Created by Scott Sirowy on 12/19/14.
//  Copyright (c) 2014 App Builders Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ArcGIS/ArcGIS.h>

@class Stats;

@interface User : NSObject

@property (nonatomic, readonly) NSString* email;

@property (nonatomic, strong, readonly) AGSPoint* homeLocation;
@property (nonatomic, strong, readonly) AGSPoint* workLocation;

@property (nonatomic, strong, readonly) Stats*    myStats;

// Will overwrite any previous user on device
- (id)initWithEmail:(NSString*)email;

// Can return nil if there is no stored user on device
+ (User*)storedUser;

+ (void)signOutStoredUser;

- (void)findHomeAddress:(NSString*)homeAddress
             workAddress:(NSString*)address2
           completion:(void (^)(NSError*))completion;

- (BOOL)hasValidCommute;

@end
