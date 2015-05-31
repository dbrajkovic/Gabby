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

class TwitterOAuthManager {
    
    let Host = "api.twitter.com"
    let HTTPPostMethod = "POST"
    let oauthCallbackURL = "gabby://oauth/sign_in_with_twitter".stringByAddingRFC3986PercentEscapesUsingEncoding()
    let oauthConsumerKey = "gKNWuxbiEvoDbFyMXs38nQ"
    let oauthSignatureMethod = "HMAC-SHA1"
    let oauthVersion = "1.0"
    var oauthNonce: String {
        let UUID = NSUUID().UUIDString
        return UUID.substringToIndex(advance(UUID.startIndex, 32)).stringByAddingRFC3986PercentEscapesUsingEncoding()
    }
    var oauthTimestamp: String {
        let timeInterval = Int(NSDate().timeIntervalSince1970)
        return "\(timeInterval)"
    }
    
    func oauthSignature(baseString :String) -> String {
        let signingKey = "m2FlAN8bFwEfmriBC8NknCTp2b7Gr4NjdW3OurY".stringByAddingRFC3986PercentEscapesUsingEncoding() + "&"
        return baseString.signatureUsingHmacSHA1WithKey(signingKey)
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
    
    func URLQueryString(dictionary : Dictionary<String, String>) -> String {
        var queryString = ""
        var keys = sorted(dictionary.keys.array)
        for key in keys {
            queryString += key + "=" + dictionary[key]!
            if key != keys.last {
                queryString += "&"
            }
        }
        return queryString
    }
    
    func authorizationString(dictionary: Dictionary<String, String>) -> String {
        var authString = "OAuth "
        var keys = sorted(dictionary.keys.array)
        for key in keys {
            authString += key + "=\"" + dictionary[key]! + "\""
            if key != keys.last {
                authString += ", "
            }
        }
        return authString
    }
    
    func oauthRequest(path: String, oauthToken: String?) -> NSMutableURLRequest {
        let requestURL = NSURL(scheme: "https", host: Host, path: path)
        let request = NSMutableURLRequest(URL: requestURL!)
        request.HTTPMethod = HTTPPostMethod
        let encodedOauthNonce = self.oauthNonce
        let encodedOauthTimeStamp = self.oauthTimestamp
        var parameters = ["oauth_callback" : oauthCallbackURL, "oauth_consumer_key" : oauthConsumerKey, "oauth_nonce" : encodedOauthNonce, "oauth_signature_method" : oauthSignatureMethod, "oauth_timestamp" : encodedOauthTimeStamp] //, "oauth_version" : oauthVersion]
        if let token = oauthToken {
            parameters["oauth_token"] = token
        }
        parameters["oauth_version"] = oauthVersion
        let baseString = self.baseString(HTTPPostMethod, URL: requestURL!, parameterString: URLQueryString(parameters))
        parameters["oauth_signature"] = self.oauthSignature(baseString).stringByAddingRFC3986PercentEscapesUsingEncoding()
        request.setValue(authorizationString(parameters), forHTTPHeaderField: "Authorization")
        return request
    }
    
    func obtainRequestToken() {
        let requestTokenPath = "/oauth/request_token"
        let request = oauthRequest(requestTokenPath, oauthToken: nil)
        
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
        
        let accessTokenPath = "/oauth/access_token"
        let request = oauthRequest(accessTokenPath, oauthToken: oauthToken)
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




















