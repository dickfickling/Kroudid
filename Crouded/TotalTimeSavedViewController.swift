//
//  TotalTimeSavedViewController.swift
//  Crouded
//
//  Created by Richard Fickling on 12/20/14.
//  Copyright (c) 2014 App Builders Inc. All rights reserved.
//

import UIKit

class TotalTimeSavedViewController: UIViewController {

    @IBOutlet weak var timeSavedLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()

        self.timeSavedLabel.text = "\(User.storedUser().myStats.totalTimeSaved)"
    }

}
