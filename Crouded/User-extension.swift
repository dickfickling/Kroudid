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
                let points = data["points"]! as UInt
                let timeSaved = data["time_saved"]! as UInt
                let totalTimeSaved = data["total_time_saved"]! as UInt
                let registrationDate = NSDate(timeIntervalSince1970: data["registration_date"]! as Double)
                let stats = Stats(points: points, timeSaved: timeSaved, totalTimeSaved: totalTimeSaved, registrationDate: registrationDate)
                
                
                let homeLocation = data["home_location"] as? [String: Double]
                let workLocation = data["work_location"] as? [String: Double]
                
                let user = User(email: email, stats: stats, home: homeLocation, work: workLocation, locked: false)
                return success(user)
            },
            failure: failure
        )
    }
    
    func refreshIncentives() {
        let commute = self.myCommute
        //TODO not from home
        APIManager.get("/incentives/\(self.email)", params: ["from": "home"],
            success: { data in
                self.myIncentives.times.removeAll(keepCapacity: false)
                let incentives = data["incentives"]! as [[String: AnyObject]]
                self.myIncentives.times = incentives
                NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: IncentivesChangedNotification, object: nil))
            }, failure: { error in
                println(error)
        })
    }
    
    @objc func postLocations(success: () -> (), failure: (NSError) -> ()) {
        let params = [
            "home_location": [
                "latitude": self.homeLocation.x,
                "longitude": self.homeLocation.y
            ],
            "work_location": [
                "latitude": self.workLocation.x,
                "longitude": self.homeLocation.y
            ]
        ]
        APIManager.post("/user/\(self.email)/locations", params: params, success: { data in
            success()
        }, failure: failure)
    }
}