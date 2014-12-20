//
//  User.m
//  Crouded
//
//  Created by Scott Sirowy on 12/19/14.
//  Copyright (c) 2014 App Builders Inc. All rights reserved.
//

#import "User.h"

#define kNSUserDefaultsEmailKey @"email"

@implementation User


- (id)initWithEmail:(NSString*)email {
    self = [super init];
    if (self) {
        _email = email;
        
        // Store email
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:email forKey:kNSUserDefaultsEmailKey];
        [defaults synchronize];
    }
    
    return self;
}

// Can return nil if there is no stored user on device
+ (User*)storedUser {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString* email = [defaults objectForKey:kNSUserDefaultsEmailKey];
    
    if (email) {
        return [[User alloc] initWithEmail:email];
    }
    
    return nil;
}

+ (void)signOutStoredUser
{
    // Clear entry in defaults
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:nil forKey:kNSUserDefaultsEmailKey];
    [defaults synchronize];
}

@end
