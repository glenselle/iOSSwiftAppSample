//
//  API.swift
//  Gecko iOS
//

import Foundation

public struct network {
    public var session: NSURLSession? {
        get {
            let sessionConfig = NSURLSessionConfiguration.defaultSessionConfiguration()
            
            // Get the token from the global testing override constant or else from the keychain
            var bearerHeader = ""
            if tokenHeader != "" {
                bearerHeader = tokenHeader
            } else {
                if let userId = Utilities.getCurrentUser() {
                    bearerHeader = "Bearer " + KeychainWrapper.stringForKey(userId)!
                } else {
                    bearerHeader = ""
                }
            }
            
            NSLog(bearerHeader)
            
            sessionConfig.HTTPAdditionalHeaders = [
                "User-Agent": appUserAgent,
                "Authorization": bearerHeader,
                "Accept": "application/json",
                "Content-Type": "application/json"
            ]
            
            return NSURLSession(configuration: sessionConfig)
        }
    }
    
//    public var manager: NSURLSession? {
//        get {
//            // Get the token from the global testing override constant or else from the keychain
//            var bearerHeader = ""
//            if tokenHeader != "" {
//                bearerHeader = tokenHeader
//            } else {
//                let keychainWrapper = KeychainItemWrapper(identifier: Utilities.getCurrentUser(), accessGroup: nil)
//                bearerHeader = "Bearer " + (keychainWrapper.objectForKey(kSecValueData) as NSString)
//            }
//            
//            var defaultHeaders = Alamofire.Manager.sharedInstance.session.configuration.HTTPAdditionalHeaders ?? [:]
//            
//// Alamofire docs discourage this...look into the proper way to handle authorisation headers with URLRequestConvertible
//            defaultHeaders["Authorization"] = bearerHeader
//            
//            let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
//            configuration.HTTPAdditionalHeaders = defaultHeaders
//            
//            let manager = Alamofire.Manager(configuration: configuration)
//        }
//    }
}

class API {
    class var sharedInstance: API {
    struct Static {
        static let instance: API = API()
        }
        return Static.instance
    }
    
    func GET(name: String, completionblock:(error: NSError, finalResponse: [NSDictionary])->()) {        
        let session = network().session!
        let task: NSURLSessionDataTask = session.dataTaskWithURL(NSURL(string: name, relativeToURL: NSURL(string: apiBaseEndpoint)), completionHandler: {(data: NSData!, response: NSURLResponse!, error: NSError?) -> Void in
            let JSON: AnyObject! = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: nil) as? [NSDictionary]

            // The results will always be an array (could be just one element)
            var result: [NSDictionary]
            
            // If the response is nil, we return an array with one empty dictionary
            if JSON == nil {
                 result = [[:]]
            } else {
                result = JSON as [NSDictionary]
            }
            
            // If there's an error, pass it, otherwise, send a blank error
            if let err = error {
                completionblock(error: err, finalResponse: result)
            } else {
                completionblock(error: NSError(), finalResponse: result)
            }
        })
        task.resume()
    }
    
    func POST(name: String, payload: NSDictionary, completionblock:(error: NSError?, finalResponse: NSDictionary)->()) {
        let session = network().session!
        var request = NSMutableURLRequest(URL: NSURL(string: name, relativeToURL: NSURL(string: apiBaseEndpoint)), cachePolicy: NSURLRequestCachePolicy.UseProtocolCachePolicy, timeoutInterval: 60.0)
        request.HTTPMethod = "POST"
        request.HTTPBody = NSJSONSerialization.dataWithJSONObject(payload, options: nil, error: nil)
        let task: NSURLSessionDataTask = session.dataTaskWithRequest(request, completionHandler: {(data: NSData!, response: NSURLResponse!, error: NSError?) -> Void in
            let httpResponse = response as NSHTTPURLResponse
            
            let JSON: AnyObject! = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: nil) as? NSDictionary
            
            // The results will always be an array (could be just one element)
            var result: NSDictionary
            
            // If the response is nil, we return an array with one empty dictionary
            if JSON == nil {
                result = [:]
            } else {
                result = JSON as NSDictionary
            }
            
            // If there's an error, pass it, otherwise, send a blank error
            if let err = error {
                completionblock(error: err, finalResponse: result)
            } else {
                completionblock(error: nil, finalResponse: result)
            }
        })
        task.resume()
    }
    
    func UPLOAD(name: String, file: NSData, completionblock:(error: NSError?, finalResponse: NSDictionary)->()) {
        
        // Get the token from the global testing override constant or else from the keychain
        var bearerHeader = ""
        if tokenHeader != "" {
            bearerHeader = tokenHeader
        } else {
            if let userId = Utilities.getCurrentUser() {
                bearerHeader = "Bearer " + KeychainWrapper.stringForKey(userId)!
            } else {
                bearerHeader = ""
            }
        }
        
        let manager = AFHTTPSessionManager()
        let fullUrl = NSURL(string: name, relativeToURL: NSURL(string: apiBaseEndpoint)).absoluteString

        // Set the appropriate authorization header
        manager.requestSerializer.setValue(bearerHeader, forHTTPHeaderField: "Authorization")
        
        manager.POST(fullUrl, parameters: nil, constructingBodyWithBlock: { (formData) in
            formData.appendPartWithFileData(file, name: "image", fileName: "image", mimeType: "image/png")
        }, success: { (operation, responseObject) in
            completionblock(error: nil, finalResponse: [:])
        }, failure: { (operation, error) in
            completionblock(error: error, finalResponse: [:])
        })
    }
}