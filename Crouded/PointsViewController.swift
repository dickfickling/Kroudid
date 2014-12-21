//
//  PointsViewController.swift
//  Crouded
//
//  Created by Richard Fickling on 12/20/14.
//  Copyright (c) 2014 App Builders Inc. All rights reserved.
//

import UIKit

class PointsViewController: UIViewController {

    @IBOutlet weak var pointsLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()

        self.pointsLabel.text = "\(User.storedUser().myStats.points)"
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("arrived"), name: CommuteCompletedNotification, object: nil)
    }
    
    func arrived() {
        UIView.animateWithDuration(0.5, delay: 0.0, options: .CurveEaseOut, animations: {
            self.pointsLabel.alpha = 0;
            
            }, completion: { finished in
                self.pointsLabel.text = "\(self.pointsLabel.text!.toInt()! + 65)"
                UIView.animateWithDuration(0.5, delay: 0.0, options: .CurveEaseOut, animations: {
                    self.pointsLabel.alpha = 1;
                    
                    }, completion: { finished in
                        
                })
                
        })
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

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
