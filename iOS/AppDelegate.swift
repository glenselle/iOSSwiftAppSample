//
//  AppDelegate.swift
//  Gecko iOS
//

import Foundation
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, PNDelegate {
    var window: UIWindow?
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: NSDictionary) -> Bool {
        
        /*
        // init Keen IO
        KeenClient.enableLogging()
        KeenClient.authorizeGeoLocationWhenInUse()
        KeenClient.sharedClientWithProjectId(keenProjectId, andWriteKey: keenWriteKey, andReadKey: keenReadKey)
        */
        
        UIApplication.sharedApplication().setStatusBarStyle(.LightContent, animated: true)
        
        //Utilities.clearNSUserDefaults()
        
        // Bridging code (upgrading underlying storage mechanism for user ids and tokens
        let keychainWrapper = KeychainItemWrapper(identifier: "UserAuthToken", accessGroup: nil)
        let token = keychainWrapper.objectForKey(kSecValueData) as String
        let userId = keychainWrapper.objectForKey(kSecAttrAccount) as String
        
        if token != "" && userId != "" {
            if KeychainWrapper.setString(token, forKey: userId) {
                
                // Only if the token is saved successfully do we set the current user
                Utilities.setCurrentUser(userId)
                
                // Wipe the keychain clear after briding to the new systems
                keychainWrapper.resetKeychainItem()
            }
        }
        // End bridging code
        
        if let userId = Utilities.getCurrentUser() {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let rootViewController: AnyObject! = storyboard.instantiateViewControllerWithIdentifier("navController")
            window?.rootViewController = rootViewController as? UIViewController
        }
        
        PubNub.setDelegate(self)
        
        
        //let airportNames = [String]("blah", "blah", "blah")
        
        let testDict: [String: Any] = [
            "name": "Glen Selle",
            "age": 19
        ]
        
        NSLog("\(testDict)")

        
        
        
        
        
        
        return true
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        
        let taskId = application.beginBackgroundTaskWithExpirationHandler { () -> Void in
            NSLog("Background task is being expired.")
        }
        
//        client.uploadWithFinishedBlock { () -> Void in
//            application.endBackgroundTask(taskId)
//        }
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func pubnubClient(client: PubNub!, didReceiveMessage message: PNMessage!) {
        NSLog("message received")
    }
    
}