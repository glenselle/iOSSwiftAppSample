//
//  FundingSourceView.swift
//  Gecko iOS
//
//  Copyright (c) 2014 Zipline, inc. All rights reserved.
//

import Foundation
import AudioToolbox
import UIKit
import Realm

class FundingSourceView: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Prevent the title from showing next to the back button
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = emptyBackButtonFix
    
    }
    
//    func loadThreads() {
//        API.sharedInstance.GET("threads", completionblock: {(error: NSError, finalResponse: [NSDictionary]) -> () in
//            NSLog("Done")
//        })
//    }
    
    func getRequest() {
        let path = "http://geckoapi.apiary-mock.com/api/v1/threads"
        let url = NSURL(string: path)
        let queue = NSOperationQueue()
        
        // Set up the request object
        var request = NSMutableURLRequest(URL: url)
        request.addValue("Gecko iOS", forHTTPHeaderField: "user-agent")
        request.addValue("Bearer 34j54k3lk4jhj3k2lkj34kk3j2hhjk", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPMethod = "GET"
        
        NSURLConnection.sendAsynchronousRequest(request, queue: queue, completionHandler: { response, data, error in
            if(error != nil) {
                NSLog("something went strong")
            } else {
                
                // Get the default realm for this thread
                let realm = RLMRealm.defaultRealm()
                
                // De-serialize the response to JSON
                let threads = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: nil) as [NSDictionary]
                
                // Begin the write of the transaction
                realm.beginWriteTransaction()
                
                // Save one Venue object (and dependents) for each element of the array
                for thread in threads {
                    Thread.createInDefaultRealmWithObject(thread)
                }
                
                // Commit the write transaction
                realm.commitWriteTransaction()
            
                var results = Message.objectsInRealm(realm, withPredicate: NSPredicate(format: "data contains 'Sure'"))
                println("Number of results matching the query: \(results.count)")
            
                // Vibrate the user's device when finished
                AudioServicesPlaySystemSound(1352)
            }
        })

    }
    
    // This function has some commments and the latest code that we should start to use
    func postRequest() {
        let path = "http://geckoapi.apiary-mock.com/api/v1/threads"
        let url = NSURL(string: path)
        let queue = NSOperationQueue()
        
        // Create a dictionary we POST to the API
        var dict = [
            "name": "Glen",
            "email": "glenselle@me.com",
            "username": "glen",
            "password": "zipline"
        ]
        
        // WIPE REALM
        // let documentsPaths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
        // var path = documentsPaths.stringByAppendingPathComponent("default.realm")
        // NSFileManager.defaultManager().removeItemAtPath(path, error: nil)
        
        // Create the session with config -- THIS IS HOW WE SHOULD DO THIS--NSURLSession is the newest & preferred way to make API requests
        //var config = NSURLSessionConfiguration()
        //config.allowsCellularAccess = true
        //var session = NSURLSession(configuration: config)
        //var session = NSURLSession.sharedSession()

        
        // Set up the request object
        var request = NSMutableURLRequest(URL: url)
        request.addValue("Gecko iOS", forHTTPHeaderField: "user-agent")
        request.addValue("Bearer 34j54k3lk4jhj3k2lkj34kk3j2hhjk", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = NSJSONSerialization.dataWithJSONObject(dict, options: nil, error: nil)
        request.HTTPMethod = "POST"
        
        //session.dataTaskWithRequest(request, completionHandler: { response, data, error in
        NSURLConnection.sendAsynchronousRequest(request, queue: queue, completionHandler: { response, data, error in
            if(error != nil) {
                NSLog("something went strong")
            } else {
                
                // De-serialize the response to JSON
                let thingy = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: nil) as NSDictionary
                
                
            }
        })
    }
}