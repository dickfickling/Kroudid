//
//  User-extension.swift
//  Crouded
//
//  Created by Richard Fickling on 12/20/14.
//  Copyright (c) 2014 App Builders Inc. All rights reserved.
//

import Foundation

extension User {
    class func enter(email: String, success: (User) -> (), failure: (NSError) -> ()) {
        APIManager.post("/user", params: ["email": email],
            success: { data in
                let user = User(email: email)
                return success(user)
            },
            failure: { error in //TODO
                let user = User(email: email)
                return success(user)
            }
        )
    }
    
    class func logout() {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setNilValueForKey(UserDefaultsEmailKey)
    }
}