//
//  TwitterSession.swift
//  Gabby
//
//  Created by Dan Brajkovic on 5/25/15.
//  Copyright (c) 2015 Pragmatic Labs, LLC. All rights reserved.
//

import UIKit

class TwitterSession: NSObject, UITabBarControllerDelegate {
    
    @IBOutlet weak var tabBarController: UITabBarController!
    var checkAuthenticationTimer: NSTimer!
    var twitterAccessToken: NSString!
    
    override func awakeFromNib() {
        checkAuthenticationTimer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: "showAuthenticationIfNeeded", userInfo: nil, repeats: true)
    }
    
    func showAuthenticationIfNeeded() {
        if self.tabBarController.isViewLoaded() {
            self.checkAuthenticationTimer.invalidate();
            let defaults = NSUserDefaults.standardUserDefaults()
            if defaults.stringForKey("oauthToken") == nil || defaults.stringForKey("oauthTokenSecret") == nil {
                self.tabBarController.performSegueWithIdentifier("SignInWithTwitterSegue", sender: nil);
            }
        }
    }
}
