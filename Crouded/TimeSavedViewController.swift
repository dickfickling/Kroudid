//
//  TimeSavedViewController.swift
//  Crouded
//
//  Created by Richard Fickling on 12/20/14.
//  Copyright (c) 2014 App Builders Inc. All rights reserved.
//

import UIKit

class TimeSavedViewController: UIViewController {

    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var sinceLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()

        let minutesSaved = Int(User.storedUser().myStats.timeSaved) / 60
        self.timeLabel.text = "\(minutesSaved)"
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "LLLL YYYY"
        let str = dateFormatter.stringFromDate(User.storedUser().myStats.registrationDate)
        
        self.sinceLabel.text = "minutes since\n\(str)"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
