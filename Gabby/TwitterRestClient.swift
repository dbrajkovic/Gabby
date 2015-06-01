//
//  TwitterRestClient.swift
//  Gabby
//
//  Created by Dan Brajkovic on 5/31/15.
//  Copyright (c) 2015 Pragmatic Labs, LLC. All rights reserved.
//

import UIKit

extension String {
    func stringByAddingRFC3986PercentEscapesUsingEncoding() -> String {
        var cfstr :CFString = self
        var allowed :CFString = "" as NSString
        var encoded :CFString = ":/?#[]@!$&'()*+,;=" as NSString
        return CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, cfstr, allowed, encoded, CFStringBuiltInEncodings.UTF8.rawValue) as String
    }
}


class TwitterRESTClient {

    static let HTTPPostMethod = "POST"
    static let oauthCallbackURL = "gabby://oauth/sign_in_with_twitter".stringByAddingRFC3986PercentEscapesUsingEncoding()
    static let oauthConsumerKey = "gKNWuxbiEvoDbFyMXs38nQ"
    static let oauthSignatureMethod = "HMAC-SHA1"
    static let oauthVersion = "1.0"
    class func oauthNonce() -> String {
        let UUID = NSUUID().UUIDString
        return UUID.substringToIndex(advance(UUID.startIndex, 32)).stringByAddingRFC3986PercentEscapesUsingEncoding()
    }
    class func oauthTimestamp() -> String {
        let timeInterval = Int(NSDate().timeIntervalSince1970)
        return "\(timeInterval)"
    }
    
    class func host() -> String {
        return "api.twitter.com"
    }
    
    class func oauthSignature(baseString :String) -> String {
        var signingKey = "m2FlAN8bFwEfmriBC8NknCTp2b7Gr4NjdW3OurY".stringByAddingRFC3986PercentEscapesUsingEncoding() + "&"
        if let tokenSecret = NSUserDefaults.standardUserDefaults().stringForKey("oauthTokenSecret") {
            signingKey += tokenSecret.stringByAddingRFC3986PercentEscapesUsingEncoding()
        }
        return baseString.signatureUsingHmacSHA1WithKey(signingKey)
    }
    
    class func baseString(HTTPMethod: String, URL: NSURL, parameterString: String) -> String {
        let encodedURLString = URL.absoluteString!.stringByAddingRFC3986PercentEscapesUsingEncoding()
        let encodedParameterString = parameterString.stringByAddingRFC3986PercentEscapesUsingEncoding()
        return String(format: "%@&%@&%@", HTTPMethod, encodedURLString, encodedParameterString)
    }
    
    class func URLQueryString(dictionary : Dictionary<String, String>) -> String {
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
    
    class func authorizationString(dictionary: Dictionary<String, String>) -> String {
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
    
    class func oauthRequest(path: String, oauthToken: String?) -> NSMutableURLRequest {
        let requestURL = NSURL(scheme: "https", host: host(), path: path)
        let request = NSMutableURLRequest(URL: requestURL!)
        request.HTTPMethod = HTTPPostMethod
        let encodedOauthNonce = self.oauthNonce()
        let encodedOauthTimeStamp = self.oauthTimestamp()
        var parameters = ["oauth_callback" : oauthCallbackURL, "oauth_consumer_key" : oauthConsumerKey, "oauth_nonce" : encodedOauthNonce, "oauth_signature_method" : oauthSignatureMethod, "oauth_timestamp" : encodedOauthTimeStamp]
        if let token = oauthToken {
            parameters["oauth_token"] = token
        }
        parameters["oauth_version"] = oauthVersion
        let baseString = self.baseString(request.HTTPMethod, URL: requestURL!, parameterString: URLQueryString(parameters))
        parameters["oauth_signature"] = self.oauthSignature(baseString).stringByAddingRFC3986PercentEscapesUsingEncoding()
        request.setValue(authorizationString(parameters), forHTTPHeaderField: "Authorization")
        return request
    }
    
    class func getRequest(resource: String, parameters: Dictionary<String, AnyObject>?) -> NSURLRequest {
        let requestURL = NSURL(scheme: "https", host: host(), path: "/1.1" + resource + ".json")
        let request = NSMutableURLRequest(URL: requestURL!)
        request.HTTPMethod = "GET"
        let encodedOauthNonce = self.oauthNonce()
        let encodedOauthTimeStamp = self.oauthTimestamp()
        var parameters = ["oauth_consumer_key" : oauthConsumerKey, "oauth_nonce" : encodedOauthNonce, "oauth_signature_method" : oauthSignatureMethod, "oauth_timestamp" : encodedOauthTimeStamp, "oauth_token" : NSUserDefaults.standardUserDefaults().stringForKey("oauthToken")!, "oauth_version" : oauthVersion]
        let baseString = self.baseString(request.HTTPMethod, URL: requestURL!, parameterString: URLQueryString(parameters))
        parameters["oauth_signature"] = self.oauthSignature(baseString).stringByAddingRFC3986PercentEscapesUsingEncoding()
        request.setValue(authorizationString(parameters), forHTTPHeaderField: "Authorization")
        return request
    }
   
}
