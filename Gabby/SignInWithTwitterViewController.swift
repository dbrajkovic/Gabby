//
//  SignInWithTwitterViewController.swift
//  Gabby
//
//  Created by Dan Brajkovic on 5/25/15.
//  Copyright (c) 2015 Pragmatic Labs, LLC. All rights reserved.
//

import UIKit

class SignInWithTwitterViewController: UIViewController {

    let oauthManager = TwitterOAuthManager()
    
    override func viewDidLoad() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didReceiveTwitterAuthToken:", name: "ApplicationDidRecieveTwitterAuthToken", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didAuthorizeUser:", name: "TwitterOAuthManagerDidAuthorizeUser", object: nil)
    }
    
    @IBAction func redirectToTwitterOAuth(sender: AnyObject) {
        oauthManager.obtainRequestToken()
    }
    
    func didReceiveTwitterAuthToken(notification: NSNotification) {
        let URL = notification.object as! NSURL
        oauthManager.obtainAccessToken(URL)
    }
    
    func didAuthorizeUser(notification: NSNotification) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

}
