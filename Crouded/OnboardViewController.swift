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
        
        if User.storedUser() == nil {
            UIView.animateWithDuration(0.5, animations: {
                self.emailTextField.alpha = 1.0
                self.passwordTextField.alpha = 1.0
            })
        } else {
            self.performSegueWithIdentifier("mainViewSegue", sender: self)
        }
    }
    
    @IBAction func loginButtonPressed(sender: AnyObject) {
        let email: NSString = self.emailTextField.text
        if email.length > 0 {
            let hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
            hud.color = navy
            User.enter(self.emailTextField.text, success: { user in
                hud.hide(true)
                self.performSegueWithIdentifier("mainViewSegue", sender: self)
            },
                failure: { error in
                    hud.hide(true)
                    let alert = UIAlertView(title: "Login failed", message: "Login failed wtf", delegate: nil, cancelButtonTitle: "dag")
                    alert.show()
            })
        } else {
            let alert = UIAlertView(title: "Enter Email", message: "Please enter your email", delegate: nil, cancelButtonTitle: "OK")
            alert.show()
        }
    }

}
