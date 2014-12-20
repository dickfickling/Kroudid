//
//  OnboardViewController.swift
//  App
//
//  Created by Richard Fickling on 12/19/14.
//  Copyright (c) 2014 App Builders Inc. All rights reserved.
//

import UIKit

class OnboardViewController: UIViewController {

    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
//        if User.getUser() == nil {
//            UIView.animateWithDuration(0.5, animations: {
//                self.emailTextField.alpha = 1.0
//                self.passwordTextField.alpha = 1.0
//            })
//        } else {
            self.performSegueWithIdentifier("mainViewSegue", sender: self)
//        }
    }
    
    @IBAction func loginButtonPressed(sender: AnyObject) {
    }

}
