//
//  MainViewController.swift
//  App
//
//  Created by Richard Fickling on 12/19/14.
//  Copyright (c) 2014 App Builders Inc. All rights reserved.
//

import UIKit

class MainViewController: UIViewController, UIAlertViewDelegate, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    @IBOutlet weak var hourLabel: UILabel!
    @IBOutlet weak var thirtyMinLabel: UILabel!
    @IBOutlet weak var carView: UIImageView!
    @IBOutlet weak var firstIncentive: UIControl!
    @IBOutlet weak var secondIncentive: UIControl!
    @IBOutlet weak var thirdIncentive: UIControl!
    var pageViewController: UIPageViewController!
    var statsViewControllers: [UIViewController] = []
    var done: Bool = false

    override func viewDidLoad() {
        
        
        super.viewDidLoad()

        self.statsViewControllers = []
        
        var timeSavedViewController = self.storyboard!.instantiateViewControllerWithIdentifier("timeSavedViewController") as UIViewController
        self.statsViewControllers.append(timeSavedViewController)
        
        var pointsViewController = self.storyboard!.instantiateViewControllerWithIdentifier("pointsViewController") as UIViewController
        self.statsViewControllers.append(pointsViewController)
        
        var totalTimeSavedViewController = self.storyboard!.instantiateViewControllerWithIdentifier("totalTimeSavedViewController") as UIViewController
        self.statsViewControllers.append(totalTimeSavedViewController)
        
        self.pageViewController.dataSource = self
        self.pageViewController.delegate = self
        self.pageViewController.setViewControllers([self.statsViewControllers[1]], direction: UIPageViewControllerNavigationDirection.Forward, animated: false, completion: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("incentivesChanged:"), name: IncentivesChangedNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("left"), name: CommuteStartedNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("arrived"), name: CommuteCompletedNotification, object: nil)
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "h:mm"
        
        let thirtymin = NSDate(timeIntervalSinceNow: 30*60)
        let hour = NSDate(timeIntervalSinceNow: 60*60)
        
        self.thirtyMinLabel.text = "leave at \(dateFormatter.stringFromDate(thirtymin))"
        self.hourLabel.text = "leave at \(dateFormatter.stringFromDate(hour))"

    }
    
    func left() {
        UIView.animateWithDuration(0.3, animations: {
            self.thirtyMinLabel.alpha = 0.0
            self.carView.alpha = 1.0
            }, completion: { complete in
                UIView.animateWithDuration(10, animations: {
                    self.carView.frame.origin.x = 320
                }, completion: { complete in
                    if !self.done {
                        self.carView.frame.origin.x = -30
                        self.left()
                    }
                })
        })
    }
    
    func arrived() {
        UIView.animateWithDuration(0.3, animations: {
            self.carView.alpha = 0.0
        })
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    deinit {
        User.signOutStoredUser();
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        if User.storedUser().hasValidCommute() {
            updateViewForUser()
            
            User.storedUser().myCommute.startCommute()
            
        } else {
            self.performSegueWithIdentifier("setCommuteSegue", sender: self)
        }
        //left()
    }
    
    func incentivesChanged(info: NSNotification) {
        updateIncentivesDisplay()
    }
    
    func updateIncentivesDisplay() {
        let incentives = User.storedUser().myIncentives
        println(incentives.times.count)
        
    }
    
    func updateViewForUser() {
        let user = User.storedUser()
        
        if user.myIncentives.times.count > 0 {
            updateIncentivesDisplay()
        }
        user.refreshIncentives()
        
    }
    
    @IBAction func logoutButtonPressed(sender: AnyObject) {
        User.signOutStoredUser()
        self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func incentiveSelected(sender: UIControl) {
        let user = User.storedUser()
        user.locked = true
        
        for control in [firstIncentive, secondIncentive, thirdIncentive] {
            if control != sender {
                UIView.animateWithDuration(0.3, animations: { control.alpha = 0.2 })
            } else {
                UIView.animateWithDuration(0.3, animations: { control.alpha = 1.0 })
            }
        }
    }
    
    
    func alertView(alertView: UIAlertView, didDismissWithButtonIndex buttonIndex: Int) {
        self.performSegueWithIdentifier("setCommuteSegue", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "embedSegue" {
            self.pageViewController = segue.destinationViewController as UIPageViewController
        }
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        let index = find(self.statsViewControllers, viewController)!
        if index == self.statsViewControllers.count - 1 {
            return nil
        } else {
            return self.statsViewControllers[index+1]
        }
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        let index = find(self.statsViewControllers, viewController)!
        if index == 0 {
            return nil
        } else {
            return self.statsViewControllers[index-1]
        }
    }
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
        return 3
    }
    
    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
        return pageViewController.viewControllers.count > 0 ? find(self.statsViewControllers, pageViewController.viewControllers[0] as UIViewController)! : 0
    }
    
    
}
