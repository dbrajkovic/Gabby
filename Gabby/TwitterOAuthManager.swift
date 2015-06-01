//
//  TwitterOAuthManager.swift
//  Gabby
//
//  Created by Dan Brajkovic on 5/25/15.
//  Copyright (c) 2015 Pragmatic Labs, LLC. All rights reserved.
//

import UIKit
import CoreFoundation


class TwitterOAuthManager {
    
    
    func dictionaryFromParameterString(parameterString: String) -> Dictionary <String, String> {
        let parameters = parameterString.componentsSeparatedByString("&")
        let dictionary = NSMutableDictionary()
        for parameter in parameters {
            let keyValue = parameter.componentsSeparatedByString("=")
            if keyValue.count != 2 {
                continue;
            }
            dictionary.setObject(keyValue[1], forKey: keyValue[0])
        }
        return dictionary.copy() as! Dictionary<String, String>;
    }
    
    func obtainRequestToken() {
        let requestTokenPath = "/oauth/request_token"
        let request = TwitterRESTClient.oauthRequest(requestTokenPath, oauthToken: nil)
        
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) {
            (response: NSURLResponse!, responseData: NSData!, error: NSError!) in
            let responseString = NSString(data: responseData, encoding: NSUTF8StringEncoding) as! String
            let responseDictionary = self.dictionaryFromParameterString(responseString)
            let redirectPath = "/oauth/authorize"
            let components = NSURLComponents()
            components.scheme = "https"
            components.host = TwitterRESTClient.host()
            components.path = redirectPath
            let oauthToken = responseDictionary["oauth_token"]
            components.query = "oauth_token=\(oauthToken!)"
            let redirectURL = components.URL
            UIApplication.sharedApplication().openURL(redirectURL!)
        }
  }
    
    func obtainAccessToken(URL: NSURL) {
        let components = NSURLComponents(URL: URL, resolvingAgainstBaseURL: false)
        let queryItems = components?.queryItems
        var queryItem = queryItems?.first as! NSURLQueryItem
        let oauthToken = queryItem.value
        queryItem = queryItems?.last as! NSURLQueryItem
        let oauthVerifier : NSString = "\(queryItem.name)=\(queryItem.value!)"
        
        let accessTokenPath = "/oauth/access_token"
        let request = TwitterRESTClient.oauthRequest(accessTokenPath, oauthToken: oauthToken)
        request.HTTPBody = oauthVerifier.dataUsingEncoding(NSUTF8StringEncoding)
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) {
            (response: NSURLResponse!, responseData: NSData!, error: NSError!) in
            let responseString = NSString(data: responseData, encoding: NSUTF8StringEncoding) as! String
            let responseDictionary = self.dictionaryFromParameterString(responseString)
            let oauthToken = responseDictionary["oauth_token"]
            let oauthTokenSecret = responseDictionary["oauth_token_secret"]
            let defaults = NSUserDefaults.standardUserDefaults()
            defaults.setValue(oauthToken, forKey: "oauthToken")
            defaults.setValue(oauthTokenSecret, forKey: "oauthTokenSecret")
            defaults.synchronize()
            NSNotificationCenter.defaultCenter().postNotificationName("TwitterOAuthManagerDidAuthorizeUser", object: nil)
        }
    }
}




















