//
//  TwitterOAuthManager.swift
//  Gabby
//
//  Created by Dan Brajkovic on 5/25/15.
//  Copyright (c) 2015 Pragmatic Labs, LLC. All rights reserved.
//

import UIKit
import CoreFoundation

extension String {
    func stringByAddingRFC3986PercentEscapesUsingEncoding() -> String {
        var cfstr :CFString = self
        var allowed :CFString = "" as NSString
        var encoded :CFString = ":/?#[]@!$&'()*+,;=" as NSString
        return CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, cfstr, allowed, encoded, CFStringBuiltInEncodings.UTF8.rawValue) as String
    }
}

class TwitterOAuthManager: NSObject {
    
    let Host = "api.twitter.com"
    
//     Per https://dev.twitter.com/web/sign-in/implementing
    
    func oauthNonce() -> String {
        let UUID = NSUUID().UUIDString
        return UUID.substringToIndex(advance(UUID.startIndex, 32))
    }
    
    func oauthSignature(baseString :String) -> String {
        let signingKey = "m2FlAN8bFwEfmriBC8NknCTp2b7Gr4NjdW3OurY".stringByAddingRFC3986PercentEscapesUsingEncoding() + "&"
        
        return baseString.signatureUsingHmacSHA1WithKey(signingKey)
    }
    
    func oauthSignatureMethod() -> String {
        return "HMAC-SHA1"
    }
    
    func  oauthTimestamp() -> String {
        
        let timeInterval = Int(NSDate().timeIntervalSince1970)
        
        return "\(timeInterval)"
    }
    
    func oauthVersion() -> String {
        return "1.0";
    }

    func baseString(HTTPMethod: String, URL: NSURL, parameterString: String) -> String {
        let encodedURLString = URL.absoluteString!.stringByAddingRFC3986PercentEscapesUsingEncoding()
        let encodedParameterString = parameterString.stringByAddingRFC3986PercentEscapesUsingEncoding()
        return String(format: "%@&%@&%@", HTTPMethod, encodedURLString, encodedParameterString)
    }
    
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
        let RequestTokenPath = "/oauth/request_token"
        let requestURL = NSURL(scheme: "https", host: Host, path: RequestTokenPath)
        let request = NSMutableURLRequest(URL: requestURL!)
        let HTTPMethod = "POST"
        let oauthCallbackURL = "gabby://oauth/sign_in_with_twitter".stringByAddingRFC3986PercentEscapesUsingEncoding()
        let oauthConsumerKey = "gKNWuxbiEvoDbFyMXs38nQ".stringByAddingRFC3986PercentEscapesUsingEncoding()
        let oauthNonce = self.oauthNonce().stringByAddingRFC3986PercentEscapesUsingEncoding()
        let oauthSignatureMethod = self.oauthSignatureMethod()
        let oauthTimeStamp = self.oauthTimestamp()
        let oauthVersion = self.oauthVersion()
        let parameterStringFormat = "oauth_callback=%@&oauth_consumer_key=%@&oauth_nonce=%@&oauth_signature_method=%@&oauth_timestamp=%@&oauth_version=%@"
        let parameterString = String(format: parameterStringFormat, oauthCallbackURL, oauthConsumerKey, oauthNonce, oauthSignatureMethod, oauthTimeStamp, oauthVersion)
        let baseString = self.baseString(HTTPMethod, URL: requestURL!, parameterString: parameterString)
        let oauthSignature = self.oauthSignature(baseString).stringByAddingRFC3986PercentEscapesUsingEncoding()
        
        request.HTTPMethod = HTTPMethod
        let authorizationFormat = "OAuth oauth_callback=\"%@\", oauth_consumer_key=\"%@\", oauth_nonce=\"%@\", oauth_signature=\"%@\", oauth_signature_method=\"%@\", oauth_timestamp=\"%@\", oauth_version=\"%@\""
        let authorizationString = String(format: authorizationFormat, oauthCallbackURL, oauthConsumerKey, oauthNonce, oauthSignature, oauthSignatureMethod, oauthTimeStamp, oauthVersion)
        request.setValue(authorizationString, forHTTPHeaderField: "Authorization")
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) {
            (response: NSURLResponse!, responseData: NSData!, error: NSError!) in
            let responseString = NSString(data: responseData, encoding: NSUTF8StringEncoding) as! String
            let responseDictionary = self.dictionaryFromParameterString(responseString)
            let redirectPath = "/oauth/authorize"
            let components = NSURLComponents()
            components.scheme = "https"
            components.host = self.Host
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
        let RequestTokenPath = "/oauth/access_token"
        let requestURLString = NSString(format: "%@\\%@", Host, RequestTokenPath)
        let requestURL = NSURL(scheme: "https", host: Host, path: RequestTokenPath)
        let request = NSMutableURLRequest(URL: requestURL!)
        let HTTPMethod = "POST"
        let oauthCallbackURL = "gabby://oauth/sign_in_with_twitter".stringByAddingRFC3986PercentEscapesUsingEncoding()
        let oauthConsumerKey = "gKNWuxbiEvoDbFyMXs38nQ".stringByAddingRFC3986PercentEscapesUsingEncoding()
        let oauthNonce = self.oauthNonce().stringByAddingRFC3986PercentEscapesUsingEncoding()
        let oauthSignatureMethod = self.oauthSignatureMethod()
        let oauthTimeStamp = self.oauthTimestamp()
        let oauthVersion = self.oauthVersion()
        let parameterStringFormat = "oauth_callback=%@&oauth_consumer_key=%@&oauth_nonce=%@&oauth_signature_method=%@&oauth_timestamp=%@&oauth_token=%@&oauth_version=%@"
        let parameterString = String(format: parameterStringFormat, oauthCallbackURL, oauthConsumerKey, oauthNonce, oauthSignatureMethod, oauthTimeStamp, oauthToken!, oauthVersion)
        let baseString = self.baseString(HTTPMethod, URL: requestURL!, parameterString: parameterString)
        let oauthSignature = self.oauthSignature(baseString).stringByAddingRFC3986PercentEscapesUsingEncoding()
        request.HTTPBody = oauthVerifier.dataUsingEncoding(NSUTF8StringEncoding)
        request.HTTPMethod = HTTPMethod
        let authorizationFormat = "OAuth oauth_callback=\"%@\", oauth_consumer_key=\"%@\", oauth_nonce=\"%@\", oauth_signature=\"%@\", oauth_signature_method=\"%@\", oauth_timestamp=\"%@\", oauth_token=\"%@\", oauth_version=\"%@\""
        let authorizationString = String(format: authorizationFormat, oauthCallbackURL, oauthConsumerKey, oauthNonce, oauthSignature, oauthSignatureMethod, oauthTimeStamp, oauthToken!, oauthVersion)
        request.setValue(authorizationString, forHTTPHeaderField: "Authorization")
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




















